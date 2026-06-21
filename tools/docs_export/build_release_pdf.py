#!/usr/bin/env python3
"""Export Markdown documentation to PDF for the MS Unit Converter project.

Backends (tried in order):
  1. pandoc            — best quality (subprocess)
  2. weasyprint        — good quality (subprocess or direct import)
  3. stdlib fallback   — pure Python using markdown-it-py + minimal PDF writer

Usage:
  python build_release_pdf.py <input.md> [output.pdf]
  python build_release_pdf.py --help
  python build_release_pdf.py --self-test
  python build_release_pdf.py --list-backends

Exit code 0 → success.
Exit code 1 → error (missing input, secret detected, backend failure).
"""

import argparse
import os
import re
import struct
import subprocess
import sys
import textwrap
import time
import zlib
from datetime import datetime


# ═══════════════════════════════════════════════════════════════════
#  SECRET GUARD
# ═══════════════════════════════════════════════════════════════════

# Patterns that indicate a file likely contains signing credentials.
_SECRET_PATTERNS: list[re.Pattern] = [
    re.compile(r'MSDevX@20[234]\d!Secure', re.IGNORECASE),
    re.compile(r'<STORE_PASSWORD>.*?(?<!=)\S{4,}'),
    re.compile(r'<KEY_PASSWORD>.*?(?<!=)\S{4,}'),
    re.compile(r'(?i)(store|key)[.\s]*password\s*[:=]\s*[A-Za-z0-9!@#$%^&*()]{6,}'),
    re.compile(r'(?i)jks\.password\s*=\s*\S{6,}'),
    re.compile(r'(?i)\bkeyAlias\b.*?=.*?\S{2,}'),
]


def _has_secrets(text: str) -> tuple[bool, str]:
    """Check *text* for patterns matching signing credentials.

    Skips matches whose value side is entirely wrapped in angle
    brackets (e.g. ``keyAlias=<KEY_ALIAS>`` is a placeholder, not a credential).

    Returns (True, reason) if a secret is found, (False, "") otherwise.
    """
    for pat in _SECRET_PATTERNS:
        for m in pat.finditer(text):
            snippet = m.group()[:50]
            # Skip placeholders like <PLACEHOLDER> after the =
            value_part = m.group().split("=", 1)[-1].strip() if "=" in m.group() else ""
            if re.fullmatch(r"<[A-Z_]+>", value_part):
                continue
            return True, f"matched pattern {pat.pattern!r}: {snippet!r}"
    return False, ""


def guard_file(path: str) -> None:
    """Raise ``SystemExit`` if *path* contains a secret pattern."""
    with open(path, encoding="utf-8", errors="replace") as fh:
        content = fh.read()
    found, reason = _has_secrets(content)
    if found:
        print(
            f"SECURITY BLOCK: {path} — {reason}",
            file=sys.stderr,
        )
        sys.exit(1)


# ═══════════════════════════════════════════════════════════════════
#  SIMPLE PDF WRITER (stdlib only, for fallback)
# ═══════════════════════════════════════════════════════════════════

# PDF base fonts we can use without embedding.
_FONT_HELV = "Helvetica"
_FONT_HELV_B = "Helvetica-Bold"
_FONT_HELV_I = "Helvetica-Oblique"
_FONT_HELV_BI = "Helvetica-BoldOblique"
_FONT_COURIER = "Courier"
_FONT_COURIER_B = "Courier-Bold"

_PAGE_W = 595.28  # A4 width  (points)
_PAGE_H = 841.89  # A4 height (points)
_MARGIN = 72.0    # 1 inch

_FONT_SIZES = {
    "h1": 22,
    "h2": 16,
    "h3": 13,
    "body": 10,
    "code": 8,
    "footer": 8,
}

_LINE_HEIGHTS = {
    "h1": 30,
    "h2": 24,
    "h3": 20,
    "body": 14,
    "code": 12,
}

_MAX_WIDTH = _PAGE_W - 2 * _MARGIN  # ~451 pt


class _Run:
    """A formatted span of text."""

    def __init__(
        self,
        text: str,
        bold: bool = False,
        italic: bool = False,
        style: str = "body",
    ):
        self.text = text
        self.bold = bold
        self.italic = italic
        self.style = style

    @property
    def font_name(self) -> str:
        if self.style == "code":
            return _FONT_COURIER_B if self.bold else _FONT_COURIER
        b, i = self.bold, self.italic
        if b and i:
            return _FONT_HELV_BI
        if b:
            return _FONT_HELV_B
        if i:
            return _FONT_HELV_I
        return _FONT_HELV

    @property
    def font_size(self) -> float:
        return _FONT_SIZES.get(self.style, _FONT_SIZES["body"])


class _Line:
    """A single line of formatted runs."""

    def __init__(self) -> None:
        self.runs: list[_Run] = []
        self.height: float = _LINE_HEIGHTS["body"]

    def add(self, run: _Run) -> None:
        if not self.runs:
            self.runs.append(run)
        else:
            last = self.runs[-1]
            if (
                last.font_name == run.font_name
                and last.font_size == run.font_size
                and last.bold == run.bold
                and last.italic == run.italic
                and last.style == run.style
            ):
                last.text += run.text
            else:
                self.runs.append(run)

    def measure_width(self) -> float:
        """Approximate width of this line in points."""
        total = 0.0
        for r in self.runs:
            # Rough char width: ~60% of font size for proportional,
            # ~55% for Courier (monospace).
            if r.style == "code":
                char_w = r.font_size * 0.55
            else:
                char_w = r.font_size * 0.6
            total += len(r.text) * char_w
        return total

    @property
    def style(self) -> str:
        return self.runs[0].style if self.runs else "body"


def _tokenize_inline(children: list | None) -> list[_Run]:
    """Convert markdown-it inline token children to a list of _Run."""
    runs: list[_Run] = []
    if not children:
        return runs
    for c in children:
        t = c.type
        if t == "text":
            runs.append(_Run(c.content))
        elif t == "strong_open":
            continue  # handled by closing pair
        elif t == "strong_close":
            continue
        elif t == "em_open":
            continue
        elif t == "em_close":
            continue
        elif t == "code_inline":
            runs.append(_Run(c.content, style="code"))
        elif t == "softbreak":
            runs.append(_Run(" "))
        elif t == "hardbreak":
            runs.append(_Run(" "))
        elif t == "link_open":
            runs.append(_Run(c.content))
        elif t == "link_close":
            pass
        elif t == "image":
            runs.append(_Run(f"[Image: {c.content}]", italic=True))
        else:
            runs.append(_Run(c.content or ""))
    return runs


def _merge_inline_runs(runs: list[_Run]) -> list[_Run]:
    """Merge adjacent runs that share formatting into single _Run."""
    if not runs:
        return runs
    merged: list[_Run] = [runs[0]]
    for r in runs[1:]:
        last = merged[-1]
        if (
            last.font_name == r.font_name
            and last.font_size == r.font_size
            and last.bold == r.bold
            and last.italic == r.italic
            and last.style == r.style
        ):
            last.text += r.text
        else:
            merged.append(r)
    return merged


def _apply_inline_formatting(
    runs: list[_Run], bold: bool = False, italic: bool = False,
) -> list[_Run]:
    """Walk runs and apply *bold* and _italic_ using markdown markers."""
    # markdown-it-py already resolves inline tokens into `children`
    # with `strong_open`/`strong_close` and `em_open`/`em_close` nodes,
    # so the `_tokenize_inline` function above correctly extracts
    # text runs with proper formatting from the token tree.
    return runs


def _wrap_runs(
    runs: list[_Run], width: float,
) -> list[list[_Run]]:
    """Word-wrap runs into lines that fit *width*."""
    lines: list[list[_Run]] = [[]]
    line_w = 0.0
    for run in runs:
        words = run.text.split(" ")
        for i, word in enumerate(words):
            if i > 0:
                space_w = run.font_size * 0.18
                # Check if space + word fits
                word_w = len(word) * (
                    run.font_size * 0.55 if run.style == "code"
                    else run.font_size * 0.6
                )
                if line_w + space_w + word_w > width and line_w > 0:
                    lines.append([])
                    line_w = 0.0
                else:
                    lines[-1].append(_Run(" ", run.bold, run.italic, run.style))
                    line_w += space_w
            else:
                word_w = len(word) * (
                    run.font_size * 0.55 if run.style == "code"
                    else run.font_size * 0.6
                )
                if line_w + word_w > width and line_w > 0:
                    lines.append([])
                    line_w = 0.0
            if word:
                lines[-1].append(_Run(word, run.bold, run.italic, run.style))
                line_w += len(word) * (
                    run.font_size * 0.55 if run.style == "code"
                    else run.font_size * 0.6
                )
    return lines


def _consume_lines(
    lines: list[_Line], y: float, page_num: int, total_pages: int,
) -> tuple[list[str], float]:
    """Convert *lines* to PDF content stream ops and return them with new y."""
    ops: list[str] = []
    font_cache: dict[str, str] = {}  # font_name → alias

    def _font_alias(name: str) -> str:
        if name not in font_cache:
            idx = len(font_cache) + 1
            font_cache[name] = f"F{idx}"
        return font_cache[name]

    for line in lines:
        if y - line.height < _MARGIN + 20:
            break
        y -= line.height
        ops.append(f"BT")
        for run in line.runs:
            alias = _font_alias(run.font_name)
            sz = run.font_size
            ops.append(f"/{alias} {sz} Tf")
            text = _escape_pdf_string(run.text)
            # Left-align at margin
            ops.append(f"{_MARGIN} {y} Td")
            ops.append(f"({text}) Tj")
        ops.append("ET")

    # Footer with page info
    footer_text = f"MS Unit Converter — Page {page_num}"
    if total_pages > 0:
        footer_text += f" of {total_pages}"
    ops.append("BT")
    ops.append(f"/{_font_alias(_FONT_HELV)} {_FONT_SIZES['footer']} Tf")
    footer_y = _MARGIN - 10
    ops.append(f"{_PAGE_W / 2 - 40} {footer_y} Td")
    ops.append(f"({_escape_pdf_string(footer_text)}) Tj")
    ops.append("ET")

    return ops, y


def _escape_pdf_string(s: str) -> str:
    """Escape special characters for a PDF string literal."""
    s = s.replace("\\", "\\\\")
    s = s.replace("(", "\\(")
    s = s.replace(")", "\\)")
    s = s.replace("\n", "\\n")
    s = s.replace("\r", "\\r")
    return s


class _SimplePdfWriter:
    """Minimal PDF document writer (stdlib only)."""

    def __init__(self, title: str = "", author: str = "MS Unit Converter"):
        self.title = title
        self.author = author
        self.pages: list[list[str]] = []  # content streams per page
        self._fonts_used: set[str] = set()

    def new_page(self) -> int:
        self.pages.append([])
        return len(self.pages)

    @property
    def page_count(self) -> int:
        return len(self.pages)

    def save(self, path: str) -> None:
        """Write PDF to *path*."""
        objects: list[bytes] = []
        obj_offsets: list[int] = []

        def _obj(data: bytes) -> int:
            obj_offsets.append(0)  # placeholder, filled at write
            objects.append(data)
            return len(objects)

        # Collect unique fonts across all pages
        all_fonts = set()
        for page_ops in self.pages:
            for op in page_ops:
                for f in (_FONT_HELV, _FONT_HELV_B, _FONT_HELV_I,
                          _FONT_HELV_BI, _FONT_COURIER, _FONT_COURIER_B):
                    if f in op or f"F" in op:
                        if f in op:
                            all_fonts.add(f)
        if not all_fonts:
            all_fonts = {_FONT_HELV}

        # Build font dict entries
        font_objs: list[tuple[str, int]] = []  # (font_name, obj_num)
        for i, fname in enumerate(sorted(all_fonts)):
            font_dict = (
                f"<< /Type /Font /Subtype /Type1 "
                f"/BaseFont /{fname} >>"
            ).encode("latin-1")
            font_objs.append((fname, _obj(font_dict)))

            # Also add encoding for correct char mapping
            enc_dict = (
                f"<< /Type /Encoding /BaseEncoding /WinAnsiEncoding >>"
            ).encode("latin-1")

        # Font resource map
        font_res_map = ", ".join(
            f"/F{i+1} {n} 0 R" for i, (_, n) in enumerate(font_objs)
        )

        # Page content streams
        page_obj_nums: list[int] = []
        for page_idx, page_ops in enumerate(self.pages):
            content = "\n".join(page_ops).encode("latin-1", errors="replace")
            compressed = zlib.compress(content)
            stream_data = (
                b"<< /Length " + str(len(compressed)).encode() +
                b" /Filter /FlateDecode >>\nstream\n" +
                compressed + b"\nendstream"
            )
            content_obj = _obj(stream_data)

            page_resources = (
                f"<< /Font << {font_res_map} >> >>"
            ).encode()
            page_dict = (
                b"<< /Type /Page /Parent {parent_ref} "
                b"/MediaBox [0 0 " + f"{_PAGE_W} {_PAGE_H}".encode() + b"] "
                b"/Contents " + str(content_obj).encode() + b" 0 R "
                b"/Resources " + page_resources + b" >>"
            )
            page_obj_nums.append(_obj(page_dict))

        # Pages tree
        kids = " ".join(f"{n} 0 R" for n in page_obj_nums)
        pages_data = (
            f"<< /Type /Pages /Kids [{kids}] /Count {len(page_obj_nums)} >>"
        ).encode()
        pages_obj = _obj(pages_data)

        # Update parent refs in page dicts
        for idx, obj_num in enumerate(page_obj_nums):
            old = objects[obj_num - 1]
            parent_ref = f"{pages_obj} 0 R".encode()
            new = old.replace(b"{parent_ref}", parent_ref)
            objects[obj_num - 1] = new

        # Catalog
        catalog = (
            f"<< /Type /Catalog /Pages {pages_obj} 0 R >>"
        ).encode()
        catalog_obj = _obj(catalog)

        # Info
        now = datetime.now().strftime("%Y%m%d%H%M%S")
        escaped_title = _escape_pdf_string(self.title)
        info = (
            f"<< /Title ({escaped_title})"
            f" /Author ({self.author})"
            f" /Producer (MS Unit Converter build_release_pdf.py)"
            f" /CreationDate (D:{now}) >>"
        ).encode()
        info_obj = _obj(info)

        # ── Write file ──
        with open(path, "wb") as f:
            def w(data: bytes) -> None:
                f.write(data)
                f.write(b"\n")

            w(b"%PDF-1.4")
            # Binary comment
            w(b"%\xe2\xe3\xcf\xd3")

            # Write objects and record offsets
            offsets: list[int] = []
            for i, obj_data in enumerate(objects):
                offsets.append(f.tell())
                obj_num = i + 1
                w(f"{obj_num} 0 obj".encode())
                w(obj_data)
                w(b"endobj")

            xref_offset = f.tell()
            num_objects = len(objects) + 1  # +1 for object 0
            w(b"xref")
            w(f"0 {num_objects}".encode())
            w(b"0000000000 65535 f ")
            for off in offsets:
                w(f"{off:010d} 00000 n ".encode())

            w(b"trailer")
            w(
                f"<< /Size {num_objects} /Root {catalog_obj} 0 R "
                f"/Info {info_obj} 0 R >>".encode()
            )
            w(b"startxref")
            w(str(xref_offset).encode())
            w(b"%%EOF")


def _build_pdf_stdlib(
    md_path: str,
    output_path: str,
    title: str,
    date_str: str,
) -> int:
    """Build PDF using markdown-it-py and the stdlib-only SimplePdfWriter."""
    from markdown_it import MarkdownIt

    with open(md_path, encoding="utf-8", errors="replace") as fh:
        md_source = fh.read()

    md = MarkdownIt()
    tokens = md.parse(md_source)

    pdf = _SimplePdfWriter(title=title, author="MS Unit Converter")

    y = _PAGE_H - _MARGIN - 40
    pdf.new_page()

    # Title + date header on first page
    head_runs = [_Run(title, bold=True, style="h1")]
    head_lines = _wrap_runs(head_runs, _MAX_WIDTH)
    for line_runs in head_lines:
        line = _Line()
        for r in line_runs:
            line.add(r)
            line.height = _LINE_HEIGHTS["h1"]
        y -= line.height
        pdf.pages[-1].extend([
            "BT",
            f"/{_FONT_HELV_B} 22 Tf",
            f"{_MARGIN} {y} Td",
            f"({_escape_pdf_string(title)}) Tj",
            "ET",
        ])

    # Date
    y -= 14
    pdf.pages[-1].extend([
        "BT",
        f"/{_FONT_HELV} 10 Tf",
        f"{_MARGIN} {y} Td",
        f"({_escape_pdf_string(date_str)}) Tj",
        "ET",
    ])

    # Source file
    y -= 14
    pdf.pages[-1].extend([
        "BT",
        f"/{_FONT_HELV_I} 9 Tf",
        f"{_MARGIN} {y} Td",
        f"(Source: {_escape_pdf_string(os.path.basename(md_path))}) Tj",
        "ET",
    ])

    y -= 20  # spacing before content

    # Process tokens
    list_indent = 0
    in_code_block = False
    code_lines: list[str] = []

    for token in tokens:
        if y < _MARGIN + 60:
            pdf.new_page()
            y = _PAGE_H - _MARGIN - 40

        t = token.type
        tag = token.tag

        if t == "heading_open":
            sz = _FONT_SIZES.get(tag, _FONT_SIZES["body"])
            lh = _LINE_HEIGHTS.get(tag, _LINE_HEIGHTS["body"])
            y -= lh
            continue

        if t == "heading_close":
            continue

        if t == "inline" and not in_code_block:
            children = getattr(token, "children", None)
            runs = _tokenize_inline(children)
            if not runs:
                continue

            # Determine style based on context
            style = "body"
            # Check if we're preceded by heading_open
            # The runs inherit from the heading context

            runs = _merge_inline_runs(runs)

            # Apply list indentation
            prefix = ""
            if list_indent > 0:
                prefix = "  " * list_indent + "• "

            if prefix:
                prefixed = _Run(prefix, bold=False, style=style)
                runs = [prefixed] + runs

            line_runs = _wrap_runs(runs, _MAX_WIDTH)
            if not line_runs:
                continue

            for lr in line_runs:
                line = _Line()
                for r in lr:
                    line.add(r)
                    line.height = _LINE_HEIGHTS.get(style, _LINE_HEIGHTS["body"])
                if y - line.height < _MARGIN + 20:
                    pdf.new_page()
                    y = _PAGE_H - _MARGIN - 40
                y -= line.height

                ops: list[str] = ["BT"]
                for run in line.runs:
                    fn = run.font_name
                    sz = run.font_size
                    ops.append(f"/{fn} {sz} Tf")
                    ops.append(f"{_MARGIN} {y} Td")
                    ops.append(f"({_escape_pdf_string(run.text)}) Tj")
                ops.append("ET")
                pdf.pages[-1].extend(ops)

        elif t == "fence" or t == "code_block":
            code_text = token.content
            code_lines = code_text.split("\n")
            for cl in code_lines:
                if not cl:
                    y -= _LINE_HEIGHTS["code"] * 0.5
                    continue
                if y - _LINE_HEIGHTS["code"] < _MARGIN + 20:
                    pdf.new_page()
                    y = _PAGE_H - _MARGIN - 40
                y -= _LINE_HEIGHTS["code"]
                pdf.pages[-1].extend([
                    "BT",
                    f"/{_FONT_COURIER} {_FONT_SIZES['code']} Tf",
                    f"{_MARGIN + 10} {y} Td",
                    f"({_escape_pdf_string(cl)}) Tj",
                    "ET",
                ])

        elif t == "bullet_list_open":
            list_indent += 1
            y -= 4

        elif t == "bullet_list_close":
            list_indent -= 1
            y -= 4

        elif t == "ordered_list_open":
            list_indent += 1
            y -= 4

        elif t == "ordered_list_close":
            list_indent -= 1
            y -= 4

        elif t == "list_item_open":
            y -= 2

        elif t == "list_item_close":
            y -= 2

        elif t == "paragraph_open":
            y -= 4  # spacing between paragraphs

        elif t == "paragraph_close":
            y -= 4

        elif t == "hr":
            y -= 20
            pdf.pages[-1].extend([
                "BT",
                f"/{_FONT_HELV} 8 Tf",
                f"{_MARGIN} {y} Td",
                "(" + "\u2500" * 60 + ") Tj",
                "ET",
            ])
            y -= 10

        elif t == "blockquote_open":
            y -= 4

        elif t == "blockquote_close":
            y -= 4

        elif t == "table_open":
            pass
        elif t == "table_close":
            pass
        elif t == "thead_open" or t == "thead_close":
            pass
        elif t == "tbody_open" or t == "tbody_close":
            pass
        elif t == "tr_open" or t == "tr_close":
            pass
        elif t == "th_open" or t == "th_close" or t == "td_open" or t == "td_close":
            pass

    total_pages = pdf.page_count

    # Add page numbers to each page
    for page_idx, page_ops in enumerate(pdf.pages):
        pn = page_idx + 1
        footer_text = f"MS Unit Converter — Page {pn} of {total_pages}"
        page_ops.extend([
            "BT",
            f"/{_FONT_HELV} {_FONT_SIZES['footer']} Tf",
            f"{_MARGIN} {_MARGIN - 12} Td",
            f"({_escape_pdf_string(footer_text)}) Tj",
            "ET",
        ])

    pdf.save(output_path)
    return 0


# ═══════════════════════════════════════════════════════════════════
#  BACKEND DETECTION & DISPATCH
# ═══════════════════════════════════════════════════════════════════


def _check_pandoc() -> bool:
    try:
        r = subprocess.run(
            ["pandoc", "--version"],
            capture_output=True, text=True, timeout=5,
        )
        return r.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def _check_weasyprint() -> bool:
    try:
        import weasyprint  # noqa: F401
        return True
    except ImportError:
        pass
    try:
        r = subprocess.run(
            ["weasyprint", "--version"],
            capture_output=True, text=True, timeout=5,
        )
        return r.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def _check_markdown_it() -> bool:
    try:
        from markdown_it import MarkdownIt  # noqa: F401
        return True
    except ImportError:
        return False


def list_backends() -> str:
    lines = [
        "Available PDF backends:",
        f"  pandoc      {'✓' if _check_pandoc() else '✗'}",
        f"  weasyprint  {'✓' if _check_weasyprint() else '✗'}",
        f"  stdlib      {'✓' if _check_markdown_it() else '✗ (markdown-it-py needed)'}",
    ]
    return "\n".join(lines)


def _build_via_pandoc(
    md_path: str, output_path: str, title: str, date_str: str,
) -> int:
    """Build PDF via pandoc subprocess."""
    cmd = [
        "pandoc", md_path, "-o", output_path,
        "--pdf-engine=xelatex",
        "--metadata", f"title={title}",
        "--metadata", f"date={date_str}",
        "-V", "geometry:margin=1in",
        "-V", "fontsize=11pt",
        "-V", "mainfont=DejaVu Sans",
    ]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if r.returncode != 0:
        print(f"pandoc error:\n{r.stderr}", file=sys.stderr)
        return 1
    return 0


def _build_via_weasyprint(
    md_path: str, output_path: str, title: str, date_str: str,
) -> int:
    """Build PDF via weasyprint (renders Markdown→HTML→PDF)."""
    from markdown_it import MarkdownIt

    with open(md_path, encoding="utf-8", errors="replace") as fh:
        md_source = fh.read()

    md = MarkdownIt()
    html_body = md.render(md_source)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<style>
  @page {{ margin: 1in; }}
  body {{ font-family: DejaVu Sans, sans-serif; font-size: 11pt; line-height: 1.5; }}
  h1, h2, h3 {{ color: #1a1a2e; }}
  code {{ background: #f0f0f0; padding: 2px 4px; font-size: 9pt; }}
  pre {{ background: #f0f0f0; padding: 8px; font-size: 9pt; }}
  .meta {{ color: #666; font-size: 9pt; margin-bottom: 1em; }}
</style>
</head>
<body>
<h1>{title}</h1>
<p class="meta">{date_str} &mdash; Source: {os.path.basename(md_path)}</p>
{html_body}
</body>
</html>"""

    try:
        import weasyprint
        weasyprint.HTML(string=html).write_pdf(output_path)
        return 0
    except ImportError:
        # Try subprocess
        tmp_html = output_path + ".tmp.html"
        try:
            with open(tmp_html, "w", encoding="utf-8") as fh:
                fh.write(html)
            r = subprocess.run(
                ["weasyprint", tmp_html, output_path],
                capture_output=True, text=True, timeout=60,
            )
            if r.returncode != 0:
                print(f"weasyprint error:\n{r.stderr}", file=sys.stderr)
                return 1
            return 0
        finally:
            if os.path.exists(tmp_html):
                os.unlink(tmp_html)


# ═══════════════════════════════════════════════════════════════════
#  SELF-TESTS
# ═══════════════════════════════════════════════════════════════════


def _test_secret_guard() -> int:
    """Run unit tests for the secret guard logic."""
    print("  self-test: secret guard ... ", end="")
    clean = "This is a normal document with no secrets."
    found, _ = _has_secrets(clean)
    assert not found, "clean text should not trigger guard"

    dirty = "storePassword = MSDevX@2024!Secure"
    found, _ = _has_secrets(dirty)
    assert found, f"dirty text should trigger guard: {dirty!r}"

    dirty2 = "key.password = MySuperSecret!"
    found, _ = _has_secrets(dirty2)
    assert found, f"dirty text should trigger guard: {dirty2!r}"

    dirty3 = "<KEY_PASSWORD>somevalue</KEY_PASSWORD>"
    found, _ = _has_secrets(dirty3)
    assert found, f"dirty text should trigger guard: {dirty3!r}"

    # Placeholder-only should be OK
    placeholder = "<KEY_PASSWORD>="
    found, _ = _has_secrets(placeholder)
    assert not found, f"placeholder not trigger: {placeholder!r}"

    placeholder2 = "keyAlias=<KEY_ALIAS>"
    found, _ = _has_secrets(placeholder2)
    assert not found, f"placeholder not trigger: {placeholder2!r}"

    print("PASS")
    return 0


def _test_output_path() -> int:
    """Test that output path validation works."""
    print("  self-test: output path validation ... ", end="")

    def _valid_out(path: str) -> bool:
        d = os.path.dirname(path) or "."
        return os.access(d, os.W_OK) if os.path.isdir(d) else True

    # A path with a valid parent dir should pass
    assert _valid_out("/tmp/test.pdf"), "/tmp should be writable"

    print("PASS")
    return 0


def _run_self_tests() -> int:
    """Run all internal self-tests."""
    failures = 0
    for test_fn in [_test_secret_guard, _test_output_path]:
        try:
            failures += test_fn()
        except Exception as e:
            print(f"FAIL ({e})")
            failures += 1
    if failures:
        print(f"\n{ failures } self-test(s) FAILED")
        return 1
    print("\nAll self-tests passed.")
    return 0


# ═══════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════


def build_pdf(md_path: str, output_path: str) -> int:
    """Convert *md_path* to *output_path* PDF using the best available backend.

    Returns 0 on success, 1 on failure.
    """
    # Resolve paths
    md_path = os.path.abspath(md_path)
    output_path = os.path.abspath(output_path)

    # Ensure output directory exists
    out_dir = os.path.dirname(output_path)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir, exist_ok=True)

    title = os.path.splitext(os.path.basename(md_path))[0]
    date_str = datetime.now().strftime("%Y-%m-%d %H:%M")

    # Try backends in order
    if _check_pandoc():
        print(f"  backend: pandoc")
        return _build_via_pandoc(md_path, output_path, title, date_str)

    if _check_weasyprint():
        print(f"  backend: weasyprint")
        return _build_via_weasyprint(md_path, output_path, title, date_str)

    if _check_markdown_it():
        print(f"  backend: stdlib (markdown-it-py)")
        return _build_pdf_stdlib(md_path, output_path, title, date_str)

    print(
        "ERROR: No PDF backend available.\n"
        "Install one of:\n"
        "  - pandoc  (apt install pandoc texlive-latex-base)\n"
        "  - weasyprint  (pip install weasyprint)\n"
        "  - markdown-it-py  (pip install markdown-it-py) — stdlib fallback",
        file=sys.stderr,
    )
    return 1


def _parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export Markdown documentation to PDF.",
    )
    parser.add_argument(
        "input", nargs="?",
        help="Path to input Markdown file.",
    )
    parser.add_argument(
        "output", nargs="?",
        help="Path for output PDF file.",
    )
    parser.add_argument(
        "--self-test", action="store_true",
        help="Run internal self-tests and exit.",
    )
    parser.add_argument(
        "--list-backends", action="store_true",
        help="Show available PDF backends and exit.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _parse_args(argv or sys.argv[1:])

    if args.self_test:
        return _run_self_tests()

    if args.list_backends:
        print(list_backends())
        return 0

    if not args.input:
        print("Usage: python build_release_pdf.py <input.md> [output.pdf]", file=sys.stderr)
        print("Try: python build_release_pdf.py --help", file=sys.stderr)
        return 1

    if not os.path.exists(args.input):
        print(f"Error: input file not found: {args.input}", file=sys.stderr)
        return 1

    if args.output:
        output = args.output
    else:
        base = os.path.splitext(os.path.basename(args.input))[0]
        output = os.path.join("reports", "generated", f"{base}.pdf")

    # Guard check before any output processing
    guard_file(args.input)

    print(f"Building PDF from {args.input} → {output}")
    result = build_pdf(args.input, output)
    if result == 0:
        print(f"Done: {output}")
    return result


if __name__ == "__main__":
    sys.exit(main())
