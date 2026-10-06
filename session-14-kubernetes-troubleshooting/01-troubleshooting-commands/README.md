# Kubernetes Troubleshooting — Diagnostic Commands Reference

**Author:** Pranav Gupta  
**Enrollment number:** 24BCS10237  
**Course:** SST DevOps & Cloud  
**Session:** 14 — Kubernetes Troubleshooting  
**Task:** 1 — Kubernetes Commands  

---

## 1. Overview

Effective Kubernetes troubleshooting follows a disciplined diagnostic workflow:
$$\text{Observe Symptoms} \rightarrow \text{Inspect Resources} \rightarrow \text{Check Events \& Logs} \rightarrow \text{Isolate Root Cause} \rightarrow \text{Remediate}$$

The standard `kubectl` CLI provides eight essential command primitives that form the backbone of any cluster diagnostic session.

---

## 2. Command Reference & Practical Diagnostics

### 2.1 `kubectl get` & `kubectl get -o wide`
- **Purpose:** Fast overview of resource state, replica counts, readiness, and network identities.
- **Why `-o wide` is critical:** Appends `IP` (Pod IP), `NODE` (host machine placement), and `NOMINATED NODE` without requiring a full `describe`.
- **Advanced formatting:**
  ```bash
  # Custom columns for quick audits:
  kubectl get pods -o custom-columns="NAME:.metadata.name,IP:.status.podIP,NODE:.spec.nodeName,STATUS:.status.phase"

  # JSONPath querying:
  kubectl get pod diagnostic-demo -o jsonpath='{.status.podIP}'
  ```

**Evidence Screenshot:**
![01-cmd-get-and-wide.png](../screenshots/01-cmd-get-and-wide.png)

---

### 2.2 `kubectl describe`
- **Purpose:** Deep inspection of resource specification, runtime state, and associated control-plane events.
- **Key Sections to Check:**
  - `Conditions`: `PodScheduled`, `Initialized`, `ContainersReady`, `Ready`.
  - `Containers -> State`: `Running`, `Waiting` (e.g. `CrashLoopBackOff`, `ErrImagePull`), `Terminated` (with Exit Code & Reason).
  - `Events`: Chronological audit log showing scheduler assignments, image pulls, probe failures, and mount errors.

**Evidence Screenshot:**
![02-cmd-describe.png](../screenshots/02-cmd-describe.png)

---

### 2.3 `kubectl logs`
- **Purpose:** Inspect stdout/stderr streams emitted by applications.
- **Troubleshooting Flags:**
  - `kubectl logs <pod> -c <container>`: Selects specific container in a multi-container pod.
  - `kubectl logs <pod> --previous`: Reads logs from the **previously crashed instance** (essential for diagnosing `CrashLoopBackOff`!).
  - `kubectl logs <pod> -f --tail=20`: Follows live logs from the last 20 lines.

### 2.4 `kubectl exec`
- **Purpose:** Execute commands directly inside running containers for interactive network, process, or filesystem diagnostics.
- **Common commands:**
  ```bash
  # Check active processes:
  kubectl exec diagnostic-demo -c web -- ps aux

  # Verify local loopback HTTP endpoint:
  kubectl exec diagnostic-demo -c web -- wget -q -O- http://localhost:80

  # Inspect DNS resolver configuration:
  kubectl exec diagnostic-demo -c web -- cat /etc/resolv.conf
  ```

**Evidence Screenshot:**
![03-cmd-logs-and-exec.png](../screenshots/03-cmd-logs-and-exec.png)

---

### 2.5 `kubectl events`
- **Purpose:** Cluster-wide or namespace-wide event stream sorted by time.
- **Syntax:**
  ```bash
  kubectl get events --field-selector involvedObject.name=diagnostic-demo --sort-by=".metadata.creationTimestamp"
  ```

### 2.6 `kubectl explain`
- **Purpose:** Built-in interactive API schema documentation directly in the terminal. No browser needed.
- **Syntax:**
  ```bash
  kubectl explain pods.spec.containers.resources
  kubectl explain pods.spec.containers.livenessProbe
  ```

### 2.7 `kubectl top`
- **Purpose:** Real-time resource metrics (CPU and Memory) collected via `metrics-server`.
- **Syntax:**
  ```bash
  kubectl top node
  kubectl top pod diagnostic-demo --containers
  ```

**Evidence Screenshot:**
![04-cmd-events-explain-top.png](../screenshots/04-cmd-events-explain-top.png)

---

## 3. Quick Reference Matrix

| Command | Best Used For | What It Tells You |
|---|---|---|
| `kubectl get -o wide` | First triage step | Which node is the pod on? What is its internal IP? Is it Ready? |
| `kubectl describe` | State & lifecycle errors | Why is it failing? Did volume mount fail? Did probe fail? What do events say? |
| `kubectl logs --previous` | CrashLoopBackOff | Why did the process terminate? Stack trace / unhandled exception. |
| `kubectl exec -it` | Live connectivity check | Can the pod resolve DNS? Can it reach database IP/port? |
| `kubectl events` | Historical audit | When was the container scheduled, killed, or rescheduled? |
| `kubectl top` | Performance bottleneck | Is the container hitting memory limits (OOMKilled) or throttling CPU? |
| `kubectl explain` | YAML validation | What is the exact casing, structure, and type of an API field? |
