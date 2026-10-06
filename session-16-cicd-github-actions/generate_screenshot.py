#!/usr/bin/env python3
import os
import sys
import re
import subprocess
from PIL import Image, ImageDraw, ImageFont

ANSI_ESCAPE = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')

def strip_ansi(text):
    return ANSI_ESCAPE.sub('', text)

def render_terminal(title, prompt_cmd_pairs, output_path, width=1050):
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
        font = ImageFont.load_default()
        font_bold = font

    line_height = 22
    header_height = 38
    padding_x = 20
    padding_y = 16

    # Pre-wrap and measure lines
    max_char_per_line = (width - 2 * padding_x) // 9
    
    total_rendered_lines = 0
    prepared_entries = []

    for item in prompt_cmd_pairs:
        if isinstance(item, tuple):
            cmd, out = item
        else:
            cmd, out = item, ""
        
        cmd_clean = strip_ansi(cmd).strip()
        out_clean = strip_ansi(out).rstrip()
        
        # Split output into lines, wrap long lines
        wrapped_out_lines = []
        if out_clean:
            for l in out_clean.split("\n"):
                if len(l) > max_char_per_line:
                    # chunk long lines
                    for i in range(0, len(l), max_char_per_line):
                        wrapped_out_lines.append(l[i:i+max_char_per_line])
                else:
                    wrapped_out_lines.append(l)

        prepared_entries.append((cmd_clean, wrapped_out_lines))
        total_rendered_lines += 1 + len(wrapped_out_lines) + 1 # prompt + output + blank line

    content_height = total_rendered_lines * line_height + 2 * padding_y
    height = header_height + content_height

    img = Image.new("RGB", (width, height), bg_color)
    draw = ImageDraw.Draw(img)

    # Window bar
    draw.rectangle([(0, 0), (width, header_height)], fill=title_bar_color)
    draw.line([(0, header_height), (width, header_height)], fill=(51, 65, 85), width=1)

    # Window dots
    draw.ellipse([(16, 13), (28, 25)], fill=(239, 68, 68))   # Red
    draw.ellipse([(36, 13), (48, 25)], fill=(245, 158, 11))  # Amber
    draw.ellipse([(56, 13), (68, 25)], fill=(34, 197, 94))   # Green

    # Window title
    title_font = font_bold if font_bold else font
    bbox = draw.textbbox((0, 0), title, font=title_font)
    title_w = bbox[2] - bbox[0]
    draw.text(((width - title_w) // 2, 9), title, font=title_font, fill=(203, 213, 225))

    # Draw content
    y = header_height + padding_y
    for cmd_clean, out_lines in prepared_entries:
        if cmd_clean.startswith("#"):
            # Comment line
            draw.text((padding_x, y), cmd_clean, font=font, fill=comment_color)
            y += line_height
        else:
            # Shell prompt: pranav@pranavOG:~$
            u_text = "pranav"
            at_text = "@"
            h_text = "pranavOG"
            sep_text = ":"
            path_text = "~"
            dollar_text = "$ "

            cur_x = padding_x
            draw.text((cur_x, y), u_text, font=font_bold, fill=prompt_user_color)
            cur_x += draw.textbbox((0, 0), u_text, font=font_bold)[2]

            draw.text((cur_x, y), at_text, font=font, fill=prompt_at_color)
            cur_x += draw.textbbox((0, 0), at_text, font=font)[2]

            draw.text((cur_x, y), h_text, font=font_bold, fill=prompt_host_color)
            cur_x += draw.textbbox((0, 0), h_text, font=font_bold)[2]

            draw.text((cur_x, y), sep_text, font=font, fill=prompt_at_color)
            cur_x += draw.textbbox((0, 0), sep_text, font=font)[2]

            draw.text((cur_x, y), path_text, font=font_bold, fill=prompt_path_color)
            cur_x += draw.textbbox((0, 0), path_text, font=font_bold)[2]

            draw.text((cur_x, y), dollar_text, font=font_bold, fill=(248, 250, 252))
            cur_x += draw.textbbox((0, 0), dollar_text, font=font_bold)[2]

            draw.text((cur_x, y), cmd_clean, font=font_bold, fill=cmd_color)
            y += line_height

        for line in out_lines:
            # Colorize status indicators if present
            line_col = text_color
            if "Ready" in line or "Running" in line or "Bound" in line or "Successful" in line or "Normal" in line:
                line_col = (187, 247, 208) # light green
            elif "Error" in line or "Failed" in line or "CrashLoopBackOff" in line or "Unhealthy" in line:
                line_col = (254, 202, 202) # light red
            elif "Warning" in line:
                line_col = (254, 240, 138) # light yellow
            draw.text((padding_x, y), line, font=font, fill=line_col)
            y += line_height

        y += line_height // 2  # spacing between commands

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    img.save(output_path, "PNG")
    print(f"Captured screenshot: {output_path} ({width}x{height})")

def run_and_capture(title, commands, output_path, cwd=None, width=1050):
    pairs = []
    for cmd in commands:
        if cmd.strip().startswith("#"):
            pairs.append((cmd, ""))
            continue
        res = subprocess.run(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        pairs.append((cmd, res.stdout))
    render_terminal(title, pairs, output_path, width=width)
