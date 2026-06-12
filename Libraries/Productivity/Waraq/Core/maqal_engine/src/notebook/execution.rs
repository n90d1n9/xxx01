// src/notebook/execution.rs
//
// Execution engine — manages the queue of cells waiting to run,
// routes kernel messages to the right cell, and tracks execution state.
//
// Architecture:
//   ExecutionQueue — ordered list of pending cell executions
//   ExecutionContext — binds a NotebookDocument to a kernel session
//   KernelMessageRouter — routes iopub/shell messages to cells
//
// The actual kernel communication (ZMQ/WebSocket) is done by the
// host platform. This module defines:
//   1. The execution queue data structures
//   2. Message routing logic (which cell gets which output)
//   3. Cell execution state transitions
//   4. Error recovery strategies

use super::cell::CellId;
use super::document::NotebookDocument;
use super::kernel::{
    ClearOutputMessage, DisplayDataMessage, ErrorMessage, ExecuteReply, ExecuteRequest,
    ExecuteResultMessage, ExecuteStatus, StreamMessage,
};
use super::magic::MagicParser;
use super::output::{CellOutput, MimeBundle};
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, VecDeque};

// ── Pending execution ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PendingExecution {
    pub cell_id: CellId,
    pub cell_idx: usize,
    pub request: ExecuteRequest,
    pub msg_id: String,
}

// ── Execution result ──────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionResult {
    pub cell_id: CellId,
    pub cell_idx: usize,
    pub execution_count: u32,
    pub status: ExecuteStatus,
    pub outputs: Vec<CellOutput>,
    pub elapsed_ms: u64,
}

impl ExecutionResult {
    pub fn is_ok(&self) -> bool {
        self.status == ExecuteStatus::Ok
    }
}

// ── Execution queue ───────────────────────────────────────────────────────────

/// FIFO queue of cells pending execution.
#[derive(Debug, Default)]
pub struct ExecutionQueue {
    queue: VecDeque<PendingExecution>,
    /// Currently executing cell (if any).
    running: Option<PendingExecution>,
}

impl ExecutionQueue {
    pub fn new() -> Self {
        Self::default()
    }

    /// Enqueue a cell for execution.
    pub fn enqueue(&mut self, exec: PendingExecution) {
        self.queue.push_back(exec);
    }

    /// Take the next cell from the queue to start running.
    pub fn start_next(&mut self) -> Option<PendingExecution> {
        if self.running.is_some() {
            return None;
        } // kernel busy
        self.running = self.queue.pop_front();
        self.running.clone()
    }

    /// Mark the current execution as complete.
    pub fn complete(&mut self) -> Option<PendingExecution> {
        self.running.take()
    }

    /// Cancel all queued executions (not the running one).
    pub fn clear_queue(&mut self) {
        self.queue.clear();
    }

    /// Cancel everything including the running execution.
    pub fn interrupt(&mut self) {
        self.running = None;
        self.queue.clear();
    }

    pub fn is_busy(&self) -> bool {
        self.running.is_some()
    }
    pub fn pending_count(&self) -> usize {
        self.queue.len()
    }
    pub fn running_cell_id(&self) -> Option<&CellId> {
        self.running.as_ref().map(|r| &r.cell_id)
    }
    pub fn queued_cell_ids(&self) -> Vec<&CellId> {
        self.queue.iter().map(|e| &e.cell_id).collect()
    }
}

// ── Cell execution request builder ────────────────────────────────────────────

/// Build an `ExecuteRequest` from a cell's source, handling magic commands.
pub struct CellExecutor;

impl CellExecutor {
    /// Prepare a cell for kernel execution.
    /// Handles magic transformation and returns:
    ///   - Some(request) if the cell should be sent to the kernel
    ///   - None if the cell was handled entirely by the engine (display magics)
    pub fn prepare(
        cell_idx: usize,
        source: &str,
        notebook: &mut NotebookDocument,
    ) -> Option<ExecuteRequest> {
        if source.trim().is_empty() {
            return None;
        }

        // Handle magic commands
        if MagicParser::is_magic(source) {
            if let Some(magic) = MagicParser::parse(source) {
                // Engine-handled display magics
                if let Some(output) = MagicParser::execute_display_magic(&magic) {
                    notebook.add_output_to(cell_idx, output);
                    if let Some(cell) = notebook.cells_mut().get_mut(cell_idx) {
                        cell.mark_done(0, 0);
                    }
                    return None;
                }
                // Kernel-transformable magics
                if let Some(transformed) = MagicParser::transform_for_kernel(&magic) {
                    return Some(ExecuteRequest::new(&transformed));
                }
                // Pass-through to kernel (handles %%sql, etc. via IPython magic)
            }
        }

        Some(ExecuteRequest::new(source))
    }
}

// ── Kernel message router ─────────────────────────────────────────────────────

/// Routes incoming kernel messages to the correct cell.
pub struct KernelMessageRouter {
    /// msg_id → cell_idx mapping (for shell replies).
    pending: HashMap<String, usize>,
    /// Currently executing cell index (for iopub messages).
    active_idx: Option<usize>,
    /// Accumulated timing start (epoch ms).
    start_ms: u64,
}

impl KernelMessageRouter {
    pub fn new() -> Self {
        Self {
            pending: HashMap::new(),
            active_idx: None,
            start_ms: 0,
        }
    }

    pub fn register(&mut self, msg_id: &str, cell_idx: usize) {
        self.pending.insert(msg_id.to_owned(), cell_idx);
    }

    pub fn set_active(&mut self, cell_idx: usize, start_ms: u64) {
        self.active_idx = Some(cell_idx);
        self.start_ms = start_ms;
    }

    pub fn clear_active(&mut self) {
        self.active_idx = None;
    }

    pub fn active_cell_idx(&self) -> Option<usize> {
        self.active_idx
    }

    // ── IOPub message routing ─────────────────────────────────────────────────

    /// Route a `stream` iopub message to the active cell.
    pub fn route_stream(&self, msg: &StreamMessage, notebook: &mut NotebookDocument) {
        if let Some(idx) = self.active_idx {
            let output = if msg.name == "stdout" {
                CellOutput::stdout(&msg.text)
            } else {
                CellOutput::stderr(&msg.text)
            };
            notebook.add_output_to(idx, output);
        }
    }

    /// Route a `display_data` message.
    pub fn route_display_data(&self, msg: &DisplayDataMessage, notebook: &mut NotebookDocument) {
        if let Some(idx) = self.active_idx {
            let bundle = json_to_mime_bundle(&msg.data);
            notebook.add_output_to(idx, CellOutput::display(bundle));
        }
    }

    /// Route an `execute_result` message.
    pub fn route_execute_result(
        &self,
        msg: &ExecuteResultMessage,
        notebook: &mut NotebookDocument,
    ) {
        if let Some(idx) = self.active_idx {
            let bundle = json_to_mime_bundle(&msg.data);
            notebook.add_output_to(idx, CellOutput::result(msg.execution_count, bundle));
        }
    }

    /// Route an `error` message.
    pub fn route_error(&self, msg: &ErrorMessage, notebook: &mut NotebookDocument) {
        if let Some(idx) = self.active_idx {
            notebook.add_output_to(
                idx,
                CellOutput::error(&msg.ename, &msg.evalue, msg.traceback.clone()),
            );
        }
    }

    /// Route a `clear_output` message.
    pub fn route_clear_output(&self, msg: &ClearOutputMessage, notebook: &mut NotebookDocument) {
        if let Some(idx) = self.active_idx {
            if !msg.wait {
                if let Some(cell) = notebook.cells_mut().get_mut(idx) {
                    cell.outputs.clear();
                }
            }
        }
    }

    // ── Shell reply routing ───────────────────────────────────────────────────

    /// Route an `execute_reply` to the cell that requested it.
    pub fn route_execute_reply(
        &mut self,
        msg_id: &str,
        reply: &ExecuteReply,
        notebook: &mut NotebookDocument,
        now_ms: u64,
    ) -> Option<ExecutionResult> {
        let cell_idx = self.pending.remove(msg_id)?;
        let elapsed = now_ms.saturating_sub(self.start_ms);

        let outputs = notebook
            .cells()
            .get(cell_idx)
            .map(|c| c.outputs.outputs.clone())
            .unwrap_or_default();

        if let Some(cell) = notebook.cells_mut().get_mut(cell_idx) {
            match reply.status {
                ExecuteStatus::Ok => cell.mark_done(reply.execution_count, elapsed),
                ExecuteStatus::Error | ExecuteStatus::Abort => {
                    cell.mark_error(reply.execution_count);
                }
            }
        }

        Some(ExecutionResult {
            cell_id: notebook
                .cells()
                .get(cell_idx)
                .map(|c| c.id.clone())
                .unwrap_or_else(|| CellId::from_str("unknown")),
            cell_idx,
            execution_count: reply.execution_count,
            status: reply.status,
            outputs,
            elapsed_ms: elapsed,
        })
    }

    pub fn unregister(&mut self, msg_id: &str) {
        self.pending.remove(msg_id);
    }
}

impl Default for KernelMessageRouter {
    fn default() -> Self {
        Self::new()
    }
}

// ── Notebook execution context ────────────────────────────────────────────────

/// Combines a notebook with its execution state.
pub struct NotebookExecutionContext {
    pub notebook: NotebookDocument,
    pub queue: ExecutionQueue,
    pub router: KernelMessageRouter,
    pub session_id: String,
    pub kernel_status: super::kernel::KernelStatus,
}

impl NotebookExecutionContext {
    pub fn new(notebook: NotebookDocument) -> Self {
        let session_id = format!("{:016x}", {
            use std::time::{SystemTime, UNIX_EPOCH};
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .map(|d| d.as_nanos() as u64)
                .unwrap_or(0)
        });
        Self {
            notebook,
            queue: ExecutionQueue::new(),
            router: KernelMessageRouter::new(),
            session_id,
            kernel_status: super::kernel::KernelStatus::Offline,
        }
    }

    /// Queue the active cell for execution.
    pub fn run_active_cell(&mut self) -> Option<PendingExecution> {
        let idx = self.notebook.active_cell;
        let source = self.notebook.cells().get(idx)?.source();
        if source.trim().is_empty() {
            return None;
        }

        let request = CellExecutor::prepare(idx, &source, &mut self.notebook)?;
        let msg_id = format!("waraq_{}_{}", self.session_id, idx);
        let cell_id = self.notebook.cells().get(idx)?.id.clone();

        let pending = PendingExecution {
            cell_id,
            cell_idx: idx,
            request,
            msg_id: msg_id.clone(),
        };

        if let Some(cell) = self.notebook.cells_mut().get_mut(idx) {
            cell.mark_queued();
        }
        self.router.register(&msg_id, idx);
        self.queue.enqueue(pending.clone());
        Some(pending)
    }

    /// Queue all code cells for execution (Run All).
    pub fn run_all(&mut self) -> Vec<PendingExecution> {
        let idxs = self.notebook.executable_cells();
        let mut results = Vec::new();
        let orig_active = self.notebook.active_cell;

        for idx in idxs {
            self.notebook.active_cell = idx;
            if let Some(p) = self.run_active_cell() {
                results.push(p);
            }
        }
        self.notebook.active_cell = orig_active;
        results
    }

    /// Run all cells above the active cell.
    pub fn run_all_above(&mut self) -> Vec<PendingExecution> {
        let limit = self.notebook.active_cell;
        let idxs: Vec<usize> = self
            .notebook
            .executable_cells()
            .into_iter()
            .filter(|&i| i < limit)
            .collect();
        let mut results = Vec::new();
        for idx in idxs {
            self.notebook.active_cell = idx;
            if let Some(p) = self.run_active_cell() {
                results.push(p);
            }
        }
        results
    }

    /// Interrupt the running cell.
    pub fn interrupt(&mut self) {
        if let Some(running_id) = self.queue.running_cell_id() {
            let idx_opt = self.notebook.index_of(running_id);
            if let Some(idx) = idx_opt {
                if let Some(cell) = self.notebook.cells_mut().get_mut(idx) {
                    cell.mark_interrupted();
                }
            }
        }
        self.queue.interrupt();
        self.router.clear_active();
        self.kernel_status = super::kernel::KernelStatus::Idle;
    }

    /// Restart the kernel — clear all state.
    pub fn restart(&mut self) {
        self.queue.interrupt();
        self.router.clear_active();
        self.notebook.clear_all_outputs();
        self.kernel_status = super::kernel::KernelStatus::Starting;
    }

    /// Notification that the kernel became idle (execution finished).
    pub fn on_kernel_idle(&mut self) {
        self.kernel_status = super::kernel::KernelStatus::Idle;
        self.router.clear_active();
        self.queue.complete();
    }

    /// Notification that the kernel became busy (execution started).
    pub fn on_kernel_busy(&mut self, now_ms: u64) {
        self.kernel_status = super::kernel::KernelStatus::Busy;
        if let Some(running) = self.queue.start_next() {
            self.router.set_active(running.cell_idx, now_ms);
            if let Some(cell) = self.notebook.cells_mut().get_mut(running.cell_idx) {
                cell.mark_running();
            }
        }
    }
}

// ── Helper: convert JSON MIME data to MimeBundle ───────────────────────────────

fn json_to_mime_bundle(data: &serde_json::Value) -> MimeBundle {
    let mut bundle = MimeBundle::new();
    if let Some(obj) = data.as_object() {
        for (mime, value) in obj {
            let mime_data = match value {
                serde_json::Value::String(s) => super::output::MimeData::Text(s.clone()),
                serde_json::Value::Array(lines) => {
                    let joined: Vec<String> = lines
                        .iter()
                        .filter_map(|v| v.as_str().map(|s| s.to_owned()))
                        .collect();
                    super::output::MimeData::Lines(joined)
                }
                other => super::output::MimeData::Json(other.clone()),
            };
            bundle.data.insert(mime.clone(), mime_data);
        }
    }
    bundle
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::notebook::cell::CellType;
    use crate::notebook::kernel::KernelRegistry;
    use crate::notebook::output::CellOutput;

    fn python_ctx() -> NotebookExecutionContext {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let nb = NotebookDocument::for_kernel(spec);
        NotebookExecutionContext::new(nb)
    }

    // ── ExecutionQueue ────────────────────────────────────────────────────────

    #[test]
    fn test_queue_enqueue_dequeue() {
        let mut q = ExecutionQueue::new();
        assert!(!q.is_busy());
        assert_eq!(q.pending_count(), 0);

        let exec = PendingExecution {
            cell_id: CellId::new(),
            cell_idx: 0,
            request: ExecuteRequest::new("x = 1"),
            msg_id: "msg1".into(),
        };
        q.enqueue(exec);
        assert_eq!(q.pending_count(), 1);

        let running = q.start_next().unwrap();
        assert!(q.is_busy());
        assert_eq!(q.pending_count(), 0);
        assert_eq!(running.msg_id, "msg1");

        q.complete();
        assert!(!q.is_busy());
    }

    #[test]
    fn test_queue_does_not_start_while_busy() {
        let mut q = ExecutionQueue::new();
        for i in 0..3 {
            q.enqueue(PendingExecution {
                cell_id: CellId::new(),
                cell_idx: i,
                request: ExecuteRequest::new("x"),
                msg_id: format!("msg{}", i),
            });
        }
        q.start_next();
        // Should not dequeue while busy
        assert!(q.start_next().is_none());
        assert_eq!(q.pending_count(), 2);
    }

    #[test]
    fn test_queue_interrupt_clears_all() {
        let mut q = ExecutionQueue::new();
        for i in 0..5 {
            q.enqueue(PendingExecution {
                cell_id: CellId::new(),
                cell_idx: i,
                request: ExecuteRequest::new("x"),
                msg_id: format!("m{}", i),
            });
        }
        q.start_next();
        q.interrupt();
        assert!(!q.is_busy());
        assert_eq!(q.pending_count(), 0);
    }

    // ── CellExecutor ─────────────────────────────────────────────────────────

    #[test]
    fn test_cell_executor_normal_code() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        nb.cells_mut()[0].set_source("x = 1 + 1");
        let req = CellExecutor::prepare(0, "x = 1 + 1", &mut nb).unwrap();
        assert_eq!(req.code, "x = 1 + 1");
    }

    #[test]
    fn test_cell_executor_empty_returns_none() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        assert!(CellExecutor::prepare(0, "", &mut nb).is_none());
        assert!(CellExecutor::prepare(0, "   \n  ", &mut nb).is_none());
    }

    #[test]
    fn test_cell_executor_display_magic_handled_inline() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        nb.cells_mut()[0].set_source("%%html\n<h1>Hello</h1>");
        let req = CellExecutor::prepare(0, "%%html\n<h1>Hello</h1>", &mut nb);
        // HTML magic is handled by engine — no request sent to kernel
        assert!(req.is_none());
        // Output should have been added
        assert!(!nb.cells()[0].outputs.is_empty());
    }

    #[test]
    fn test_cell_executor_pip_transformed() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        let req = CellExecutor::prepare(0, "%pip install numpy", &mut nb).unwrap();
        assert!(req.code.contains("pip"));
        assert!(req.code.contains("numpy"));
    }

    // ── KernelMessageRouter ───────────────────────────────────────────────────

    #[test]
    fn test_router_stream_routing() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        let mut router = KernelMessageRouter::new();
        router.set_active(0, 0);
        router.route_stream(
            &StreamMessage {
                name: "stdout".into(),
                text: "hello\n".into(),
            },
            &mut nb,
        );
        assert_eq!(nb.cells()[0].outputs.stdout_text(), "hello\n");
    }

    #[test]
    fn test_router_error_routing() {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        let mut router = KernelMessageRouter::new();
        router.set_active(0, 0);
        router.route_error(
            &ErrorMessage {
                ename: "ZeroDivisionError".into(),
                evalue: "division by zero".into(),
                traceback: vec!["Traceback...".into()],
            },
            &mut nb,
        );
        assert!(nb.cells()[0].outputs.has_error());
    }

    // ── NotebookExecutionContext ───────────────────────────────────────────────

    #[test]
    fn test_run_active_cell() {
        let mut ctx = python_ctx();
        ctx.kernel_status = super::super::kernel::KernelStatus::Idle;
        ctx.notebook.cells_mut()[0].set_source("x = 42");
        let pending = ctx.run_active_cell().unwrap();
        assert_eq!(pending.request.code, "x = 42");
        assert_eq!(ctx.queue.pending_count(), 1);
    }

    #[test]
    fn test_run_all_queues_only_code_cells() {
        let mut ctx = python_ctx();
        ctx.notebook.cells_mut()[0].set_source("x = 1");
        ctx.notebook.insert_cell_below(CellType::Markdown);
        ctx.notebook.cells_mut()[1].set_source("# heading");
        ctx.notebook.insert_cell_below(CellType::Code);
        ctx.notebook.cells_mut()[2].set_source("print(x)");

        let pending = ctx.run_all();
        assert_eq!(pending.len(), 2, "Only 2 code cells should be queued");
    }

    #[test]
    fn test_interrupt_clears_queue_and_marks_cell() {
        let mut ctx = python_ctx();
        ctx.notebook.cells_mut()[0].set_source("import time; time.sleep(100)");
        ctx.run_active_cell();
        ctx.on_kernel_busy(0);
        ctx.interrupt();
        assert!(!ctx.queue.is_busy());
        assert_eq!(ctx.queue.pending_count(), 0);
        assert_eq!(ctx.kernel_status, super::super::kernel::KernelStatus::Idle);
    }

    #[test]
    fn test_restart_clears_all_outputs() {
        let mut ctx = python_ctx();
        ctx.notebook.cells_mut()[0].add_output(CellOutput::stdout("hello\n"));
        for _ in 0..5 {
            ctx.notebook.next_execution_count();
        }
        ctx.restart();
        assert!(ctx.notebook.cells()[0].outputs.is_empty());
        assert_eq!(ctx.notebook.execution_counter(), 0);
        assert_eq!(
            ctx.kernel_status,
            super::super::kernel::KernelStatus::Starting
        );
    }
}
