# Stage 1: grab a prebuilt Verdaccio (avoids npmjs.org at build time,
# which also helps on restricted networks — only Docker Hub/ghcr needed).
FROM verdaccio/verdaccio:6 AS upstream

FROM ghcr.io/home-assistant/base:latest

# Install Node.js runtime + jq (jq is the fallback options parser when the
# Supervisor API is unavailable, e.g. plain `docker run` testing).
# No npm install needed — Verdaccio is copied from the official image above.
# hadolint ignore=DL3018
RUN \
    apk add --no-cache \
        nodejs \
        jq \
    && mkdir -p /etc/verdaccio/plugins /data/verdaccio/storage

COPY --from=upstream /usr/local/lib/node_modules/verdaccio /usr/local/lib/node_modules/verdaccio
RUN \
    ln -sf ../lib/node_modules/verdaccio/bin/verdaccio /usr/local/bin/verdaccio \
    && node --version \
    && verdaccio --version

# Copy s6-overlay service definitions (rootfs/etc/services.d/verdaccio/run)
COPY rootfs /
RUN chmod a+x /etc/services.d/verdaccio/run /etc/services.d/verdaccio/finish
