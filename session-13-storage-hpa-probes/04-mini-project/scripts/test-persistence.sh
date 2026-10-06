#!/usr/bin/env bash
set -e

NS="taskflow-prod"
echo "=== Step 1: Locating PostgreSQL Pod ==="
DB_POD=$(kubectl get pods -n "$NS" -l app=postgres-db -o jsonpath='{.items[0].metadata.name}')
echo "Active DB Pod: $DB_POD"

echo "=== Step 2: Creating Table & Inserting Records ==="
kubectl exec -n "$NS" "$DB_POD" -- psql -U taskflow -d taskflow -c "
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    event VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO audit_logs (event) VALUES ('Session 13 Mini Project Initialized');
INSERT INTO audit_logs (event) VALUES ('Storage PVC Binding Verified');
INSERT INTO audit_logs (event) VALUES ('Pre-Pod Deletion Data Checkpoint');
SELECT * FROM audit_logs;
"

echo "=== Step 3: Simulating Pod Crash / Node Failure (Force Deleting Pod) ==="
kubectl delete pod -n "$NS" "$DB_POD" --grace-period=0 --force
echo "Old Pod $DB_POD terminated."

echo "=== Step 4: Waiting for Kubernetes Deployment to Reschedule New Pod ==="
kubectl wait --for=condition=Ready pod -l app=postgres-db -n "$NS" --timeout=60s
NEW_DB_POD=$(kubectl get pods -n "$NS" -l app=postgres-db -o jsonpath='{.items[0].metadata.name}')
echo "New Replacement Pod: $NEW_DB_POD"

echo "=== Step 5: Querying Database to Prove Persistent Data Survived ==="
kubectl exec -n "$NS" "$NEW_DB_POD" -- psql -U taskflow -d taskflow -c "
SELECT * FROM audit_logs;
INSERT INTO audit_logs (event) VALUES ('Post-Restart Persistence Confirmed');
SELECT count(*) AS total_records_preserved FROM audit_logs;
"

echo "=== SUCCESS: Data survived across pod recreation via PersistentVolume! ==="
