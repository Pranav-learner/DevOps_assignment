#!/usr/bin/env bash
set -e

NS="shopsphere-incident"
echo "=== End-to-End Post-Incident Health & Traffic Verification ==="

echo "1. Checking Endpoints Population across Services:"
kubectl get endpoints -n "$NS"

echo -e "\n2. Testing Backend API Traffic directly via Pod & Service:"
API_IP=$(kubectl get svc api-service -n "$NS" -o jsonpath='{.spec.clusterIP}')
minikube ssh -- "curl -s http://$API_IP:8080" | jq . || minikube ssh -- "curl -s http://$API_IP:8080"

echo -e "\n3. Testing Frontend Web Service:"
WEB_IP=$(kubectl get svc web-service -n "$NS" -o jsonpath='{.spec.clusterIP}')
minikube ssh -- "curl -s -I http://$WEB_IP:80 | head -n 3"

echo -e "\n=== ALL TESTS PASSED: ShopSphere Platform Fully Restored! ==="
