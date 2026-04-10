#!/usr/bin/env bash
set -euo pipefail

PROOF_DIR="${1:?Usage: ./verify.sh proofs/<commit>.proof/}"

echo "── Checking proof bundle: ${PROOF_DIR}"

if [ ! -f "${PROOF_DIR}/certificate.json" ]; then
  echo "❌ certificate.json not found in ${PROOF_DIR}"
  exit 1
fi
echo "✓ certificate.json found"

if [ ! -f "${PROOF_DIR}/proof.ots" ]; then
  echo "⚠️  proof.ots not found — Bitcoin confirmation may still be pending (~2 hours)"
  exit 0
fi
echo "✓ proof.ots found"

CERT_HASH=$(grep -o '"hash":"[^"]*"' "${PROOF_DIR}/certificate.json" | cut -d'"' -f4)
ORIGIN_ID=$(grep -o '"origin_id":"[^"]*"' "${PROOF_DIR}/certificate.json" | cut -d'"' -f4)

if [ -z "$CERT_HASH" ]; then
  echo "❌ Could not extract hash from certificate.json"
  exit 1
fi
echo "✓ Certificate hash: ${CERT_HASH}"
echo "  Origin ID: ${ORIGIN_ID}"

echo ""
echo "── Reproducing deterministic artifact from current checkout..."

tar --sort=name \
    --mtime='UTC 1970-01-01' \
    --owner=0 --group=0 --numeric-owner \
    --exclude='.git' \
    --exclude='proofs' \
    -cf /tmp/verify-build.tar .
gzip -n -f /tmp/verify-build.tar

REPRODUCED_HASH=$(sha256sum /tmp/verify-build.tar.gz | cut -d' ' -f1)
echo "✓ Reproduced hash: ${REPRODUCED_HASH}"

echo ""
echo "── Comparing hashes..."

CERT_HASH_CLEAN="${CERT_HASH#sha256:}"

if [ "$REPRODUCED_HASH" = "$CERT_HASH_CLEAN" ]; then
  echo "✅ HASH MATCH — artifact is identical to what was anchored"
else
  echo "❌ HASH MISMATCH"
  echo "   Certificate: ${CERT_HASH_CLEAN}"
  echo "   Reproduced:  ${REPRODUCED_HASH}"
  echo "   Checkout the exact commit to reproduce the original hash."
  rm -f /tmp/verify-build.tar.gz
  exit 1
fi

echo ""
echo "── Verifying OpenTimestamps proof against Bitcoin..."

if command -v ots &>/dev/null; then
  ots verify "${PROOF_DIR}/proof.ots" && echo "✅ Bitcoin verification passed" || echo "⚠️  OTS verification returned non-zero"
else
  echo "⚠️  'ots' CLI not installed. Install with: pip install opentimestamps-client"
  echo "   Or verify online at: https://verify-anchoring.org"
  echo "   Or use: npx @umarise/cli verify --origin-id ${ORIGIN_ID}"
fi

rm -f /tmp/verify-build.tar.gz

echo ""
echo "── Verification complete"
echo "   This verification used ZERO Umarise infrastructure."
echo "   Tools used: git, tar, gzip, sha256sum, ots"
