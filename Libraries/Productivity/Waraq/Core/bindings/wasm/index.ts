// bindings/wasm/index.ts — Complete TypeScript binding for the Waraq editor engine.

import init, { WasmEditor } from './pkg/waraq_editor_core';
export type { WasmEditor };

// ═══ Types ════════════════════════════════════════════════════════════════════

export interface VisibleLine { line_number: number; text: string; byte_offset: number; }
export interface Token { start: number; end: number; line: number; col_start: number; col_end: number; kind: number; }
export interface CursorPosition { line: number; col: number; }
export interface SelectionRange { start: number; end: number; }
export interface FoldRange { start_line: number; end_line: number; collapsed: boolean; }
export interface DiagnosticInfo { line: number; col: number; end_line: number; end_col: number; severity: number; message: string; source?: string; }
export interface SearchMatchInfo { start: number; end: number; line: number; col: number; is_current: boolean; match_index: number; total_matches: number; }
export interface DecorationRenderInfo { id: number; start_byte: number; end_byte: number; start_line: number; start_col: number; end_line: number; end_col: number; is_whole_line: boolean; kind: string; glyph_icon?: string; hover_message?: string; after_text?: string; before_text?: string; }
export interface RenderFrame { lines: VisibleLine[]; cursors: CursorPosition[]; selections: SelectionRange[]; tokens: Token[]; folds: FoldRange[]; diagnostics: DiagnosticInfo[]; search_matches: SearchMatchInfo[]; decorations: DecorationRenderInfo[]; total_lines: number; scroll_offset: number; language: string; }
export interface SearchMatch { start: number; end: number; line: number; col: number; total: number; index: number; }
export interface DocumentStats { bytes: number; chars: number; words: number; lines: number; sentences: number; paragraphs: number; }
export interface BatchResponse { ok: boolean; frame: RenderFrame | null; search: SearchMatch | null; ext_result: unknown | null; errors: string[]; ops_applied: number; }
export interface MonacoPosition { lineNumber: number; column: number; }
export interface MonacoRange { startLineNumber: number; startColumn: number; endLineNumber: number; endColumn: number; }
export interface FindMatch { startLineNumber: number; startColumn: number; endLineNumber: number; endColumn: number; }
export interface WordAtPosition { word: string; startColumn: number; endColumn: number; }
export interface PaletteItem { id: string; title: string; enabled: boolean; }
export interface StatusBarItem { id: string; text: string; tooltip?: string; command?: string; priority: number; visible: boolean; }
export interface Notification { kind: 'Info' | 'Warning' | 'Error'; message: string; actions: string[]; }
export interface KernelInfo { name: string; display_name: string; language: string; file_extension?: string; }
export interface SnippetExpansion { text: string; tab_stops: Array<{ index: number; start: number; len: number; placeholder: string }>; final_cursor: number; }
export interface VariableInfo { name: string; type_name: string; kind: string; repr: string; shape?: string; dtype?: string; }

export type BatchCommand =
    | { cmd: 'insert'; at: number; text: string }
    | { cmd: 'delete'; start: number; end: number }
    | { cmd: 'replace'; start: number; end: number; text: string }
    | { cmd: 'undo' } | { cmd: 'redo' }
    | { cmd: 'cursor_move'; pos: number; extend?: boolean }
    | { cmd: 'cursor_add'; pos: number } | { cmd: 'cursor_collapse' }
    | { cmd: 'type_char'; codepoint: number }
    | { cmd: 'key_backspace' } | { cmd: 'key_delete' } | { cmd: 'key_enter' }
    | { cmd: 'key_tab' } | { cmd: 'key_shift_tab' }
    | { cmd: 'motion'; code: number; extend?: boolean }
    | { cmd: 'move_up'; lines: number; extend?: boolean }
    | { cmd: 'move_down'; lines: number; extend?: boolean }
    | { cmd: 'select_word' } | { cmd: 'select_line' } | { cmd: 'select_all' }
    | { cmd: 'expand_selection' } | { cmd: 'add_cursor_next_occurrence' }
    | { cmd: 'scroll_by'; delta: number }
    | { cmd: 'set_viewport_height'; height: number }
    | { cmd: 'ensure_line_visible'; line: number }
    | { cmd: 'set_language'; language: string }
    | { cmd: 'search_start'; pattern: string; flags?: number }
    | { cmd: 'search_next' } | { cmd: 'search_prev' } | { cmd: 'search_clear' }
    | { cmd: 'replace_current'; replacement: string }
    | { cmd: 'replace_all_matches'; replacement: string }
    | { cmd: 'set_config_value'; key: string; value: string }
    | { cmd: 'fold_toggle'; line: number } | { cmd: 'fold_all' } | { cmd: 'unfold_all' }
    | { cmd: 'copy' } | { cmd: 'cut' } | { cmd: 'cycle_paste' }
    | { cmd: 'format_document' } | { cmd: 'format_on_save' } | { cmd: 'sort_imports' }
    | { cmd: 'macro_start'; register: string } | { cmd: 'macro_stop' }
    | { cmd: 'macro_play'; register: string; count?: number }
    | { cmd: 'ext_cmd_execute'; command: string; args?: unknown }
    | { cmd: 'theme_set'; theme_id: string }
    | { cmd: 'snippet_expand'; prefix: string }
    | { cmd: 'ext_activate_startup' }
    | { cmd: 'delta_decorations'; remove_ids?: number[]; add_specs?: unknown[] }
    | { cmd: 'clear_decorations'; owner: string }
    | { cmd: 'execute_edits'; edits: unknown[] }
    | { cmd: 'render_frame' };

// ═══ Editor class ═════════════════════════════════════════════════════════════

export class Editor {
    private _inner: WasmEditor;
    private _disposed = false;

    constructor(inner: WasmEditor) { this._inner = inner; }

    private check() { if (this._disposed) throw new Error('Editor disposed'); }
    dispose() { if (!this._disposed) { this._inner.free(); this._disposed = true; } }
    get isDisposed() { return this._disposed; }

    // Mutations
    insert(at: number, text: string) { this.check(); this._inner.insert(at, text); }
    delete(start: number, end: number) { this.check(); this._inner.delete(start, end); }
    replace(start: number, end: number, text: string) { this.check(); this._inner.replace(start, end, text); }
    undo() { this.check(); this._inner.undo(); }
    redo() { this.check(); this._inner.redo(); }
    get canUndo() { this.check(); return this._inner.can_undo(); }
    get canRedo() { this.check(); return this._inner.can_redo(); }

    // Keys
    typeChar(cp: number) { this.check(); this._inner.type_char(cp); }
    typeString(s: string) { for (const c of s) this._inner.type_char(c.codePointAt(0)!); }
    keyBackspace() { this.check(); this._inner.key_backspace(); }
    keyDelete() { this.check(); this._inner.key_delete(); }
    keyEnter() { this.check(); this._inner.key_enter(); }
    keyTab() { this.check(); this._inner.key_tab(); }
    keyShiftTab() { this.check(); this._inner.key_shift_tab(); }

    // Cursor
    moveCursor(pos: number, extend = false) { this.check(); this._inner.cursor_move(pos, extend); }
    addCursor(pos: number) { this.check(); this._inner.cursor_add(pos); }
    collapseCursors() { this.check(); this._inner.cursor_collapse(); }
    get cursorPos() { this.check(); return this._inner.cursor_pos(); }
    get cursorCount() { this.check(); return this._inner.cursor_count(); }
    selectWord() { this.check(); this._inner.select_word(); }
    selectLine() { this.check(); this._inner.select_line(); }
    selectAll() { this.check(); this._inner.select_all(); }
    expandSelection() { this.check(); this._inner.expand_selection(); }
    addCursorAtNextOccurrence() { this.check(); this._inner.add_cursor_at_next_occurrence(); }

    // Motion
    motionCode(code: number, extend = false) { this.check(); this._inner.motion_code(code, extend); }
    moveUp(lines = 1, extend = false) { this.check(); this._inner.move_up(lines, extend); }
    moveDown(lines = 1, extend = false) { this.check(); this._inner.move_down(lines, extend); }

    // Viewport
    setViewportHeight(h: number) { this.check(); this._inner.set_viewport_height(h); }
    scrollBy(delta: number) { this.check(); this._inner.scroll_by(delta); }
    ensureLineVisible(line: number) { this.check(); this._inner.ensure_line_visible(line); }

    // Text access
    getText() { this.check(); return this._inner.get_text(); }
    getLine(n: number) { this.check(); return this._inner.get_line(n); }
    get byteLen() { this.check(); return this._inner.byte_len(); }
    get lineCount() { this.check(); return this._inner.line_count(); }

    // Language
    setLanguage(lang: string) { this.check(); this._inner.set_language(lang); }
    get language() { this.check(); return this._inner.get_language(); }
    setConfig(key: string, value: string) { this.check(); this._inner.set_config_value(key, value); }

    // Search
    searchStart(pattern: string, flags = 0): SearchMatch | null {
        this.check();
        const j = this._inner.search_start(pattern, flags);
        return j ? JSON.parse(j) : null;
    }
    searchNext(): SearchMatch | null { this.check(); const j = this._inner.search_next(); return j ? JSON.parse(j) : null; }
    searchPrev(): SearchMatch | null { this.check(); const j = this._inner.search_prev(); return j ? JSON.parse(j) : null; }
    searchClear() { this.check(); this._inner.search_clear(); }
    replaceCurrent(r: string) { this.check(); this._inner.replace_current(r); }
    replaceAll(r: string) { this.check(); return this._inner.replace_all(r); }

    // Folds
    toggleFold(line: number) { this.check(); this._inner.fold_toggle(line); }
    foldAll() { this.check(); this._inner.fold_all(); }
    unfoldAll() { this.check(); this._inner.unfold_all(); }

    // Clipboard
    copy() { this.check(); this._inner.copy(); }
    cut() { this.check(); this._inner.cut(); }
    paste() { this.check(); this._inner.paste(); }
    cyclePaste() { this.check(); this._inner.cycle_paste(); }
    get clipboardText() { this.check(); return this._inner.clipboard_text() ?? ''; }

    // Format
    formatDocument() { this.check(); this._inner.format_document(); }
    formatOnSave() { this.check(); this._inner.format_on_save(); }
    sortImports() { this.check(); this._inner.sort_imports(); }

    // Macros
    macroStart(reg: string) { this.check(); this._inner.macro_start(reg); }
    macroStop() { this.check(); this._inner.macro_stop(); }
    macroPlay(reg: string, count = 1) { this.check(); this._inner.macro_play(reg, count); }
    get isMacroRecording() { this.check(); return this._inner.macro_is_recording(); }

    // Diagnostics / stats
    get errorCount() { this.check(); return this._inner.error_count(); }
    get warningCount() { this.check(); return this._inner.warning_count(); }
    get wordCount() { this.check(); return this._inner.word_count(); }
    get charCount() { this.check(); return this._inner.char_count(); }
    documentStats(): DocumentStats { this.check(); return JSON.parse(this._inner.document_stats()); }

    // Decorations
    deltaDecorations(removeIds: number[], addSpecs: unknown[]): number[] {
        this.check();
        const r = this._inner.delta_decorations(JSON.stringify(removeIds), JSON.stringify(addSpecs));
        return r ? JSON.parse(r) : [];
    }
    clearDecorations(owner: string) { this.check(); this._inner.clear_decorations(owner); }

    // TextModel
    getLineContent(lineNumber: number) { this.check(); return this._inner.model_get_line(lineNumber) ?? ''; }
    getOffsetAt(lineNumber: number, column: number) { this.check(); return this._inner.model_get_offset(lineNumber, column); }
    getPositionAt(offset: number): MonacoPosition { this.check(); return JSON.parse(this._inner.model_get_position(offset)); }
    getValueInRange(sl: number, sc: number, el: number, ec: number) { this.check(); return this._inner.model_get_value_in_range(sl, sc, el, ec) ?? ''; }
    findMatches(search: string, flags = 0, limit = 0): FindMatch[] { this.check(); const r = this._inner.model_find_matches(search, flags, limit); return r ? JSON.parse(r) : []; }
    getWordAtPosition(line: number, col: number): WordAtPosition | null { this.check(); const r = this._inner.model_word_at(line, col); return r ? JSON.parse(r) : null; }
    executeEdits(edits: unknown[]) { this.check(); return this._inner.execute_edits(JSON.stringify(edits)); }

    // Extensions
    activateStartup() { this.batch([{ cmd: 'ext_activate_startup' }]); }
    getPaletteItems(query?: string): PaletteItem[] { this.check(); const r = query ? this._inner.cmd_search(query) : this._inner.cmd_palette(); return r ? JSON.parse(r) : []; }
    executeCommand(id: string, args?: unknown) { this.check(); const r = this._inner.cmd_execute(id, args ? JSON.stringify(args) : null); return r ? JSON.parse(r) : null; }
    resolveKey(key: string, ctx?: Record<string, unknown>) { this.check(); const r = this._inner.key_resolve(key, ctx ? JSON.stringify(ctx) : null); return r ? JSON.parse(r) : { command: null, pending: false }; }
    getThemes() { this.check(); const r = this._inner.theme_list(); return r ? JSON.parse(r) : []; }
    setTheme(id: string) { this.check(); return this._inner.theme_set(id) === 0; }
    getSnippets(lang?: string) { this.check(); const r = this._inner.snippets_for_language(lang ?? this.language); return r ? JSON.parse(r) : []; }
    expandSnippet(prefix: string, lang?: string): SnippetExpansion | null { this.check(); const r = this._inner.snippet_expand(lang ?? this.language, prefix); return r ? JSON.parse(r) : null; }
    getStatusBarItems(): StatusBarItem[] { this.check(); const r = this._inner.statusbar_items(); return r ? JSON.parse(r) : []; }
    updateStatusBarItem(id: string, text: string) { this.check(); return this._inner.statusbar_update(id, text) === 0; }
    drainNotifications(): Notification[] { this.check(); const r = this._inner.notifications_drain(); return r ? JSON.parse(r) : []; }
    pollEvents() { this.check(); const r = this._inner.ext_poll_events(); return r ? JSON.parse(r) : []; }
    drainEvents() { this.check(); const r = this._inner.ext_drain_events(); return r ? JSON.parse(r) : []; }
    getExtensions() { this.check(); const r = this._inner.ext_list(); return r ? JSON.parse(r) : []; }

    // Render
    renderFrame(): RenderFrame { this.check(); return JSON.parse(this._inner.render_frame_json()); }

    // Batch
    batch(cmds: BatchCommand[]): BatchResponse { this.check(); return JSON.parse(this._inner.batch(JSON.stringify(cmds))); }
    exec(cmds: BatchCommand[], withFrame = false): BatchResponse {
        return this.batch(withFrame ? [...cmds, { cmd: 'render_frame' }] : cmds);
    }

    static version() { return WasmEditor.version(); }
}

// ═══ Factory ══════════════════════════════════════════════════════════════════

let _initialized = false;

export async function createEditor(content = '', language = ''): Promise<Editor> {
    if (!_initialized) { await init(); _initialized = true; }
    const inner = content ? WasmEditor.fromString(content) : new WasmEditor();
    const ed = new Editor(inner);
    if (language) ed.setLanguage(language);
    return ed;
}

export function createEditorSync(content = '', language = ''): Editor {
    const inner = content ? WasmEditor.fromString(content) : new WasmEditor();
    const ed = new Editor(inner);
    if (language) ed.setLanguage(language);
    return ed;
}

// ═══ Utilities ════════════════════════════════════════════════════════════════

export function detectLanguage(filename: string, firstLine?: string): string | null {
    const ext = filename.toLowerCase().split('.').pop() ?? '';
    const byExt: Record<string, string> = {
        rs:'rust', js:'javascript', mjs:'javascript', cjs:'javascript', ts:'typescript',
        jsx:'jsx', tsx:'tsx', py:'python', pyw:'python', rb:'ruby', java:'java',
        kt:'kotlin', kts:'kotlin', scala:'scala', go:'go', swift:'swift',
        c:'c', h:'c', cpp:'cpp', cc:'cpp', cxx:'cpp', hpp:'cpp', cs:'csharp',
        dart:'dart', r:'r', jl:'julia', html:'html', htm:'html', css:'css',
        scss:'scss', sass:'scss', json:'json', toml:'toml', yaml:'yaml', yml:'yaml',
        md:'markdown', mdx:'markdown', sh:'bash', bash:'bash', zsh:'bash',
        sql:'sql', hs:'haskell', lua:'lua', pl:'perl', ex:'elixir', exs:'elixir',
    };
    if (byExt[ext]) return byExt[ext];
    const base = filename.split('/').pop() ?? filename;
    if (['Makefile','makefile','GNUmakefile'].includes(base)) return 'makefile';
    if (base === 'Dockerfile') return 'dockerfile';
    if (firstLine?.startsWith('#!')) {
        if (firstLine.includes('python')) return 'python';
        if (firstLine.includes('node') || firstLine.includes('deno')) return 'javascript';
        if (firstLine.includes('bash') || firstLine.includes('/sh')) return 'bash';
        if (firstLine.includes('ruby')) return 'ruby';
    }
    return null;
}

export const MotionCode = { CharLeft:0, CharRight:1, WordLeft:2, WordRight:3, WordEnd:4, LineStart:5, LineFirstNonWs:6, LineEnd:7, LineUp:8, LineDown:9, ParagraphUp:10, ParagraphDown:11, PageUp:12, PageDown:13, MatchingBracket:14, DocumentStart:15, DocumentEnd:16 } as const;
export const SearchFlags = { CaseSensitive:0x01, WholeWord:0x02, Regex:0x04 } as const;
export const CellTypeId  = { Code:0, Markdown:1, Raw:2 } as const;
export const KernelStatusCode = { Offline:0, Starting:1, Idle:2, Busy:3, Restarting:4, Dead:5 } as const;
export const ExportFormatCode = { Html:0, Script:1, Markdown:2, Rst:3, Latex:4, Strip:5 } as const;

export const KNOWN_KERNELS: KernelInfo[] = [
    { name:'python3',    display_name:'Python 3 (ipykernel)', language:'python',     file_extension:'.py'   },
    { name:'ir',         display_name:'R',                    language:'r',           file_extension:'.r'    },
    { name:'julia-1.10', display_name:'Julia 1.10',           language:'julia',       file_extension:'.jl'   },
    { name:'java',       display_name:'Java (IJava)',          language:'java',        file_extension:'.java' },
    { name:'kotlin',     display_name:'Kotlin (kotlin-jupyter)', language:'kotlin',   file_extension:'.kt'   },
    { name:'scala',      display_name:'Scala (almond)',        language:'scala',       file_extension:'.scala'},
    { name:'javascript', display_name:'JavaScript (tslab)',    language:'javascript',  file_extension:'.js'   },
    { name:'typescript', display_name:'TypeScript (tslab)',    language:'typescript',  file_extension:'.ts'   },
    { name:'rust',       display_name:'Rust (evcxr)',          language:'rust',        file_extension:'.rs'   },
    { name:'go',         display_name:'Go (gophernotes)',      language:'go',          file_extension:'.go'   },
    { name:'bash',       display_name:'Bash',                  language:'bash',        file_extension:'.sh'   },
    { name:'sql',        display_name:'SQL (xeus-sqlite)',     language:'sql',         file_extension:'.sql'  },
];

export function tokenKindName(kind: number): string {
    return (['Default','Keyword','String','Number','Comment','Operator','Function','Type','Variable','Constant','Punctuation','Attribute'] as const)[kind] ?? `Unknown(${kind})`;
}

// ═══ AI API additions to Editor class ════════════════════════════════════════
// These are added as standalone functions (WASM build exposes them via WasmEditor)

export interface AiCompletionRequest {
    needs_request: boolean;
    request_id?: number;
    context?: { prefix: string; suffix: string; language: string; file_uri: string };
}

export interface AiPrompt {
    task: string;
    messages: Array<{ role: string; content: string }>;
    estimated_tokens: number;
    language: string;
    cursor_offset?: number;
    instruction?: string;
}

export interface AiResult {
    applied: boolean;
    ops?: number;
    explanation?: string;
    error?: string;
    bytes_changed?: number;
    inserted?: number;
}

export interface DiagnosticItem {
    range: { startLineNumber: number; startColumn: number; endLineNumber: number; endColumn: number };
    severity: 1 | 2 | 3 | 4;  // Error/Warning/Info/Hint
    message: string;
    source?: string;
}

// Extend the Editor class with AI and LSP methods
declare module './index' {
    interface Editor {
        // AI
        get aiHasCompletion(): boolean;
        get aiCompletionText(): string | null;
        acceptCompletion(): boolean;
        dismissCompletion(): void;
        aiOnChange(): AiCompletionRequest;
        buildExplainPrompt(): AiPrompt;
        buildEditPrompt(instruction: string): AiPrompt;
        buildFimPrompt(): AiPrompt;
        applyAiResult(task: 'explain' | 'edit' | 'generate' | 'fim', response: string): AiResult;
        extractAiContext(): { prefix: string; suffix: string; language: string; file_uri: string };
        aiCompletionStats(): Record<string, unknown>;

        // Session
        captureSession(): string;
        get isDirty(): boolean;
        markClean(): void;
        get undoDepth(): number;

        // LSP pipeline
        applyLspDiagnostics(diagnosticsJson: DiagnosticItem[]): number;
        applyLspHover(hoverJson: unknown, offset: number): void;
        clearLspHover(): void;
        lspCodeActions(actionsJson: unknown[]): { actions: unknown[]; cursor: { line: number; col: number }; count: number };
        applyLspEdit(editJson: unknown): number;

        // Settings
        loadUserSettings(json: string): boolean;
        loadWorkspaceSettings(json: string): boolean;
        setSetting(key: string, value: string): void;
        getAllSettings(): Record<string, unknown>;
    }
}

// Workspace types
export interface WorkspaceTab {
    tab_id: number;
    file_uri: string;
    language: string;
    dirty: boolean;
}

export interface FindInFilesResult {
    file_uri: string;
    line: number;
    col: number;
    text: string;
}
