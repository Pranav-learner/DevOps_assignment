# DevOps Homework — Section B

All sixteen DevOps homework tasks, each in its own folder with its own `README.md`.

| | |
|---|---|
| **Author** | Pranav Gupta |
| **Enrollment number** | 24BCS10237 |

---

## Submission index

The submission form has one field per topic. Each links to that topic's `README.md`:

| # | Topic | Folder | Source handout |
|---|---|---|---|
| 1 | **Docker Images** | [`Docker_Images/`](Docker_Images/README.md) | Docker Multi-Stage Build Homework |
| 2 | **Docker Fundamentals** | [`Docker_Fundamentals/`](Docker_Fundamentals/README.md) | Docker Homework Tasks — Hello World Applications |
| 3 | **Git and GitHub** | [`Git_and_GitHub/`](Git_and_GitHub/README.md) | Git Homework Tasks |
| 4 | **Shell Scripting** | [`Shell_Scripting/`](Shell_Scripting/README.md) | Shell Scripting Homework Task |
| 5 | **Docker Networking** | [`Docker_Networking/`](Docker_Networking/README.md) | Docker Networking & Volume Homework |
| 6 | **Linux Fundamentals** | [`Linux_Fundamentals/`](Linux_Fundamentals/README.md) | Linux Homework Tasks |
| 7 | **Networking** | [`Networking/`](Networking/README.md) | Networking Homework Tasks |
| 8 | **Kubernetes Services** | [`session-11-kubernetes-services/`](session-11-kubernetes-services/README.md) | Session 11 — Kubernetes Services |
| 9 | **Kubernetes Core Objects** | [`session10-k8s-core-objects/`](session10-k8s-core-objects/README.md) | Session 10 — Kubernetes Core Objects |
| 10 | **Kubernetes Fundamentals** | [`session9-k8s/`](session9-k8s/README.md) | Session 9 — Kubernetes Fundamentals & Architecture |
| 11 | **Ingress, ConfigMaps & Secrets** | [`session-12-ingress-configmaps-secrets/`](session-12-ingress-configmaps-secrets/README.md) | Session 12 — ConfigMaps, Secrets & Ingress |
| 12 | **Kubernetes Storage, HPA & Probes** | [`session-13-storage-hpa-probes/`](session-13-storage-hpa-probes/README.md) | Session 13: Kubernetes Storage, HPA & Probes |
| 13 | **Kubernetes Troubleshooting** | [`session-14-kubernetes-troubleshooting/`](session-14-kubernetes-troubleshooting/README.md) | Session 14 — Kubernetes Troubleshooting |
| 14 | **Helm** | [`session-15-helm/`](session-15-helm/README.md) | Session 15 — Helm |
| 15 | **CI/CD & GitHub Actions** | [`session-16-cicd-github-actions/`](session-16-cicd-github-actions/README.md) | Session 16 — CI/CD & GitHub Actions |
| 16 | **Complete CI/CD & DevSecOps** | [`session-17-cicd-devsecops/`](session-17-cicd-devsecops/README.md) | Session 17 — Complete CI/CD & DevSecOps |
| 17 | **Terraform & Infrastructure as Code** | [`session-18-terraform-iac/`](session-18-terraform-iac/README.md) | Session 18 — Terraform & Infrastructure as Code |
| 18 | **Cloud & Terraform in Action** | [`session-19-cloud-terraform-in-action/`](session-19-cloud-terraform-in-action/README.md) | Session 19 — Cloud & Terraform in Action |

---

## What is in each folder

### 1. [Docker Images](Docker_Images/README.md)
Multi-stage Dockerfile built and run on **port 8080**, displaying *"Hello World from Docker multi-stage build"*, verified with `docker ps`, `curl` and a browser screenshot. Includes a measured size comparison against a single-stage build of the same app — **472 MB → 19.5 MB (96% smaller)**. Plus three separate application deployments (Node.js, Python, Java).

### 2. [Docker Fundamentals](Docker_Fundamentals/README.md)
Six containerised Hello World web apps — `nodejs-app`, `python-app`, `java-app`, `Apache-app`, `React-app`, `nginx-app` — each with its own Dockerfile, built, run and verified. All six confirmed returning HTTP 200 with browser screenshots. The React app is a real Vite production build compiled inside the image.

### 3. [Git and GitHub](Git_and_GitHub/README.md)
`git commit -a -m` vs `git commit -m`, demonstrated with the case that actually distinguishes them (untracked vs modified-tracked files). Then a full cherry-pick exercise: 4 commits on `main`, 3 on a feature branch, one specific commit cherry-picked across and verified — including proof that the picked commit gets a **new SHA**.

### 4. [Shell Scripting](Shell_Scripting/README.md)
`sysinfo.sh` — a system information script using variables, `read -p`, `mkdir`, `touch`, `date`, `hostname`, `whoami`, `df`, `ps` and `>` output redirection, with a full annotated run.

### 5. [Docker Networking](Docker_Networking/README.md)
Three containers across three networks with the backend dual-homed, including a **connectivity matrix that proves the frontend cannot reach the database**. Apache on the host network. A bind mount edited live, with `StartedAt` timestamps proving the container was never restarted. Plus a real overlay network created in swarm mode with 3 replicas and VIP-based service discovery.

### 6. [Linux Fundamentals](Linux_Fundamentals/README.md)
Soft vs hard links demonstrated at the inode level, including the decisive delete-the-original test. `adduser` vs `useradd` with proof of what each does and does not create. `journalctl` run against a real systemd host with a live service. A worked command cheat sheet across 12 categories.

### 7. [Networking](Networking/README.md)
Twelve categories of networking commands — `ip`, `route`, `ping`, `traceroute`, `dig`/`nslookup`/`host`, `ss`/`netstat`, `nc`, `curl`/`wget`, `arp`, `whois`, `tcpdump` — each executed, with output and an explanation of what it means and when to reach for it.

### 8. [Kubernetes Services](session-11-kubernetes-services/README.md)
All five Service types — **ClusterIP, NodePort, LoadBalancer, Headless and ExternalName** — on a Minikube cluster, sharing one Nginx Pod named `web`. ClusterIP was tested with `curl` from inside the cluster. NodePort and LoadBalancer were opened in the browser through `minikube service --url`. Headless DNS returned the Pod IP directly, and ExternalName returned a CNAME to `google.com`. Each Service folder has its YAML, terminal and browser screenshots, and a README.

### 9. [Kubernetes Core Objects](session10-k8s-core-objects/README.md)
All five core workload objects — **Pod, ReplicaSet, Deployment, StatefulSet and DaemonSet** — applied and verified on Minikube, using the reference repository's manifests **byte-for-byte** (MD5-verified, including its `deamonset.yml` spelling). Highlights proven with real output: a two-container Pod at `2/2` sharing one IP; **ReplicaSet self-healing** (deleted Pod replaced under a new name in 6s); the Deployment → ReplicaSet → Pod chain confirmed through `ownerReferences`, plus scaling 3→5→3; a StatefulSet with stable ordinals `mysql-0/1/2`, ordered start-up and **one Bound 5Gi PVC per Pod**; and a DaemonSet whose `DESIRED 1` is derived from the cluster's single node. 21 terminal screenshots.

### 10. [Kubernetes Fundamentals](session9-k8s/README.md)
Minikube and `kubectl` installation verified, then the **full cluster lifecycle executed for real** — `minikube status` with every component `Running`, a graceful `minikube stop` showing all components `Stopped`, and a genuine `minikube start` bringing it back (including Minikube's own client/server version-skew warning). Plus a documented breakdown of the **Control Plane** (`kube-apiserver`, `etcd`, `kube-scheduler`, `kube-controller-manager`) and **Worker Node** (`kubelet`, `kube-proxy`, CRI/containerd, Pod) components, with an end-to-end trace of what happens during `kubectl apply`. 5 screenshots.

### 11. [Ingress, ConfigMaps & Secrets](session-12-ingress-configmaps-secrets/README.md)
All **14 Session 12 tasks** executed on Minikube with the NGINX Ingress Controller. Highlights: the **ConfigMap immobility drill** — patched to `staging` while the running Pod still reported `production`, fixed by a zero-downtime `rollout restart`; the **trailing-newline Secret bug** exposed byte-by-byte with `xxd` (`...ZK` vs `...ZQ=`); combined `envFrom` + `secretKeyRef` injection verified inside the container; and **Layer 7 routing** proven four ways — path-based (`/` → nginx, `/api/` → backend), host-based virtual hosts on one IP, hybrid host+path, and **TLS termination** returning `HTTP 200` over a TLSv1.3 handshake with a self-signed `CN=campus.local` certificate. Ends with scripted deploy/teardown. 17 screenshots.

### 12. [Kubernetes Storage, HPA & Probes](session-13-storage-hpa-probes/README.md)
All **Session 13 tasks and mini-project** executed on Minikube. Highlights: **Kubernetes Storage deep dive** (`emptyDir` multi-container data sharing, `hostPath` worker node filesystem mount, manual `PersistentVolume` + `PersistentVolumeClaim` binding, and automated on-demand dynamic provisioning via `StorageClass`); **Horizontal Pod Autoscaling (HPA)** drill using `hpa.yml` — baseline metrics verified via `metrics-server`, surge traffic simulated with multi-thread load generators driving CPU to 151%, automatic scale-out from **1 to 3 to 6 replicas**, and graceful cool-down; **Container Health Probes** — `startupProbe` absorbing slow bootstrap latency, `readinessProbe` dynamically gating Service Endpoints, and `livenessProbe` catching container crashes and self-healing; and the **TaskFlow Cloud Platform Mini-Project** — multi-tier architecture with dynamic PVC-backed PostgreSQL 17 database proving **zero data loss across forced pod deletion**, autoscaled API tier scaling from **2 to 7 replicas**, and zero-downtime endpoint isolation. 16 terminal screenshots.

### 13. [Kubernetes Troubleshooting](session-14-kubernetes-troubleshooting/README.md)
All **Session 14 diagnostic commands, common failure mode playbooks, and the incident remediation mini-project** executed on Minikube. Highlights: **Diagnostic CLI mastery** across `kubectl get -o wide`, `kubectl describe`, `kubectl logs --previous`, `kubectl exec`, `kubectl events`, `kubectl explain`, and `kubectl top`; **8 Common failure mode triage drills** (`CrashLoopBackOff`, `ImagePullBackOff`/`ErrImagePull`, `Pending`, `ContainerCreating`, Service connectivity label selector mismatch, CoreDNS resolution, Pod networking `127.0.0.1` vs `0.0.0.0` binding, and `CreateContainerConfigError` secret key mismatch) with root cause isolation and verified fixes; and **Operation Triage: ShopSphere Outage Mini-Project** — triaging a multi-tier platform outage with 4 concurrent failures, executing automated triage scripts, applying full remediation, and proving recovery with live HTTP curl tests. 16 terminal screenshots.

### 14. [Helm](session-15-helm/README.md)
All **Session 15 package management tasks, rollback lifecycles, and enterprise mini-project** executed on Minikube with Helm v3.17.1. Highlights: **Helm CLI mastery** across all 11 core commands (`helm repo`, `helm search`, `helm create`, `helm install`, `helm list`, `helm status`, `helm get`, `helm upgrade`, `helm history`, `helm rollback`, and `helm uninstall`); **Complete Rollback Lifecycle Drill** ($v1 \to v2 \to \text{Verify} \to v3\text{ [Broken]} \to \text{Verify Degradation} \to \text{Rollback to } v2 \to \text{Verify Recovery}$) proving zero-downtime automated recovery from faulty releases; and the **CloudStore Platform Mini-Project** — enterprise multi-tier e-commerce Helm chart featuring decoupled ConfigMaps, encrypted Secrets, Layer 7 Ingress routing, dual health probes, Horizontal Pod Autoscaler (HPA v2 with CPU/memory targets), multi-environment profiles (`values-staging.yaml`, `values-prod.yaml`), automated scripts, and live HTTP verification tests. 16 terminal screenshots.

### 15. [CI/CD & GitHub Actions](session-16-cicd-github-actions/README.md)
Complete **CI/CD demo project powered by GitHub Actions** covering full theoretical depth (CI vs CD comparison, workflow architecture, jobs, runners, steps, secrets, artifacts, build, test, pipeline execution) and a hardened Node.js microservice (`TaskPulse API`). Highlights: **Continuous Integration (CI)** running static syntax linting, Jest unit tests, Supertest REST integration tests with **94.28% statement coverage**, and uploading coverage report artifacts; **Continuous Deployment (CD)** building a hardened multi-stage Docker container (non-root `node` user, built-in container healthchecks), registering image with GitHub Secrets, deploying to Minikube Kubernetes cluster in namespace `cicd-demo`, waiting for zero-downtime rollout completion, and verifying live HTTP endpoint traffic (`/` and `/health`). 8 terminal screenshots.

### 16. [Complete CI/CD & DevSecOps](session-17-cicd-devsecops/README.md)
Complete **CI/CD + DevSecOps demo project** implementing an automated 11-stage pipeline for a high-security microservice (`VaultShield API`). Highlights: **End-to-End Shift-Left Security** integrating **SAST** (Static Application Security Testing via Trivy Config scanning K8s manifests and Dockerfiles against CIS benchmarks), **SCA** (Software Composition Analysis via Trivy FS scanning third-party dependencies against CVE databases), **Secret Scanning** (Gitleaks scanning codebase, commits, and configs for leaked credentials), and **Container Image Vulnerability Scanning** (Trivy Image scanning multi-stage Alpine container layers); **Automated Security Gate** enforcing zero-tolerance policy (0 Critical, 0 High) and halting pipeline upon violations; **Zero-CVE Multi-Stage Dockerfile** stripping build tools (`npm`, `npx`, `apk`) and running unprivileged; **Kubernetes Pod Security Standard (Restricted)** deployment (`runAsNonRoot`, `readOnlyRootFilesystem`, `drop: [ALL]`); and fully automated bash runner scripts with live Minikube rollout and smoke test verification. 10 terminal screenshots.

### 17. [Terraform & Infrastructure as Code](session-18-terraform-iac/README.md)
Complete **Terraform IaC and AWS Cloud Architecture research project**. Highlights: **Terraform S3 Demo project** (`terraform-s3-demo/`) provisioning an enterprise-grade AWS S3 bucket with S3 Versioning, Server-Side Encryption (SSE-S3 AES-256), and S3 Public Access Block; complete lifecycle execution across all 8 Terraform phases (`terraform init`, `terraform fmt`, `terraform validate`, `terraform plan`, `terraform apply`, `terraform show`, `terraform output`, and `terraform destroy`) captured with live terminal execution evidence and clean state verification; and comprehensive deep-dive **AWS Cloud Services Research** (`aws-services/`) spanning **01. IAM** (Governance, Users, Groups, Roles, Policies, Least Privilege, Cross-account access), **02. EC2** (Compute, AMIs, Instance Types, Key Pairs, Security Groups, EBS, Lifecycle), **03. S3** (Storage classes, Versioning, Lifecycle policies, Encryption, Bucket policies), **04. VPC** (Networking, CIDR, Subnets, Route Tables, IGW, NAT Gateway, Security Groups vs NACLs), and **05. DynamoDB & RDS** (NoSQL vs Relational, Multi-AZ high availability, Read Replicas, Backups). 8 terminal screenshots.

### 18. [Cloud & Terraform in Action](session-19-cloud-terraform-in-action/README.md)
Complete **End-to-End Cloud Infrastructure as Code (IaC) project** provisioned using HashiCorp Terraform. Highlights: Multi-tier AWS cloud architecture spanning **Virtual Private Cloud (VPC)** (`10.0.0.0/16`), **Public Subnet** (`10.0.1.0/24`), **Internet Gateway (IGW)**, **Public Route Table** and association, stateful **Security Group** (HTTP 80 & SSH 22 ingress, all egress), **Amazon EC2 Compute instance** (`t2.micro`) bootstrapped via Cloud-Init User Data, and **Amazon S3 Object Storage bucket** with Server-Side Encryption (SSE-S3 AES-256), S3 Versioning, and S3 Public Access Block. Explicit resource dependencies demonstrated (`depends_on`), input variables with type constraints, outputs exporting computed endpoints, and complete lifecycle execution across all phases (`terraform init`, `fmt`, `validate`, `plan`, `apply`, `state list`, `state show`, `output`, and `destroy`). 8 terminal screenshots.

---

## How this work was done

Everything in these READMEs was **actually executed** on this machine, and the outputs are copied verbatim rather than written from memory. Where a command failed or behaved differently than the task text implies, that is documented honestly rather than papered over.

**Environment:**

| | |
|---|---|
| Host OS | Garuda Linux (zen kernel 7.1.8-zen1-3-zen) |
| Hostname / User | `pranavOG` / `pranav` |
| Docker | 29.2.1 |
| Minikube | v1.38.1 (`docker` driver) |
| Kubernetes | v1.35.1 |
| Git | 2.55.0 |
| Shell | Bash |
| Screenshots | Captured directly from terminal sessions on `pranav@pranavOG` |

**Evidence files.** Alongside each README, the folders contain the demo scripts and the complete unedited transcripts (`*-demo.sh`, `*-output.txt`), so every claim can be re-run and checked.

---

## Two notes on the handouts

Two tasks referenced material that was not included in the PDFs I was given. Rather than guess and risk answering the wrong question, both are flagged clearly in place:

1. **Networking, Task 1** refers to "commands and repo shared in devops-hero github repo" — no link was provided. The Networking README covers the standard Linux networking toolkit comprehensively instead.
2. **Docker Images, Task 1** says to clone "the repository containing the multi-stage Dockerfile" — no link was provided. A multi-stage application was written from scratch that satisfies every stated requirement (port 8080, the exact required output string, verified with `docker ps`).

If either repository is supplied, those sections can be re-run against it.

---

## Reproducing everything

Each folder's README contains the exact build/run/cleanup commands for that task. In general:

```bash
git clone <this-repo-url>
cd devops-homework

# Example: the multi-stage build
cd Docker_Images/multistage-app
docker build -t multistage-app:latest .
docker run -d --name multistage-demo -p 8080:8080 multistage-app:latest
curl http://localhost:8080/text
# -> Hello World from Docker multi-stage build
```
