// src/notebook/mod.rs
//
// Notebook subsystem — complete Jupyter-compatible notebook engine.
//
// Usage:
//   let kernel_reg = KernelRegistry::new();
//   let spec = kernel_reg.default_for_language("python").unwrap();
//   let nb = NotebookDocument::for_kernel(spec);
//   let mut ctx = NotebookExecutionContext::new(nb);
//
//   // Set cell source via its editor
//   ctx.notebook.cells_mut()[0].set_source("import pandas as pd\npd.__version__");
//
//   // Queue for execution
//   let pending = ctx.run_active_cell().unwrap();
//
//   // (Platform layer sends pending.request to kernel via ZMQ/WebSocket)
//   // On iopub message:
//   ctx.router.route_stream(&stream_msg, &mut ctx.notebook);
//   // On execute_reply:
//   ctx.router.route_execute_reply(&msg_id, &reply, &mut ctx.notebook, now_ms);

pub mod cell;
pub mod document;
pub mod execution;
pub mod export;
pub mod inspector;
pub mod kernel;
pub mod magic;
pub mod ops;
pub mod output;

pub use cell::{Cell, CellExecutionState, CellId, CellMetadata, CellSnapshot, CellType};
pub use document::{IpynbDocument, NotebookDocument, NotebookMetadata};
pub use execution::{CellExecutor, ExecutionQueue, ExecutionResult, NotebookExecutionContext};
pub use export::{ExportFormat, ExportOptions, NotebookExporter};
pub use inspector::{
    CellDiffOp, KernelCompletionBridge, KernelVariable, NotebookDiff, NotebookDiffer, VarKind,
    VariableInspector,
};
pub use kernel::{
    CompleteReply, CompleteRequest, ConnectionFile, ExecuteReply, ExecuteRequest, ExecuteStatus,
    InspectReply, InspectRequest, JupyterMessage, KernelInfoReply, KernelRegistry, KernelSpec,
    KernelStatus, LanguageInfo, MessageChannel, MessageHeader,
};
pub use magic::{MagicInfo, MagicKind, MagicParser, ParsedMagic};
pub use ops::{
    apply_notebook_edit, apply_notebook_operation, compact_notebook_artifact,
    maintain_notebook_artifact, maintain_notebook_artifact_with_outcome, notebook_artifact,
    notebook_operation, plan_notebook_artifact_maintenance, replay_notebook_log,
    restore_notebook_artifact, NotebookArtifact, NotebookArtifactCompactionInfo,
    NotebookArtifactMaintenanceOutcome, NotebookArtifactMaintenancePlan,
    NotebookArtifactMaintenancePolicy, NotebookDocumentOps, NotebookEdit, NotebookEditError,
    NotebookEditOutcome, NotebookOperation, NotebookOperationLog, MAQAL_ENGINE_ID,
};
pub use output::{
    CellOutput, ErrorOutput, MimeBundle, MimeData, OutputBuffer, StreamName, StreamOutput,
};

// ── Notebook C API ─────────────────────────────────────────────────────────────
//
// The C API wraps a `NotebookExecutionContext` as an opaque handle.
// Host applications (Flutter, Java, WASM) use this to:
//   • Create/load/save notebooks
//   • Query cells and their outputs
//   • Queue cells for execution
//   • Route kernel messages back into the notebook
//   • Get serialisable snapshots for the UI

use std::boxed::Box;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_ulong};

/// Opaque notebook handle.
pub struct NotebookHandle {
    pub ctx: NotebookExecutionContext,
}

/// Create a new empty notebook for the given kernel name.
/// Returns null if kernel is not found.
/// CALLER MUST call notebook_destroy.
#[no_mangle]
pub extern "C" fn notebook_create(kernel_name: *const c_char) -> *mut NotebookHandle {
    if kernel_name.is_null() {
        return std::ptr::null_mut();
    }
    let name = match unsafe { CStr::from_ptr(kernel_name) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let reg = KernelRegistry::new();
    let spec = match reg.get(name) {
        Some(s) => s.clone(),
        None => {
            // Try by language
            match reg.default_for_language(name) {
                Some(s) => s.clone(),
                None => return std::ptr::null_mut(),
            }
        }
    };
    let nb = NotebookDocument::for_kernel(&spec);
    let ctx = NotebookExecutionContext::new(nb);
    Box::into_raw(Box::new(NotebookHandle { ctx }))
}

/// Load a notebook from .ipynb JSON.
/// Returns null on parse error.
/// CALLER MUST call notebook_destroy.
#[no_mangle]
pub extern "C" fn notebook_from_json(json: *const c_char) -> *mut NotebookHandle {
    if json.is_null() {
        return std::ptr::null_mut();
    }
    let s = match unsafe { CStr::from_ptr(json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    match IpynbDocument::from_json(s) {
        Ok(ipynb) => {
            let nb = ipynb.to_notebook();
            let ctx = NotebookExecutionContext::new(nb);
            Box::into_raw(Box::new(NotebookHandle { ctx }))
        }
        Err(_) => std::ptr::null_mut(),
    }
}

/// Serialise the notebook to .ipynb JSON.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_to_json(handle: *const NotebookHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let ipynb = IpynbDocument::from_notebook(&h.ctx.notebook);
    let json = ipynb.to_json_pretty();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Destroy a notebook handle.
#[no_mangle]
pub extern "C" fn notebook_destroy(handle: *mut NotebookHandle) {
    if !handle.is_null() {
        unsafe {
            drop(Box::from_raw(handle));
        }
    }
}

/// Free a string returned by notebook API.
#[no_mangle]
pub extern "C" fn notebook_free_str(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            drop(CString::from_raw(ptr));
        }
    }
}

/// Get cell count.
#[no_mangle]
pub extern "C" fn notebook_cell_count(handle: *const NotebookHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.ctx.notebook.cell_count() as c_ulong
}

/// Get active cell index.
#[no_mangle]
pub extern "C" fn notebook_active_cell(handle: *const NotebookHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.ctx.notebook.active_cell as c_ulong
}

/// Set active cell index.
#[no_mangle]
pub extern "C" fn notebook_set_active_cell(handle: *mut NotebookHandle, idx: c_ulong) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .ctx
        .notebook
        .focus_cell_at(idx as usize);
}

/// Insert a cell below the active cell.
/// cell_type: 0=Code, 1=Markdown, 2=Raw
#[no_mangle]
pub extern "C" fn notebook_insert_cell_below(handle: *mut NotebookHandle, cell_type: c_int) {
    if handle.is_null() {
        return;
    }
    let ct = match cell_type {
        1 => CellType::Markdown,
        2 => CellType::Raw,
        _ => CellType::Code,
    };
    unsafe { &mut *handle }.ctx.notebook.insert_cell_below(ct);
}

/// Insert a cell above the active cell.
#[no_mangle]
pub extern "C" fn notebook_insert_cell_above(handle: *mut NotebookHandle, cell_type: c_int) {
    if handle.is_null() {
        return;
    }
    let ct = match cell_type {
        1 => CellType::Markdown,
        2 => CellType::Raw,
        _ => CellType::Code,
    };
    unsafe { &mut *handle }.ctx.notebook.insert_cell_above(ct);
}

/// Delete the active cell.
#[no_mangle]
pub extern "C" fn notebook_delete_cell(handle: *mut NotebookHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    if unsafe { &mut *handle }.ctx.notebook.delete_active_cell() {
        1
    } else {
        0
    }
}

/// Move active cell up/down. direction: -1=up, 1=down.
#[no_mangle]
pub extern "C" fn notebook_move_cell(handle: *mut NotebookHandle, direction: c_int) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let ok = if direction < 0 {
        h.ctx.notebook.move_cell_up()
    } else {
        h.ctx.notebook.move_cell_down()
    };
    if ok {
        1
    } else {
        0
    }
}

/// Get cell info as JSON for a specific index.
/// JSON: {"id":"...","type":"code|markdown|raw","source":"...","execution_count":N,
///         "execution_state":"idle|queued|running|done|error","line_count":N}
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_get_cell(handle: *const NotebookHandle, idx: c_ulong) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let cell = match h.ctx.notebook.cells().get(idx as usize) {
        Some(c) => c,
        None => return std::ptr::null_mut(),
    };
    let ct = match cell.cell_type {
        CellType::Code => "code",
        CellType::Markdown => "markdown",
        CellType::Raw => "raw",
    };
    let state = format!("{:?}", cell.execution_state).to_lowercase();
    let json = serde_json::json!({
        "id": cell.id.0,
        "type": ct,
        "source": cell.source(),
        "execution_count": cell.execution_count,
        "execution_state": state,
        "line_count": cell.line_count(),
        "has_error": cell.has_error(),
        "output_count": cell.outputs.len(),
    })
    .to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Set the source of a cell by index.
#[no_mangle]
pub extern "C" fn notebook_set_cell_source(
    handle: *mut NotebookHandle,
    idx: c_ulong,
    source: *const c_char,
) {
    if handle.is_null() || source.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let s = match unsafe { CStr::from_ptr(source) }.to_str() {
        Ok(s) => s,
        Err(_) => return,
    };
    if let Some(cell) = h.ctx.notebook.cells_mut().get_mut(idx as usize) {
        cell.set_source(s);
    }
}

/// Get cell outputs as JSON.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_get_outputs(handle: *const NotebookHandle, idx: c_ulong) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let outputs = match h.ctx.notebook.cells().get(idx as usize) {
        Some(c) => c.outputs.to_json(),
        None => serde_json::Value::Array(vec![]),
    };
    let json = serde_json::to_string(&outputs).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Clear outputs of a specific cell.
#[no_mangle]
pub extern "C" fn notebook_clear_outputs(handle: *mut NotebookHandle, idx: c_ulong) {
    if handle.is_null() {
        return;
    }
    if let Some(cell) = unsafe { &mut *handle }
        .ctx
        .notebook
        .cells_mut()
        .get_mut(idx as usize)
    {
        cell.clear_outputs();
    }
}

/// Clear all outputs in the notebook.
#[no_mangle]
pub extern "C" fn notebook_clear_all_outputs(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.notebook.clear_all_outputs();
}

/// Queue the active cell for execution.
/// Returns JSON PendingExecution or null if nothing to execute.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_run_cell(handle: *mut NotebookHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    match h.ctx.run_active_cell() {
        Some(pending) => {
            let json = serde_json::json!({
                "msg_id": pending.msg_id,
                "cell_idx": pending.cell_idx,
                "code": pending.request.code,
                "silent": pending.request.silent,
            })
            .to_string();
            CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Queue all code cells for execution.
/// Returns JSON array of PendingExecution objects.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_run_all(handle: *mut NotebookHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let pending = h.ctx.run_all();
    let json = serde_json::json!(pending
        .iter()
        .map(|p| serde_json::json!({
            "msg_id": p.msg_id, "cell_idx": p.cell_idx, "code": p.request.code,
        }))
        .collect::<Vec<_>>())
    .to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Interrupt the running cell.
#[no_mangle]
pub extern "C" fn notebook_interrupt(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.interrupt();
}

/// Restart the kernel (clears outputs).
#[no_mangle]
pub extern "C" fn notebook_restart(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.restart();
}

/// Route a kernel stream message (stdout/stderr) to the current cell.
/// name_json: "stdout" or "stderr", text: the output text.
#[no_mangle]
pub extern "C" fn notebook_on_stream(
    handle: *mut NotebookHandle,
    name: *const c_char,
    text: *const c_char,
) {
    if handle.is_null() {
        return;
    }
    let name_s = if name.is_null() {
        "stdout"
    } else {
        match unsafe { CStr::from_ptr(name) }.to_str() {
            Ok(s) => s,
            Err(_) => "stdout",
        }
    };
    let text_s = if text.is_null() {
        ""
    } else {
        match unsafe { CStr::from_ptr(text) }.to_str() {
            Ok(s) => s,
            Err(_) => "",
        }
    };
    let h = unsafe { &mut *handle };
    h.ctx.router.route_stream(
        &crate::notebook::kernel::StreamMessage {
            name: name_s.into(),
            text: text_s.into(),
        },
        &mut h.ctx.notebook,
    );
}

/// Route a kernel execute_result message.
/// exec_count: execution count, data_json: MIME data JSON object.
#[no_mangle]
pub extern "C" fn notebook_on_execute_result(
    handle: *mut NotebookHandle,
    exec_count: c_ulong,
    data_json: *const c_char,
) {
    if handle.is_null() {
        return;
    }
    let data: serde_json::Value = if data_json.is_null() {
        serde_json::Value::Object(Default::default())
    } else {
        match unsafe { CStr::from_ptr(data_json) }.to_str() {
            Ok(s) => serde_json::from_str(s).unwrap_or_default(),
            Err(_) => Default::default(),
        }
    };
    let h = unsafe { &mut *handle };
    h.ctx.router.route_execute_result(
        &crate::notebook::kernel::ExecuteResultMessage {
            execution_count: exec_count as u32,
            data,
            metadata: Default::default(),
        },
        &mut h.ctx.notebook,
    );
}

/// Route a kernel error message.
#[no_mangle]
pub extern "C" fn notebook_on_error(
    handle: *mut NotebookHandle,
    ename: *const c_char,
    evalue: *const c_char,
    traceback: *const c_char,
) {
    if handle.is_null() {
        return;
    }
    let ename_s = if ename.is_null() {
        ""
    } else {
        match unsafe { CStr::from_ptr(ename) }.to_str() {
            Ok(s) => s,
            Err(_) => "",
        }
    };
    let evalue_s = if evalue.is_null() {
        ""
    } else {
        match unsafe { CStr::from_ptr(evalue) }.to_str() {
            Ok(s) => s,
            Err(_) => "",
        }
    };
    let tb_vec: Vec<String> = if traceback.is_null() {
        vec![]
    } else {
        match unsafe { CStr::from_ptr(traceback) }.to_str() {
            Ok(s) => s.lines().map(|l| l.to_owned()).collect(),
            Err(_) => vec![],
        }
    };
    let h = unsafe { &mut *handle };
    h.ctx.router.route_error(
        &crate::notebook::kernel::ErrorMessage {
            ename: ename_s.into(),
            evalue: evalue_s.into(),
            traceback: tb_vec,
        },
        &mut h.ctx.notebook,
    );
}

/// Notify the notebook that the kernel became idle.
#[no_mangle]
pub extern "C" fn notebook_on_kernel_idle(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.on_kernel_idle();
}

/// Notify the notebook that the kernel became busy. now_ms: current epoch ms.
#[no_mangle]
pub extern "C" fn notebook_on_kernel_busy(handle: *mut NotebookHandle, now_ms: c_ulong) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.on_kernel_busy(now_ms as u64);
}

/// Get a summary of all cells as JSON (for rendering the cell list).
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_cell_list(handle: *const NotebookHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let cells: Vec<serde_json::Value> = h
        .ctx
        .notebook
        .cells()
        .iter()
        .enumerate()
        .map(|(i, cell)| {
            let ct = match cell.cell_type {
                CellType::Code => "code",
                CellType::Markdown => "markdown",
                CellType::Raw => "raw",
            };
            let state = format!("{:?}", cell.execution_state).to_lowercase();
            serde_json::json!({
                "idx": i,
                "id": cell.id.0,
                "type": ct,
                "execution_count": cell.execution_count,
                "execution_state": state,
                "has_error": cell.has_error(),
                "output_count": cell.outputs.len(),
                "line_count": cell.line_count(),
                "is_active": i == h.ctx.notebook.active_cell,
            })
        })
        .collect();
    let json = serde_json::to_string(&cells).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// List all available kernels as JSON.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_list_kernels() -> *mut c_char {
    let reg = KernelRegistry::new();
    let list: Vec<serde_json::Value> = reg
        .all()
        .into_iter()
        .map(|k| {
            serde_json::json!({
                "name":         k.kernel_name,
                "display_name": k.display_name,
                "language":     k.language,
                "file_extension": k.metadata.file_extension,
            })
        })
        .collect();
    let json = serde_json::to_string(&list).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Parse a magic command from source. Returns JSON or null if not a magic.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_parse_magic(source: *const c_char) -> *mut c_char {
    if source.is_null() {
        return std::ptr::null_mut();
    }
    let s = match unsafe { CStr::from_ptr(source) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    match MagicParser::parse(s) {
        Some(m) => {
            let kind = if m.kind == MagicKind::Line {
                "line"
            } else {
                "cell"
            };
            let json = serde_json::json!({
                "kind": kind,
                "name": m.name,
                "args": m.args,
                "body": m.body,
                "is_builtin": m.is_builtin(),
            })
            .to_string();
            CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Get kernel status.
/// Returns: 0=Offline, 1=Starting, 2=Idle, 3=Busy, 4=Restarting, 5=Dead
#[no_mangle]
pub extern "C" fn notebook_kernel_status(handle: *const NotebookHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.ctx.kernel_status as c_int
}

/// Get is-dirty flag.
#[no_mangle]
pub extern "C" fn notebook_is_dirty(handle: *const NotebookHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    if unsafe { &*handle }.ctx.notebook.dirty {
        1
    } else {
        0
    }
}

/// Split the active cell at the cursor position.
#[no_mangle]
pub extern "C" fn notebook_split_cell(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.notebook.split_cell_at_cursor();
}

/// Merge the active cell with the cell above.
#[no_mangle]
pub extern "C" fn notebook_merge_above(handle: *mut NotebookHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    if unsafe { &mut *handle }.ctx.notebook.merge_with_above() {
        1
    } else {
        0
    }
}

/// Copy the active cell to clipboard.
#[no_mangle]
pub extern "C" fn notebook_copy_cell(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.notebook.copy_cell();
}

/// Cut the active cell.
#[no_mangle]
pub extern "C" fn notebook_cut_cell(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.notebook.cut_cell();
}

/// Paste cells below the active cell.
#[no_mangle]
pub extern "C" fn notebook_paste_cell(handle: *mut NotebookHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.ctx.notebook.paste_cell_below();
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    fn get_str(ptr: *mut c_char) -> String {
        if ptr.is_null() {
            return String::new();
        }
        let s = unsafe { CStr::from_ptr(ptr).to_str().unwrap().to_owned() };
        notebook_free_str(ptr);
        s
    }

    #[test]
    fn test_notebook_create_python() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        assert!(!h.is_null());
        assert_eq!(notebook_cell_count(h), 1);
        notebook_destroy(h);
    }

    #[test]
    fn test_notebook_create_by_language() {
        for lang in &["python", "java", "rust", "javascript"] {
            let name = CString::new(*lang).unwrap();
            let h = notebook_create(name.as_ptr());
            assert!(!h.is_null(), "Should create notebook for {}", lang);
            notebook_destroy(h);
        }
    }

    #[test]
    fn test_notebook_create_unknown_returns_null() {
        let name = CString::new("unknown_kernel_xyz").unwrap();
        let h = notebook_create(name.as_ptr());
        assert!(h.is_null());
    }

    #[test]
    fn test_notebook_insert_and_delete_cell() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        notebook_insert_cell_below(h, 0);
        assert_eq!(notebook_cell_count(h), 2);
        notebook_delete_cell(h);
        assert_eq!(notebook_cell_count(h), 1);
        notebook_destroy(h);
    }

    #[test]
    fn test_notebook_set_get_cell_source() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        let src = CString::new("x = 42\nprint(x)").unwrap();
        notebook_set_cell_source(h, 0, src.as_ptr());
        let cell_json = get_str(notebook_get_cell(h, 0));
        let v: serde_json::Value = serde_json::from_str(&cell_json).unwrap();
        assert_eq!(v["line_count"], 2);
        notebook_destroy(h);
    }

    #[test]
    fn test_notebook_run_cell_returns_pending() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        let src = CString::new("x = 1 + 1").unwrap();
        notebook_set_cell_source(h, 0, src.as_ptr());
        let ptr = notebook_run_cell(h);
        assert!(!ptr.is_null(), "Should return pending execution");
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["cell_idx"], 0);
        assert_eq!(v["code"], "x = 1 + 1");
        notebook_destroy(h);
    }

    #[test]
    fn test_notebook_on_stream() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        let src = CString::new("print('hello')").unwrap();
        notebook_set_cell_source(h, 0, src.as_ptr());
        notebook_run_cell(h);
        notebook_on_kernel_busy(h, 0);
        let stream = CString::new("stdout").unwrap();
        let text = CString::new("hello\n").unwrap();
        notebook_on_stream(h, stream.as_ptr(), text.as_ptr());
        let outputs = get_str(notebook_get_outputs(h, 0));
        let arr: serde_json::Value = serde_json::from_str(&outputs).unwrap();
        assert!(!arr.as_array().unwrap().is_empty());
        notebook_destroy(h);
    }

    #[test]
    fn test_notebook_on_error() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        let src = CString::new("1/0").unwrap();
        notebook_set_cell_source(h, 0, src.as_ptr());
        notebook_run_cell(h);
        notebook_on_kernel_busy(h, 0);
        let ename = CString::new("ZeroDivisionError").unwrap();
        let evalue = CString::new("division by zero").unwrap();
        let tb = CString::new("Traceback...\n  line 1").unwrap();
        notebook_on_error(h, ename.as_ptr(), evalue.as_ptr(), tb.as_ptr());
        let cell_json = get_str(notebook_get_cell(h, 0));
        let v: serde_json::Value = serde_json::from_str(&cell_json).unwrap();
        assert_eq!(v["has_error"], true);
        notebook_destroy(h);
    }

    #[test]
    fn test_notebook_clear_outputs() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        // Add output manually via on_stream
        let src = CString::new("print('hi')").unwrap();
        notebook_set_cell_source(h, 0, src.as_ptr());
        notebook_run_cell(h);
        notebook_on_kernel_busy(h, 0);
        let sn = CString::new("stdout").unwrap();
        let tx = CString::new("hi\n").unwrap();
        notebook_on_stream(h, sn.as_ptr(), tx.as_ptr());
        notebook_clear_outputs(h, 0);
        let out = get_str(notebook_get_outputs(h, 0));
        let arr: serde_json::Value = serde_json::from_str(&out).unwrap();
        assert!(arr.as_array().unwrap().is_empty());
        notebook_destroy(h);
    }

    #[test]
    fn test_notebook_ipynb_roundtrip() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        let src = CString::new("import numpy as np").unwrap();
        notebook_set_cell_source(h, 0, src.as_ptr());
        notebook_insert_cell_below(h, 1); // markdown
        let md_src = CString::new("# Analysis").unwrap();
        notebook_set_cell_source(h, 1, md_src.as_ptr());

        let json_ptr = notebook_to_json(h);
        let json = get_str(json_ptr);
        assert!(json.contains("numpy"));
        assert!(json.contains("Analysis"));
        assert!(json.contains("nbformat"));

        let json_cstr = CString::new(json).unwrap();
        let h2 = notebook_from_json(json_cstr.as_ptr());
        assert!(!h2.is_null());
        assert_eq!(notebook_cell_count(h2), 2);
        notebook_destroy(h);
        notebook_destroy(h2);
    }

    #[test]
    fn test_notebook_list_kernels() {
        let ptr = notebook_list_kernels();
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        let kernels = arr.as_array().unwrap();
        assert!(kernels.len() >= 20);
        assert!(kernels.iter().any(|k| k["name"] == "python3"));
        assert!(kernels.iter().any(|k| k["name"] == "rust"));
    }

    #[test]
    fn test_notebook_parse_magic() {
        let src = CString::new("%pip install numpy").unwrap();
        let ptr = notebook_parse_magic(src.as_ptr());
        assert!(!ptr.is_null());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["name"], "pip");
        assert_eq!(v["kind"], "line");
    }

    #[test]
    fn test_notebook_parse_non_magic() {
        let src = CString::new("x = 1 + 2").unwrap();
        assert!(notebook_parse_magic(src.as_ptr()).is_null());
    }

    #[test]
    fn test_notebook_cell_list() {
        let name = CString::new("python3").unwrap();
        let h = notebook_create(name.as_ptr());
        notebook_insert_cell_below(h, 1);
        let ptr = notebook_cell_list(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(arr.as_array().unwrap().len(), 2);
        notebook_destroy(h);
    }

    #[test]
    fn test_null_safety_notebook_api() {
        assert!(notebook_to_json(std::ptr::null()).is_null());
        assert_eq!(notebook_cell_count(std::ptr::null()), 0);
        assert_eq!(notebook_active_cell(std::ptr::null()), 0);
        notebook_insert_cell_below(std::ptr::null_mut(), 0);
        assert_eq!(notebook_delete_cell(std::ptr::null_mut()), 0);
        assert!(notebook_run_cell(std::ptr::null_mut()).is_null());
        notebook_interrupt(std::ptr::null_mut());
        notebook_restart(std::ptr::null_mut());
    }
}

// ── Notebook export C API ─────────────────────────────────────────────────────

/// Export a notebook to the given format.
/// format: 0=Html, 1=Script, 2=Markdown, 3=Rst, 4=Latex, 5=Strip
/// Returns the exported string.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_export(handle: *const NotebookHandle, format: c_int) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let fmt = match format {
        0 => ExportFormat::Html,
        1 => ExportFormat::Script,
        2 => ExportFormat::Markdown,
        3 => ExportFormat::Rst,
        4 => ExportFormat::Latex,
        5 => ExportFormat::Strip,
        _ => ExportFormat::Markdown,
    };
    let opts = ExportOptions::default();
    let output = NotebookExporter::export(&h.ctx.notebook, fmt, &opts);
    CString::new(output)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Export with custom options JSON.
/// options_json: {"include_outputs":true,"include_exec_count":true,"title":"My Notebook"}
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_export_with_options(
    handle: *const NotebookHandle,
    format: c_int,
    options_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let fmt = match format {
        0 => ExportFormat::Html,
        1 => ExportFormat::Script,
        2 => ExportFormat::Markdown,
        3 => ExportFormat::Rst,
        4 => ExportFormat::Latex,
        5 => ExportFormat::Strip,
        _ => ExportFormat::Markdown,
    };
    let mut opts = ExportOptions::default();
    if !options_json.is_null() {
        if let Ok(s) = unsafe { CStr::from_ptr(options_json) }.to_str() {
            if let Ok(v) = serde_json::from_str::<serde_json::Value>(s) {
                if let Some(b) = v["include_outputs"].as_bool() {
                    opts.include_outputs = b;
                }
                if let Some(b) = v["include_exec_count"].as_bool() {
                    opts.include_exec_count = b;
                }
                if let Some(b) = v["hide_tagged_input"].as_bool() {
                    opts.hide_tagged_input = b;
                }
                if let Some(b) = v["hide_tagged_output"].as_bool() {
                    opts.hide_tagged_output = b;
                }
                if let Some(t) = v["title"].as_str() {
                    opts.title = Some(t.to_owned());
                }
            }
        }
    }
    let output = NotebookExporter::export(&h.ctx.notebook, fmt, &opts);
    CString::new(output)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Variable inspector C API ──────────────────────────────────────────────────

/// Get the Python code to run inside the kernel to inspect the namespace.
/// Returns a static string (do NOT free).
#[no_mangle]
pub extern "C" fn notebook_inspector_code() -> *const c_char {
    static CODE: std::sync::OnceLock<std::ffi::CString> = std::sync::OnceLock::new();
    CODE.get_or_init(|| {
        std::ffi::CString::new(VariableInspector::inspector_code())
            .unwrap_or_else(|_| std::ffi::CString::new("").unwrap())
    })
    .as_ptr()
}

/// Update the variable inspector from the kernel's JSON output.
/// json_output: the stdout from running notebook_inspector_code() in the kernel.
/// Returns the variable table as JSON.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_inspect_variables(
    handle: *mut NotebookHandle,
    json_output: *const c_char,
    now_ms: c_ulong,
) -> *mut c_char {
    if handle.is_null() || json_output.is_null() {
        return std::ptr::null_mut();
    }
    let _h = unsafe { &mut *handle };
    let s = match unsafe { CStr::from_ptr(json_output) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    // Use a local inspector — caller can cache the result
    let mut inspector = VariableInspector::new();
    inspector.parse_json_output(s, now_ms as u64);
    let json = inspector.to_json();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Convert a kernel complete_reply JSON to completion items JSON.
/// reply_json: the complete_reply content from the kernel.
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_kernel_completions(
    reply_json: *const c_char,
    source: *const c_char,
) -> *mut c_char {
    if reply_json.is_null() {
        return std::ptr::null_mut();
    }
    let json = match unsafe { CStr::from_ptr(reply_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let src = if source.is_null() {
        ""
    } else {
        match unsafe { CStr::from_ptr(source) }.to_str() {
            Ok(s) => s,
            Err(_) => "",
        }
    };
    let reply: CompleteReply = match serde_json::from_str(json) {
        Ok(r) => r,
        Err(_) => return std::ptr::null_mut(),
    };
    let items = KernelCompletionBridge::to_completion_items(&reply, src);
    let out = serde_json::to_string(&items).unwrap_or_else(|_| "[]".into());
    CString::new(out)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Notebook diff C API ────────────────────────────────────────────────────────

/// Diff two notebooks provided as .ipynb JSON strings.
/// Returns diff summary JSON: {"cells_added":N,"cells_deleted":N,"cells_changed":N,"identical":bool}
/// CALLER MUST call notebook_free_str.
#[no_mangle]
pub extern "C" fn notebook_diff(json_a: *const c_char, json_b: *const c_char) -> *mut c_char {
    if json_a.is_null() || json_b.is_null() {
        return std::ptr::null_mut();
    }
    let sa = match unsafe { CStr::from_ptr(json_a) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let sb = match unsafe { CStr::from_ptr(json_b) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    match NotebookDiffer::diff_ipynb(sa, sb) {
        Ok(diff) => {
            let json = serde_json::json!({
                "cells_added":   diff.cells_added,
                "cells_deleted": diff.cells_deleted,
                "cells_changed": diff.cells_changed,
                "identical":     diff.identical,
                "summary":       diff.summary(),
                "op_count":      diff.ops.len(),
            })
            .to_string();
            CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        Err(_) => std::ptr::null_mut(),
    }
}
