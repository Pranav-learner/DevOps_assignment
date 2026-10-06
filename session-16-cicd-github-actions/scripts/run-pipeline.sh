#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "  Executing End-to-End CI/CD Pipeline (GitHub Actions Simulation)"
echo "=========================================================="

# 1. CI Phase: Lint & Tests
./test-app.sh

# 2. CD Phase 1: Container Build
./build-docker.sh

# 3. CD Phase 2: Deploy & Smoke Test
./deploy-k8s.sh

echo "=========================================================="
echo "  ALL PIPELINE STAGES PASSED SUCCESSFULLY!"
echo "=========================================================="
