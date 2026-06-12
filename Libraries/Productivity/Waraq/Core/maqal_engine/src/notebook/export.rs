// src/notebook/export.rs
//
// Notebook export — converts a NotebookDocument into various output formats,
// equivalent to `jupyter nbconvert`.
//
// Supported formats:
//   Html     — self-contained HTML with syntax highlighting + rendered outputs
//   Script   — plain source code file (Python/Julia/R/etc.), comments for Markdown
//   Markdown — Markdown document with code fences and output blocks
//   Rst      — reStructuredText (for Sphinx documentation)
//   Latex    — LaTeX document
//   Strip    — clean .ipynb with all outputs removed

use super::cell::{CellSnapshot, CellType};
use super::document::{IpynbDocument, NotebookDocument};
use super::output::{CellOutput, StreamName};
use serde::{Deserialize, Serialize};

// ── Export format ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ExportFormat {
    Html,
    Script,
    Markdown,
    Rst,
    Latex,
    /// .ipynb with all outputs cleared.
    Strip,
}

impl ExportFormat {
    pub fn file_extension(&self) -> &'static str {
        match self {
            ExportFormat::Html => ".html",
            ExportFormat::Script => "", // determined by language
            ExportFormat::Markdown => ".md",
            ExportFormat::Rst => ".rst",
            ExportFormat::Latex => ".tex",
            ExportFormat::Strip => ".ipynb",
        }
    }

    pub fn mime_type(&self) -> &'static str {
        match self {
            ExportFormat::Html => "text/html",
            ExportFormat::Script => "text/plain",
            ExportFormat::Markdown => "text/markdown",
            ExportFormat::Rst => "text/x-rst",
            ExportFormat::Latex => "application/x-latex",
            ExportFormat::Strip => "application/json",
        }
    }
}

// ── Export options ────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct ExportOptions {
    /// Include cell outputs in the export.
    pub include_outputs: bool,
    /// Include cell execution counts ([1]:, [2]:, etc.).
    pub include_exec_count: bool,
    /// Include cell metadata (tags, etc.).
    pub include_metadata: bool,
    /// Strip input from cells with the "hide_input" tag.
    pub hide_tagged_input: bool,
    /// Strip output from cells with the "hide_output" tag.
    pub hide_tagged_output: bool,
    /// Only include cells with these tags (empty = all cells).
    pub filter_tags: Vec<String>,
    /// Notebook title override.
    pub title: Option<String>,
}

impl Default for ExportOptions {
    fn default() -> Self {
        Self {
            include_outputs: true,
            include_exec_count: true,
            include_metadata: false,
            hide_tagged_input: true,
            hide_tagged_output: true,
            filter_tags: Vec::new(),
            title: None,
        }
    }
}

// ── Exporter ──────────────────────────────────────────────────────────────────

pub struct NotebookExporter;

impl NotebookExporter {
    pub fn export(
        notebook: &NotebookDocument,
        format: ExportFormat,
        opts: &ExportOptions,
    ) -> String {
        let cells: Vec<CellSnapshot> = notebook
            .cells()
            .iter()
            .map(CellSnapshot::from_cell)
            .collect();
        let title = opts
            .title
            .clone()
            .or_else(|| notebook.metadata.title.clone())
            .unwrap_or_else(|| "Notebook".to_owned());
        let language = notebook.language().to_owned();

        match format {
            ExportFormat::Html => Self::to_html(&cells, &title, &language, opts),
            ExportFormat::Script => Self::to_script(&cells, &language, opts),
            ExportFormat::Markdown => Self::to_markdown(&cells, &title, &language, opts),
            ExportFormat::Rst => Self::to_rst(&cells, &title, &language, opts),
            ExportFormat::Latex => Self::to_latex(&cells, &title, &language, opts),
            ExportFormat::Strip => Self::to_stripped_ipynb(notebook),
        }
    }

    // ── HTML export ───────────────────────────────────────────────────────────

    fn to_html(
        cells: &[CellSnapshot],
        title: &str,
        language: &str,
        opts: &ExportOptions,
    ) -> String {
        let mut body = String::new();

        for (_i, cell) in cells.iter().enumerate() {
            if !Self::cell_visible(cell, opts) {
                continue;
            }

            match cell.cell_type {
                CellType::Markdown => {
                    if !Self::hide_input(cell, opts) {
                        body.push_str(&format!(
                            "<div class=\"cell cell-markdown\">\n<div class=\"cell-source\">\n{}\n</div>\n</div>\n",
                            html_escape(&cell.source_text())
                        ));
                    }
                }
                CellType::Code => {
                    let mut cell_html = String::from("<div class=\"cell cell-code\">\n");

                    if !Self::hide_input(cell, opts) {
                        let prompt = if opts.include_exec_count {
                            format!(
                                "[{}]: ",
                                cell.execution_count
                                    .map(|n| n.to_string())
                                    .unwrap_or_else(|| " ".into())
                            )
                        } else {
                            String::new()
                        };
                        cell_html.push_str(&format!(
                            "<div class=\"cell-input\">\
                             <div class=\"prompt input-prompt\">{}</div>\
                             <div class=\"cell-source\"><pre><code class=\"language-{}\">{}</code></pre></div></div>\n",
                            prompt, language, html_escape(&cell.source_text())
                        ));
                    }

                    if opts.include_outputs
                        && !Self::hide_output(cell, opts)
                        && !cell.outputs.is_empty()
                    {
                        cell_html.push_str("<div class=\"cell-output\">\n");
                        for output in &cell.outputs {
                            cell_html.push_str(&Self::output_to_html(output, cell.execution_count));
                        }
                        cell_html.push_str("</div>\n");
                    }

                    cell_html.push_str("</div>\n");
                    body.push_str(&cell_html);
                }
                CellType::Raw => {
                    if !Self::hide_input(cell, opts) {
                        body.push_str(&format!(
                            "<div class=\"cell cell-raw\"><pre>{}</pre></div>\n",
                            html_escape(&cell.source_text())
                        ));
                    }
                }
            }
        }

        format!(
            r#"<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<style>
  body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          max-width: 900px; margin: 0 auto; padding: 2rem; background: #fff; color: #24292e; }}
  .cell {{ margin: 1rem 0; border: 1px solid #e1e4e8; border-radius: 6px; overflow: hidden; }}
  .cell-input {{ display: flex; background: #f6f8fa; }}
  .prompt {{ font-family: monospace; color: #6a737d; padding: .5rem .75rem; min-width: 5rem;
             text-align: right; border-right: 1px solid #e1e4e8; user-select: none; }}
  .cell-source {{ flex: 1; }}
  pre {{ margin: 0; padding: .75rem; overflow-x: auto; }}
  code {{ font-family: 'JetBrains Mono', 'Fira Code', monospace; font-size: 0.875rem; }}
  .cell-output {{ padding: .75rem; border-top: 1px solid #e1e4e8; }}
  .output-stream {{ font-family: monospace; font-size: 0.875rem; white-space: pre-wrap; }}
  .output-stderr {{ color: #cb2431; }}
  .output-error {{ background: #fff5f5; border-left: 3px solid #cb2431; padding: .5rem; }}
  .output-html {{ overflow-x: auto; }}
  .cell-markdown {{ padding: 1rem; }}
  .execution-count {{ color: #6a737d; font-family: monospace; font-size: 0.75rem; }}
</style>
</head>
<body>
<h1>{title}</h1>
{body}
</body>
</html>"#,
            title = html_escape(title),
            body = body
        )
    }

    fn output_to_html(output: &CellOutput, _exec_count: Option<u32>) -> String {
        match output {
            CellOutput::Stream(s) => {
                let cls = if s.name == StreamName::Stderr {
                    "output-stream output-stderr"
                } else {
                    "output-stream"
                };
                format!(
                    "<div class=\"{}\"><pre>{}</pre></div>\n",
                    cls,
                    html_escape(&s.text)
                )
            }
            CellOutput::DisplayData { data, .. } | CellOutput::ExecuteResult { data, .. } => {
                let count_str = if let CellOutput::ExecuteResult {
                    execution_count, ..
                } = output
                {
                    format!(
                        "<div class=\"execution-count\">[{}]: </div>",
                        execution_count
                    )
                } else {
                    String::new()
                };

                let content = if let Some(text) = data.data.get("text/html") {
                    format!("<div class=\"output-html\">{}</div>", text.as_joined())
                } else if let Some(img) = data.data.get("image/png") {
                    format!(
                        "<img src=\"data:image/png;base64,{}\" style=\"max-width:100%\">",
                        img.as_str()
                    )
                } else if let Some(img) = data.data.get("image/svg+xml") {
                    img.as_joined()
                } else if let Some(text) = data.data.get("text/plain") {
                    format!("<pre>{}</pre>", html_escape(&text.as_joined()))
                } else {
                    String::new()
                };

                format!("{}{}\n", count_str, content)
            }
            CellOutput::Error(e) => {
                format!(
                    "<div class=\"output-error\"><strong>{}: {}</strong><pre>{}</pre></div>\n",
                    html_escape(&e.ename),
                    html_escape(&e.evalue),
                    html_escape(&e.traceback.join("\n"))
                )
            }
        }
    }

    // ── Script export ─────────────────────────────────────────────────────────

    fn to_script(cells: &[CellSnapshot], language: &str, opts: &ExportOptions) -> String {
        let comment = Self::comment_prefix(language);
        let mut out = String::new();

        for cell in cells {
            if !Self::cell_visible(cell, opts) {
                continue;
            }

            match cell.cell_type {
                CellType::Code => {
                    if !Self::hide_input(cell, opts) {
                        if opts.include_exec_count {
                            if let Some(n) = cell.execution_count {
                                out.push_str(&format!("{} In [{}]:\n", comment, n));
                            }
                        }
                        out.push_str(&cell.source_text());
                        if !cell.source_text().ends_with('\n') {
                            out.push('\n');
                        }
                        out.push('\n');

                        if opts.include_outputs && !cell.outputs.is_empty() {
                            for output in &cell.outputs {
                                let text = match output {
                                    CellOutput::Stream(s) => s.text.clone(),
                                    CellOutput::ExecuteResult { data, .. }
                                    | CellOutput::DisplayData { data, .. } => {
                                        data.best_text().unwrap_or("").to_owned()
                                    }
                                    CellOutput::Error(e) => format!("{}: {}", e.ename, e.evalue),
                                };
                                if !text.is_empty() {
                                    for line in text.lines() {
                                        out.push_str(&format!("{} {}\n", comment, line));
                                    }
                                }
                            }
                            out.push('\n');
                        }
                    }
                }
                CellType::Markdown => {
                    for line in cell.source_text().lines() {
                        out.push_str(&format!("{} {}\n", comment, line));
                    }
                    out.push('\n');
                }
                CellType::Raw => {
                    for line in cell.source_text().lines() {
                        out.push_str(&format!("{} {}\n", comment, line));
                    }
                    out.push('\n');
                }
            }
        }
        out
    }

    fn comment_prefix(language: &str) -> &'static str {
        match language {
            "python" | "r" | "ruby" | "bash" | "julia" => "#",
            "javascript" | "typescript" | "java" | "kotlin" | "scala" | "swift" | "go" | "rust"
            | "cpp" | "c" => "//",
            "sql" => "--",
            "matlab" | "octave" => "%",
            "haskell" => "--",
            _ => "#",
        }
    }

    // ── Markdown export ───────────────────────────────────────────────────────

    fn to_markdown(
        cells: &[CellSnapshot],
        title: &str,
        language: &str,
        opts: &ExportOptions,
    ) -> String {
        let mut out = format!("# {}\n\n", title);

        for cell in cells {
            if !Self::cell_visible(cell, opts) {
                continue;
            }

            match cell.cell_type {
                CellType::Markdown => {
                    if !Self::hide_input(cell, opts) {
                        out.push_str(&cell.source_text());
                        if !cell.source_text().ends_with('\n') {
                            out.push('\n');
                        }
                        out.push('\n');
                    }
                }
                CellType::Code => {
                    if !Self::hide_input(cell, opts) {
                        if opts.include_exec_count {
                            if let Some(n) = cell.execution_count {
                                out.push_str(&format!("<!-- In [{}] -->\n", n));
                            }
                        }
                        out.push_str(&format!(
                            "```{}\n{}\n```\n\n",
                            language,
                            cell.source_text().trim_end()
                        ));
                    }

                    if opts.include_outputs && !Self::hide_output(cell, opts) {
                        for output in &cell.outputs {
                            match output {
                                CellOutput::Stream(s) => {
                                    if !s.text.is_empty() {
                                        out.push_str("```\n");
                                        out.push_str(&s.text);
                                        if !s.text.ends_with('\n') {
                                            out.push('\n');
                                        }
                                        out.push_str("```\n\n");
                                    }
                                }
                                CellOutput::ExecuteResult { data, .. }
                                | CellOutput::DisplayData { data, .. } => {
                                    if let Some(md) = data.data.get("text/markdown") {
                                        out.push_str(&md.as_joined());
                                        out.push_str("\n\n");
                                    } else if let Some(txt) = data.data.get("text/plain") {
                                        out.push_str("```\n");
                                        out.push_str(&txt.as_joined());
                                        out.push_str("\n```\n\n");
                                    } else if let Some(img) = data.data.get("image/png") {
                                        out.push_str(&format!(
                                            "![output](data:image/png;base64,{})\n\n",
                                            img.as_str()
                                        ));
                                    }
                                }
                                CellOutput::Error(e) => {
                                    out.push_str(&format!("> **{}: {}**\n\n", e.ename, e.evalue));
                                }
                            }
                        }
                    }
                }
                CellType::Raw => {
                    out.push_str(&cell.source_text());
                    out.push_str("\n\n");
                }
            }
        }
        out
    }

    // ── RST export ────────────────────────────────────────────────────────────

    fn to_rst(cells: &[CellSnapshot], title: &str, language: &str, opts: &ExportOptions) -> String {
        let underline = "=".repeat(title.len());
        let mut out = format!("{}\n{}\n\n", title, underline);

        for cell in cells {
            if !Self::cell_visible(cell, opts) {
                continue;
            }

            match cell.cell_type {
                CellType::Markdown => {
                    // RST is similar to Markdown for basic content
                    for line in cell.source_text().lines() {
                        // Convert basic Markdown headings to RST
                        if line.starts_with("## ") {
                            let h = &line[3..];
                            out.push_str(&format!("{}\n{}\n\n", h, "-".repeat(h.len())));
                        } else if line.starts_with("# ") {
                            let h = &line[2..];
                            out.push_str(&format!("{}\n{}\n\n", h, "=".repeat(h.len())));
                        } else {
                            out.push_str(line);
                            out.push('\n');
                        }
                    }
                    out.push('\n');
                }
                CellType::Code => {
                    if !Self::hide_input(cell, opts) {
                        out.push_str(&format!(".. code-block:: {}\n\n", language));
                        for line in cell.source_text().lines() {
                            out.push_str(&format!("   {}\n", line));
                        }
                        out.push('\n');
                    }
                    if opts.include_outputs {
                        for output in &cell.outputs {
                            if let CellOutput::Stream(s) = output {
                                out.push_str("::\n\n");
                                for line in s.text.lines() {
                                    out.push_str(&format!("   {}\n", line));
                                }
                                out.push('\n');
                            }
                        }
                    }
                }
                _ => {}
            }
        }
        out
    }

    // ── LaTeX export ──────────────────────────────────────────────────────────

    fn to_latex(
        cells: &[CellSnapshot],
        title: &str,
        language: &str,
        opts: &ExportOptions,
    ) -> String {
        let mut out = format!(
            r"\documentclass{{article}}
\usepackage{{listings}}
\usepackage{{graphicx}}
\usepackage{{hyperref}}
\usepackage{{amsmath}}
\usepackage{{amssymb}}
\lstset{{language={lang},basicstyle=\ttfamily\small,breaklines=true}}
\title{{{title}}}
\begin{{document}}
\maketitle
",
            lang = Self::latex_language(language),
            title = latex_escape(title)
        );

        for cell in cells {
            if !Self::cell_visible(cell, opts) {
                continue;
            }

            match cell.cell_type {
                CellType::Markdown => {
                    out.push_str(&Self::markdown_to_latex(&cell.source_text()));
                    out.push('\n');
                }
                CellType::Code => {
                    if !Self::hide_input(cell, opts) {
                        out.push_str(&format!(
                            "\\begin{{lstlisting}}\n{}\n\\end{{lstlisting}}\n\n",
                            cell.source_text()
                        ));
                    }
                    if opts.include_outputs {
                        for output in &cell.outputs {
                            if let CellOutput::Stream(s) = output {
                                out.push_str(&format!(
                                    "\\begin{{verbatim}}\n{}\n\\end{{verbatim}}\n\n",
                                    s.text
                                ));
                            } else if let Some(bundle) = output.mime_bundle() {
                                if let Some(latex) = bundle.data.get("text/latex") {
                                    out.push_str(&format!("{}\n\n", latex.as_joined()));
                                } else if let Some(txt) = bundle.data.get("text/plain") {
                                    out.push_str(&format!(
                                        "\\begin{{verbatim}}\n{}\n\\end{{verbatim}}\n\n",
                                        txt.as_joined()
                                    ));
                                }
                            }
                        }
                    }
                }
                _ => {}
            }
        }
        out.push_str(r"\end{document}");
        out
    }

    fn markdown_to_latex(text: &str) -> String {
        let mut result = String::new();
        for line in text.lines() {
            if line.starts_with("### ") {
                result.push_str(&format!(
                    "\\subsubsection{{{}}}\n",
                    latex_escape(&line[4..])
                ));
            } else if line.starts_with("## ") {
                result.push_str(&format!("\\subsection{{{}}}\n", latex_escape(&line[3..])));
            } else if line.starts_with("# ") {
                result.push_str(&format!("\\section{{{}}}\n", latex_escape(&line[2..])));
            } else {
                result.push_str(&latex_escape(line));
                result.push('\n');
            }
        }
        result
    }

    fn latex_language(language: &str) -> &'static str {
        match language {
            "python" => "Python",
            "java" => "Java",
            "rust" => "Rust",
            "javascript" | "typescript" => "JavaScript",
            "r" => "R",
            "bash" => "bash",
            "sql" => "SQL",
            _ => "TeX",
        }
    }

    // ── Stripped .ipynb ───────────────────────────────────────────────────────

    fn to_stripped_ipynb(notebook: &NotebookDocument) -> String {
        let ipynb = IpynbDocument::from_notebook(notebook);
        let mut stripped = ipynb.clone();
        for cell in &mut stripped.cells {
            cell.outputs.clear();
            cell.execution_count = None;
        }
        stripped.to_json_pretty()
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    fn cell_visible(cell: &CellSnapshot, opts: &ExportOptions) -> bool {
        if opts.filter_tags.is_empty() {
            return true;
        }
        opts.filter_tags
            .iter()
            .any(|tag| cell.metadata.tags.contains(tag))
    }

    fn hide_input(cell: &CellSnapshot, opts: &ExportOptions) -> bool {
        opts.hide_tagged_input
            && cell
                .metadata
                .tags
                .iter()
                .any(|t| t == "hide_input" || t == "hide-input")
    }

    fn hide_output(cell: &CellSnapshot, opts: &ExportOptions) -> bool {
        opts.hide_tagged_output
            && cell
                .metadata
                .tags
                .iter()
                .any(|t| t == "hide_output" || t == "hide-output")
    }
}

// ── HTML / LaTeX escaping ─────────────────────────────────────────────────────

fn html_escape(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&#x27;")
}

fn latex_escape(s: &str) -> String {
    s.replace('\\', "\\textbackslash{}")
        .replace('&', "\\&")
        .replace('%', "\\%")
        .replace('$', "\\$")
        .replace('#', "\\#")
        .replace('^', "\\textasciicircum{}")
        .replace('_', "\\_")
        .replace('{', "\\{")
        .replace('}', "\\}")
        .replace('~', "\\textasciitilde{}")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::notebook::cell::CellType;
    use crate::notebook::document::NotebookDocument;
    use crate::notebook::kernel::KernelRegistry;
    use crate::notebook::output::{CellOutput, MimeBundle};

    fn python_notebook_with_content() -> NotebookDocument {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);

        nb.cells_mut()[0].set_source("import numpy as np\nx = np.array([1, 2, 3])\nprint(x)");
        nb.cells_mut()[0].add_output(CellOutput::stdout("[1 2 3]\n"));
        nb.cells_mut()[0].execution_count = Some(1);

        nb.insert_cell_below(CellType::Markdown);
        nb.cells_mut()[1].set_source("## Analysis\n\nThis is the analysis section.");

        nb.insert_cell_below(CellType::Code);
        nb.cells_mut()[2].set_source("x.mean()");
        nb.cells_mut()[2].add_output(CellOutput::result(2, MimeBundle::new().text("2.0")));
        nb.cells_mut()[2].execution_count = Some(2);

        nb
    }

    // ── HTML export ────────────────────────────────────────────────────────────

    #[test]
    fn test_html_export_structure() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions::default();
        let html = NotebookExporter::export(&nb, ExportFormat::Html, &opts);

        assert!(html.contains("<!DOCTYPE html>"));
        assert!(html.contains("<title>"));
        assert!(html.contains("cell-code"));
        assert!(html.contains("cell-markdown"));
        assert!(html.contains("import numpy"));
        assert!(html.contains("Analysis"));
    }

    #[test]
    fn test_html_export_includes_outputs() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions {
            include_outputs: true,
            ..Default::default()
        };
        let html = NotebookExporter::export(&nb, ExportFormat::Html, &opts);
        assert!(html.contains("[1 2 3]"), "stdout should appear in HTML");
    }

    #[test]
    fn test_html_export_no_outputs() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions {
            include_outputs: false,
            ..Default::default()
        };
        let html = NotebookExporter::export(&nb, ExportFormat::Html, &opts);
        assert!(
            !html.contains("[1 2 3]"),
            "stdout should NOT appear when outputs disabled"
        );
    }

    #[test]
    fn test_html_escape() {
        assert_eq!(html_escape("<script>"), "&lt;script&gt;");
        assert_eq!(html_escape("a & b"), "a &amp; b");
        assert_eq!(html_escape("\"quoted\""), "&quot;quoted&quot;");
    }

    #[test]
    fn test_html_export_exec_count() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions {
            include_exec_count: true,
            ..Default::default()
        };
        let html = NotebookExporter::export(&nb, ExportFormat::Html, &opts);
        assert!(
            html.contains("[1]:") || html.contains("[1]"),
            "Execution count should appear"
        );
    }

    // ── Script export ──────────────────────────────────────────────────────────

    #[test]
    fn test_script_export_python() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions::default();
        let script = NotebookExporter::export(&nb, ExportFormat::Script, &opts);

        assert!(script.contains("import numpy as np"));
        assert!(
            script.contains("# ## Analysis"),
            "Markdown should be commented out"
        );
        assert!(script.contains("x.mean()"));
    }

    #[test]
    fn test_script_export_comment_prefixes() {
        assert_eq!(NotebookExporter::comment_prefix("python"), "#");
        assert_eq!(NotebookExporter::comment_prefix("java"), "//");
        assert_eq!(NotebookExporter::comment_prefix("sql"), "--");
        assert_eq!(NotebookExporter::comment_prefix("haskell"), "--");
        assert_eq!(NotebookExporter::comment_prefix("matlab"), "%");
    }

    #[test]
    fn test_script_output_as_comments() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions {
            include_outputs: true,
            ..Default::default()
        };
        let s = NotebookExporter::export(&nb, ExportFormat::Script, &opts);
        assert!(s.contains("# [1 2 3]"), "Output should appear as comment");
    }

    // ── Markdown export ────────────────────────────────────────────────────────

    #[test]
    fn test_markdown_export_structure() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions::default();
        let md = NotebookExporter::export(&nb, ExportFormat::Markdown, &opts);

        assert!(md.contains("# "), "Should have H1 title");
        assert!(md.contains("```python"), "Code should be in fenced blocks");
        assert!(md.contains("import numpy"));
        assert!(md.contains("## Analysis"));
    }

    #[test]
    fn test_markdown_export_outputs_as_code_block() {
        let nb = python_notebook_with_content();
        let opts = ExportOptions {
            include_outputs: true,
            ..Default::default()
        };
        let md = NotebookExporter::export(&nb, ExportFormat::Markdown, &opts);
        assert!(
            md.contains("[1 2 3]"),
            "stdout should appear in markdown output block"
        );
    }

    #[test]
    fn test_markdown_export_error_output() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        nb.cells_mut()[0].set_source("1/0");
        nb.cells_mut()[0].add_output(CellOutput::error(
            "ZeroDivisionError",
            "division by zero",
            vec![],
        ));
        let md = NotebookExporter::export(&nb, ExportFormat::Markdown, &ExportOptions::default());
        assert!(
            md.contains("ZeroDivisionError"),
            "Error should appear in markdown"
        );
    }

    // ── RST export ─────────────────────────────────────────────────────────────

    #[test]
    fn test_rst_export_structure() {
        let nb = python_notebook_with_content();
        let rst = NotebookExporter::export(&nb, ExportFormat::Rst, &ExportOptions::default());
        assert!(rst.contains(".. code-block::"));
        assert!(rst.contains("import numpy"));
    }

    // ── LaTeX export ──────────────────────────────────────────────────────────

    #[test]
    fn test_latex_export_structure() {
        let nb = python_notebook_with_content();
        let tex = NotebookExporter::export(&nb, ExportFormat::Latex, &ExportOptions::default());
        assert!(tex.contains("\\documentclass"));
        assert!(tex.contains("\\begin{document}"));
        assert!(tex.contains("\\end{document}"));
        assert!(tex.contains("\\begin{lstlisting}"));
        assert!(tex.contains("import numpy"));
    }

    #[test]
    fn test_latex_escape() {
        assert_eq!(latex_escape("a & b"), "a \\& b");
        assert_eq!(latex_escape("50%"), "50\\%");
        assert_eq!(latex_escape("$x$"), "\\$x\\$");
        assert_eq!(latex_escape("a_b"), "a\\_b");
    }

    // ── Strip export ───────────────────────────────────────────────────────────

    #[test]
    fn test_strip_export_removes_outputs() {
        let nb = python_notebook_with_content();
        let json = NotebookExporter::export(&nb, ExportFormat::Strip, &ExportOptions::default());
        let ipynb = IpynbDocument::from_json(&json).unwrap();
        for cell in &ipynb.cells {
            assert!(
                cell.outputs.is_empty(),
                "Stripped notebook should have no outputs"
            );
            assert!(
                cell.execution_count.is_none(),
                "Stripped notebook should have no exec counts"
            );
        }
    }

    #[test]
    fn test_strip_export_keeps_source() {
        let nb = python_notebook_with_content();
        let json = NotebookExporter::export(&nb, ExportFormat::Strip, &ExportOptions::default());
        assert!(
            json.contains("import numpy"),
            "Stripped notebook should keep source code"
        );
    }

    // ── Tag filtering ──────────────────────────────────────────────────────────

    #[test]
    fn test_hide_tagged_input() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        nb.cells_mut()[0].set_source("secret = 'hidden code'");
        nb.cells_mut()[0].metadata.tags.push("hide_input".into());

        let opts = ExportOptions {
            hide_tagged_input: true,
            ..Default::default()
        };
        let md = NotebookExporter::export(&nb, ExportFormat::Markdown, &opts);
        assert!(!md.contains("secret"), "Input should be hidden due to tag");
    }

    // ── ExportFormat helpers ───────────────────────────────────────────────────

    #[test]
    fn test_export_format_extensions() {
        assert_eq!(ExportFormat::Html.file_extension(), ".html");
        assert_eq!(ExportFormat::Markdown.file_extension(), ".md");
        assert_eq!(ExportFormat::Latex.file_extension(), ".tex");
        assert_eq!(ExportFormat::Strip.file_extension(), ".ipynb");
    }

    #[test]
    fn test_export_format_mime_types() {
        assert_eq!(ExportFormat::Html.mime_type(), "text/html");
        assert_eq!(ExportFormat::Markdown.mime_type(), "text/markdown");
        assert_eq!(ExportFormat::Latex.mime_type(), "application/x-latex");
    }
}
