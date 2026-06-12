// src/notebook/magic.rs
//
// Magic command parser — handles IPython-style magic commands.
//
// Line magics  (%cmd args)  affect only one line.
// Cell magics  (%%cmd args) affect the whole cell.
//
// Built-in magics:
//   %timeit / %%timeit    — time execution of code
//   %time                 — time a single statement
//   %run                  — run a Python script
//   %load / %loadfile     — load file content into cell
//   %env                  — set/get environment variables
//   %matplotlib           — configure matplotlib backend
//   %%bash / %%sh         — run cell as shell script
//   %%python              — run cell as Python (in subprocess)
//   %%javascript / %%js   — run cell as JavaScript
//   %%html                — render cell as HTML
//   %%markdown            — render cell as Markdown
//   %%latex               — render cell as LaTeX
//   %%sql                 — run cell as SQL
//   %who / %whos          — list variables
//   %history              — show command history
//   %reset                — reset kernel namespace
//   %pip / %conda         — install packages
//   %cd / %pwd            — directory operations
//   %lsmagic              — list all magics
//   %capture              — capture output

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Magic kind ────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum MagicKind {
    /// `%cmd` — applies to a single line.
    Line,
    /// `%%cmd` — applies to the entire cell.
    Cell,
}

// ── Parsed magic ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParsedMagic {
    pub kind: MagicKind,
    /// Magic name (without % prefix): "timeit", "bash", "html"
    pub name: String,
    /// Arguments on the same line as the magic declaration.
    pub args: String,
    /// The cell body (for cell magics — everything after the first line).
    pub body: String,
    /// Parsed key-value options: -n 100 → {"n": "100"}
    pub options: HashMap<String, String>,
}

impl ParsedMagic {
    /// True if this magic should be executed by the *engine* (not sent to kernel).
    pub fn is_builtin(&self) -> bool {
        BUILTIN_MAGICS.iter().any(|(name, kind, _)| {
            name == &self.name.as_str() && (*kind == MagicKind::Line || *kind == MagicKind::Cell)
        })
    }

    /// Get a positional argument by index.
    pub fn arg(&self, idx: usize) -> Option<&str> {
        self.args.split_whitespace().nth(idx)
    }

    /// Get an option value by flag name (without dash).
    pub fn option(&self, key: &str) -> Option<&str> {
        self.options.get(key).map(|s| s.as_str())
    }

    /// The number to repeat for %timeit (defaults to 7 runs × 1000 loops).
    pub fn timeit_params(&self) -> (u32, u32) {
        let n: u32 = self
            .options
            .get("n")
            .and_then(|v| v.parse().ok())
            .unwrap_or(7);
        let r: u32 = self
            .options
            .get("r")
            .and_then(|v| v.parse().ok())
            .unwrap_or(1000);
        (n, r)
    }
}

/// (name, kind, description)
const BUILTIN_MAGICS: &[(&str, MagicKind, &str)] = &[
    // Timing
    (
        "timeit",
        MagicKind::Line,
        "Time statement execution (average of multiple runs)",
    ),
    ("timeit", MagicKind::Cell, "Time cell execution"),
    ("time", MagicKind::Line, "Time single statement execution"),
    // File operations
    (
        "run",
        MagicKind::Line,
        "Run a Python script in the current namespace",
    ),
    (
        "load",
        MagicKind::Line,
        "Load source code from file into cell",
    ),
    (
        "loadfile",
        MagicKind::Line,
        "Load source code from file into cell",
    ),
    ("save", MagicKind::Line, "Save cell source to file"),
    // Environment
    ("env", MagicKind::Line, "Get/set environment variables"),
    ("cd", MagicKind::Line, "Change working directory"),
    ("pwd", MagicKind::Line, "Print working directory"),
    ("ls", MagicKind::Line, "List directory contents"),
    // Cell rendering
    ("html", MagicKind::Cell, "Render cell as HTML"),
    ("markdown", MagicKind::Cell, "Render cell as Markdown"),
    ("latex", MagicKind::Cell, "Render cell as LaTeX"),
    ("svg", MagicKind::Cell, "Render cell as SVG"),
    ("javascript", MagicKind::Cell, "Execute cell as JavaScript"),
    ("js", MagicKind::Cell, "Execute cell as JavaScript (alias)"),
    // Shell
    ("bash", MagicKind::Cell, "Execute cell as Bash shell script"),
    ("sh", MagicKind::Cell, "Execute cell as shell script"),
    ("powershell", MagicKind::Cell, "Execute cell as PowerShell"),
    (
        "python",
        MagicKind::Cell,
        "Execute cell as Python in subprocess",
    ),
    // Language overrides
    ("sql", MagicKind::Cell, "Execute cell as SQL query"),
    ("ruby", MagicKind::Cell, "Execute cell with Ruby"),
    ("perl", MagicKind::Cell, "Execute cell with Perl"),
    ("r", MagicKind::Cell, "Execute cell with R"),
    // Package management
    ("pip", MagicKind::Line, "Run pip package manager"),
    ("conda", MagicKind::Line, "Run conda package manager"),
    (
        "apt",
        MagicKind::Line,
        "Run apt package manager (Colab/Linux)",
    ),
    // Namespace
    ("who", MagicKind::Line, "Print interactive variables"),
    (
        "whos",
        MagicKind::Line,
        "Print interactive variables with details",
    ),
    ("reset", MagicKind::Line, "Reset the kernel namespace"),
    // History
    ("history", MagicKind::Line, "Show input history"),
    ("recall", MagicKind::Line, "Recall a history entry"),
    // Output capture
    ("capture", MagicKind::Cell, "Capture output into a variable"),
    // Matplotlib
    (
        "matplotlib",
        MagicKind::Line,
        "Configure matplotlib backend",
    ),
    // Utilities
    ("lsmagic", MagicKind::Line, "List available magic commands"),
    ("magic", MagicKind::Line, "Show information about magics"),
    (
        "pinfo",
        MagicKind::Line,
        "Provide detailed info about an object",
    ),
    (
        "pinfo2",
        MagicKind::Line,
        "Provide extra detailed info about an object",
    ),
    (
        "pdef",
        MagicKind::Line,
        "Print the definition header for an object",
    ),
    ("pdoc", MagicKind::Line, "Print the docstring for an object"),
    (
        "psource",
        MagicKind::Line,
        "Print source code for an object",
    ),
    ("debug", MagicKind::Line, "Activate debugger on error"),
    ("pdb", MagicKind::Line, "Control automatic pdb invocation"),
    (
        "autoreload",
        MagicKind::Line,
        "Auto-reload modified modules",
    ),
];

// ── Magic parser ──────────────────────────────────────────────────────────────

pub struct MagicParser;

impl MagicParser {
    /// Check if a source string starts with a magic command.
    pub fn is_magic(source: &str) -> bool {
        let trimmed = source.trim_start();
        trimmed.starts_with("%%") || trimmed.starts_with('%')
    }

    /// Parse the magic from a cell source.
    /// Returns None if the source is not a magic command.
    pub fn parse(source: &str) -> Option<ParsedMagic> {
        let source = source.trim_start();

        if source.starts_with("%%") {
            Self::parse_cell_magic(source)
        } else if source.starts_with('%') && !source.starts_with("%%") {
            Self::parse_line_magic(source)
        } else {
            None
        }
    }

    fn parse_cell_magic(source: &str) -> Option<ParsedMagic> {
        // %%name args\nbody
        let rest = &source[2..]; // strip %%
        let lines: Vec<&str> = rest.splitn(2, '\n').collect();
        let first_line = lines[0].trim();
        let body = lines.get(1).copied().unwrap_or_default().to_owned();

        let (name, args_str) = Self::split_name_args(first_line);
        let options = Self::parse_options(&args_str);

        Some(ParsedMagic {
            kind: MagicKind::Cell,
            name: name.to_lowercase(),
            args: args_str,
            body,
            options,
        })
    }

    fn parse_line_magic(source: &str) -> Option<ParsedMagic> {
        // %name args
        let rest = &source[1..]; // strip %
        let line = rest.lines().next().unwrap_or("").trim();
        let (name, args_str) = Self::split_name_args(line);
        let options = Self::parse_options(&args_str);

        Some(ParsedMagic {
            kind: MagicKind::Line,
            name: name.to_lowercase(),
            args: args_str,
            body: String::new(),
            options,
        })
    }

    fn split_name_args(s: &str) -> (String, String) {
        let mut iter = s.splitn(2, char::is_whitespace);
        let name = iter.next().unwrap_or("").trim().to_owned();
        let args = iter.next().unwrap_or("").trim().to_owned();
        (name, args)
    }

    /// Parse `-key value` and `--flag` options from args string.
    fn parse_options(args: &str) -> HashMap<String, String> {
        let mut opts = HashMap::new();
        let mut tokens = args.split_whitespace().peekable();
        while let Some(token) = tokens.next() {
            if token.starts_with("--") {
                opts.insert(token[2..].to_owned(), "true".to_owned());
            } else if token.starts_with('-') && token.len() > 1 {
                let key = &token[1..];
                let val = match tokens.peek().copied() {
                    Some(v) if !v.starts_with('-') => tokens.next().unwrap_or("").to_owned(),
                    _ => "true".to_owned(),
                };
                opts.insert(key.to_owned(), val);
            }
        }
        opts
    }

    /// Translate a magic command into kernel-executable code.
    /// Returns the transformed source or None if the magic is engine-only.
    pub fn transform_for_kernel(magic: &ParsedMagic) -> Option<String> {
        match (magic.kind, magic.name.as_str()) {
            // Timing
            (MagicKind::Line, "timeit") => {
                let (n, r) = magic.timeit_params();
                Some(format!(
                    "import timeit as _timeit_module\n\
                     _t = _timeit_module.repeat(lambda: {}, number={}, repeat={})\n\
                     print(f'{{min(_t)*1e3:.3f}} ms ± {{(_t[-1]-_t[0])*1e3:.3f}} ms per loop')",
                    magic.args, r, n
                ))
            }
            (MagicKind::Cell, "timeit") => {
                let (n, r) = magic.timeit_params();
                let code = magic.body.replace('\n', "\\n").replace('"', "\\\"");
                Some(format!(
                    "import timeit as _t\n\
                     _res = _t.repeat('{}', number={}, repeat={})\n\
                     print(f'{{min(_res)*1e3:.3f}} ms per loop (mean ± std. dev. of {} runs)')",
                    code, r, n, n
                ))
            }
            // Shell pass-through cells
            (MagicKind::Cell, "bash") | (MagicKind::Cell, "sh") => {
                Some(format!(
                    "import subprocess as _sp\n\
                     _r = _sp.run('{}', shell=True, capture_output=True, text=True)\n\
                     print(_r.stdout, end='')\n\
                     if _r.stderr: print(_r.stderr, end='')",
                    magic.body.replace('\'', "\\'")))
            }
            // Package managers
            (MagicKind::Line, "pip") => {
                Some(format!("import sys; import subprocess; subprocess.check_call([sys.executable, '-m', 'pip', {}])",
                    magic.args.split_whitespace().map(|a| format!("'{}'", a)).collect::<Vec<_>>().join(", ")))
            }
            (MagicKind::Line, "conda") => {
                Some(format!("import subprocess; subprocess.check_call(['conda', {}])",
                    magic.args.split_whitespace().map(|a| format!("'{}'", a)).collect::<Vec<_>>().join(", ")))
            }
            // Environment
            (MagicKind::Line, "env") => {
                if magic.args.contains('=') {
                    let parts: Vec<&str> = magic.args.splitn(2, '=').collect();
                    Some(format!("import os; os.environ['{}'] = '{}'",
                        parts[0].trim(), parts[1].trim()))
                } else if magic.args.is_empty() {
                    Some("import os; print('\\n'.join(f'{k}={v}' for k,v in sorted(os.environ.items())))".into())
                } else {
                    Some(format!("import os; print(os.environ.get('{}', 'not set'))", magic.args.trim()))
                }
            }
            // Directory
            (MagicKind::Line, "cd") => {
                Some(format!("import os; os.chdir('{}'); print(os.getcwd())", magic.args.trim()))
            }
            (MagicKind::Line, "pwd") => {
                Some("import os; print(os.getcwd())".into())
            }
            (MagicKind::Line, "ls") => {
                let path = if magic.args.is_empty() { ".".into() } else { magic.args.clone() };
                Some(format!("import os; print('\\n'.join(sorted(os.listdir('{}'))))", path))
            }
            // Who/whos
            (MagicKind::Line, "who") => {
                Some("print(' '.join(k for k,v in locals().items() if not k.startswith('_')))".into())
            }
            (MagicKind::Line, "whos") => {
                Some("print('\\n'.join(f'{k:<20} {type(v).__name__:<15} {repr(v)[:50]}' for k,v in locals().items() if not k.startswith('_')))".into())
            }
            // %run
            (MagicKind::Line, "run") => {
                let path = magic.arg(0).unwrap_or("");
                Some(format!("exec(open('{}').read(), globals())", path))
            }
            // %lsmagic
            (MagicKind::Line, "lsmagic") => {
                let names: Vec<&str> = BUILTIN_MAGICS.iter().map(|(n,_,_)| *n).collect();
                Some(format!("print('Available magics: {}')", names.join(", ")))
            }
            // %history
            (MagicKind::Line, "history") => {
                Some("# history not available outside IPython".into())
            }
            // HTML/Markdown/LaTeX — engine handles these via display output
            (MagicKind::Cell, "html") | (MagicKind::Cell, "markdown")
            | (MagicKind::Cell, "latex") | (MagicKind::Cell, "svg") => None,
            // JavaScript
            (MagicKind::Cell, "javascript") | (MagicKind::Cell, "js") => None,
            // SQL — engine or extension handles
            (MagicKind::Cell, "sql") => None,
            // Default: not transformable by engine
            _ => None,
        }
    }

    /// Handle engine-side magics that produce immediate output
    /// (HTML, Markdown, LaTeX) without sending to the kernel.
    pub fn execute_display_magic(
        magic: &ParsedMagic,
    ) -> Option<crate::notebook::output::CellOutput> {
        use crate::notebook::output::{CellOutput, MimeBundle};
        match (magic.kind, magic.name.as_str()) {
            (MagicKind::Cell, "html") => {
                Some(CellOutput::display(MimeBundle::new().html(&magic.body)))
            }
            (MagicKind::Cell, "markdown") => {
                Some(CellOutput::display(MimeBundle::new().markdown(&magic.body)))
            }
            (MagicKind::Cell, "latex") => {
                Some(CellOutput::display(MimeBundle::new().latex(&magic.body)))
            }
            (MagicKind::Cell, "svg") => {
                Some(CellOutput::display(MimeBundle::new().svg(&magic.body)))
            }
            _ => None,
        }
    }

    /// List all known magic names.
    pub fn all_magics() -> Vec<MagicInfo> {
        let mut seen = std::collections::HashSet::new();
        BUILTIN_MAGICS
            .iter()
            .filter_map(|(name, kind, desc)| {
                let key = format!("{:?}{}", kind, name);
                if seen.insert(key) {
                    Some(MagicInfo {
                        name: name.to_string(),
                        kind: *kind,
                        description: desc.to_string(),
                    })
                } else {
                    None
                }
            })
            .collect()
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct MagicInfo {
    pub name: String,
    pub kind: MagicKind,
    pub description: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_magic_line() {
        assert!(MagicParser::is_magic("%timeit x+1"));
        assert!(MagicParser::is_magic("%pip install numpy"));
        assert!(!MagicParser::is_magic("x = 1"));
        assert!(!MagicParser::is_magic("# comment"));
    }

    #[test]
    fn test_is_magic_cell() {
        assert!(MagicParser::is_magic("%%bash\necho hello"));
        assert!(MagicParser::is_magic("%%html\n<b>bold</b>"));
    }

    #[test]
    fn test_parse_line_magic() {
        let m = MagicParser::parse("%timeit x + 1").unwrap();
        assert_eq!(m.kind, MagicKind::Line);
        assert_eq!(m.name, "timeit");
        assert_eq!(m.args, "x + 1");
    }

    #[test]
    fn test_parse_cell_magic() {
        let src = "%%bash\necho hello\necho world\n";
        let m = MagicParser::parse(src).unwrap();
        assert_eq!(m.kind, MagicKind::Cell);
        assert_eq!(m.name, "bash");
        assert!(m.body.contains("echo hello"));
        assert!(m.body.contains("echo world"));
    }

    #[test]
    fn test_parse_magic_with_options() {
        let m = MagicParser::parse("%timeit -n 10 -r 100 x + 1").unwrap();
        assert_eq!(m.option("n"), Some("10"));
        assert_eq!(m.option("r"), Some("100"));
    }

    #[test]
    fn test_parse_cell_magic_with_args() {
        let m = MagicParser::parse("%%capture output\nprint('hello')").unwrap();
        assert_eq!(m.name, "capture");
        assert_eq!(m.args, "output");
        assert_eq!(m.body, "print('hello')");
    }

    #[test]
    fn test_transform_pip_magic() {
        let m = MagicParser::parse("%pip install numpy pandas").unwrap();
        let code = MagicParser::transform_for_kernel(&m).unwrap();
        assert!(code.contains("pip"));
        assert!(code.contains("numpy"));
        assert!(code.contains("pandas"));
    }

    #[test]
    fn test_transform_env_set() {
        let m = MagicParser::parse("%env MY_VAR=hello").unwrap();
        let code = MagicParser::transform_for_kernel(&m).unwrap();
        assert!(code.contains("MY_VAR"));
        assert!(code.contains("hello"));
        assert!(code.contains("os.environ"));
    }

    #[test]
    fn test_transform_cd() {
        let m = MagicParser::parse("%cd /tmp").unwrap();
        let code = MagicParser::transform_for_kernel(&m).unwrap();
        assert!(code.contains("os.chdir"));
        assert!(code.contains("/tmp"));
    }

    #[test]
    fn test_transform_bash_magic() {
        let src = "%%bash\necho 'hello world'";
        let m = MagicParser::parse(src).unwrap();
        let code = MagicParser::transform_for_kernel(&m).unwrap();
        assert!(code.contains("subprocess"));
        assert!(code.contains("echo"));
    }

    #[test]
    fn test_display_magic_html() {
        let src = "%%html\n<h1>Hello</h1>";
        let m = MagicParser::parse(src).unwrap();
        let output = MagicParser::execute_display_magic(&m).unwrap();
        if let crate::notebook::output::CellOutput::DisplayData { data, .. } = output {
            assert!(data.has_html());
            assert!(data.best_text().unwrap().contains("Hello"));
        } else {
            panic!("Expected DisplayData output");
        }
    }

    #[test]
    fn test_display_magic_markdown() {
        let src = "%%markdown\n# Heading\nSome text";
        let m = MagicParser::parse(src).unwrap();
        let output = MagicParser::execute_display_magic(&m).unwrap();
        assert!(!output.is_error());
    }

    #[test]
    fn test_html_magic_returns_none_transform() {
        let m = MagicParser::parse("%%html\n<b>hi</b>").unwrap();
        // HTML magic is engine-handled, not kernel-transformed
        assert!(MagicParser::transform_for_kernel(&m).is_none());
    }

    #[test]
    fn test_non_magic_returns_none() {
        assert!(MagicParser::parse("x = 1 + 2").is_none());
        assert!(MagicParser::parse("def foo(): pass").is_none());
    }

    #[test]
    fn test_lsmagic() {
        let m = MagicParser::parse("%lsmagic").unwrap();
        let code = MagicParser::transform_for_kernel(&m).unwrap();
        assert!(code.contains("print"));
    }

    #[test]
    fn test_all_magics_list() {
        let magics = MagicParser::all_magics();
        assert!(!magics.is_empty());
        assert!(magics.iter().any(|m| m.name == "timeit"));
        assert!(magics
            .iter()
            .any(|m| m.name == "bash" && m.kind == MagicKind::Cell));
        assert!(magics.iter().any(|m| m.name == "pip"));
    }

    #[test]
    fn test_timeit_params() {
        let m = MagicParser::parse("%timeit -n 3 -r 50 sum(range(100))").unwrap();
        let (n, r) = m.timeit_params();
        assert_eq!(n, 3);
        assert_eq!(r, 50);
    }

    #[test]
    fn test_timeit_params_defaults() {
        let m = MagicParser::parse("%timeit x + 1").unwrap();
        let (n, r) = m.timeit_params();
        assert_eq!(n, 7);
        assert_eq!(r, 1000);
    }
}
