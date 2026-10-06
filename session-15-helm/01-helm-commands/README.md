# Session 15 — Task 1: Essential Helm CLI Commands

This directory documents hands-on execution and technical reference for all core Helm commands required for cloud-native package management in Kubernetes.

---

## Command Reference Summary

| Command | Subcommands / Flags Covered | Primary Purpose |
|---|---|---|
| `helm repo` | `add`, `list`, `update`, `remove` | Manage remote chart repositories (HTTP/OCI) |
| `helm search` | `repo`, `hub` | Discover charts in local repo cache or Artifact Hub |
| `helm create` | `<chart-name>` | Scaffold a standard Kubernetes Helm chart directory structure |
| `helm install` | `<release-name> <chart> [-n <ns>] [--set] [-f]` | Render templates, package, and deploy manifests to Kubernetes |
| `helm list` | `-n <ns>`, `-A`, `-a`, `-q` | List deployed, failed, or uninstalled releases |
| `helm status` | `<release-name> [-n <ns>] [--show-desc]` | Display current release metadata, notes, and resource status |
| `helm get` | `values`, `manifest`, `all`, `notes`, `hooks` | Fetch rendered manifests, user-supplied values, or chart notes |
| `helm upgrade` | `<release-name> <chart> [--set] [-f] [--reuse-values]` | Apply delta changes, increment revision, trigger zero-downtime rolling update |
| `helm history` | `<release-name> [-n <ns>]` | View chronological revision history and descriptions |
| `helm rollback` | `<release-name> <revision> [-n <ns>]` | Rollback release to a target historical revision |
| `helm uninstall` | `<release-name> [-n <ns>] [--keep-history]` | Delete all rendered Kubernetes resources for a given release |

---

## 1. `helm repo` — Repository Management

Helm charts are distributed via chart repositories (web servers hosting a `chart.tgz` package and an `index.yaml` catalog).

### Syntax & Flags
```bash
helm repo add <repo-name> <repo-url>
helm repo list
helm repo update [repo-name]
helm repo remove <repo-name>
```

### Execution & Output
```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories

$ helm repo list
NAME   	URL                               
bitnami	https://charts.bitnami.com/bitnami

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
```

---

## 2. `helm search` — Discovering Charts

Helm supports querying both local repository indexes (`helm search repo`) and Artifact Hub's global registry (`helm search hub`).

### Syntax & Flags
```bash
helm search repo <keyword>
helm search hub <keyword>
```

### Execution & Output
```bash
$ helm search repo bitnami/nginx | head -n 4
NAME                            	CHART VERSION	APP VERSION	DESCRIPTION                                       
bitnami/nginx                   	25.2.1       	1.31.6     	NGINX Open Source is a web server that can be a...
bitnami/nginx-ingress-controller	12.0.7       	1.13.1     	NGINX Ingress Controller is an Ingress controll...
bitnami/nginx-intel             	2.1.15       	0.4.9      	DEPRECATED NGINX Open Source for Intel is a lig...

$ helm search hub redis | head -n 5
URL                                               	CHART VERSION            	APP VERSION         	DESCRIPTION                                       
https://artifacthub.io/packages/helm/magefleet-...	0.1.0                    	7.2                 	A Helm chart for Redis 7.2 with persistence and...
https://artifacthub.io/packages/helm/redis/redis  	0.1.1                    	6.0.8.9             	A Helm chart for Redis.                           
https://artifacthub.io/packages/helm/scalified-...	8.8.3                    	8.8.3               	Redis Helm Chart                                  
https://artifacthub.io/packages/helm/redis-arm/...	17.8.0                   	7.0.8               	Redis(R) is an open source, advanced key-value ...
```

---

## 3. `helm create` — Scaffolding a Chart

Generates an opinionated chart directory skeleton following official Helm community best practices.

### Syntax
```bash
helm create sample-app
```

### Generated Directory Layout
```
sample-app/
├── Chart.yaml              # Chart metadata (name, version, appVersion, type, dependencies)
├── values.yaml             # Default configuration values injected into templates
├── .helmignore             # Patterns to ignore when packaging chart tarballs
├── charts/                 # Subcharts / chart dependencies directory
└── templates/              # Go template files evaluated by Helm engine
    ├── _helpers.tpl        # Template partials and reusable named blocks
    ├── deployment.yaml     # Kubernetes Deployment manifest template
    ├── service.yaml        # Kubernetes Service manifest template
    ├── serviceaccount.yaml # Kubernetes ServiceAccount template
    ├── ingress.yaml        # Kubernetes Ingress template (disabled by default)
    ├── hpa.yaml            # Horizontal Pod Autoscaler template (disabled by default)
    ├── NOTES.txt           # Post-installation instructional output
    └── tests/
        └── test-connection.yaml  # Helm test pod manifest template
```

---

## 4. `helm install` — Deploying a Release

Renders the templates in the target chart with `values.yaml` and deploys the resulting Kubernetes objects.

### Syntax
```bash
helm install <release-name> <chart-path-or-repo> -n <namespace> [--create-namespace] [--set key=val] [-f custom-values.yaml]
```

### Execution & Output
```bash
$ helm install sample-release ./sample-app -n helm-practice --create-namespace
NAME: sample-release
LAST DEPLOYED: Tue Oct  6 23:53:57 2026
NAMESPACE: helm-practice
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace helm-practice -l "app.kubernetes.io/name=sample-app,app.kubernetes.io/instance=sample-release" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace helm-practice $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace helm-practice port-forward $POD_NAME 8080:$CONTAINER_PORT
```

---

## 5. `helm list` — Listing Releases

Queries the cluster storage (Kubernetes Secrets with type `helm.sh/release.v1`) to enumerate deployed charts.

### Syntax
```bash
helm list -n <namespace>
helm list -A                 # Across all namespaces
helm list --all              # Include failed or uninstalled releases
```

### Execution & Output
```bash
$ helm list -n helm-practice
NAME          	NAMESPACE    	REVISION	UPDATED                                	STATUS  	CHART           	APP VERSION
sample-release	helm-practice	1       	2026-10-06 23:53:57.417709874 +0530 IST	deployed	sample-app-0.1.0	1.16.0     
```

---

## 6. `helm status` — Inspecting Release Status

Returns real-time deployment status, last deployed timestamp, active revision number, and rendered `NOTES.txt`.

### Syntax
```bash
helm status <release-name> -n <namespace>
```

### Execution & Output
```bash
$ helm status sample-release -n helm-practice
NAME: sample-release
LAST DEPLOYED: Tue Oct  6 23:53:57 2026
NAMESPACE: helm-practice
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace helm-practice -l "app.kubernetes.io/name=sample-app,app.kubernetes.io/instance=sample-release" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace helm-practice $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace helm-practice port-forward $POD_NAME 8080:$CONTAINER_PORT
```

---

## 7. `helm get` — Extracting Release Components

Allows inspection of individual internal parts of a release stored in cluster state.

### Subcommands
- `helm get values <release>`: Shows only user-supplied override values (`-a` displays all computed values).
- `helm get manifest <release>`: Shows all fully rendered Kubernetes YAML manifests sent to the API server.
- `helm get notes <release>`: Shows only rendered `NOTES.txt`.
- `helm get all <release>`: Shows values, manifests, hooks, and notes combined.

### Execution & Output
```bash
$ helm get values sample-release -n helm-practice
USER-SUPPLIED VALUES:
null

$ helm get manifest sample-release -n helm-practice | head -n 22
---
# Source: sample-app/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sample-release-sample-app
  labels:
    helm.sh/chart: sample-app-0.1.0
    app.kubernetes.io/name: sample-app
    app.kubernetes.io/instance: sample-release
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
automountServiceAccountToken: true
---
# Source: sample-app/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-release-sample-app
  labels:
    helm.sh/chart: sample-app-0.1.0
    app.kubernetes.io/name: sample-app
    app.kubernetes.io/instance: sample-release
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
```

---

## 8. `helm upgrade` — Applying Rolling Updates

Re-evaluates the templates with new parameters and applies updates cleanly without destroying unmodified resources.

### Syntax
```bash
helm upgrade <release-name> <chart> -n <namespace> [--set key=val] [-f values.yaml]
```

### Execution & Output
```bash
$ helm upgrade sample-release ./sample-app -n helm-practice --set replicaCount=3 --set image.tag=1.25-alpine
Release "sample-release" has been upgraded. Happy Helming!
NAME: sample-release
LAST DEPLOYED: Tue Oct  6 23:54:51 2026
NAMESPACE: helm-practice
STATUS: deployed
REVISION: 2
```

---

## 9. `helm history` — Auditing Revisions

Displays the complete audit trail of every modification made to the release.

### Syntax
```bash
helm history <release-name> -n <namespace>
```

### Execution & Output
```bash
$ helm history sample-release -n helm-practice
REVISION	UPDATED                 	STATUS    	CHART           	APP VERSION	DESCRIPTION     
1       	Tue Oct  6 23:53:57 2026	superseded	sample-app-0.1.0	1.16.0     	Install complete
2       	Tue Oct  6 23:54:51 2026	deployed  	sample-app-0.1.0	1.16.0     	Upgrade complete
```

---

## 10. `helm rollback` — Restoring a Known-Good Revision

Reverts the entire release back to any specified previous revision number. Helm increments the revision counter and applies the exact manifest configuration of the selected historical revision.

### Syntax
```bash
helm rollback <release-name> <target-revision-number> -n <namespace>
```

### Execution & Output
```bash
$ helm rollback sample-release 1 -n helm-practice
Rollback was a success! Happy Helming!

$ helm history sample-release -n helm-practice
REVISION	UPDATED                 	STATUS    	CHART           	APP VERSION	DESCRIPTION     
1       	Tue Oct  6 23:53:57 2026	superseded	sample-app-0.1.0	1.16.0     	Install complete
2       	Tue Oct  6 23:54:51 2026	superseded	sample-app-0.1.0	1.16.0     	Upgrade complete
3       	Tue Oct  6 23:54:58 2026	deployed  	sample-app-0.1.0	1.16.0     	Rollback to 1   
```

---

## 11. `helm uninstall` — Deleting a Release

Removes all associated Kubernetes objects managed by the release, leaving the cluster clean.

### Syntax
```bash
helm uninstall <release-name> -n <namespace>
```

### Execution & Output
```bash
$ helm uninstall sample-release -n helm-practice
release "sample-release" uninstalled

$ helm list -n helm-practice
NAME	NAMESPACE	REVISION	UPDATED	STATUS	CHART	APP VERSION
```

---

## Evidence Screenshots

Terminal evidence screenshots for Task 1 are stored in [`screenshots/`](../screenshots/):
1. `01-cmd-repo-and-search.png`: `helm repo add`, `list`, `update`, and `helm search`.
2. `02-cmd-create-and-structure.png`: `helm create sample-app` and directory tree layout.
3. `03-cmd-install-and-list.png`: `helm install sample-release` and `helm list`.
4. `04-cmd-status-and-get.png`: `helm status` and `helm get` (values, manifest, notes).
5. `05-cmd-upgrade-and-history.png`: `helm upgrade` and `helm history`.
6. `06-cmd-rollback-and-uninstall.png`: `helm rollback` and `helm uninstall`.
