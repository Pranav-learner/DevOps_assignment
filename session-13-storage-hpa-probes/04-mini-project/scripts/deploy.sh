#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "=== Deploying TaskFlow Cloud Platform (Session 13 Mini Project) ==="

echo "1. Creating Namespace..."
kubectl apply -f "$DIR/01-namespace.yaml"

echo "2. Provisioning Storage & Secrets..."
kubectl apply -f "$DIR/02-db-storage.yaml"
kubectl apply -f "$DIR/03-db-secret.yaml"

echo "3. Deploying PostgreSQL Database..."
kubectl apply -f "$DIR/04-db-deployment.yaml"
kubectl apply -f "$DIR/05-db-service.yaml"

echo "4. Deploying TaskFlow API Microservice..."
kubectl apply -f "$DIR/06-api-configmap.yaml"
kubectl apply -f "$DIR/07-api-deployment.yaml"
kubectl apply -f "$DIR/08-api-service.yaml"

echo "5. Configuring Horizontal Pod Autoscaler..."
kubectl apply -f "$DIR/09-api-hpa.yaml"

echo "6. Waiting for workloads to reach Ready state..."
kubectl wait --for=condition=Ready pod -l app=postgres-db -n taskflow-prod --timeout=90s
kubectl wait --for=condition=Ready pod -l app=taskflow-api -n taskflow-prod --timeout=60s

echo "=== Deployment Succeeded! ==="
kubectl get all,pvc,hpa -n taskflow-prod
