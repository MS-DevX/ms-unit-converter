# PDF Documentation Export Tooling

## Purpose

The `build_release_pdf.py` script converts Markdown documentation files
(README.md, RELEASE_GUIDE.md, and any docs/\*.md) into PDF format for
offline distribution and release packaging.

It is a **developer tool** — not part of the Flutter app. The app never
reads or depends on these PDFs.

## How to Run

```bash
# Single file → explicit output path
python tools/docs_export/build_release_pdf.py README.md docs/generated/readme.pdf

# Single file → auto-named in reports/generated/
python tools/docs_export/build_release_pdf.py RELEASE_GUIDE.md

# See available backends
python tools/docs_export/build_release_pdf.py --list-backends

# Run internal self-tests
python tools/docs_export/build_release_pdf.py --self-test
```

## Backends

The script tries backends in this order:

| Backend | How to Install | Quality |
|---------|---------------|---------|
| pandoc  | `apt install pandoc texlive-latex-base` | Best |
| weasyprint | `pip install weasyprint` | Good |
| stdlib (markdown-it-py) | `pip install markdown-it-py` | Basic |

The stdlib fallback uses `markdown-it-py` (already installed in this
environment) plus a minimal PDF writer built on `zlib` and raw PDF
objects — **no external PDF library required**.

## Security

The script includes a **secret guard** that scans input files for
patterns resembling signing credentials (passwords, key aliases, etc.).

- If a secret is detected, the script exits with code 1 and prints a
  SECURITY BLOCK message.
- The secret itself is **never printed** beyond a brief matched snippet.
- Placeholders (e.g. `<KEY_ALIAS>`) in angle brackets are treated as
  safe and allowed through.

## Why PDF?

PDFs are the standard format for release documentation, offering:
- Universal readability without Markdown rendering tools
- Page breaks, headers, and footers for professional presentation
- Easy attachment to release notes and email announcements

## How to Avoid Committing Secrets

1. Run `python tools/docs_export/build_release_pdf.py <file>` **before**
   committing to catch accidental credential inclusion.
2. Keep signing values in `key.properties` (already in `.gitignore`).
3. Use `<PLACEHOLDER>` notation for examples in documentation.

## Output Location

Generated PDFs go to:
- `docs/generated/` — when an explicit output path is given
- `reports/generated/` — when only the input path is provided

## File Layout

```
tools/docs_export/
├── README.md
└── build_release_pdf.py    # Python script (stdlib + markdown-it-py)
```
