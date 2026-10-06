#!/usr/bin/env bash
set -e

NS="taskflow-prod"
echo "=== Step 1: Checking Baseline Endpoints & Pod States ==="
kubectl get pods -n "$NS" -l app=taskflow-api
kubectl get endpoints taskflow-api-service -n "$NS"

FIRST_POD=$(kubectl get pods -n "$NS" -l app=taskflow-api -o jsonpath='{.items[0].metadata.name}')
echo "Selected target Pod: $FIRST_POD"

echo "=== Step 2: Simulating Readiness Failure on $FIRST_POD ==="
kubectl exec -n "$NS" "$FIRST_POD" -- wget -q -O- http://127.0.0.1:8080/simulate-unready
sleep 4

echo "=== Step 3: Verifying Endpoint Gating (Traffic Detached) ==="
kubectl get pods -n "$NS" -l app=taskflow-api
kubectl get endpoints taskflow-api-service -n "$NS"

echo "=== Step 4: Simulating Fatal Container Crash (Testing Liveness Restart) ==="
kubectl exec -n "$NS" "$FIRST_POD" -- wget -q -O- http://127.0.0.1:8080/simulate-crash || true
sleep 6

echo "=== Step 5: Verifying Container Self-Healing ==="
kubectl get pods -n "$NS" -l app=taskflow-api
kubectl describe pod -n "$NS" "$FIRST_POD" | tail -n 12
