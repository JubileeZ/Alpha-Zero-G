# Active Task: Windows CI Chocolatey flake harden

- **Status:** Done
- **Objective:** Stop Windows Sanity failing when Chocolatey CDN 503s on shellcheck
- **Acceptance:** Windows install step gets jq + shellcheck without depending on choco for shellcheck
- **Issue/Ticket:** https://github.com/JubileeZ/alpha-zero-g/actions/runs/30684661105

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `.github/workflows/ci.yml`
- **Decisions:** shellcheck via GitHub release zip; jq stays choco with skip + 3 retries
- **Blocked:** None
- **Next:** None — pushed for CI re-run

## Todo
- [x] Harden Windows install step

## Blockers / Notes
- Prior flake: choco 503 on shellcheck; Install step still green, Sanity failed
