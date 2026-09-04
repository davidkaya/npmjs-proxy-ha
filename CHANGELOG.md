# Changelog

## 1.0.0

- Initial release: Verdaccio 6 caching proxy to `registry.npmjs.org` on port 4873.
- Options: `log_level`, `uplink`, `maxage`, `timeout`, `max_body_size`, `allow_offline`, `allow_publish`, `enable_web`.
- Persistent cache in `/data/verdaccio/storage`, htpasswd at `/data/verdaccio/htpasswd`.
- Health check via `tcp://[HOST]:[PORT:4873]`, Web UI link wired.
