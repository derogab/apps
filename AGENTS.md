# Guidelines for Agents

Agent contract for apps configuration.
Goal: minimal diffs, stable networking, predictable operations, configuration standards.

## Project Overview

This repository contains configuration files for personal containerized apps, organized as one app per directory under `apps/`.

## Non-negotiables

- Use Docker Compose Specification syntax; do not add top-level `version`.
- Keep one compose file per app: `<app>/docker-compose.yml`.
- Create a `.gitignore` file in each app directory ignoring `data/` and other persistent directories.
- Keep standard top-level key order.
- Every service must define `container_name` and `restart`.
- Preserve existing behavior unless the task explicitly requests a change.

## Network model

- Each stack owns a named bridge network with IPAM and a `/24` subnet.
- Before assigning a subnet, check all stacks to confirm it is not already used.
- Never reuse a subnet already assigned to another stack.
- For new stacks, find used `/24` subnets across all stacks and choose the next free one.
- Services use static `ipv4_address` values.
- For new services, allocate the next free IP in that stack (`.2+`, avoid `.1`).
- Never renumber existing IPs unless an explicit migration is requested.
- For cross-stack connectivity, attach existing shared networks with `external: true`.

## Port management

- Before assigning a host port, check all existing compose files to ensure it's not already used.
- Use ports in the `80xx` range for web UIs where possible.

## Environment model

- Root `.env` (`apps/.env`) is the shared environment.
- App `.env` (`<app>/.env`) is the app-specific environment.
- In Compose files, `env_file` loads shared/app env values, while `environment` is for fixed per-service values.
- Use `${VAR}` for required values and `${VAR:-default}` for optional defaults.
- Never hardcode secrets or tokens in compose files.
- Keep `PUID: 1000` and `PGID: 1000` always (some images may ignore unsupported keys).
- Do not hardcode `TZ` in compose files; rely on `env_file` if timezone configuration is needed.

## Storage and paths

- Use relative bind mounts from the app directory.
- Keep persistent data app-local by default (e.g. `./data`, `./media`, `./downloads`, `./models`).
- Use service-specific subdirectories: `./data/<service-name>:/container/path` for future-proofing.
- Use read-only mounts for sensitive host paths whenever possible.
- Avoid absolute host paths unless there is no safe alternative.

## Readiness and startup order

- If service A depends on service B readiness, add a healthcheck to B.
- Use `depends_on` with `condition: service_healthy` for readiness gating.
- Preserve existing healthcheck timing unless there is a concrete reason to tune it.

## Homepage labels (required for user-facing services)

- Include all labels:
  - `homepage.group`
  - `homepage.name`
  - `homepage.icon`
  - `homepage.href`
  - `homepage.description`
- When port is exposed: use `http://${CUSTOM_LOCAL_HOST:-localhost}:<port>`.
- When no port exposed (e.g., Cloudflared-only, bots): use official service URL or GitHub repo URL.
- Reuse existing groups: `Tools`, `Entertainment`, `Bots`, `Privacy`.
- Add new groups only when needed and keep naming stable.

## Security posture

- Apply least privilege by default.
- Docker API access goes through `homepage/dockerproxy` only.
- Do not expand dockerproxy permissions without a concrete requirement.
- Keep dockerproxy read-only posture (`POST=0` and socket mount `:ro`).
- Avoid `privileged: true`, host networking, and broad `cap_add` unless explicitly required.

## Image and tag policy

- Repository convention is `:latest` tags.
- Keep the existing tag strategy within touched files.
- If pinning to a fixed version, add a short reason comment.

## Compose style

- YAML indentation: 2 spaces.
- Follow, as much as possible, the structure and ordering standards already used in other configs.
- Use inline comments only for non-obvious values.

## Final checklist

- Subnets and static IPs are unique and unchanged unless intentionally migrated.
- `container_name` and `restart` are present for all touched services.
- Env references follow existing layering; no plaintext secrets introduced.
- Volumes are relative and persistence paths are intentional.
- Healthchecks/dependency conditions are correct.
- Homepage labels are complete on user-facing services.
- No accidental privilege expansion.

## Continuous improvement

This document can be improved when new know-how is understood from conversations.
