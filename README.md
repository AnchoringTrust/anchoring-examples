# anchoring-examples

[![Anchored by Umarise](https://img.shields.io/badge/anchored%20by-Umarise-orange?logo=bitcoin&logoColor=white)](https://umarise.com)
[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Umarise%20Anchor-blue?logo=github)](https://github.com/marketplace/actions/umarise-anchor)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-green)](LICENSE)
[![Spec: anchoring-spec.org](https://img.shields.io/badge/spec-anchoring--spec.org-lightgrey)](https://anchoring-spec.org)

**Every artifact in this repository is anchored to Bitcoin.**

Verify any `.proof` file at [verify-anchoring.org](https://verify-anchoring.org).

---

## How it works

On every push to `main`, the workflow:

1. Creates a build artifact
2. Anchors it to Bitcoin via [`anchor-action`](https://github.com/marketplace/actions/umarise-anchor)
3. Uploads the `.proof` file as a build artifact
4. Commits lightweight proof (`certificate.json` + `proof.ots`) to `/proofs`

The proof is independently verifiable. No account, no vendor, no trust required.

---

## Try it yourself

1. Fork this repo
2. Add `UMARISE_API_KEY` to your repo secrets (Settings → Secrets → Actions)
3. Push a commit
4. Check the Actions tab — download the `.proof` artifact

Get a free API key (100 anchors, no credit card): [umarise.com/developers](https://umarise.com/developers)

---

## Workflow templates

Pick the template that matches your stack:

| Template | Stack | What it anchors |
|----------|-------|-----------------|
| [`anchor.yml`](.github/workflows/anchor.yml) | **Any** (default) | Deterministic repo snapshot |
| [`anchor-python.yml`](.github/workflows/anchor-python.yml) | **Python** | Test suite → build → anchor |
| [`anchor-node.yml`](.github/workflows/anchor-node.yml) | **Node.js** | npm test → build → anchor |
| [`anchor-docker.yml`](.github/workflows/anchor-docker.yml) | **Docker** | Container image → anchor |

### Default — deterministic repo snapshot

\`\`\`yaml
- name: Create deterministic build artifact
  run: |
    tar --sort=name --mtime='UTC 1970-01-01' \
        --owner=0 --group=0 --numeric-owner \
        --exclude='.git' --exclude='proofs' \
        -cf build.tar .
    gzip -n -f build.tar

- name: Anchor to Bitcoin
  uses: AnchoringTrust/anchor-action@v1
  with:
    file: build.tar.gz
  env:
    UMARISE_API_KEY: \${{ secrets.UMARISE_API_KEY }}
\`\`\`

### Python — test then anchor

\`\`\`yaml
- run: pip install -r requirements.txt
- run: pytest

- name: Build
  run: python -m build

- name: Anchor to Bitcoin
  uses: AnchoringTrust/anchor-action@v1
  with:
    file: dist/*.tar.gz
  env:
    UMARISE_API_KEY: \${{ secrets.UMARISE_API_KEY }}
\`\`\`

### Node.js — test then anchor

\`\`\`yaml
- run: npm ci
- run: npm test

- name: Build
  run: npm run build && tar czf build.tar.gz dist/

- name: Anchor to Bitcoin
  uses: AnchoringTrust/anchor-action@v1
  with:
    file: build.tar.gz
  env:
    UMARISE_API_KEY: \${{ secrets.UMARISE_API_KEY }}
\`\`\`

### Docker — anchor container image

\`\`\`yaml
- name: Build image
  run: docker build -t myapp:\${{ github.sha }} .

- name: Save image
  run: docker save myapp:\${{ github.sha }} | gzip > image.tar.gz

- name: Anchor to Bitcoin
  uses: AnchoringTrust/anchor-action@v1
  with:
    file: image.tar.gz
  env:
    UMARISE_API_KEY: \${{ secrets.UMARISE_API_KEY }}
\`\`\`

---

## Verify

No account needed. No trust required.

\`\`\`bash
npx @umarise/cli verify --origin-id <origin_id>

pip install umarise && umarise verify --origin-id <origin_id>

# Web — drag and drop
# https://verify-anchoring.org → HASH + OTS tab

# Full independent verification (zero trust)
./verify.sh proofs/abc1234.proof/
\`\`\`

See [`verify.sh`](verify.sh) for the full independent verification script.

---

## What this proves

| Layer | Tool | Proves |
|-------|------|--------|
| Code signing | GPG / Sigstore | **Who** signed it |
| SBOM | Syft / Trivy | **What** is in it |
| **Anchoring** | **Umarise** | **When** it existed |

A `.proof` file next to a `.sig` and `.sbom` completes the audit trail: **what, who, and when**.

---

## The proof bundle

Each proof consists of two files (~4KB total):

\`\`\`
proofs/
├── abc1234.json              ← metadata (origin_id, hash, status)
└── abc1234.proof/
    ├── certificate.json      ← hash, origin_id, timestamp
    └── proof.ots             ← OpenTimestamps Bitcoin proof (binary)
\`\`\`

| File | What it contains | How to verify |
|------|-----------------|---------------|
| `certificate.json` | Hash, origin_id, timestamp | Compare hash against reproduced artifact |
| `proof.ots` | Merkle path → Bitcoin block | `ots verify proof.ots` or verify-anchoring.org |

The original artifact is **not stored** — it's reproducible from the git commit via deterministic hashing.

---

## Security

- **Source code never leaves the runner** — only the 64-byte SHA-256 hash is transmitted
- **Pin the action** for production: `AnchoringTrust/anchor-action@<commit-sha>`
- **Proof is tamper-evident** — modifying `proof.ots` invalidates the Bitcoin verification

---

## Credits & idempotency

| Scenario | Credits |
|----------|---------|
| First push (new hash) | 1 |
| Re-run same commit | 0 |
| New commit (code changed) | 1 |

Deterministic hashing ensures re-runs are free.

---

## Links

- [GitHub Marketplace — Umarise Anchor](https://github.com/marketplace/actions/umarise-anchor)
- [Independent verifier — verify-anchoring.org](https://verify-anchoring.org)
- [Open specification — anchoring-spec.org](https://anchoring-spec.org)
- [CLI — @umarise/cli](https://www.npmjs.com/package/@umarise/cli)
- [API docs — umarise.com/developers](https://umarise.com/developers)

## License

[Unlicense](LICENSE) — Public Domain

