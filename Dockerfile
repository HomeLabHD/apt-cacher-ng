FROM docker.io/library/debian:trixie-slim

LABEL maintainer="HomeLabHD <homelabhelp@gmail.com>" \
    org.opencontainers.image.title="apt-cacher-ng" \
    org.opencontainers.image.description="A caching proxy for Debian-based package downloads — fast APT installs in CI and homelab." \
    org.opencontainers.image.source="https://github.com/HomeLabHD/apt-cacher-ng" \
    org.opencontainers.image.url="https://hub.docker.com/r/hlhd/apt-cacher-ng" \
    org.opencontainers.image.documentation="https://github.com/HomeLabHD/apt-cacher-ng#readme" \
    org.opencontainers.image.licenses="BSD-4-Clause" \
    org.opencontainers.image.vendor="HomeLabHD"

ENV DEBIAN_FRONTEND=noninteractive \
    APT_CACHER_NG_VERSION=3.7.5 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng \
    PASS_THROUGH_PATTERN='.*' \
    PRECACHE_FOR= \
    USER_AGENT= \
    EX_THRESHOLD=4 \
    ADMIN_AUTH_USER= \
    ADMIN_AUTH_PASS= \
    ADMIN_AUTH_USER_FILE= \
    ADMIN_AUTH_PASS_FILE= \
    MAX_THREADS=20 \
    NETWORK_TIMEOUT=60 \
    PORT= \
    BIND_ADDRESS= \
    RESERVE_SPACE= \
    KEEP_EXTRA_VERSIONS= \
    PROXY= \
    OFFLINE_MODE= \
    DONT_CACHE= \
    DONT_CACHE_REQUESTED= \
    DONT_CACHE_RESOLVED= \
    MAX_DL_SPEED= \
    LOCAL_DIRS= \
    REPORT_PAGE= \
    EXPOSE_ORIGIN= \
    DEBUG= \
    VERBOSE= \
    VERBOSE_LOG= \
    UNBUFFER_LOGS=

# Install apt-cacher-ng and runtime dependencies (no wget/curl/gosu — smaller attack surface)
# The pin is the UPSTREAM version; the trailing -* follows whatever Debian revision is
# current at build time (3.7.5-1, a later -2, a +debNuN security update). Pinning the
# full revision froze the image out of Debian's own security patches for the same
# upstream release, which is the whole point of rebuilding.
RUN apt-get update && apt-get install -y --no-install-recommends \
      "apt-cacher-ng=${APT_CACHER_NG_VERSION}-*" ca-certificates tini \
 && rm -rf /var/lib/apt/lists/*

# Override defaults — last value wins, no need to patch acng.conf
RUN printf '%s\n' \
    'ForeGround: 1' \
    'LogDir: /var/log/apt-cacher-ng' \
    'PassThroughPattern: .*' \
    'MaxStandbyConThreads: 20' \
    'MaxConThreads: -1' \
    'NetworkTimeout: 60' \
    'VfileUseRangeOps: 1' \
    'ReuseConnections: 1' \
    'PipelineDepth: 10' \
    > /etc/apt-cacher-ng/zz_overrides.conf

COPY src/entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

EXPOSE 3142/tcp

# Port is read from the file the entrypoint derives it into, so a custom PORT stays
# healthy; the literal 0C46 (3142) is only the pre-start fallback.
HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
    CMD grep -q ":$(cat /run/apt-cacher-ng/port.hex 2>/dev/null || echo 0C46) " /proc/net/tcp 2>/dev/null || exit 1

ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/sbin/entrypoint.sh"]
CMD []
