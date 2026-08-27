#!/bin/sh
set -e

CACHE_DIR="${APT_CACHER_NG_CACHE_DIR}"
LOG_DIR="${APT_CACHER_NG_LOG_DIR}"

# Ensure required directories exist
mkdir -p /run/apt-cacher-ng "$CACHE_DIR" "$LOG_DIR"
chown -R "$APT_CACHER_NG_USER:$APT_CACHER_NG_USER" /run/apt-cacher-ng "$CACHE_DIR" "$LOG_DIR"

# Runtime config overrides — rewrite the override file with current env values
printf '%s\n' \
    "ForeGround: 1" \
    "LogDir: ${LOG_DIR}" \
    "PassThroughPattern: ${PASS_THROUGH_PATTERN}" \
    "MaxStandbyConThreads: ${MAX_THREADS}" \
    "NetworkTimeout: ${NETWORK_TIMEOUT}" \
    "ExThreshold: ${EX_THRESHOLD}" \
    "MaxConThreads: -1" \
    "VfileUseRangeOps: 1" \
    "ReuseConnections: 1" \
    "PipelineDepth: 10" \
    > /etc/apt-cacher-ng/zz_overrides.conf

# Quoted: these values legitimately contain spaces — PrecacheFor takes a brace list of
# references, UserAgent an arbitrary string — and unquoted they word-split, turning the
# test into `[ -z a b ]` ("too many arguments"). That still wrote the value, since the
# error exit fell through the ||, but printed a shell error on every start.
[ -z "${PRECACHE_FOR}" ] || printf '%s\n' \
    "PrecacheFor: ${PRECACHE_FOR}" \
    >> /etc/apt-cacher-ng/zz_overrides.conf

[ -z "${USER_AGENT}" ] || printf '%s\n' \
    "UserAgent: ${USER_AGENT}" \
    >> /etc/apt-cacher-ng/zz_overrides.conf

# Secrets-from-file (_FILE convention): an env var holding a credential is readable by
# anyone who can run `docker inspect` or read /proc/<pid>/environ, and it is copied into
# every child process. A mounted file — a docker/compose secret, a k8s projected volume —
# is not. The file wins when both are set.
#
# An unreadable _FILE is FATAL rather than a fallback: the operator asked for
# authentication, and quietly starting without it would leave the admin interface open,
# which is the opposite of what they requested. Failing to start is the safe direction.
for _cred in ADMIN_AUTH_USER ADMIN_AUTH_PASS; do
    eval "_file=\${${_cred}_FILE}"
    [ -n "$_file" ] || continue
    if [ ! -r "$_file" ]; then
        echo "entrypoint: ${_cred}_FILE=$_file is not readable — refusing to start without the credential it should supply" >&2
        exit 1
    fi
    # $(...) strips trailing newlines, so a file written with a trailing newline works.
    eval "${_cred}=\$(cat \"\$_file\")"
done
unset _cred _file

# AdminAuth is a credential, so it is kept out of the world-readable override file and
# locked to the service account: created 0600 BEFORE the secret is written (never world-
# readable, even briefly) and owned by the user acng drops to, which is why 0600 root
# would not do — the daemon could no longer read its own config.
if [ -n "${ADMIN_AUTH_USER}" ] && [ -n "${ADMIN_AUTH_PASS}" ]; then
    umask 077
    : > /etc/apt-cacher-ng/zz_overrides_security.conf
    chown "$APT_CACHER_NG_USER:$APT_CACHER_NG_USER" /etc/apt-cacher-ng/zz_overrides_security.conf
    printf '%s\n' \
        "AdminAuth: ${ADMIN_AUTH_USER}:${ADMIN_AUTH_PASS}" \
        > /etc/apt-cacher-ng/zz_overrides_security.conf
fi

# Pre-create log files to prevent race conditions
touch "$LOG_DIR/apt-cacher.log" "$LOG_DIR/error.log"
chown "$APT_CACHER_NG_USER:$APT_CACHER_NG_USER" "$LOG_DIR"/*.log

# Start apt-cacher-ng in foreground as service user
su -s /bin/sh -c '/usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng ForeGround=1' "$APT_CACHER_NG_USER" &

# Wait for log files to appear
for file in "$LOG_DIR/apt-cacher.log" "$LOG_DIR/error.log"; do
  while [ ! -f "$file" ]; do sleep 0.5; done
done

# Stream logs to stdout
exec tail -F "$LOG_DIR"/apt-cacher.log "$LOG_DIR"/error.log
