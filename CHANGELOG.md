# Changelog

## 1.1.0

- Caching is now OFF by default: new `enable_cache` option (default `false`) maps to the uplink `cache` flag. Set it to `true` to cache upstream packages in `/data/verdaccio/storage`.
- `maxage` now only applies when `enable_cache` is `true`.

## 1.0.0

- Initial release: Verdaccio 6 caching proxy to `registry.npmjs.org` on port 4873.
- Options: `log_level`, `uplink`, `maxage`, `timeout`, `max_body_size`, `allow_offline`, `allow_publish`, `enable_web`.
- Persistent cache in `/data/verdaccio/storage`, htpasswd at `/data/verdaccio/htpasswd`.
- Health check via `tcp://[HOST]:[PORT:4873]`, Web UI link wired.
