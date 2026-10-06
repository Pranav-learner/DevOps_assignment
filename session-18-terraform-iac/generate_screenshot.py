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
    prompt_user_color = (74, 222, 128)   # Green
    prompt_at_color = (148, 163, 184)    # Gray
    prompt_host_color = (56, 189, 248)   # Sky blue
    prompt_path_color = (250, 204, 21)   # Yellow
    cmd_color = (255, 255, 255)
    comment_color = (148, 163, 184)

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

    # Calculate canvas height
    total_lines = 0
    for cmd_c, out_lines in prepared_entries:
        total_lines += 1  # prompt + cmd
        total_lines += len(out_lines)
        total_lines += 1  # gap

    height = header_height + (2 * padding_y) + (total_lines * line_height) + 20
    height = max(height, 220)

    img = Image.new("RGB", (width, height), bg_color)
    draw = ImageDraw.Draw(img)

    # Window header bar
    draw.rectangle([0, 0, width, header_height], fill=title_bar_color)

    # Traffic light dots
    draw.ellipse([14, 13, 26, 25], fill=(239, 68, 68))   # Red
    draw.ellipse([34, 13, 46, 25], fill=(245, 158, 11))  # Yellow
    draw.ellipse([54, 13, 66, 25], fill=(34, 197, 94))   # Green

    # Window title centered
    title_text = f"pranavOG: {title}"
    draw.text((80, 10), title_text, font=font_bold, fill=(203, 213, 225))

    # Render entries
    current_y = header_height + padding_y

    for cmd_c, out_lines in prepared_entries:
        x = padding_x
        # Render prompt: pranav@pranavOG:~/.../terraform-s3-demo$
        draw.text((x, current_y), "pranav", font=font_bold, fill=prompt_user_color)
        x += font_bold.getlength("pranav")
        draw.text((x, current_y), "@", font=font, fill=prompt_at_color)
        x += font.getlength("@")
        draw.text((x, current_y), "pranavOG", font=font_bold, fill=prompt_host_color)
        x += font_bold.getlength("pranavOG")
        draw.text((x, current_y), ":", font=font, fill=prompt_at_color)
        x += font.getlength(":")
        draw.text((x, current_y), "~/DevOps/session-18/terraform-s3-demo", font=font_bold, fill=prompt_path_color)
        x += font_bold.getlength("~/DevOps/session-18/terraform-s3-demo")
        draw.text((x, current_y), "$ ", font=font_bold, fill=prompt_at_color)
        x += font_bold.getlength("$ ")
        
        # Command text
        draw.text((x, current_y), cmd_c, font=font_bold, fill=cmd_color)
        current_y += line_height

        # Output text lines
        for out_line in out_lines:
            color = text_color
            if out_line.strip().startswith("Plan:") or "Success!" in out_line or "complete!" in out_line:
                color = (74, 222, 128)  # Bright Green
            elif "will be created" in out_line or out_line.strip().startswith("+"):
                color = (56, 189, 248)  # Light Cyan
            elif "will be destroyed" in out_line or out_line.strip().startswith("-"):
                color = (248, 113, 113) # Light Red
            elif out_line.strip().startswith("#") or out_line.strip().startswith("Initializing"):
                color = (148, 163, 184) # Muted gray
            
            draw.text((padding_x, current_y), out_line, font=font, fill=color)
            current_y += line_height

        current_y += line_height // 2

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated screenshot: {output_path}")

def run_cmd(cmd, cwd):
    res = subprocess.run(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return res.stdout

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    tf_dir = os.path.join(base_dir, "terraform-s3-demo")
    sc_dir = os.path.join(base_dir, "screenshots")

    # 1. Terraform Init
    out_ver = run_cmd("terraform -version", tf_dir)
    out_init = run_cmd("terraform init", tf_dir)
    render_terminal(
        "Terraform Init & Provider Resolution",
        [("terraform -version", out_ver), ("terraform init", out_init)],
        os.path.join(sc_dir, "01-terraform-init.png")
    )

    # 2. Terraform Fmt & Validate
    out_fmt = run_cmd("terraform fmt", tf_dir)
    if not out_fmt.strip():
        out_fmt = "(All files already formatted according to canonical HCL style)"
    out_val = run_cmd("terraform validate", tf_dir)
    render_terminal(
        "Terraform Fmt & Validation Check",
        [("terraform fmt", out_fmt), ("terraform validate", out_val)],
        os.path.join(sc_dir, "02-terraform-fmt-validate.png")
    )

    # 3. Terraform Plan
    out_plan = run_cmd("terraform plan -no-color", tf_dir)
    render_terminal(
        "Terraform Execution Plan Generation",
        [("terraform plan", out_plan)],
        os.path.join(sc_dir, "03-terraform-plan.png")
    )

    # 4. Terraform Apply
    out_apply = run_cmd("terraform apply -auto-approve -no-color", tf_dir)
    render_terminal(
        "Terraform Apply & S3 Bucket Creation",
        [("terraform apply -auto-approve", out_apply)],
        os.path.join(sc_dir, "04-terraform-apply.png")
    )

    # 5. Terraform Show
    out_show = run_cmd("terraform show -no-color", tf_dir)
    render_terminal(
        "Terraform Show & Live State Inspection",
        [("terraform show", out_show)],
        os.path.join(sc_dir, "05-terraform-show.png")
    )

    # 6. Terraform Output
    out_out = run_cmd("terraform output -no-color", tf_dir)
    out_json = run_cmd("terraform output -json", tf_dir)
    render_terminal(
        "Terraform Output Queries (Text & JSON)",
        [("terraform output", out_out), ("terraform output -json", out_json)],
        os.path.join(sc_dir, "06-terraform-output.png")
    )

    # 7. Terraform Destroy
    out_dest = run_cmd("terraform destroy -auto-approve -no-color", tf_dir)
    render_terminal(
        "Terraform Destroy & Infrastructure Teardown",
        [("terraform destroy -auto-approve", out_dest)],
        os.path.join(sc_dir, "07-terraform-destroy.png")
    )

    # 8. State Lifecycle Verification
    out_state = run_cmd("terraform state list", tf_dir)
    if not out_state.strip():
        out_state = "(No resources found in state - teardown complete and verified)"
    render_terminal(
        "Terraform State Clean Verification",
        [("terraform state list", out_state)],
        os.path.join(sc_dir, "08-terraform-clean-verification.png")
    )

if __name__ == "__main__":
    main()
