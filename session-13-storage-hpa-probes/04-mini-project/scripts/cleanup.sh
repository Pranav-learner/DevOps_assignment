#!/usr/bin/env bash
set -e

echo "=== Tearing down TaskFlow Cloud Platform ==="
kubectl delete namespace taskflow-prod --wait=true
echo "Namespace taskflow-prod and all enclosed resources deleted cleanly."
