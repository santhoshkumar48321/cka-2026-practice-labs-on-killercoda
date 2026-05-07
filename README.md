# CKA 2026 Practice Labs on Killercoda

This repository contains **25 CKA-style hands-on scenarios** designed for Killercoda.
Each scenario follows a consistent structure and includes automated `CHECK` verification.

## Repository structure

Each scenario folder uses this layout:

```text
XX-scenario-name/
├── index.json
├── intro.md
├── step1.md
├── finish.md
└── scripts/
    ├── background.sh
    └── verify.sh
```

## Current standardized setup

- `index.json` is normalized across all scenarios:
  - backend image: `kubernetes-kubeadm-2nodes`
  - intro text/background wired to `intro.md` and `scripts/background.sh`
  - step wired to `step1.md` and `scripts/verify.sh`
  - finish wired to `finish.md`
- `background.sh` scripts:
  - use `#!/usr/bin/env bash` and `set -euo pipefail`
  - include `wait_kube()` with up to 60s polling (special handling for scenario 14)
  - use idempotent create/apply patterns
  - end with `echo "Setup complete"`
- `verify.sh` scripts:
  - use strict pass/fail behavior with clear failure messages
  - end with `echo "PASS"` and `exit 0`
  - are idempotent and scenario-specific

## How to run in Killercoda

1. Fork this repository.
2. In Killercoda Creator, add your GitHub repository.
3. Add Killercoda deploy key to GitHub repo Deploy Keys (read-only).
4. Launch any scenario and complete `step1.md` tasks.
5. Click **CHECK** to run `scripts/verify.sh`.

## Local validation commands

Run these from repository root:

```bash
# Shell syntax checks for all scenario scripts
find . -path '*/scripts/*.sh' -type f -print0 | xargs -0 -n1 bash -n

# JSON validity and required wiring checks
python - <<'PYCODE'
import glob, json
for p in glob.glob('[0-9][0-9]-*/index.json'):
    json.load(open(p))
print('index.json files are valid JSON')
PYCODE
```

## Scenarios

01 through 25 are included and mapped in `structure.json`.

## Contribution notes

- Keep scenario resource names consistent across `intro.md`, `step1.md`, `background.sh`, and `verify.sh`.
- Keep setup and verification idempotent.
- Prefer minimal, targeted changes to existing scenarios.
