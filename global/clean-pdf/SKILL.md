---
name: clean-pdf
description: "Use this skill to produce beautifully typeset PDF documents from conversation content, notes, essays, reflections, or any prose. Uses LaTeX (xelatex) to create professional-quality documents with Georgia font, colored insight boxes, structured sections, and clean typography. Also generates .md, .docx, and .txt companion files. Triggers: user asks for a 'clean PDF', 'formatted document', 'typeset this', 'make this into a PDF', 'save this conversation as a document', or '/clean-pdf'. Do NOT use for manipulating existing PDFs (merging, splitting, OCR) -- use the /pdf skill for that."
---

# Clean PDF — Professional Document Production

## Overview

This skill produces beautifully typeset PDF documents from content using LaTeX as the typesetting engine. It also generates companion files in .md, .docx, and .txt formats. The result is a professional, readable document suitable for printing or archiving.

## Prerequisites

- **xelatex** (MiKTeX or TeX Live) — for PDF compilation
- **pandoc** — for .docx and .txt conversion
- Both are installed on this system at:
  - xelatex: `C:\Users\ariel\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex`
  - pandoc: `C:\Users\ariel\AppData\Local\Pandoc\pandoc`

## Process

### Step 1: Determine output location

Ask the user where to save, or default to:
```
C:\Users\ariel\Documents\{descriptive-folder-name}\
```

### Step 2: Write the Markdown source first

Write `conversation.md` (or a descriptive filename) with the full content. This is the source of truth. Use:
- `> **Ariel:**` blockquotes for user prompts
- `> **KEY INSIGHT:**` blockquotes for highlighted advice/insights
- `###` for subsections, `##` for major sections
- `---` horizontal rules between major parts
- Standard markdown formatting (bold, italic, lists)

### Step 3: Write the LaTeX source

Write a `.tex` file using the **exact template below**. This template produces the signature look.

### Step 4: Compile the PDF

```bash
cd "{output-dir}" && xelatex -interaction=nonstopmode {filename}.tex && xelatex -interaction=nonstopmode {filename}.tex
```

Always run xelatex **twice** for correct cross-references and page numbers.

### Step 5: Generate companion formats

```bash
export PATH="$PATH:/c/Users/ariel/AppData/Local/Pandoc"
pandoc {filename}.md -o {filename}.docx -f markdown -t docx
pandoc {filename}.md -o {filename}.txt -f markdown -t plain --wrap=auto --columns=80
```

### Step 6: Verify all files

Confirm all 4 files exist and report sizes:
```bash
ls -lh "{output-dir}/" | grep -E "\.(pdf|docx|md|txt)$"
```

---

## LaTeX Template

This is the exact template that produces the clean, professional look. Adapt the content but preserve the structure and styling.

```latex
\documentclass[12pt, letterpaper]{article}
\usepackage[margin=1in]{geometry}
\usepackage{xcolor}
\usepackage{tcolorbox}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage{setspace}
\usepackage{microtype}
\usepackage{hyperref}
\usepackage{fontspec}

% ── Font ──────────────────────────────────────────────
\setmainfont{Georgia}

% ── Hyperlinks ────────────────────────────────────────
\hypersetup{
    colorlinks=true,
    linkcolor=darkgray,
    urlcolor=darkgray
}

% ── Colors ────────────────────────────────────────────
\definecolor{promptbg}{RGB}{240,240,245}        % Light lavender for prompts
\definecolor{insightbg}{RGB}{255,248,230}        % Warm amber for insights
\definecolor{insightborder}{RGB}{200,160,60}     % Gold border for insights
\definecolor{summarybg}{RGB}{235,245,235}        % Soft green for summary items
\definecolor{summaryborder}{RGB}{60,140,60}      % Green border for summary
\definecolor{promptborder}{RGB}{100,100,140}     % Muted purple for prompts

% ── Box defaults ──────────────────────────────────────
\tcbset{
    boxrule=0.5pt,
    arc=3pt,
    left=10pt,
    right=10pt,
    top=8pt,
    bottom=8pt
}

% ── Custom environments ───────────────────────────────
% Prompt box (user's words)
\newenvironment{prompt}{%
    \begin{tcolorbox}[colback=promptbg, colframe=promptborder,
        title={\textsc{Ariel}}, fonttitle=\bfseries\small,
        coltitle=promptborder]
    \itshape
}{%
    \end{tcolorbox}
}

% Key insight box (highlighted wisdom)
\newenvironment{insight}{%
    \begin{tcolorbox}[colback=insightbg, colframe=insightborder,
        title={\small\textbf{Key Insight}},
        fonttitle=\color{insightborder}]
}{%
    \end{tcolorbox}
}

% Summary item box (for numbered takeaways)
\newenvironment{summarybox}{%
    \begin{tcolorbox}[colback=summarybg, colframe=summaryborder]
}{%
    \end{tcolorbox}
}

% ── Section formatting ────────────────────────────────
\titleformat{\section}{\Large\bfseries}{}{0pt}{}[\vspace{2pt}\hrule\vspace{8pt}]
\titleformat{\subsection}{\large\bfseries\itshape}{}{0pt}{}

% ── Line spacing ──────────────────────────────────────
\setstretch{1.25}

% ── Document ──────────────────────────────────────────
\begin{document}

\begin{center}
{\LARGE\bfseries DOCUMENT TITLE}\\[6pt]
{\large SUBTITLE OR DESCRIPTION}\\[12pt]
{\normalsize DATE}\\[4pt]
{\small AUTHOR / ATTRIBUTION}
\end{center}

\vspace{20pt}

\noindent\textit{Opening context paragraph in italics.}

\vspace{10pt}

%% ── Section ──────────────────────────────────────────
\section{Section Title}

\begin{prompt}
User's question or prompt goes here in italic inside a lavender box.
\end{prompt}

Regular response text goes here. Use standard LaTeX formatting:
\textbf{bold}, \textit{italic}, \texttt{monospace}.

\begin{insight}
Key insights go in amber boxes. These are the most important
pieces of advice, wisdom, or analysis that the reader should
pay special attention to.
\end{insight}

\subsection{Subsection Title}

More content here. Use \begin{quote}\textit{...}\end{quote}
for quoted speech or suggested scripts.

%% ── Summary Section ──────────────────────────────────
\section{Summary}

\begin{summarybox}
\textbf{\large 1. First principle title.}

Explanation of the principle.
\end{summarybox}

\vspace{6pt}

\begin{summarybox}
\textbf{\large 2. Second principle title.}

Explanation of the principle.
\end{summarybox}

%% ── Closing ──────────────────────────────────────────
\vspace{30pt}
\begin{center}
\rule{0.4\textwidth}{0.4pt}\\[10pt]
\textit{``Closing quote or reflection.''}
\end{center}

\end{document}
```

---

## Design Principles

These rules produce the signature look. Follow them even when adapting the template:

1. **Font: Georgia, 12pt.** Serif font optimized for readability on screen and print. Never use Computer Modern (LaTeX default) — it looks academic, not professional.

2. **Margins: 1 inch all sides.** Standard letter paper. Clean, not cramped.

3. **Line spacing: 1.25.** Slightly more than single-spaced. Readable without feeling like a textbook.

4. **Three box types, three colors:**
   - **Prompt boxes** (lavender/purple): user's words, questions, or prompts
   - **Insight boxes** (amber/gold): key advice, highlighted wisdom, critical observations
   - **Summary boxes** (green): numbered principles, takeaways, action items

5. **Section headers:** Large bold with a horizontal rule underneath. No numbering.

6. **Subsection headers:** Large bold italic. No numbering, no rule.

7. **Quoted speech / suggested scripts:** Use `\begin{quote}\textit{...}\end{quote}` — indented and italic, clearly set apart from analysis.

8. **No page numbers in header/footer.** LaTeX default page numbering at bottom is fine.

9. **Title block:** Centered, large bold title, subtitle in regular size, date, and attribution. No separate title page — it flows into the content.

10. **Closing:** Centered horizontal rule with a closing quote in italics.

---

## Adapting for Different Content Types

### Conversations / Reflections
Use `prompt` environments for the user's words. Use `insight` environments for key observations. Include a summary section with numbered `summarybox` items.

### Essays / Blog Posts
Skip the `prompt` environments. Use `insight` boxes sparingly for the most important arguments. The summary section becomes "Key Arguments" or "Takeaways."

### Technical Documents
Replace `insight` boxes with `\begin{tcolorbox}[colback=insightbg, colframe=insightborder, title={\small\textbf{Important}}]` for warnings or critical notes. Use `\texttt{}` and `verbatim` environments for code.

### Letters / Memos
Simplify: use only the title block, body text, and closing. Skip boxes entirely. The Georgia font and spacing alone carry the professional look.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `fontspec` error | Make sure you're using `xelatex`, not `pdflatex` |
| Georgia not found | Install Georgia font or substitute with `TeX Gyre Termes` |
| Overfull hbox warnings | These are minor — text slightly exceeds margins. Ignorable for most content. To fix, rephrase the offending line. |
| Cross-references wrong | Run xelatex twice |
| pandoc not found | `export PATH="$PATH:/c/Users/ariel/AppData/Local/Pandoc"` |
| Compile hangs | Use `-interaction=nonstopmode` flag |

## Naming Conventions

- Folder: descriptive kebab-case in Documents (e.g., `self-reflection-april-2026`)
- Files: `{topic}.{ext}` — same base name across all 4 formats
- If multiple documents in one session, use descriptive names, not `document-1`
