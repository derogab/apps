# Home Assistant

## Reverse proxy configuration

Home Assistant is exposed externally via the `cloudflared` tunnel (`172.20.0.2`). By default, HA's HTTP integration rejects requests from reverse proxies with errors like:

```
A request from a reverse proxy was received from 172.20.0.2, but your HTTP integration is not set-up for reverse proxies
```

To fix this, add the following to `data/home-assistant/configuration.yaml` on the host (the `data/` directory is gitignored and lives only on the host running the container):

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.20.0.0/24
```

Then restart the container:

```bash
docker compose restart
```

Notes:

- `172.20.0.0/24` is the `cloudflared` bridge subnet — trusting the whole range means future services on that network keep working without re-configuring HA.
- If `configuration.yaml` already has an `http:` key, merge these entries under it instead of declaring `http:` twice.
