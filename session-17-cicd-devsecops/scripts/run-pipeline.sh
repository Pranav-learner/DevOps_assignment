#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "  Executing Full DevSecOps CI/CD Pipeline (11 Stages)"
echo "=========================================================="

# 1. Code & Build & Unit Test
cd ../app
echo "[Stage 1, 2, 3] Code Linting & Automated Unit Tests..."
npm run lint
npm run test:ci
cd "$SCRIPT_DIR"

# 4. SAST
./run-sast.sh

# 5. SCA
./run-sca.sh

# 6. Secret Scan
./run-secret-scan.sh

# 7. Docker Build
./build-docker.sh

# 8. Container Image Scan
./run-container-scan.sh

# 9. Security Gate
./enforce-security-gate.sh

# 10 & 11. Push Image & Deploy to Kubernetes
./deploy-k8s.sh

echo "=========================================================="
echo "  FULL DEVSECOPS PIPELINE COMPLETED SUCCESSFULLY!"
echo "=========================================================="
