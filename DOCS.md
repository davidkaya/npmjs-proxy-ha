# Home Assistant Add-on: NPMjs Proxy

## What is this?

A npm registry proxy (Verdaccio 6) with uplink to `https://registry.npmjs.org/`.

- By default it is a pure pass-through proxy (caching OFF).
- Set `enable_cache: true` and the first `npm install` fetches tarballs/metadata from npmjs.org and stores them in `/data/verdaccio/storage`.
- With caching on, repeat installs are served locally — faster LAN installs, lower WAN traffic, works briefly during upstream outages (per `maxage` / `allow_offline`).
- Optional private-package publishing behind htpasswd auth.

## Installation

See `README.md`. After install, check the Log tab for:

```text
[INFO] Starting NPMjs Proxy...
[INFO] Wrote Verdaccio config to /etc/verdaccio/config.yaml
 warn --- config file  - /etc/verdaccio/config.yaml
 warn --- http address - http://0.0.0.0:4873/ - verdaccio/6.x
```

## Configuration reference

| Option | Default | Description |
|--------|---------|-------------|
| `log_level` | `info` | Verdaccio log level. |
| `uplink` | `https://registry.npmjs.org/` | Upstream registry. Use a mirror e.g. `https://registry.npmmirror.com/` if desired. Must end with `/`. |
| `enable_cache` | `false` | Cache upstream packages locally. `false` = pure pass-through proxy. |
| `maxage` | `30m` | Uplink metadata cache time (only used when `enable_cache` is `true`). Longer = fewer upstream hits, slower freshness. |
| `timeout` | `30s` | Upstream request timeout. |
| `max_body_size` | `32mb` | Max publish payload. Unused in mirror mode. |
| `allow_offline` | `true` | Serve stale cache + allow `offline_publish` when upstream is down. |
| `allow_publish` | `false` | `false` = read-only mirror (`max_users: -1`). `true` = allow `npm adduser` / `npm publish`. |
| `enable_web` | `false` | Serve Verdaccio web UI on `:4873`. Enable for browsing/searching cached packages. |

### Example: aggressive LAN cache

```yaml
log_level: info
uplink: https://registry.npmjs.org/
enable_cache: true
maxage: 2h
timeout: 30s
max_body_size: 32mb
allow_offline: true
allow_publish: false
enable_web: true
```

## Client setup

Per-project `.npmrc`:

```ini
registry=http://homeassistant.local:4873/
```

Or scoped (only proxy one scope, rest direct to npmjs):

```ini
@mycompany:registry=http://homeassistant.local:4873/
```

Docker builds on your LAN can use `--build-arg NPM_REGISTRY=http://homeassistant.local:4873` + `npm ci --registry $NPM_REGISTRY`.

## Storage & backups

- Storage: `/data/verdaccio/storage` (persistent volume, included in HA backups).
- Auth file: `/data/verdaccio/htpasswd`.
- To clear the cache: stop the add-on, delete `/data/verdaccio/storage` via SSH/Samba, start again.

## Troubleshooting

- **Add-on not in store**: Add-on Store → ⋮ → Check for updates, then hard-refresh (Ctrl+F5). Check Supervisor logs for `config.yaml` validation errors.
- **EAI_AGAIN / uplink timeouts**: upstream unreachable. Increase `timeout`, check DNS, or rely on cache with `allow_offline: true`.
- **`npm publish` 403**: expected in mirror mode. Set `allow_publish: true` and `npm adduser` first.
- **Port conflict**: change host port in the add-on Network section (e.g. `4874`), clients then use `:4874`.
- **Windows CRLF**: `rootfs/etc/services.d/verdaccio/run` must use LF line endings (`#!/usr/bin/with-contenv bashio` breaks on CRLF).

## Security notes

- This proxy speaks plain HTTP on your LAN by design (npm registry default). Do not expose 4873 to the internet without a reverse proxy + TLS + auth in front.
- No ingress support by design (you chose direct port `4873`). If you need HA sidebar access, enable `enable_web: true` and use the Web UI link, or ask to add ingress.
