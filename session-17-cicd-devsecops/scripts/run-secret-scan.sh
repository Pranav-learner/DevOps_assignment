#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

echo "=========================================================="
echo "  [DevSecOps Stage 6] Secret Scanning: Credential Detection"
echo "=========================================================="

echo "[+] Executing Gitleaks deep scan against codebase and configs..."
gitleaks detect --source=. --config=config/.gitleaks.toml --no-git --verbose

echo ""
echo "=========================================================="
echo "  Secret Scan Passed: Zero Leaks / Hardcoded Keys Detected"
echo "=========================================================="
