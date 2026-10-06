#!/usr/bin/env bash
set -e

echo "=== Tearing down shopsphere-incident namespace ==="
kubectl delete namespace shopsphere-incident --wait=true
echo "Cleaned up shopsphere-incident namespace."
