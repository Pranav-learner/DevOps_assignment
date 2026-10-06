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
        total_lines += 1  # prompt + cmd
        total_lines += len(out_lines)
        total_lines += 1  # gap

    height = header_height + (2 * padding_y) + (total_lines * line_height) + 20
    height = max(height, 220)

    img = Image.new("RGB", (width, height), bg_color)
    draw = ImageDraw.Draw(img)

    # Window header bar
    draw.rectangle([0, 0, width, header_height], fill=title_bar_color)

    # Window controls
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
        draw.text((x, current_y), "~/DevOps/session-19-cloud-terraform", font=font_bold, fill=prompt_path_color)
        x += font_bold.getlength("~/DevOps/session-19-cloud-terraform")
        draw.text((x, current_y), "$ ", font=font_bold, fill=prompt_at_color)
        x += font_bold.getlength("$ ")
        
        draw.text((x, current_y), cmd_c, font=font_bold, fill=cmd_color)
        current_y += line_height

        for out_line in out_lines:
            color = text_color
            if out_line.strip().startswith("Plan:") or "Success!" in out_line or "complete!" in out_line:
                color = (74, 222, 128)  # Bright Green
            elif "will be created" in out_line or out_line.strip().startswith("+"):
                color = (56, 189, 248)  # Cyan
            elif "will be destroyed" in out_line or out_line.strip().startswith("-"):
                color = (248, 113, 113) # Red
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
    sc_dir = os.path.join(base_dir, "screenshots")

    # 1. Init & Validation
    out_init = run_cmd("terraform init", base_dir)
    out_fmt = run_cmd("terraform fmt", base_dir)
    if not out_fmt.strip():
        out_fmt = "(All HCL configuration files already formatted)"
    out_val = run_cmd("terraform validate", base_dir)
    render_terminal(
        "Terraform Init & Validation Check",
        [("terraform init", out_init), ("terraform fmt", out_fmt), ("terraform validate", out_val)],
        os.path.join(sc_dir, "01-terraform-init-validate.png")
    )

    # 2. Plan (Full Stack)
    out_plan = run_cmd("terraform plan -no-color", base_dir)
    render_terminal(
        "Terraform Plan: End-to-End Cloud Infrastructure",
        [("terraform plan", out_plan)],
        os.path.join(sc_dir, "02-terraform-plan.png")
    )

    # 3. Apply
    out_apply = run_cmd("terraform apply -auto-approve -no-color", base_dir)
    render_terminal(
        "Terraform Apply: Provisioning VPC, Subnet, SG, EC2, and S3",
        [("terraform apply -auto-approve", out_apply)],
        os.path.join(sc_dir, "03-terraform-apply.png")
    )

    # 4. State List
    out_state = run_cmd("terraform state list", base_dir)
    render_terminal(
        "Terraform State: Managed Cloud Resources List",
        [("terraform state list", out_state)],
        os.path.join(sc_dir, "04-terraform-state-list.png")
    )

    # 5. Show State of Specific Resource (EC2 Instance)
    out_show_ec2 = run_cmd("terraform state show aws_instance.web -no-color", base_dir)
    render_terminal(
        "Terraform State Show: Detailed EC2 Instance Attributes",
        [("terraform state show aws_instance.web", out_show_ec2)],
        os.path.join(sc_dir, "05-terraform-show-ec2.png")
    )

    # 6. Outputs
    out_out = run_cmd("terraform output -no-color", base_dir)
    out_json = run_cmd("terraform output -json", base_dir)
    render_terminal(
        "Terraform Outputs: Computed Cloud Endpoints & IDs",
        [("terraform output", out_out), ("terraform output -json", out_json)],
        os.path.join(sc_dir, "06-terraform-outputs.png")
    )

    # 7. Destroy
    out_dest = run_cmd("terraform destroy -auto-approve -no-color", base_dir)
    render_terminal(
        "Terraform Destroy: Tearing Down Full Cloud Stack",
        [("terraform destroy -auto-approve", out_dest)],
        os.path.join(sc_dir, "07-terraform-destroy.png")
    )

    # 8. Clean Verification
    out_clean = run_cmd("terraform state list", base_dir)
    if not out_clean.strip():
        out_clean = "(Empty state - all 11 cloud resources destroyed and verified)"
    render_terminal(
        "Terraform Clean State Verification",
        [("terraform state list", out_clean)],
        os.path.join(sc_dir, "08-terraform-clean-state.png")
    )

if __name__ == "__main__":
    main()
