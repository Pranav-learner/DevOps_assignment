#!/usr/bin/env bash
set -e

NS="shopsphere-incident"
echo "=========================================================="
echo "         INCIDENT INVESTIGATION & TRIAGE AUDIT"
echo "=========================================================="

echo -e "\n--- 1. High-Level Namespace Resource Overview ---"
kubectl get pods -n "$NS" -o wide

echo -e "\n--- 2. Database Tier (db-deployment) Diagnosis ---"
DB_POD=$(kubectl get pods -n "$NS" -l app=db -o jsonpath='{.items[0].metadata.name}' || true)
if [ -n "$DB_POD" ]; then
    echo "Inspecting DB Pod: $DB_POD"
    kubectl describe pod -n "$NS" "$DB_POD" | grep -A 4 "Requests:" || true
    kubectl describe pod -n "$NS" "$DB_POD" | tail -n 6
fi

echo -e "\n--- 3. Cache Tier (cache-deployment) Diagnosis ---"
CACHE_POD=$(kubectl get pods -n "$NS" -l app=cache -o jsonpath='{.items[0].metadata.name}' || true)
if [ -n "$CACHE_POD" ]; then
    echo "Inspecting Cache Pod: $CACHE_POD"
    kubectl describe pod -n "$NS" "$CACHE_POD" | grep -A 3 "Volumes:" || true
    kubectl describe pod -n "$NS" "$CACHE_POD" | tail -n 6
fi

echo -e "\n--- 4. Backend API Tier (api-deployment) Diagnosis ---"
API_POD=$(kubectl get pods -n "$NS" -l app=api -o jsonpath='{.items[0].metadata.name}' || true)
if [ -n "$API_POD" ]; then
    echo "Inspecting API Pod: $API_POD"
    kubectl logs -n "$NS" "$API_POD" --tail=5 || true
    kubectl describe pod -n "$NS" "$API_POD" | grep -A 4 "Last State:" || true
fi

echo -e "\n--- 5. Service & Endpoint Routing Diagnosis ---"
kubectl get endpoints -n "$NS"
kubectl describe svc api-service -n "$NS" | grep -E "(Selector:|Endpoints:)"
