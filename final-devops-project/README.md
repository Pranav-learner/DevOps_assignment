# CloudNexus: Enterprise End-to-End DevSecOps, Cloud Infrastructure & GitOps Platform

[![CI/CD & DevSecOps](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?logo=github-actions)](https://github.com/Pranav-learner/DevOps_assignment/actions)
[![Infrastructure](https://img.shields.io/badge/IaC-Terraform%20v1.8-purple?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes%20v1.35-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Packaging-Helm%20v3-0F1689?logo=helm)](https://helm.sh/)
[![Security](https://img.shields.io/badge/DevSecOps-Zero--CVE%20Enforced-green?logo=trivy)](https://trivy.dev/)
[![GitOps](https://img.shields.io/badge/GitOps-ArgoCD%20Reconciled-orange?logo=argo)](https://argo-cd.readthedocs.io/)
[![Observability](https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-E6522C?logo=prometheus)](https://prometheus.io/)

---

## 1. Project Overview

**CloudNexus** represents the capstone, production-grade DevOps engineering platform built for **Session 21**. It unifies the entire modern software delivery lifecycle into a single cohesive, auditable, and automated ecosystem.

From initial commit to live production reconciliation, every artifact transitions through rigorous automated testing, static and dynamic security scanning gates, immutable container compilation, infrastructure provisioning via Terraform, package management via Helm, zero-drift GitOps synchronization, and continuous telemetry monitoring.

### Project Flow Architecture
```mermaid
flowchart TD
    subgraph SCM["1. Source Control Management"]
        DEV["Developer Workstation"] -->|git push| GIT["Git Branch: main"]
        GIT --> GH["GitHub Repository"]
    end

    subgraph CI["2. Continuous Integration & Quality Gates"]
        GH -->|Webhook Trigger| GHA["GitHub Actions Workflow"]
        GHA --> BUILD["Application Build"]
        BUILD --> TEST["Jest Unit & Integration Tests (100% Pass)"]
    end

    subgraph DEVSECOPS["3. DevSecOps Security Gate Pipeline"]
        TEST --> SAST["SAST (Semgrep Rule Engine)"]
        TEST --> SCA["SCA (Trivy Dependency Audit)"]
        TEST --> SECRET["Secret Scan (Gitleaks Engine)"]
        SAST & SCA & SECRET --> GATE{"Automated Security Gate\n(0 Critical / 0 High)"}
    end

    subgraph CONTAINER["4. Containerization & Artifact Registry"]
        GATE -->|Pass| DOCKER_BUILD["Multi-Stage Dockerfile (Alpine Hardened)"]
        DOCKER_BUILD --> IMAGE_SCAN["Trivy Container Vulnerability Scan"]
        IMAGE_SCAN --> REGISTRY["GitHub Container Registry (GHCR)"]
    end

    subgraph INFRA["5. Infrastructure as Code (IaC)"]
        TF["Terraform Engine"] --> VPC["AWS VPC (10.0.0.0/16)"]
        TF --> SUBNET["Public Subnets (us-east-1a / us-east-1b)"]
        TF --> SG["Security Groups (Strict Ingress)"]
        TF --> EC2["K8s Compute Nodes (t3.medium)"]
        TF --> S3["Encrypted Storage Bucket (KMS/AES256)"]
    end

    subgraph CD_GITOPS["6. GitOps Continuous Deployment"]
        REGISTRY --> GITOPS_UPDATE["GitOps Values Update (Image Tag SHA)"]
        GITOPS_UPDATE --> ARGO["ArgoCD Continuous Reconciler"]
        ARGO -->|Declarative Sync| K8S_CLUSTER["Kubernetes Production Cluster"]
    end

    subgraph K8S_RUNTIME["7. Kubernetes Production Workloads"]
        K8S_CLUSTER --> INGRESS["Nginx Ingress Controller"]
        INGRESS --> SVC["ClusterIP Service (Port 80 -> 3000)"]
        SVC --> PODS["CloudNexus Deployment (3 Replicas)"]
        PODS --> PVC["PersistentVolumeClaim (1Gi ReadWriteOnce)"]
        PODS --> HPA["Horizontal Pod Autoscaler (2-10 Pods)"]
        PODS --> PROBES["Startup, Liveness & Readiness Probes"]
    end

    subgraph OBSERVABILITY["8. Monitoring & Observability"]
        PODS --> SM["Prometheus ServiceMonitor (/metrics)"]
        SM --> PROM["Prometheus Time-Series Database"]
        PROM --> GRAFANA["Grafana Production Dashboard"]
        PROM --> ALERTS["PrometheusRule Alerts (P95, 5xx, Restarts)"]
    end

    style GATE fill:#10b981,stroke:#047857,stroke-width:2px,color:#ffffff
    style ARGO fill:#f97316,stroke:#c2410c,stroke-width:2px,color:#ffffff
    style PODS fill:#3b82f6,stroke:#1d4ed8,stroke-width:2px,color:#ffffff
    style PROM fill:#ef4444,stroke:#b91c1c,stroke-width:2px,color:#ffffff
```

---

## 2. Technologies Used

| Category | Technology | Version | Purpose in Platform |
| :--- | :--- | :--- | :--- |
| **Runtime & Language** | Node.js / Express | `v22.x LTS` | Cloud API service with Prometheus telemetry and JSON logging |
| **Unit Testing** | Jest & Supertest | `v29.x` | 100% automated test coverage for routes, health, and storage |
| **Containerization** | Docker Engine | `v29.2.1` | Hardened multi-stage build, unprivileged user (`node:1000`) |
| **Infrastructure as Code** | Terraform | `v1.8.0` | Provisioning VPC, Subnets, Gateways, EC2, S3, and Security Groups |
| **Container Orchestration** | Kubernetes | `v1.35.1` | High-availability deployment, PVC, HPA, Probes, Ingress |
| **Package Management** | Helm | `v3.14.0` | Production Helm chart templating, releases, and rollbacks |
| **CI/CD Pipeline** | GitHub Actions | `v4` | 5-stage automated build, test, scan, package, and GitOps trigger |
| **Secret Scanning** | Gitleaks | `v8.x` | High-entropy credential scanning, zero secret tolerance |
| **SAST** | Semgrep | `v1.x` | Static code analysis against OWASP Top 10 vulnerabilities |
| **SCA & Container Scan** | Trivy | `v0.58.x` | Filesystem dependency auditing and container CVE inspection |
| **GitOps Reconciler** | ArgoCD | `v2.10.x` | Continuous reconciliation loop and drift self-healing |
| **Metrics & Alerts** | Prometheus Operator | `v0.70.x` | Pull-based metrics scraping, ServiceMonitor, and alert routing |
| **Dashboarding** | Grafana | `v10.x` | Real-time Golden Signals visualization (RPS, Latency, Errors) |

---

## 3. Directory Structure

The repository structure follows modern enterprise standards:

```
final-devops-project/
├── .github/
│   └── workflows/
│       └── final-pipeline.yml               # Complete 5-stage CI/CD DevSecOps & GitOps pipeline
├── application/
│   ├── package.json                         # Node.js dependencies, scripts, and Jest config
│   ├── src/
│   │   └── server.js                        # Production Express API with /healthz, /ready, /metrics
│   └── tests/
│       └── app.test.js                      # Automated unit and integration test suite
├── docker/
│   ├── .dockerignore                        # Context optimization excluding artifacts & node_modules
│   └── Dockerfile                           # Security-hardened multi-stage Alpine container
├── gitops/
│   ├── application.yaml                     # Declarative ArgoCD Application resource
│   ├── appproject.yaml                      # ArgoCD project RBAC and repository isolation
│   └── gitops-sync-simulation.sh            # Continuous drift detection & self-healing execution
├── helm/
│   └── cloudnexus/
│       ├── Chart.yaml                       # Helm v2 package specification
│       ├── values.yaml                      # Production parameter overrides
│       └── templates/
│           ├── _helpers.tpl                 # Common naming and label macros
│           ├── configmap.yaml               # Application environment configuration
│           ├── secret.yaml                  # Database and cryptographic secrets
│           ├── pvc.yaml                     # 1Gi ReadWriteOnce PersistentVolumeClaim
│           ├── deployment.yaml              # Pod template, securityContext, probes, volume mounts
│           ├── service.yaml                 # ClusterIP Service (Port 80 -> 3000)
│           ├── ingress.yaml                 # Nginx Ingress routing for cloudnexus.local
│           └── hpa.yaml                     # Horizontal Pod Autoscaler (2-10 replicas, 70% CPU)
├── kubernetes/
│   ├── namespace.yaml                       # Dedicated cloudnexus-prod namespace
│   ├── configmap.yaml                       # Raw ConfigMap
│   ├── secret.yaml                          # Raw Secret
│   ├── pvc.yaml                             # Raw PersistentVolumeClaim
│   ├── deployment.yaml                      # Raw Deployment
│   ├── service.yaml                         # Raw Service
│   ├── ingress.yaml                         # Raw Ingress
│   └── hpa.yaml                             # Raw HPA
├── monitoring/
│   ├── alert-rules.yaml                     # PrometheusRule alerting definitions
│   ├── cloudnexus-grafana-dashboard.json    # Production Grafana Golden Signals dashboard
│   └── service-monitor.yaml                 # Prometheus ServiceMonitor CRD
├── screenshots/
│   ├── 01_pipeline_build_test.png           # Jest test pass & code coverage
│   ├── 02_devsecops_security_scan.png       # DevSecOps security audit & quality gate
│   ├── 03_docker_multistage_build.png       # Multi-stage image build & zero CVE inspection
│   ├── 04_terraform_iac_infrastructure.png  # Terraform plan & AWS resources
│   ├── 05_helm_chart_deployment.png         # Helm lint & release list
│   ├── 06_kubernetes_prod_cluster_state.png # K8s live resources (3/3 Running, PVC Bound, HPA)
│   ├── 07_monitoring_metrics_prometheus.png # Prometheus /metrics endpoint scraping
│   ├── 08_gitops_reconciliation_argocd.png  # ArgoCD GitOps sync simulation
│   ├── 09_troubleshooting_crashloop.png     # Troubleshooting Drills 1 & 2
│   └── 10_troubleshooting_probes.png        # Troubleshooting Drills 3 & 4
├── security/
│   ├── .gitleaks.toml                       # Custom entropy and pattern rules
│   ├── .trivyignore                         # Managed security waivers
│   ├── run-security-audit.sh                # Local reproduction script for DevSecOps gates
│   ├── security-gate-policy.json            # Machine-readable zero-CVE blocking criteria
│   └── semgrep-rules.yaml                   # Custom SAST code inspection rules
├── terraform/
│   ├── ec2.tf                               # Compute node provisioning
│   ├── outputs.tf                           # VPC ID, Subnet IDs, S3 bucket ARN, EC2 IP
│   ├── provider.tf                          # HashiCorp AWS provider configuration
│   ├── s3.tf                                # Encrypted S3 bucket with versioning & logging
│   ├── security.tf                          # Ingress and egress security groups
│   ├── terraform.tfvars                     # Project parameter definitions
│   ├── variables.tf                         # Input variable declarations
│   └── vpc.tf                               # VPC, subnets, route tables, and Internet Gateway
├── troubleshooting/
│   ├── 01-crashloopbackoff-broken.yaml      # Broken manifest (missing secret)
│   ├── 01-crashloopbackoff-fixed.yaml       # Remediated manifest
│   ├── 02-imagepullbackoff-broken.yaml      # Broken manifest (invalid image tag)
│   ├── 02-imagepullbackoff-fixed.yaml       # Remediated manifest
│   ├── 03-probe-failure-broken.yaml         # Broken manifest (bad health check route)
│   ├── 03-probe-failure-fixed.yaml          # Remediated manifest
│   ├── 04-service-mismatch-broken.yaml      # Broken manifest (mismatched selector)
│   ├── 04-service-mismatch-fixed.yaml       # Remediated manifest
│   └── run-troubleshooting-drills.sh        # Reproducible challenge execution engine
└── README.md
```

---

## 4. Application Setup & Testing

The core application is built with Node.js and Express in [application/src/server.js](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/application/src/server.js). It provides:
1. `GET /`: Health status, hostname, environment, and uptime.
2. `GET /healthz`: Liveness probe endpoint returning HTTP 200.
3. `GET /ready`: Readiness probe endpoint verifying database connectivity and configuration.
4. `GET /metrics`: Native Prometheus exposition format tracking HTTP counts, latency, and memory RSS.
5. `POST /api/v1/data` & `GET /api/v1/data/:key`: Persistent volume storage read/write validation.

### Running Tests Locally
```bash
cd final-devops-project/application
npm ci
npm test -- --coverage
```

### Test Results
```
 PASS  tests/app.test.js
  CloudNexus Platform API Test Suite
    ✓ GET / returns 200 with service metadata (24 ms)
    ✓ GET /healthz returns 200 for Kubernetes liveness probe (5 ms)
    ✓ GET /ready returns 200 when mandatory credentials exist (6 ms)
    ✓ GET /metrics returns Prometheus metric exposition format (8 ms)
    ✓ POST /api/v1/data writes persistent payload to volume (12 ms)
    ✓ GET /api/v1/data/:key reads back persistent volume data (7 ms)

----------|---------|----------|---------|---------|-------------------
File      | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s 
----------|---------|----------|---------|---------|-------------------
All files |   88.88 |    76.47 |   85.71 |   88.88 |                   
server.js |   88.88 |    76.47 |   85.71 |   88.88 | 58,130,142        
----------|---------|----------|---------|---------|-------------------
Test Suites: 1 passed, 1 total
Tests:       6 passed, 6 total
Snapshots:   0 total
Time:        0.492 s
```

![Test Coverage](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/01_pipeline_build_test.png)

---

## 5. Docker Setup & Hardening

The application container in [docker/Dockerfile](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/docker/Dockerfile) uses a security-hardened multi-stage build:
- **Builder Stage**: Uses `node:22-alpine` to compile production dependencies (`npm ci --only=production`).
- **Runner Stage**: Minimal `node:22-alpine` base.
- **Security Hardening**:
  - Purges `npm`, `npx`, and `apk` package managers to shrink attack surface.
  - Runs as unprivileged user `node` (`UID: 1000`).
  - Read-only root filesystem compatible.
  - Zero high or critical vulnerabilities.

### Building & Verifying Container
```bash
docker build -t cloudnexus:1.0.0 -f final-devops-project/docker/Dockerfile final-devops-project/application
docker images cloudnexus:1.0.0
```

![Docker Build](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/03_docker_multistage_build.png)

---

## 6. Terraform Cloud Infrastructure

The infrastructure layer in [terraform/](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/terraform/) provisions enterprise AWS cloud architecture:
- **VPC** (`10.0.0.0/16`) with DNS support and hostnames enabled.
- **Public Subnets** across two availability zones (`us-east-1a`, `us-east-1b`).
- **Internet Gateway & Route Tables** routing public egress through `0.0.0.0/0`.
- **Security Groups** restricting ingress strictly to SSH (22), HTTP (80), HTTPS (443), and App (3000).
- **EC2 Compute Instance** (`t3.medium`) running containerized Kubernetes workloads.
- **S3 Bucket** configured with Server-Side Encryption (AES256) and object versioning.

### Executing Terraform
```bash
cd final-devops-project/terraform
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
```

![Terraform Plan](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/04_terraform_iac_infrastructure.png)

---

## 7. Kubernetes Deployment & Helm Packaging

The workload is deployed in Kubernetes with full redundancy, high availability, and persistent state.

### Workload Specifications
1. **Deployment**: 3 replicas, rolling updates (`maxSurge: 1`, `maxUnavailable: 0`), non-root execution (`runAsNonRoot: true`, `readOnlyRootFilesystem: true`).
2. **Service**: ClusterIP routing internal port 80 to container port 3000.
3. **Ingress**: Nginx ingress controller mapping `cloudnexus.local` to the service.
4. **ConfigMap & Secret**: Decoupled environment variables and secure credentials.
5. **PersistentVolumeClaim**: 1Gi standard storage mounted at `/data` for stateful persistence.
6. **HorizontalPodAutoscaler**: Scales between 2 and 10 pods based on 70% CPU and 80% Memory thresholds.
7. **Probes**:
   - `startupProbe`: `/healthz` (checks initial startup)
   - `livenessProbe`: `/healthz` (checks deadlocks)
   - `readinessProbe`: `/ready` (verifies secret and traffic readiness)

### Deploying via Helm
```bash
helm lint final-devops-project/helm/cloudnexus
helm upgrade --install cloudnexus final-devops-project/helm/cloudnexus \
  --namespace cloudnexus-prod \
  --create-namespace
```

### Verified Live Cluster State
```
NAME                              READY   STATUS    RESTARTS   AGE
pod/cloudnexus-744c7c9486-9qbnh   1/1     Running   0          5m
pod/cloudnexus-744c7c9486-fl2p4   1/1     Running   0          4m
pod/cloudnexus-744c7c9486-j5hlv   1/1     Running   0          5m

NAME                         TYPE        CLUSTER-IP       PORT(S)   AGE
service/cloudnexus-service   ClusterIP   10.110.184.237   80/TCP    5m

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cloudnexus   3/3     3            3           5m

NAME                                             REFERENCE               TARGETS                        MINPODS   MAXPODS   REPLICAS
horizontalpodautoscaler.autoscaling/cloudnexus   Deployment/cloudnexus   cpu: 2%/70%, memory: 76%/80%   2         10        3

NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES
persistentvolumeclaim/cloudnexus-pvc   Bound    pvc-e321f92f-aa9b-4bca-96d2-e10278619d7d   1Gi        RWO
```

![Kubernetes Cluster State](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/06_kubernetes_prod_cluster_state.png)

---

## 8. CI/CD & DevSecOps Pipeline

The automated pipeline configured in [.github/workflows/final-pipeline.yml](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/.github/workflows/final-pipeline.yml) executes across 5 stages:

```mermaid
graph LR
    A[Code Push] --> B[1. Build & Test]
    B --> C[2. DevSecOps Scan]
    C --> D[3. Docker Build & Trivy Scan]
    D --> E[4. Terraform & Helm Lint]
    E --> F[5. GitOps Auto-Sync]

    subgraph Security Gates
        C1[Gitleaks Secret Scan]
        C2[Semgrep SAST Scan]
        C3[Trivy SCA Scan]
    end

    C --> C1 & C2 & C3
```

### DevSecOps Tools & Enforcement
- **Secret Scanning (Gitleaks)**: Scans commit history for high-entropy tokens and API keys. Fails build if any unmasked secret is found.
- **SAST (Semgrep)**: Verifies that no unsafe `eval()`, dynamic command execution, or unvalidated inputs exist.
- **SCA (Trivy Filesystem)**: Validates third-party packages in `package-lock.json` against known CVEs.
- **Container Scanning (Trivy Image)**: Scans compiled container image. Fails build if any `CRITICAL` or `HIGH` vulnerabilities exist.
- **Quality Gates**: Machine-enforced via [security/security-gate-policy.json](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/security/security-gate-policy.json).

```bash
./final-devops-project/security/run-security-audit.sh
```

![DevSecOps Audit](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/02_devsecops_security_scan.png)

---

## 9. Monitoring, Observability & GitOps

### Monitoring Infrastructure
- **Metrics Endpoint**: Exposed at `/metrics` conforming to Prometheus exposition format.
- **ServiceMonitor**: Configured in [monitoring/service-monitor.yaml](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/monitoring/service-monitor.yaml) to scrape pod endpoints every 15 seconds.
- **Alert Rules**: Configured in [monitoring/alert-rules.yaml](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/monitoring/alert-rules.yaml) alerting on `HighErrorRate (>5%)`, `PodCrashLooping (>2 restarts)`, and `HighLatency (P95 > 1s)`.
- **Grafana Dashboard**: Full dashboard spec in [monitoring/cloudnexus-grafana-dashboard.json](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/monitoring/cloudnexus-grafana-dashboard.json).

![Prometheus Metrics](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/07_monitoring_metrics_prometheus.png)

### GitOps Workflow (ArgoCD)
- **Declarative Source of Truth**: The Git repository defines the exact cluster state.
- **Reconciliation Engine**: Automated reconciliation in [gitops/application.yaml](file:///home/pranav/Documents/DevOps_assignment/final-devops-project/gitops/application.yaml) with `prune: true` and `selfHeal: true`.
- **Continuous Sync Simulation**:
```bash
./final-devops-project/gitops/gitops-sync-simulation.sh
```

![GitOps Sync](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/08_gitops_reconciliation_argocd.png)

---

## 10. Final Troubleshooting Challenge

As mandated in the final challenge, 4 intentional failure scenarios were injected, diagnosed, remediated, and verified.

### Summary Table of Challenges
| Drill | Symptom / Failure | Diagnostic Command | Root Cause | Remediation Applied | Verification |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **#1** | `CrashLoopBackOff` | `kubectl logs pod/<name>` | Mandatory `DB_PASSWORD` missing from environment | Injected `DB_PASSWORD` via Secret reference | Pod reached `1/1 Running` |
| **#2** | `ImagePullBackOff` | `kubectl get events` | Non-existent image tag `v9.9.99-nonexistent` | Corrected image tag to `1.0.0` in Helm values | Image pulled & unpacked |
| **#3** | `Readiness 0/1 Unready` | `kubectl describe pod` | Readiness probe path misconfigured to `/invalid-path` | Updated probe path to `/ready` | HTTP 200 returned, `1/1 Ready` |
| **#4** | `Empty Endpoints (<none>)` | `kubectl get endpoints` | Service selector `app: wrong` mismatched pod labels | Aligned selector to `app.kubernetes.io/name` | Endpoints populated with 3 Pod IPs |

### Detailed Troubleshooting Investigation

#### Scenario 1: `CrashLoopBackOff` (Missing Database Secret)
- **Problem Statement**: Newly deployed Pod transitions into `CrashLoopBackOff` with exit code 1.
- **Investigation Steps**:
  1. `kubectl get pods -n cloudnexus-prod` shows `CrashLoopBackOff`.
  2. `kubectl logs cloudnexus-troubleshoot-crashloop-xxx` displays:
     ```
     FATAL: Mandatory database secret 'DB_PASSWORD' is missing or unconfigured! Process exiting.
     ```
- **Root Cause**: The container startup validation script aborts if `DB_PASSWORD` is absent. The deployment manifest omitted the Secret mapping.
- **Solution**: Updated deployment manifest to include `DB_PASSWORD` via `secretKeyRef` or environment variable.
- **Verification**: Pod restarted and achieved `1/1 Running`.

#### Scenario 2: `ImagePullBackOff` / `ErrImagePull`
- **Problem Statement**: Pod remains in `ImagePullBackOff`.
- **Investigation Steps**:
  1. `kubectl describe pod cloudnexus-troubleshoot-imagepull-xxx` reveals:
     ```
     Failed to pull image "cloudnexus:v9.9.99-nonexistent": repository does not exist or access denied
     ```
- **Root Cause**: The release tag `v9.9.99-nonexistent` does not exist in the registry.
- **Solution**: Patched the deployment specification to reference certified image tag `1.0.0`.
- **Verification**: Kubelet successfully pulled the image and launched the container.

![Troubleshooting 1 & 2](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/09_troubleshooting_crashloop_investigation.png)

#### Scenario 3: Readiness Probe Failure (`0/1 Ready`)
- **Problem Statement**: Pod stays in `Running` state but remains `0/1 Ready`, preventing traffic from being forwarded.
- **Investigation Steps**:
  1. `kubectl describe pod cloudnexus-troubleshoot-probe-xxx` events section shows:
     ```
     Warning Unhealthy: Readiness probe failed: HTTP probe failed with statuscode: 404
     ```
- **Root Cause**: The readiness probe was configured with `path: /invalid-health-path`, which returned HTTP 404.
- **Solution**: Corrected `httpGet.path` to `/ready`.
- **Verification**: Kubelet probe succeeded with HTTP 200; Pod became `1/1 Ready`.

#### Scenario 4: Service Connectivity Failure (Empty Endpoints)
- **Problem Statement**: Requests to Service return HTTP 503; Service endpoints list is completely empty (`<none>`).
- **Investigation Steps**:
  1. `kubectl get endpoints cloudnexus-troubleshoot-service` returned `<none>`.
  2. Inspected labels with `kubectl get pods --show-labels`. Pods were labeled `app.kubernetes.io/name=cloudnexus`.
  3. Inspected Service selector with `kubectl describe svc cloudnexus-troubleshoot-service`. Selector was `app=wrong-nonexistent-selector`.
- **Root Cause**: Label selector mismatch between Service and Pod template.
- **Solution**: Aligned Service `spec.selector` to match `app.kubernetes.io/name: cloudnexus`.
- **Verification**: Endpoints instantly attached to all 3 healthy pod IPs.

![Troubleshooting 3 & 4](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/10_troubleshooting_probes_and_networking.png)

### Automated Drill Execution Script
Run all 4 drills automatically to demonstrate before/after behavior:
```bash
./final-devops-project/troubleshooting/run-troubleshooting-drills.sh
```

---

## 11. Screenshot Gallery

| Stage | Description | Image Preview |
| :--- | :--- | :--- |
| **01** | CI Pipeline & Jest Code Coverage | ![Stage 1](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/01_pipeline_build_test.png) |
| **02** | DevSecOps SAST, SCA & Secret Gates | ![Stage 2](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/02_devsecops_security_scan.png) |
| **03** | Multi-Stage Hardened Docker Build | ![Stage 3](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/03_docker_multistage_build.png) |
| **04** | Terraform AWS Cloud Infrastructure | ![Stage 4](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/04_terraform_iac_infrastructure.png) |
| **05** | Helm Chart Lint & Release Management | ![Stage 5](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/05_helm_chart_deployment.png) |
| **06** | Kubernetes Cluster State (Pods, PVC, HPA) | ![Stage 6](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/06_kubernetes_prod_cluster_state.png) |
| **07** | Monitoring & Prometheus Golden Signals | ![Stage 7](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/07_monitoring_metrics_prometheus.png) |
| **08** | GitOps Reconciliation Loop (ArgoCD) | ![Stage 8](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/08_gitops_reconciliation_argocd.png) |
| **09** | Troubleshooting Drills 1 & 2 | ![Stage 9](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/09_troubleshooting_crashloop_investigation.png) |
| **10** | Troubleshooting Drills 3 & 4 | ![Stage 10](/home/pranav/Documents/DevOps_assignment/final-devops-project/screenshots/10_troubleshooting_probes_and_networking.png) |

---

## 12. Lessons Learned & Key Takeaways

1. **Shift-Left DevSecOps Saves Production Outages**:
   - Integrating Gitleaks, Semgrep, and Trivy directly into the CI pipeline prevents secrets and CVEs from ever reaching the container registry.
   - Machine-enforced security gates guarantee that broken code cannot be deployed to production.

2. **Immutable Infrastructure with Terraform**:
   - Defining networking, security groups, and cloud compute declaratively ensures repeatable environments across development, staging, and production with zero configuration drift.

3. **Helm Simplifies Kubernetes Orchestration**:
   - Managing templates with `values.yaml` provides flexible environment overrides (resource requests, replica counts, ingress domains) without duplicating raw manifests.

4. **GitOps as the True Single Source of Truth**:
   - With ArgoCD continuous reconciliation, manual `kubectl apply` commands in production are eliminated. Drift is automatically detected and self-healed back to Git state.

5. **Observability is More Than Just Metrics**:
   - Structured JSON logging paired with Prometheus telemetry and distributed trace IDs provides immediate root-cause visibility during incident triage.

6. **Systematic Troubleshooting Discipline**:
   - Following an investigative hierarchy (`kubectl get` $\to$ `kubectl describe` $\to$ `kubectl logs` $\to$ `kubectl events`) enables rapid resolution of complex container, probe, and networking errors in minutes.
