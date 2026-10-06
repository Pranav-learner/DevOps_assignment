#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NS="shopsphere-incident"

echo "=== Applying Comprehensive Incident Remediation (02-fixed-stack.yaml) ==="
kubectl apply -f "$DIR/manifests/02-fixed-stack.yaml"

echo "Waiting for all workloads to converge to Ready state..."
kubectl rollout status deployment/db-deployment -n "$NS" --timeout=60s
kubectl rollout status deployment/cache-deployment -n "$NS" --timeout=60s
kubectl rollout status deployment/api-deployment -n "$NS" --timeout=60s
kubectl rollout status deployment/web-deployment -n "$NS" --timeout=60s

echo "=== Remediation Applied Successfully! ==="
kubectl get pods,svc,endpoints -n "$NS" -o wide
