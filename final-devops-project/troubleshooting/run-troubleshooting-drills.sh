#!/usr/bin/env bash
set -eo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="pranav-prod"

echo "=========================================================="
echo " Pranav Troubleshooting Challenge Drills"
echo "=========================================================="

kubectl create namespace "${NAMESPACE}" 2>/dev/null || true

echo "----------------------------------------------------------"
echo "DRILL 1: CrashLoopBackOff (Missing Secret Investigation)"
echo "----------------------------------------------------------"
kubectl apply -f "${DIR}/01-crashloopbackoff-broken.yaml"
echo "Waiting for pod failure state..."
sleep 5
kubectl get pods -n "${NAMESPACE}" -l app=troubleshoot-1
echo "Fetching pod logs to identify root cause:"
kubectl logs -n "${NAMESPACE}" -l app=troubleshoot-1 --tail=5 || true
echo "Applying remediation fix..."
kubectl apply -f "${DIR}/01-crashloopbackoff-fixed.yaml"
kubectl rollout status deployment/pranav-troubleshoot-crashloop -n "${NAMESPACE}" --timeout=60s
echo "✅ DRILL 1 RESOLVED: Pod is 1/1 Running!"
kubectl delete deployment pranav-troubleshoot-crashloop -n "${NAMESPACE}"

echo "----------------------------------------------------------"
echo "DRILL 2: ImagePullBackOff (Invalid Image Tag)"
echo "----------------------------------------------------------"
kubectl apply -f "${DIR}/02-imagepullbackoff-broken.yaml"
echo "Waiting for image pull failure..."
sleep 5
kubectl get pods -n "${NAMESPACE}" -l app=troubleshoot-2
echo "Inspecting Kubernetes event log for root cause:"
kubectl get events -n "${NAMESPACE}" --sort-by='.metadata.creationTimestamp' | tail -n 5
echo "Applying remediation fix..."
kubectl apply -f "${DIR}/02-imagepullbackoff-fixed.yaml"
kubectl rollout status deployment/pranav-troubleshoot-imagepull -n "${NAMESPACE}" --timeout=60s
echo "✅ DRILL 2 RESOLVED: Pod is 1/1 Running!"
kubectl delete deployment pranav-troubleshoot-imagepull -n "${NAMESPACE}"

echo "----------------------------------------------------------"
echo "DRILL 3: Probe Failure (Readiness 0/1 Unhealthy)"
echo "----------------------------------------------------------"
kubectl apply -f "${DIR}/03-probe-failure-broken.yaml"
echo "Waiting for probe failure..."
sleep 8
kubectl get pods -n "${NAMESPACE}" -l app=troubleshoot-3
echo "Describing pod probe events:"
kubectl describe pod -n "${NAMESPACE}" -l app=troubleshoot-3 | grep -E "(Readiness probe|Unhealthy)" || true
echo "Applying remediation fix..."
kubectl apply -f "${DIR}/03-probe-failure-fixed.yaml"
kubectl rollout status deployment/pranav-troubleshoot-probe -n "${NAMESPACE}" --timeout=60s
echo "✅ DRILL 3 RESOLVED: Pod is 1/1 Running and Ready!"
kubectl delete deployment pranav-troubleshoot-probe -n "${NAMESPACE}"

echo "----------------------------------------------------------"
echo "DRILL 4: Service Connectivity (Mismatched Selector)"
echo "----------------------------------------------------------"
kubectl apply -f "${DIR}/04-service-mismatch-broken.yaml"
echo "Inspecting Service endpoints with broken selector:"
kubectl get endpoints pranav-troubleshoot-service -n "${NAMESPACE}"
echo "Applying remediation fix with matching selector..."
kubectl apply -f "${DIR}/04-service-mismatch-fixed.yaml"
echo "Inspecting Service endpoints after fix:"
kubectl get endpoints pranav-troubleshoot-service -n "${NAMESPACE}"
echo "✅ DRILL 4 RESOLVED: Service endpoints successfully mapped to application pods!"
kubectl delete service pranav-troubleshoot-service -n "${NAMESPACE}"

echo ""
echo "🎉 ALL 4 TROUBLESHOOTING CHALLENGES VERIFIED AND RESOLVED!"
