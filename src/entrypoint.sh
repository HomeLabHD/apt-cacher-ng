#!/bin/sh
set -e

CACHE_DIR="${APT_CACHER_NG_CACHE_DIR}"
LOG_DIR="${APT_CACHER_NG_LOG_DIR}"

# Ensure required directories exist
mkdir -p /run/apt-cacher-ng "$CACHE_DIR" "$LOG_DIR"
chown -R "$APT_CACHER_NG_USER:$APT_CACHER_NG_USER" /run/apt-cacher-ng "$CACHE_DIR" "$LOG_DIR"

OVERRIDES=/etc/apt-cacher-ng/zz_overrides.conf

# Runtime config overrides — rewrite the override file with current env values.
# CacheDir is written from the same variable the directories above are created from:
# omitting it meant the entrypoint created and chowned whatever the operator asked for
# while the daemon kept caching in its compiled-in default, so a volume mounted at the
# requested path stayed empty and the real cache lived somewhere unmounted.
printf '%s\n' \
    "ForeGround: 1" \
    "CacheDir: ${CACHE_DIR}" \
    "LogDir: ${LOG_DIR}" \
    "PassThroughPattern: ${PASS_THROUGH_PATTERN}" \
    "MaxStandbyConThreads: ${MAX_THREADS}" \
    "NetworkTimeout: ${NETWORK_TIMEOUT}" \
    "ExThreshold: ${EX_THRESHOLD}" \
    "MaxConThreads: -1" \
    "VfileUseRangeOps: 1" \
    "ReuseConnections: 1" \
    "PipelineDepth: 10" \
    > "$OVERRIDES"

# Optional directives: appended ONLY when the operator sets them, so an unset variable
# leaves acng's own default in force rather than overriding it with an empty value.
# Quoted throughout — several of these legitimately contain spaces (PrecacheFor takes a
# brace list, UserAgent an arbitrary string, DontCache a regex); unquoted they word-split
# and the guard becomes `[ -z a b ]`, i.e. "too many arguments".
emit_opt() {
    # $1 = acng directive, $2 = value; a value of "" means "not set, leave the default"
    [ -n "$2" ] || return 0
    printf '%s: %s\n' "$1" "$2" >> "$OVERRIDES"
}

emit_opt PrecacheFor        "${PRECACHE_FOR}"
emit_opt UserAgent          "${USER_AGENT}"
emit_opt Port               "${PORT}"
emit_opt BindAddress        "${BIND_ADDRESS}"
emit_opt ReserveSpace       "${RESERVE_SPACE}"
emit_opt KeepExtraVersions  "${KEEP_EXTRA_VERSIONS}"
emit_opt Proxy              "${PROXY}"
emit_opt OfflineMode        "${OFFLINE_MODE}"
emit_opt DontCache          "${DONT_CACHE}"
emit_opt DontCacheRequested "${DONT_CACHE_REQUESTED}"
emit_opt DontCacheResolved  "${DONT_CACHE_RESOLVED}"
emit_opt MaxDlSpeed         "${MAX_DL_SPEED}"
emit_opt LocalDirs          "${LOCAL_DIRS}"
emit_opt ReportPage         "${REPORT_PAGE}"
emit_opt ExposeOrigin       "${EXPOSE_ORIGIN}"
emit_opt Debug              "${DEBUG}"
emit_opt Verbose            "${VERBOSE}"
emit_opt VerboseLog         "${VERBOSE_LOG}"
emit_opt UnbufferLogs       "${UNBUFFER_LOGS}"

# The healthcheck cannot read the env, so the effective port is written where it can:
# it greps /proc/net/tcp, whose local_address column is UPPERCASE HEX. Deriving it here
# keeps a custom Port from silently failing health while the daemon is perfectly fine.
printf '%04X\n' "${PORT:-3142}" > /run/apt-cacher-ng/port.hex

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
