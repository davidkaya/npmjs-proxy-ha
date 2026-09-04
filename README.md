# NPMjs Proxy — Home Assistant Add-on

Verdaccio-based proxy for `registry.npmjs.org`, running as a Home Assistant OS add-on.

Point `npm` / `yarn` / `pnpm` at `http://homeassistant.local:4873`. By default it is a pure pass-through proxy; set `enable_cache: true` and packages are fetched once from npmjs.org, then served from local cache in `/data/verdaccio/storage` (survives reboots, backups, and upstream outages).

## Install

### Option A — Local `/addons` folder (fastest for testing)

1. Copy this folder to `\\homeassistant.local\addons\npmjs-proxy` (Samba) or `/addons/npmjs-proxy` (SSH).
2. HA → Settings → Add-ons → Add-on Store → ⋮ → Check for updates → Local add-ons → **NPMjs Proxy** → Install → Start.

### Option B — As a repository

Add this Git repo URL under Add-on Store → ⋮ → Repositories, then install **NPMjs Proxy**.

## Configuration

```yaml
log_level: info          # debug|info|http|warn|error|fatal
uplink: https://registry.npmjs.org/
enable_cache: false      # true = cache upstream packages locally
maxage: 30m              # how long to cache metadata when enable_cache is true (e.g. 10m, 1h, 24h)
timeout: 30s             # upstream timeout
max_body_size: 32mb      # max package publish size
allow_offline: true      # serve cache + allow offline publish when upstream down
allow_publish: false     # false = read-only mirror; true = allow npm publish (private pkgs)
enable_web: false        # true = Verdaccio web UI on :4873
```

Cache (when enabled) persists in `/data/verdaccio/storage` and is included in HA backups.

## Usage

```bash
# one-off
npm install --registry http://homeassistant.local:4873 lodash

# per-project (.npmrc in your project root)
registry=http://homeassistant.local:4873/

# global
npm config set registry http://homeassistant.local:4873/
yarn config set registry http://homeassistant.local:4873/
pnpm config set registry http://homeassistant.local:4873/
```

Verify:

```bash
curl http://homeassistant.local:4873/lodash
npm view lodash version --registry http://homeassistant.local:4873
```

Revert to upstream:

```bash
npm config set registry https://registry.npmjs.org/
```

## Private packages (optional)

1. Set `allow_publish: true`, restart the add-on.
2. `npm adduser --registry http://homeassistant.local:4873`
3. `npm publish --registry http://homeassistant.local:4873`

Default (`allow_publish: false`) disables signup (`max_users: -1`) so the proxy is read-only (no private packages can be published).

## Ports

| Container | Host (default) | Description |
|-----------|----------------|-------------|
| 4873/tcp  | 4873           | npm registry + optional web UI |

Web UI (`enable_web: true`): `http://homeassistant.local:4873/`
Health check: `tcp://[HOST]:[PORT:4873]`

## Building

Local Supervisor build picks up `Dockerfile` automatically. Multi-arch (`aarch64`, `amd64`, `armv7`) via the HA base image.

## Files

- `config.yaml` — add-on definition, options + schema
- `Dockerfile` — multi-stage: Verdaccio 6 from official image + `ghcr.io/home-assistant/base`
- `rootfs/etc/services.d/verdaccio/run` — s6 service, renders `/etc/verdaccio/config.yaml` from options via bashio
- `DOCS.md` — extended docs (shown in add-on Docs tab)
- `repository.yaml` — repo metadata
