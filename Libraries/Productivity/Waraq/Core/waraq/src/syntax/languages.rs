// src/syntax/languages.rs
//
// Language detection by file extension or shebang line.

pub fn detect_language(filename: &str, first_line: Option<&str>) -> Option<&'static str> {
    // By extension
    if let Some((_, ext)) = filename.rsplit_once('.') {
        let lang = match ext.to_lowercase().as_str() {
            "rs" => "rust",
            "js" | "mjs" | "cjs" => "javascript",
            "ts" => "typescript",
            "tsx" => "tsx",
            "jsx" => "jsx",
            "py" | "pyw" => "python",
            "java" => "java",
            "kt" | "kts" => "kotlin",
            "swift" => "swift",
            "go" => "go",
            "c" | "h" => "c",
            "cpp" | "cc" | "cxx" | "hpp" => "cpp",
            "cs" => "csharp",
            "rb" => "ruby",
            "php" => "php",
            "html" | "htm" => "html",
            "css" => "css",
            "scss" | "sass" => "scss",
            "json" => "json",
            "toml" => "toml",
            "yaml" | "yml" => "yaml",
            "md" | "mdx" => "markdown",
            "sh" | "bash" | "zsh" => "bash",
            "sql" => "sql",
            "lua" => "lua",
            "dart" => "dart",
            _ => return None,
        };
        return Some(lang);
    }

    // By shebang
    if let Some(line) = first_line {
        if line.starts_with("#!") {
            if line.contains("python") {
                return Some("python");
            }
            if line.contains("node") || line.contains("deno") {
                return Some("javascript");
            }
            if line.contains("bash") || line.contains("sh") {
                return Some("bash");
            }
            if line.contains("ruby") {
                return Some("ruby");
            }
            if line.contains("perl") {
                return Some("perl");
            }
        }
    }

    None
}

/// Is this language supported by tree-sitter grammars?
pub fn has_grammar(lang: &str) -> bool {
    matches!(
        lang,
        "rust"
            | "javascript"
            | "typescript"
            | "tsx"
            | "python"
            | "java"
            | "c"
            | "cpp"
            | "go"
            | "ruby"
            | "html"
            | "css"
            | "json"
            | "toml"
            | "yaml"
            | "bash"
            | "kotlin"
            | "dart"
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rust_extension() {
        assert_eq!(detect_language("main.rs", None), Some("rust"));
        assert_eq!(detect_language("lib.rs", None), Some("rust"));
    }

    #[test]
    fn test_javascript_extensions() {
        assert_eq!(detect_language("app.js", None), Some("javascript"));
        assert_eq!(detect_language("app.mjs", None), Some("javascript"));
        assert_eq!(detect_language("app.jsx", None), Some("jsx"));
    }

    #[test]
    fn test_typescript_extensions() {
        assert_eq!(detect_language("app.ts", None), Some("typescript"));
        assert_eq!(detect_language("app.tsx", None), Some("tsx"));
    }

    #[test]
    fn test_python_extension() {
        assert_eq!(detect_language("script.py", None), Some("python"));
        assert_eq!(detect_language("script.pyw", None), Some("python"));
    }

    #[test]
    fn test_unknown_extension() {
        assert_eq!(detect_language("file.xyz", None), None);
        assert_eq!(detect_language("Makefile", None), None);
    }

    #[test]
    fn test_python_shebang() {
        assert_eq!(
            detect_language("script", Some("#!/usr/bin/env python3")),
            Some("python")
        );
    }

    #[test]
    fn test_node_shebang() {
        assert_eq!(
            detect_language("script", Some("#!/usr/bin/env node")),
            Some("javascript")
        );
    }

    #[test]
    fn test_has_grammar() {
        assert!(has_grammar("rust"));
        assert!(has_grammar("python"));
        assert!(has_grammar("javascript"));
        assert!(!has_grammar("unknown_lang_xyz"));
    }

    #[test]
    fn test_dart_extension() {
        assert_eq!(detect_language("main.dart", None), Some("dart"));
    }

    #[test]
    fn test_java_extension() {
        assert_eq!(detect_language("Main.java", None), Some("java"));
    }

    #[test]
    fn test_go_extension() {
        assert_eq!(detect_language("main.go", None), Some("go"));
    }

    #[test]
    fn test_markdown_extension() {
        assert_eq!(detect_language("README.md", None), Some("markdown"));
        assert_eq!(detect_language("post.mdx", None), Some("markdown"));
    }
}
