#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../app"
cd "$APP_DIR"

echo "=========================================================="
echo "  [CI Stage 1 & 2] Linting & Automated Test Suite"
echo "=========================================================="

echo "[+] Step 1: Syntax & Lint Verification..."
npm run lint

echo ""
echo "[+] Step 2: Running Jest Unit & Integration Tests..."
npm run test:ci

echo ""
echo "=========================================================="
echo "  CI Tests & Coverage Completed with 100% Success!"
echo "=========================================================="
