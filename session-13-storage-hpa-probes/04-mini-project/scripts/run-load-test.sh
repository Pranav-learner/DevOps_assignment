#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NS="taskflow-prod"

echo "=== Step 1: Starting Load Generator Deployment ==="
kubectl apply -f "$DIR/10-load-generator.yaml"
kubectl scale deployment taskflow-load-generator -n "$NS" --replicas=4

echo "=== Step 2: Observing CPU Spikes & HPA Scaling Decisions ==="
for i in {1..8}; do
    echo "--- Poll cycle $i ---"
    kubectl top pods -n "$NS" -l app=taskflow-api || true
    kubectl get hpa taskflow-api-hpa -n "$NS"
    sleep 10
done

echo "=== Step 3: Removing Load Generator ==="
kubectl delete deployment taskflow-load-generator -n "$NS"

echo "=== Step 4: Observing Stabilization & Scale-Down ==="
sleep 15
kubectl get hpa taskflow-api-hpa -n "$NS"
kubectl get pods -n "$NS" -l app=taskflow-api
