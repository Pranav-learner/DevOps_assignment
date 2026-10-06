#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "=== Triggering Production Outage Incident (Deploying Broken Stack) ==="
kubectl apply -f "$DIR/manifests/01-broken-stack.yaml"

echo "Waiting 10s for failure states to manifest..."
sleep 10
kubectl get pods,svc,endpoints -n shopsphere-incident
