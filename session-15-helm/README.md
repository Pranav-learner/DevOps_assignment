# Session 15: Helm — Kubernetes Package Management & Rollback Operations

| Metadata | Details |
|---|---|
| **Author** | Pranav Gupta |
| **Enrollment Number** | 24BCS10237 |
| **Operating System** | Garuda Linux (zen kernel 7.1.8-zen1-3-zen) |
| **Cluster Engine** | Minikube v1.38.1 (`docker` driver) |
| **Kubernetes Version** | v1.35.1 |
| **Helm Version** | v3.17.1 |

---

## Executive Summary

This repository contains the complete implementation, real-cluster execution evidence, and architectural documentation for **Session 15: Helm**. All tasks were executed live against a local Kubernetes cluster with zero mockups.

1. **Task 1: Helm CLI Command Mastery**: Hands-on execution of all 11 required command suites (`repo`, `search`, `create`, `install`, `list`, `status`, `get`, `upgrade`, `history`, `rollback`, `uninstall`), including internal release state inspection.
2. **Task 2: End-to-End Rollback Lifecycle**: Comprehensive execution of the complete rollback drill ($v1 \to v2 \to \text{Verify} \to v3 \text{ [Broken]} \to \text{Verify Degradation} \to \text{Rollback to } v2 \to \text{Verify Recovery}$), proving zero-downtime automated recovery.
3. **Task 3: Enterprise Mini-Project (CloudStore Platform)**: Production-grade Helm chart featuring decoupled ConfigMaps, encrypted Secrets, Layer 7 Ingress routing, dual health probes (`liveness` & `readiness`), Horizontal Pod Autoscaler (HPA v2), multi-environment profiles (`values-staging.yaml`, `values-prod.yaml`), automated operational scripts, and verification curl tests.

---

## Repository Structure

```
session-15-helm/
├── 01-helm-commands/
│   ├── sample-app/                  # Scaffolded and customized Helm chart
│   └── README.md                    # In-depth guide to all 11 command categories
├── 02-helm-rollback/
│   ├── web-portal/                  # Rollback test chart
│   ├── values-v1.yaml               # Revision 1 baseline values (nginx:1.24, 2 replicas)
│   ├── values-v2.yaml               # Revision 2 feature values (nginx:1.25, 3 replicas)
│   ├── values-v3.yaml               # Revision 3 broken values (bad image tag)
│   └── README.md                    # Complete rollback lifecycle walkthrough
├── 03-mini-project/
│   ├── cloudstore-chart/            # Enterprise multi-tier e-commerce Helm chart
│   │   ├── Chart.yaml               # Chart metadata (v1.0.0, appVersion 2.5.0)
│   │   ├── values.yaml              # Development values
│   │   ├── values-staging.yaml      # Staging profile
│   │   ├── values-prod.yaml         # Production HA & autoscaling profile
│   │   └── templates/               # Kubernetes resource templates
│   ├── scripts/
│   │   ├── deploy.sh                # Lint, template, and deploy
│   │   ├── upgrade.sh               # Zero-downtime rolling upgrade
│   │   ├── rollback.sh              # Safe rollback to target revision
│   │   ├── verify.sh                # Release health & HTTP traffic verification
│   │   └── cleanup.sh               # Teardown and cleanup
│   └── README.md                    # Enterprise mini-project documentation
├── screenshots/                     # 16 High-fidelity terminal screenshots
└── README.md                        # Master Session 15 documentation
```

---

## Visual Screenshot Evidence Gallery

All 16 high-resolution terminal captures are stored in [`screenshots/`](screenshots/):

### Task 1: Helm Commands
| # | File | Focus Area | Command Covered |
|---|---|---|---|
| 01 | [`01-cmd-repo-and-search.png`](screenshots/01-cmd-repo-and-search.png) | Repositories & Discovery | `helm repo add`, `list`, `update` & `helm search` |
| 02 | [`02-cmd-create-and-structure.png`](screenshots/02-cmd-create-and-structure.png) | Chart Scaffolding | `helm create sample-app` & directory structure |
| 03 | [`03-cmd-install-and-list.png`](screenshots/03-cmd-install-and-list.png) | Deployment & Listing | `helm install` & `helm list -n helm-practice` |
| 04 | [`04-cmd-status-and-get.png`](screenshots/04-cmd-status-and-get.png) | State Inspection | `helm status` & `helm get` (values, manifest, notes) |
| 05 | [`05-cmd-upgrade-and-history.png`](screenshots/05-cmd-upgrade-and-history.png) | Upgrades & Audit | `helm upgrade --set` & `helm history` |
| 06 | [`06-cmd-rollback-and-uninstall.png`](screenshots/06-cmd-rollback-and-uninstall.png) | Rollback & Teardown | `helm rollback` & `helm uninstall` |

### Task 2: Helm Rollback Lifecycle
| # | File | Step | Description |
|---|---|---|---|
| 07 | [`07-rollback-step1-install-v1.png`](screenshots/07-rollback-step1-install-v1.png) | **Step 1: Install v1** | Initial deployment of Revision 1 (2 replicas, `nginx:1.24-alpine`) |
| 08 | [`08-rollback-step2-upgrade-v2.png`](screenshots/08-rollback-step2-upgrade-v2.png) | **Step 2 & 3: Upgrade v2 & Verify** | Rolling upgrade to Revision 2 (3 replicas, `nginx:1.25-alpine`) |
| 09 | [`09-rollback-step3-upgrade-v3.png`](screenshots/09-rollback-step3-upgrade-v3.png) | **Step 4 & 5: Upgrade v3 & Verify Failure** | Deployment degraded: Invalid image tag triggers `ImagePullBackOff` |
| 10 | [`10-rollback-step4-rollback-v2.png`](screenshots/10-rollback-step4-rollback-v2.png) | **Step 6: Rollback to v2** | `helm rollback web-portal 2` restores previous stable revision |
| 11 | [`11-rollback-step5-history-verification.png`](screenshots/11-rollback-step5-history-verification.png) | **Step 7: Final Verification** | Restored 3 healthy pods, zero downtime, Revision 4 recorded |

### Task 3: Mini-Project (CloudStore Platform)
| # | File | Focus Area | Description |
|---|---|---|---|
| 12 | [`12-miniproject-chart-lint-template.png`](screenshots/12-miniproject-chart-lint-template.png) | Quality Assurance | `helm lint` validation & dry-run manifest rendering |
| 13 | [`13-miniproject-staging-install.png`](screenshots/13-miniproject-staging-install.png) | Staging Deployment | Deployment with `values-staging.yaml` profile |
| 14 | [`14-miniproject-prod-install-hpa.png`](screenshots/14-miniproject-prod-install-hpa.png) | Production Deployment | Deployment with `values-prod.yaml` (3 replicas, HPA, Ingress) |
| 15 | [`15-miniproject-upgrade-canary.png`](screenshots/15-miniproject-upgrade-canary.png) | Zero-Downtime Upgrade | Rolling upgrade to `nginx:1.27-alpine` & live HTTP curl test |
| 16 | [`16-miniproject-rollback-verification.png`](screenshots/16-miniproject-rollback-verification.png) | Remediation & Teardown | Rollback to Revision 2, endpoint verification, clean uninstall |

---

## Core Helm Technical Architecture

```mermaid
flowchart TD
    User["DevOps Engineer / CI Pipeline"] -->|helm install / upgrade| HelmCLI["Helm Client v3.17.1"]
    
    subgraph Engine["Helm Templating Engine"]
        ChartYAML["Chart.yaml"] --> Engine
        ValuesYAML["values.yaml / overrides"] --> Engine
        Templates["templates/*.yaml + _helpers.tpl"] --> Engine
    end
    
    HelmCLI --> Engine
    Engine -->|Rendered Kubernetes Manifests| KubeAPI["kube-apiserver"]
    
    subgraph K8sState["Kubernetes Cluster"]
        SecretStorage["Secret: sh.helm.release.v1.{release}.v{n}"]
        Workloads["Deployments, Services, Ingress, HPA"]
    end
    
    KubeAPI -->|Stores Release Metadata| SecretStorage
    KubeAPI -->|Applies Workloads| Workloads
    
    style User fill:#1e293b,stroke:#3b82f6,color:#fff
    style HelmCLI fill:#1e293b,stroke:#06b6d4,color:#fff
    style Engine fill:#1e293b,stroke:#8b5cf6,color:#fff
    style KubeAPI fill:#1e293b,stroke:#10b981,color:#fff
    style K8sState fill:#1e293b,stroke:#f59e0b,color:#fff
```

---

## Key Helm Concepts & SRE Best Practices

1. **No Tiller in Helm v3**: Helm 3 interacts directly with the Kubernetes API using client credentials. Release state is stored as versioned Secrets directly in the release namespace (`sh.helm.release.v1.<release-name>.v<revision>`).
2. **Atomic Upgrades & Timeouts**: In production CI/CD, always use `--atomic --timeout 5m` with `helm upgrade` to automatically trigger a rollback if any Pod fails readiness probes.
3. **Values Hierarchy**:
   $$\text{Default } \texttt{values.yaml} < \text{Environment Profile } (\texttt{-f values-prod.yaml}) < \text{CLI Overrides } (\texttt{--set key=value})$$
4. **Rollback Immutability**: A rollback never destroys history; it appends a new revision with the identical manifest state of the selected historical revision, guaranteeing full auditability.
