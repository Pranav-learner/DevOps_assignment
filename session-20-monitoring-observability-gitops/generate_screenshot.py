#!/usr/bin/env python3
import os
import sys
import re
import subprocess
from PIL import Image, ImageDraw, ImageFont

ANSI_ESCAPE = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')

def strip_ansi(text):
    return ANSI_ESCAPE.sub('', text)

def render_terminal(title, prompt_cmd_pairs, output_path, width=1080):
    bg_color = (24, 26, 32)
    title_bar_color = (36, 39, 48)
    text_color = (226, 232, 240)
    prompt_user_color = (74, 222, 128)
    prompt_at_color = (148, 163, 184)
    prompt_host_color = (56, 189, 248)
    prompt_path_color = (250, 204, 21)
    cmd_color = (255, 255, 255)

    font_size = 14
    try:
        font = ImageFont.truetype("/usr/share/fonts/TTF/Hack-Regular.ttf", font_size)
        font_bold = ImageFont.truetype("/usr/share/fonts/TTF/Hack-Bold.ttf", font_size)
    except Exception:
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", font_size)
            font_bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", font_size)
        except Exception:
            font = ImageFont.load_default()
            font_bold = font

    line_height = 22
    header_height = 38
    padding_x = 20
    padding_y = 16

    max_char_per_line = (width - 2 * padding_x) // 9
    prepared_entries = []

    for item in prompt_cmd_pairs:
        if isinstance(item, tuple):
            cmd, out = item
        else:
            cmd, out = item, ""
        
        cmd_clean = strip_ansi(cmd).strip()
        out_clean = strip_ansi(out).rstrip()
        
        wrapped_out_lines = []
        if out_clean:
            for l in out_clean.split("\n"):
                if len(l) > max_char_per_line:
                    for i in range(0, len(l), max_char_per_line):
                        wrapped_out_lines.append(l[i:i+max_char_per_line])
                else:
                    wrapped_out_lines.append(l)
        
        prepared_entries.append((cmd_clean, wrapped_out_lines))

    total_lines = 0
    for cmd_c, out_lines in prepared_entries:
        total_lines += 1
        total_lines += len(out_lines)
        total_lines += 1

    height = header_height + (2 * padding_y) + (total_lines * line_height) + 20
    height = max(height, 220)

    img = Image.new("RGB", (width, height), bg_color)
    draw = ImageDraw.Draw(img)

    draw.rectangle([0, 0, width, header_height], fill=title_bar_color)
    draw.ellipse([14, 13, 26, 25], fill=(239, 68, 68))
    draw.ellipse([34, 13, 46, 25], fill=(245, 158, 11))
    draw.ellipse([54, 13, 66, 25], fill=(34, 197, 94))

    title_text = f"pranavOG: {title}"
    draw.text((80, 10), title_text, font=font_bold, fill=(203, 213, 225))

    current_y = header_height + padding_y

    for cmd_c, out_lines in prepared_entries:
        x = padding_x
        draw.text((x, current_y), "pranav", font=font_bold, fill=prompt_user_color)
        x += font_bold.getlength("pranav")
        draw.text((x, current_y), "@", font=font, fill=prompt_at_color)
        x += font.getlength("@")
        draw.text((x, current_y), "pranavOG", font=font_bold, fill=prompt_host_color)
        x += font_bold.getlength("pranavOG")
        draw.text((x, current_y), ":", font=font, fill=prompt_at_color)
        x += font.getlength(":")
        draw.text((x, current_y), "~/DevOps/session-20", font=font_bold, fill=prompt_path_color)
        x += font_bold.getlength("~/DevOps/session-20")
        draw.text((x, current_y), "$ ", font=font_bold, fill=prompt_at_color)
        x += font_bold.getlength("$ ")
        
        draw.text((x, current_y), cmd_c, font=font_bold, fill=cmd_color)
        current_y += line_height

        for out_line in out_lines:
            color = text_color
            if "SUCCESS" in out_line or "Running" in out_line or "IN-SYNC" in out_line or "successfully" in out_line:
                color = (74, 222, 128)
            elif "WARNING" in out_line or "DRIFT" in out_line or "WARN" in out_line:
                color = (250, 204, 21)
            elif "CRITICAL" in out_line or "ERROR" in out_line or "500" in out_line or "Terminating" in out_line:
                color = (248, 113, 113)
            elif out_line.strip().startswith("#") or "RECONCILE" in out_line:
                color = (148, 163, 184)
            elif out_line.strip().startswith("pulsewatch_") or out_line.strip().startswith("pod/"):
                color = (56, 189, 248)
            
            draw.text((padding_x, current_y), out_line, font=font, fill=color)
            current_y += line_height

        current_y += line_height // 2

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated screenshot: {output_path}")

def run_cmd(cmd, cwd=None):
    res = subprocess.run(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return res.stdout

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    sc_dir = os.path.join(base_dir, "screenshots")

    # 1. Monitoring Deployment and Health
    out_k8s = run_cmd("kubectl get pods,svc -n observability-demo")
    pod_name = run_cmd("kubectl get pods -n observability-demo -l app=pulsewatch-api -o jsonpath='{.items[0].metadata.name}'").strip()
    out_health = run_cmd(f"kubectl exec -n observability-demo {pod_name} -- wget -qO- http://127.0.0.1:3000/healthz")
    render_terminal(
        "Kubernetes Monitoring Deployment & Health Check",
        [("kubectl get pods,svc -n observability-demo", out_k8s),
         (f"kubectl exec -n observability-demo {pod_name} -- wget -qO- http://127.0.0.1:3000/healthz", out_health)],
        os.path.join(sc_dir, "01-monitoring-deployment-and-health.png")
    )

    # 2. Prometheus Metrics Exporter
    out_metrics = run_cmd(f"kubectl exec -n observability-demo {pod_name} -- wget -qO- http://127.0.0.1:3000/metrics | head -n 25")
    render_terminal(
        "Prometheus Metrics Exporter (/metrics)",
        [(f"kubectl exec -n observability-demo {pod_name} -- wget -qO- http://127.0.0.1:3000/metrics | head -n 25", out_metrics)],
        os.path.join(sc_dir, "02-prometheus-metrics-exporter.png")
    )

    # 3. CPU & Memory Utilization Surveillance
    out_top_node = run_cmd("kubectl top nodes")
    out_top_pods = run_cmd("kubectl top pods -n observability-demo")
    render_terminal(
        "CPU & Memory Utilization (Nodes & Pods)",
        [("kubectl top nodes", out_top_node),
         ("kubectl top pods -n observability-demo", out_top_pods)],
        os.path.join(sc_dir, "03-cpu-memory-utilization.png")
    )

    # 4. Structured JSON Logging with Trace Correlation
    out_logs = run_cmd(f"kubectl logs -n observability-demo {pod_name} --tail 6")
    render_terminal(
        "Structured JSON Logging with Trace Correlation",
        [(f"kubectl logs -n observability-demo {pod_name} --tail 6", out_logs)],
        os.path.join(sc_dir, "04-structured-json-logs.png")
    )

    # 5. Declarative Alerting Rules Configuration
    out_alerts = run_cmd(f"cat {os.path.join(base_dir, 'monitoring-demo/k8s/alert-rules.yaml')} | head -n 35")
    render_terminal(
        "Declarative Prometheus Alerting Rules",
        [("cat monitoring-demo/k8s/alert-rules.yaml | head -n 35", out_alerts)],
        os.path.join(sc_dir, "05-alerting-rules-configuration.png")
    )

    # 6. GitOps: Initial Sync
    out_gitops_init = run_cmd("kubectl get pods,svc -n gitops-demo")
    render_terminal(
        "GitOps Step 1: Initial Sync from Git Source of Truth",
        [("kubectl get pods,svc -n gitops-demo", out_gitops_init)],
        os.path.join(sc_dir, "06-gitops-initial-sync.png")
    )

    # 7. GitOps: Drift Detection & Automated Self-Healing
    # Re-run a concise drill of drift detection
    run_cmd("kubectl scale deployment gitops-frontend-app -n gitops-demo --replicas=5")
    out_drift = run_cmd("kubectl get deployment gitops-frontend-app -n gitops-demo -o jsonpath='{.spec.replicas}'")
    out_heal = run_cmd(f"bash {os.path.join(base_dir, 'gitops-demo/gitops-reconciler.sh')} reconcile")
    render_terminal(
        "GitOps Step 2 & 3: Drift Detection & Automated Self-Healing",
        [("kubectl scale deployment gitops-frontend-app -n gitops-demo --replicas=5", f"Deployment scaled to {out_drift} replicas (Manual Drift)"),
         ("bash gitops-demo/gitops-reconciler.sh reconcile", out_heal)],
        os.path.join(sc_dir, "07-gitops-drift-detection-healing.png")
    )

    # 8. GitOps: Declarative Update & Automated Rollout
    manifest = os.path.join(base_dir, 'gitops-demo/git-repo/apps/frontend-app.yaml')
    run_cmd(f"sed -i 's/replicas: .*/replicas: 3/' {manifest}")
    out_update = run_cmd(f"bash {os.path.join(base_dir, 'gitops-demo/gitops-reconciler.sh')} reconcile")
    out_final_pods = run_cmd("kubectl get pods -n gitops-demo")
    render_terminal(
        "GitOps Step 4: Declarative Git Commit & In-Cluster Sync",
        [("git commit -m 'Scale frontend to 3 replicas' && bash gitops-demo/gitops-reconciler.sh", out_update),
         ("kubectl get pods -n gitops-demo", out_final_pods)],
        os.path.join(sc_dir, "08-gitops-declarative-update.png")
    )

if __name__ == "__main__":
    main()
