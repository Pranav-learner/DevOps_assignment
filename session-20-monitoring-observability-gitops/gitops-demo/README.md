# GitOps — Principles, Continuous Reconciliation & Hands-on Kubernetes Demo

## 1. What is GitOps?

**GitOps** is an operational framework and methodology that takes DevOps best practices used for application development (such as version control, collaboration, compliance, and CI/CD) and applies them to infrastructure automation and application delivery.

The term was coined in 2017 by **Alexis Richardson (CEO of Weaveworks)**. The foundational premise of GitOps is simple:

> **"Git is the single source of truth for declaratively describing the entire desired state of the system, and software agents automatically ensure that the live system matches that desired state."**

```
+-----------------------------------------------------------------------------------------+
|                                  THE 4 GITOPS PRINCIPLES                                |
+-----------------------------------------------------------------------------------------+
| 1. Declarative Descriptions  | The entire system is described declaratively in Git.     |
| 2. Versioned Desired State   | Desired state is versioned, immutable, and audited.      |
| 3. Automated Pull Sync       | Approved state changes are automatically applied.        |
| 4. Continuous Reconciliation | Software agents continuously reconcile drift.           |
+-----------------------------------------------------------------------------------------+
```

---

## 2. Core Concepts of GitOps

### 2.1 Git as the Single Source of Truth
- In traditional DevOps, deployments are performed imperatively by CI pipelines pushing commands (`kubectl apply`, `helm install`, `terraform apply`) using elevated cluster administrator credentials stored in CI secrets.
- In GitOps, **Git holds the entire desired system state**. No human engineer or CI runner executes imperative commands directly against the production Kubernetes API.
- All modifications (scaling replicas, updating container image tags, changing ingress hostnames, rotating config maps) must be committed to Git via **Pull Requests (PRs)**.
- Provides immediate auditability: `git log` shows exactly *who* changed *what*, *when*, and *why*, while `git revert` provides instant, atomic rollbacks.

### 2.2 Declarative Configuration
- **Imperative** (Forbidden in GitOps): Telling the system *how* to do something (`kubectl scale deployment web --replicas=5`).
- **Declarative** (Mandated in GitOps): Describing *what* the system should look like:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: web
  spec:
    replicas: 5
    template: ...
  ```
- Kubernetes YAML, Helm charts, and Kustomize overlays are natively declarative.

### 2.3 Continuous Reconciliation Loop & Drift Detection
The heart of GitOps is an in-cluster control loop:

$$\text{Drift} = |\text{Live Cluster State} - \text{Git Desired State}|$$

```
                           +---------------------------+
                           |  Git Repository (Desired) |
                           +-------------+-------------+
                                         |
                                         v
                         +-------------------------------+
                         | GitOps Reconciler / Controller|
                         +---------------+---------------+
                                         |
                       +-----------------+-----------------+
                       |                                   |
                       v                                   v
             [ No Drift Detected ]               [ Drift Detected! ]
               Cluster is in Sync                  Live != Desired
                                                           |
                                                           v
                                                 [ Auto-Reconciliation ]
                                                  Self-heal cluster to
                                                  match Git declaration
```

If a rogue operator imperatively modifies the cluster via `kubectl scale` or an attacker tampers with a deployment, the GitOps controller immediately detects the discrepancy and overwrites the live cluster to match Git.

---

## 3. GitOps Workflow: CI vs. CD Separation

GitOps strictly separates **Continuous Integration (CI)** from **Continuous Delivery (CD)**:

```
[ Developer ] 
      │
      │ 1. Git Push (App Code)
      ▼
[ CI Pipeline (GitHub Actions) ]
      │ - Run Unit & Integration Tests
      │ - Build & Scan Container Image
      │ - Push Image: `ghcr.io/org/app:v2.1.0`
      │
      │ 2. Update Manifest in Config Repo: `image: v2.1.0`
      ▼
[ GitOps Config Repository ] <──────────────────────────────────────+
      ▲                                                             │
      │ 3. Automated Pull Scrape                                    │
      ▼                                                             │
[ In-Cluster GitOps Agent (Argo CD / Flux) ]                        │
      │                                                             │
      │ 4. Reconcile & Rollout Deployment                           │
      ▼                                                             │
[ Kubernetes Cluster (Live State) ] ── 5. Continuous Drift Detection ┘
```

---

## 4. Kubernetes GitOps Controllers: Argo CD vs. Flux CD

| Feature | Argo CD | Flux CD |
|---|---|---|
| **Architecture** | Web UI + Application CRD controller | Set of composable Kubernetes controllers (Kustomize, Helm, Notification) |
| **User Interface** | Rich, interactive web dashboard visualizing resource health and git diffs | Primarily CLI-driven (`flux` CLI), optional community UI |
| **Multi-Tenancy** | Strong RBAC, Projects, Single Sign-On (SSO) | Native Kubernetes namespace isolation |
| **Ecosystem** | Argo Rollouts (Canary/Blue-Green), Argo Workflows | Flagger (Progressive Delivery / Canary) |
| **CNCF Status** | Graduated Project | Graduated Project |

---

## 5. Hands-on GitOps Demo Breakdown

The demonstration implemented in [`gitops-reconciler.sh`](gitops-reconciler.sh) and verified via [`test-gitops-workflow.sh`](test-gitops-workflow.sh) proves the core GitOps lifecycle on a live Kubernetes cluster:

### Step 1: Initial GitOps Synchronization
- Desired State in [`git-repo/apps/frontend-app.yaml`](git-repo/apps/frontend-app.yaml): `replicas: 2`.
- GitOps Controller reconciles cluster: provisions Deployment and Service. Verified 2 active pods.

### Step 2: Manual Tampering & Drift Injection
- Simulates unauthorized operator intervention:
  ```bash
  kubectl scale deployment gitops-frontend-app -n gitops-demo --replicas=5
  ```
- Cluster diverged to 5 pods.

### Step 3: Drift Detection & Automated Self-Healing
- Reconciler compares Git (`replicas=2`) with Cluster (`replicas=5`).
- Flags warning: `[!] WARNING: CONFIGURATION DRIFT DETECTED!`.
- Immediately issues self-healing reconciliation, terminating 3 unauthorized pods and restoring 2 replicas.

### Step 4: Declarative Git Commit & Automated Rollout
- Developer updates Git manifest: `replicas: 3`.
- Reconciler detects new desired state, applies update, and verifies graceful scale-out to 3 replicas.
