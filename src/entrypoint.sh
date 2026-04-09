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

[ -z ${PRECACHE_FOR} ] || printf '%s\n' \
    "PrecacheFor: ${PRECACHE_FOR}" \
    >> /etc/apt-cacher-ng/zz_overrides.conf

[ -z ${USER_AGENT} ] || printf '%s\n' \
    "UserAgent: ${USER_AGENT}" \
    >> /etc/apt-cacher-ng/zz_overrides.conf

[ -z ${ADMIN_AUTH_USER} ] || [ -z ${ADMIN_AUTH_PASS} ] || printf '%s\n' \
    "AdminAuth: ${ADMIN_AUTH_USER}:${ADMIN_AUTH_PASS}" \
    > /etc/apt-cacher-ng/zz_overrides_security.conf


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
