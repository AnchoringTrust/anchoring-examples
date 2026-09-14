# anchoring-examples

[![Anchored by Umarise](https://img.shields.io/badge/anchored%20by-Umarise-orange?logo=bitcoin&logoColor=white)](https://umarise.com)
[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Umarise%20Anchor-blue?logo=github)](https://github.com/marketplace/actions/umarise-anchor)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-green)](LICENSE)
[![Spec: anchoring-spec.org](https://img.shields.io/badge/spec-anchoring--spec.org-lightgrey)](https://anchoring-spec.org)

**Every artifact in this repository is anchored to Bitcoin.**

Verify any `.proof` file at [verify-anchoring.org](https://verify-anchoring.org).

Conference attendees: see [The Berlin example](#the-berlin-example).

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

## The Berlin example

`berlin.txt` is the artifact used in the Nextcloud Community Conference
lightning talk. Its proof is `berlin.txt.ots`, anchored to Bitcoin.

**Step 1 — check you have the same bytes.**

    Linux:    sha256sum berlin.txt
    macOS:    shasum -a 256 berlin.txt
    Windows:  Get-FileHash .\berlin.txt -Algorithm SHA256

Expected:

    3979803321ad2608d3d97bbe678c893e1aad610f23b6a7fa3c0fc967616cc787

If your digest differs, you do not have the same file. Windows prints
uppercase; the comparison is case-insensitive. This file is checked out
with LF line endings (see `.gitattributes`).

**Step 2 — verify the proof.**

    Web:  https://verify-anchoring.org  (HASH + OTS tab)
    Info: ots info berlin.txt.ots

`berlin.txt.ots` is confirmed in Bitcoin block 965633. `ots info` shows the
full Merkle path offline, ending in that block's header. The other
`PendingAttestation` lines are additional calendars that have not been
included in a block yet; one confirmed attestation is what matters.

`ots verify berlin.txt.ots` compares that path against a Bitcoin node. If
you do not run one locally it reports that it cannot connect, which says
nothing about the proof.

**Step 3 — check the block yourself.**

Look up block 965633 in any block explorer and compare its Merkle root to:

    796881583ff407a6dd554b62b137d3228c7aa66534360511104a0c49acaf4b7a

This proves the file existed no later than that block. It says nothing
about who wrote it or whether its contents are true. Nothing in this
chain requires Umarise.

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

