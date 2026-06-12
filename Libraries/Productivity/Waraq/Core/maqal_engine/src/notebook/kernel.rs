// src/notebook/kernel.rs
//
// Kernel protocol — the Jupyter messaging protocol (wire format) and
// the kernel registry that maps language names to kernel specs.
//
// Jupyter uses ZeroMQ for local kernels and WebSocket for remote kernels.
// This module defines:
//   1. KernelSpec     — metadata about an available kernel
//   2. KernelRegistry — all known kernels + discovery from jupyter kernelspec
//   3. KernelStatus   — lifecycle state machine
//   4. JupyterMessage — the wire protocol message format
//   5. Request/Reply types for all channels
//
// The actual ZMQ/WebSocket transport is NOT here — that lives in the
// platform layer. This module only defines types so the engine remains
// portable (WASM, native, FFI all share the same types).

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Kernel spec ───────────────────────────────────────────────────────────────

/// A kernel specification — equivalent to kernelspec JSON in Jupyter.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KernelSpec {
    /// Human-readable display name: "Python 3 (ipykernel)"
    pub display_name: String,
    /// Language this kernel executes: "python", "java", "rust", etc.
    pub language: String,
    /// Command to start the kernel: ["python", "-m", "ipykernel_launcher", "-f", "{connection_file}"]
    pub argv: Vec<String>,
    /// Environment variables to set.
    pub env: HashMap<String, String>,
    /// Interrupt signal type: "message" (preferred) or "signal" (unix kill)
    pub interrupt_mode: InterruptMode,
    /// Kernel display metadata.
    pub metadata: KernelMetadata,
    /// Unique key identifying this kernel type.
    pub kernel_name: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum InterruptMode {
    Signal,
    Message,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KernelMetadata {
    pub version: Option<String>,
    pub debugger: bool,
    pub codemirror_mode: Option<serde_json::Value>,
    pub pygments_lexer: Option<String>,
    pub file_extension: Option<String>,
    pub mimetype: Option<String>,
}

impl Default for KernelMetadata {
    fn default() -> Self {
        Self {
            version: None,
            debugger: false,
            codemirror_mode: None,
            pygments_lexer: None,
            file_extension: None,
            mimetype: None,
        }
    }
}

impl KernelSpec {
    /// Build a spec for a well-known kernel.
    pub fn known(name: &str) -> Option<Self> {
        KNOWN_KERNELS.iter().find(|(k, _, _, _)| *k == name).map(
            |(kernel_name, display_name, language, file_ext)| {
                KernelSpec {
                    display_name: display_name.to_string(),
                    language: language.to_string(),
                    argv: vec![], // platform fills this in
                    env: HashMap::new(),
                    interrupt_mode: InterruptMode::Signal,
                    metadata: KernelMetadata {
                        file_extension: Some(file_ext.to_string()),
                        ..Default::default()
                    },
                    kernel_name: kernel_name.to_string(),
                }
            },
        )
    }
}

/// (kernel_name, display_name, language, file_extension)
const KNOWN_KERNELS: &[(&str, &str, &str, &str)] = &[
    ("python3", "Python 3 (ipykernel)", "python", ".py"),
    ("python2", "Python 2 (ipykernel)", "python", ".py"),
    ("ir", "R", "r", ".r"),
    ("julia-1.9", "Julia 1.9", "julia", ".jl"),
    ("julia-1.10", "Julia 1.10", "julia", ".jl"),
    ("java", "Java (IJava)", "java", ".java"),
    ("kotlin", "Kotlin (kotlin-jupyter)", "kotlin", ".kt"),
    ("scala", "Scala (almond)", "scala", ".scala"),
    (
        "javascript",
        "JavaScript (Node.js tslab)",
        "javascript",
        ".js",
    ),
    ("typescript", "TypeScript (tslab)", "typescript", ".ts"),
    ("rust", "Rust (evcxr)", "rust", ".rs"),
    ("c++14", "C++ (xeus-cling)", "cpp", ".cpp"),
    ("c++17", "C++ 17 (xeus-cling)", "cpp", ".cpp"),
    ("bash", "Bash", "bash", ".sh"),
    ("sql", "SQL (xeus-sqlite)", "sql", ".sql"),
    ("haskell", "Haskell (IHaskell)", "haskell", ".hs"),
    ("go", "Go (gophernotes)", "go", ".go"),
    ("ruby", "Ruby (IRuby)", "ruby", ".rb"),
    ("swift", "Swift", "swift", ".swift"),
    ("lua", "Lua", "lua", ".lua"),
    ("perl5", "Perl 5 (IPerl)", "perl", ".pl"),
    ("elixir", "Elixir", "elixir", ".ex"),
    ("erlang", "Erlang", "erlang", ".erl"),
    ("octave", "Octave", "octave", ".m"),
    ("matlab", "MATLAB", "matlab", ".m"),
    ("sagemath", "SageMath", "python", ".py"),
    ("xspark", "Apache Spark (Scala)", "scala", ".scala"),
    ("pyspark", "PySpark", "python", ".py"),
    ("dart", "Dart", "dart", ".dart"),
];

// ── Kernel registry ───────────────────────────────────────────────────────────

/// Registry of all kernels available on this system.
pub struct KernelRegistry {
    kernels: HashMap<String, KernelSpec>,
}

impl KernelRegistry {
    pub fn new() -> Self {
        let mut reg = Self {
            kernels: HashMap::new(),
        };
        reg.register_known_kernels();
        reg
    }

    fn register_known_kernels(&mut self) {
        for (name, _, _, _) in KNOWN_KERNELS {
            if let Some(spec) = KernelSpec::known(name) {
                self.kernels.insert(name.to_string(), spec);
            }
        }
    }

    /// Register a kernel from a kernelspec JSON.
    pub fn register_from_json(&mut self, name: &str, json: &str) -> anyhow::Result<()> {
        let spec: KernelSpec = serde_json::from_str(json)?;
        self.kernels.insert(name.to_owned(), spec);
        Ok(())
    }

    pub fn get(&self, name: &str) -> Option<&KernelSpec> {
        self.kernels.get(name)
    }

    pub fn all(&self) -> Vec<&KernelSpec> {
        let mut list: Vec<&KernelSpec> = self.kernels.values().collect();
        list.sort_by_key(|k| &k.display_name);
        list
    }

    pub fn for_language(&self, language: &str) -> Vec<&KernelSpec> {
        let lang = language.to_lowercase();
        self.kernels
            .values()
            .filter(|k| k.language.to_lowercase() == lang)
            .collect()
    }

    pub fn default_for_language(&self, language: &str) -> Option<&KernelSpec> {
        // Prefer the most common kernel name for the language
        let preferred = match language.to_lowercase().as_str() {
            "python" => "python3",
            "r" => "ir",
            "julia" => "julia-1.10",
            "java" => "java",
            "kotlin" => "kotlin",
            "scala" => "scala",
            "javascript" | "js" => "javascript",
            "typescript" | "ts" => "typescript",
            "rust" => "rust",
            "cpp" | "c++" => "c++17",
            "bash" => "bash",
            "sql" => "sql",
            "go" => "go",
            "ruby" => "ruby",
            "haskell" => "haskell",
            _ => language,
        };
        self.get(preferred)
            .or_else(|| self.for_language(language).first().copied())
    }

    pub fn count(&self) -> usize {
        self.kernels.len()
    }
}

impl Default for KernelRegistry {
    fn default() -> Self {
        Self::new()
    }
}

// ── Kernel status ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum KernelStatus {
    /// Not yet started.
    Offline,
    /// Process starting.
    Starting,
    /// Connected and idle.
    Idle,
    /// Executing a cell.
    Busy,
    /// Being restarted.
    Restarting,
    /// Process terminated.
    Dead,
}

impl KernelStatus {
    pub fn is_available(&self) -> bool {
        matches!(self, Self::Idle)
    }
    pub fn is_alive(&self) -> bool {
        matches!(
            self,
            Self::Starting | Self::Idle | Self::Busy | Self::Restarting
        )
    }
}

// ── Jupyter message header ────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MessageHeader {
    pub msg_id: String,
    pub session: String,
    pub username: String,
    pub date: String,
    pub msg_type: String,
    pub version: String,
}

impl MessageHeader {
    pub fn new(msg_type: &str, session: &str) -> Self {
        use std::time::{SystemTime, UNIX_EPOCH};
        static MSG_COUNTER: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(0);
        let n = MSG_COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let t = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map(|d| d.as_secs())
            .unwrap_or(0);
        Self {
            msg_id: format!("{:016x}{:016x}", t, n),
            session: session.to_owned(),
            username: "waraq".into(),
            date: format!("{}", t),
            msg_type: msg_type.to_owned(),
            version: "5.3".into(),
        }
    }
}

/// A Jupyter wire protocol message.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JupyterMessage {
    pub header: MessageHeader,
    pub parent_header: serde_json::Value,
    pub metadata: serde_json::Value,
    pub content: serde_json::Value,
    pub buffers: Vec<Vec<u8>>,
    pub channel: MessageChannel,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum MessageChannel {
    Shell,
    IoPub,
    Stdin,
    Control,
    Heartbeat,
}

impl JupyterMessage {
    pub fn new(
        channel: MessageChannel,
        msg_type: &str,
        session: &str,
        content: serde_json::Value,
    ) -> Self {
        Self {
            header: MessageHeader::new(msg_type, session),
            parent_header: serde_json::Value::Object(Default::default()),
            metadata: serde_json::Value::Object(Default::default()),
            content,
            buffers: Vec::new(),
            channel,
        }
    }

    pub fn msg_type(&self) -> &str {
        &self.header.msg_type
    }
    pub fn msg_id(&self) -> &str {
        &self.header.msg_id
    }
}

// ── Shell channel requests ────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecuteRequest {
    /// Source code to execute.
    pub code: String,
    /// If true, don't add to kernel's history.
    pub silent: bool,
    /// If true, store input/output in history.
    pub store_history: bool,
    /// Evaluate these expressions and return their results.
    pub user_expressions: HashMap<String, String>,
    /// If true, allow stdin input_request.
    pub allow_stdin: bool,
    /// If true, raise an error on first error instead of continuing.
    pub stop_on_error: bool,
}

impl ExecuteRequest {
    pub fn new(code: &str) -> Self {
        Self {
            code: code.to_owned(),
            silent: false,
            store_history: true,
            user_expressions: HashMap::new(),
            allow_stdin: true,
            stop_on_error: true,
        }
    }

    pub fn silent(code: &str) -> Self {
        Self {
            code: code.to_owned(),
            silent: true,
            store_history: false,
            ..Self::new("")
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecuteReply {
    pub status: ExecuteStatus,
    pub execution_count: u32,
    pub user_expressions: HashMap<String, serde_json::Value>,
    /// Only present when status == Error.
    pub ename: Option<String>,
    pub evalue: Option<String>,
    pub traceback: Option<Vec<String>>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ExecuteStatus {
    Ok,
    Error,
    Abort,
}

// ── Completion ────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompleteRequest {
    pub code: String,
    pub cursor_pos: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompleteReply {
    pub status: String,
    pub matches: Vec<String>,
    pub cursor_start: u32,
    pub cursor_end: u32,
    pub metadata: serde_json::Value,
}

// ── Inspection ────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InspectRequest {
    pub code: String,
    pub cursor_pos: u32,
    /// 0=plain text, 1=rich HTML
    pub detail_level: u8,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InspectReply {
    pub status: String,
    pub found: bool,
    pub data: HashMap<String, serde_json::Value>,
    pub metadata: serde_json::Value,
}

// ── Kernel info ───────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KernelInfoReply {
    pub status: String,
    pub protocol_version: String,
    pub implementation: String,
    pub implementation_version: String,
    pub language_info: LanguageInfo,
    pub banner: String,
    pub help_links: Vec<HelpLink>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LanguageInfo {
    pub name: String,
    pub version: String,
    pub mimetype: String,
    pub file_extension: String,
    pub pygments_lexer: Option<String>,
    pub codemirror_mode: Option<serde_json::Value>,
    pub nbconvert_exporter: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HelpLink {
    pub text: String,
    pub url: String,
}

// ── IOPub messages ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatusMessage {
    pub execution_state: String, // "idle" | "busy" | "starting"
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamMessage {
    pub name: String, // "stdout" | "stderr"
    pub text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecuteInputMessage {
    pub code: String,
    pub execution_count: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DisplayDataMessage {
    pub data: serde_json::Value,
    pub metadata: serde_json::Value,
    pub transient: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecuteResultMessage {
    pub execution_count: u32,
    pub data: serde_json::Value,
    pub metadata: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorMessage {
    pub ename: String,
    pub evalue: String,
    pub traceback: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClearOutputMessage {
    pub wait: bool,
}

// ── Connection file ───────────────────────────────────────────────────────────

/// The connection file Jupyter kernels read on startup.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConnectionFile {
    pub control_port: u16,
    pub shell_port: u16,
    pub transport: String,        // "tcp"
    pub signature_scheme: String, // "hmac-sha256"
    pub stdin_port: u16,
    pub hb_port: u16,
    pub ip: String, // "127.0.0.1"
    pub iopub_port: u16,
    pub key: String, // HMAC key
}

impl ConnectionFile {
    /// Generate a connection file with random ports.
    pub fn generate(ip: &str) -> Self {
        // In production, pick free ports. Here we use fixed defaults.
        Self {
            control_port: 5554,
            shell_port: 5555,
            transport: "tcp".into(),
            signature_scheme: "hmac-sha256".into(),
            stdin_port: 5556,
            hb_port: 5557,
            ip: ip.to_owned(),
            iopub_port: 5558,
            key: uuid_v4(),
        }
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap_or_default()
    }
}

fn uuid_v4() -> String {
    // Simple deterministic UUID v4 without external deps
    use std::time::{SystemTime, UNIX_EPOCH};
    let t = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_nanos() as u64)
        .unwrap_or(0);
    static C: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(0);
    let n = C.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    format!(
        "{:08x}-{:04x}-4{:03x}-{:04x}-{:012x}",
        (t >> 32) as u32,
        (t >> 16) as u16 & 0xFFFF,
        t as u16 & 0x0FFF,
        (n as u16 & 0x3FFF) | 0x8000,
        n & 0xFFFF_FFFF_FFFF
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_kernel_registry_all_known_kernels() {
        let reg = KernelRegistry::new();
        assert!(reg.count() >= 20, "Should have at least 20 kernels");
    }

    #[test]
    fn test_kernel_registry_get_python() {
        let reg = KernelRegistry::new();
        let k = reg.get("python3").unwrap();
        assert_eq!(k.language, "python");
        assert_eq!(k.display_name, "Python 3 (ipykernel)");
    }

    #[test]
    fn test_kernel_registry_for_language() {
        let reg = KernelRegistry::new();
        let python_kernels = reg.for_language("python");
        assert!(!python_kernels.is_empty());
        assert!(python_kernels.iter().all(|k| k.language == "python"));
    }

    #[test]
    fn test_kernel_registry_default_for_language() {
        let reg = KernelRegistry::new();
        assert_eq!(
            reg.default_for_language("python").unwrap().kernel_name,
            "python3"
        );
        assert_eq!(
            reg.default_for_language("rust").unwrap().kernel_name,
            "rust"
        );
        assert_eq!(
            reg.default_for_language("java").unwrap().kernel_name,
            "java"
        );
        assert!(reg.default_for_language("unknown_lang_xyz").is_none());
    }

    #[test]
    fn test_kernel_registry_all_sorted() {
        let reg = KernelRegistry::new();
        let all = reg.all();
        let names: Vec<&str> = all.iter().map(|k| k.display_name.as_str()).collect();
        let mut sorted = names.clone();
        sorted.sort();
        assert_eq!(names, sorted, "Kernels should be sorted by display name");
    }

    #[test]
    fn test_kernel_spec_known() {
        let spec = KernelSpec::known("rust").unwrap();
        assert_eq!(spec.language, "rust");
        assert_eq!(spec.kernel_name, "rust");
    }

    #[test]
    fn test_kernel_status_predicates() {
        assert!(KernelStatus::Idle.is_available());
        assert!(!KernelStatus::Busy.is_available());
        assert!(KernelStatus::Busy.is_alive());
        assert!(!KernelStatus::Dead.is_alive());
        assert!(!KernelStatus::Offline.is_alive());
    }

    #[test]
    fn test_message_header_unique_ids() {
        let h1 = MessageHeader::new("execute_request", "sess1");
        let h2 = MessageHeader::new("execute_request", "sess1");
        assert_ne!(h1.msg_id, h2.msg_id);
    }

    #[test]
    fn test_jupyter_message_construction() {
        let m = JupyterMessage::new(
            MessageChannel::Shell,
            "execute_request",
            "sess1",
            serde_json::json!({"code": "1+1", "silent": false}),
        );
        assert_eq!(m.msg_type(), "execute_request");
        assert_eq!(m.channel, MessageChannel::Shell);
    }

    #[test]
    fn test_execute_request_new() {
        let req = ExecuteRequest::new("print('hello')");
        assert_eq!(req.code, "print('hello')");
        assert!(req.store_history);
        assert!(!req.silent);
    }

    #[test]
    fn test_execute_request_silent() {
        let req = ExecuteRequest::silent("x = 1");
        assert!(req.silent);
        assert!(!req.store_history);
    }

    #[test]
    fn test_connection_file_generation() {
        let cf = ConnectionFile::generate("127.0.0.1");
        assert_eq!(cf.ip, "127.0.0.1");
        assert_eq!(cf.transport, "tcp");
        assert!(!cf.key.is_empty());
        let json = cf.to_json();
        let restored: ConnectionFile = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.shell_port, cf.shell_port);
    }

    #[test]
    fn test_known_kernels_coverage() {
        // Ensure all major languages have kernels
        let reg = KernelRegistry::new();
        for lang in &[
            "python",
            "java",
            "kotlin",
            "scala",
            "javascript",
            "typescript",
            "rust",
            "r",
            "go",
            "ruby",
        ] {
            assert!(
                reg.default_for_language(lang).is_some(),
                "Should have kernel for {}",
                lang
            );
        }
    }

    #[test]
    fn test_kernel_spec_json_roundtrip() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let json = serde_json::to_string(spec).unwrap();
        let restored: KernelSpec = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.kernel_name, "python3");
        assert_eq!(restored.language, "python");
    }
}
