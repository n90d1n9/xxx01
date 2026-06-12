// bindings/java/WaraqEditor.java
//
// Complete Java 21+ Foreign Function & Memory API binding.
// Covers: editor, search, folds, clipboard, macros, format, diagnostics,
//         decorations, TextModel, extension system, and notebook API.
//
// Usage:
//   try (var ed = new WaraqEditor("fn main() {}", "rust")) {
//       ed.setLanguage("rust");
//       var frame = ed.renderFrame();
//       System.out.println("Lines: " + frame.get("total_lines"));
//   }

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.lang.foreign.*;
import java.lang.invoke.MethodHandle;
import java.nio.charset.StandardCharsets;
import java.util.*;

public final class WaraqEditor implements AutoCloseable {

    // ── Library loading ──────────────────────────────────────────────────────

    private static final Linker        LINKER = Linker.nativeLinker();
    private static final SymbolLookup  LIB;
    private static final ObjectMapper  JSON   = new ObjectMapper();
    private static final Arena         GLOBAL = Arena.global();

    static {
        String libName = System.getProperty("os.name","").toLowerCase().contains("win")
            ? "waraq_editor_core.dll"
            : System.getProperty("os.name","").toLowerCase().contains("mac")
              ? "libwaraq_editor_core.dylib"
              : "libwaraq_editor_core.so";
        LIB = SymbolLookup.libraryLookup(libName, GLOBAL);
    }

    // ── Helper: build MethodHandle ──────────────────────────────────────────

    private static MethodHandle fn(String name, FunctionDescriptor desc) {
        return LINKER.downcallHandle(LIB.find(name)
            .orElseThrow(() -> new UnsatisfiedLinkError("Missing: " + name)), desc);
    }

    private static final ValueLayout.OfAddress PTR = ValueLayout.ADDRESS;
    private static final ValueLayout.OfLong    U64 = ValueLayout.JAVA_LONG;
    private static final ValueLayout.OfInt     I32 = ValueLayout.JAVA_INT;
    private static final ValueLayout.OfByte    U8  = ValueLayout.JAVA_BYTE;

    // ── Function handles ────────────────────────────────────────────────────

    // Core create/destroy
    private static final MethodHandle H_CREATE     = fn("editor_create",              FunctionDescriptor.of(PTR));
    private static final MethodHandle H_CREATE_STR = fn("editor_create_with_content", FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_DESTROY    = fn("editor_destroy",             FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_FREE_STR   = fn("editor_free_str",            FunctionDescriptor.ofVoid(PTR));

    // Text access
    private static final MethodHandle H_GET_TEXT   = fn("editor_get_text",    FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_GET_LINE   = fn("editor_get_line",    FunctionDescriptor.of(PTR, PTR, U64));
    private static final MethodHandle H_BYTE_LEN   = fn("editor_byte_len",    FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_LINE_COUNT = fn("editor_line_count",  FunctionDescriptor.of(U64, PTR));

    // Mutations
    private static final MethodHandle H_INSERT   = fn("editor_insert",  FunctionDescriptor.of(I32, PTR, U64, PTR));
    private static final MethodHandle H_DELETE   = fn("editor_delete",  FunctionDescriptor.of(I32, PTR, U64, U64));
    private static final MethodHandle H_REPLACE  = fn("editor_replace", FunctionDescriptor.of(I32, PTR, U64, U64, PTR));
    private static final MethodHandle H_UNDO     = fn("editor_undo",    FunctionDescriptor.of(I32, PTR));
    private static final MethodHandle H_REDO     = fn("editor_redo",    FunctionDescriptor.of(I32, PTR));
    private static final MethodHandle H_CAN_UNDO = fn("editor_can_undo", FunctionDescriptor.of(I32, PTR));
    private static final MethodHandle H_CAN_REDO = fn("editor_can_redo", FunctionDescriptor.of(I32, PTR));

    // Cursor
    private static final MethodHandle H_CURSOR_POS      = fn("editor_cursor_pos",      FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_CURSOR_COUNT    = fn("editor_cursor_count",     FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_CURSOR_MOVE     = fn("editor_cursor_move",      FunctionDescriptor.ofVoid(PTR, U64, I32));
    private static final MethodHandle H_CURSOR_ADD      = fn("editor_cursor_add",       FunctionDescriptor.ofVoid(PTR, U64));
    private static final MethodHandle H_CURSOR_COLLAPSE = fn("editor_cursor_collapse",  FunctionDescriptor.ofVoid(PTR));

    // Viewport
    private static final MethodHandle H_SET_VH      = fn("editor_set_viewport_height", FunctionDescriptor.ofVoid(PTR, U64));
    private static final MethodHandle H_SCROLL_BY   = fn("editor_scroll_by",           FunctionDescriptor.ofVoid(PTR, I32));
    private static final MethodHandle H_ENSURE_LINE = fn("editor_ensure_line_visible",  FunctionDescriptor.ofVoid(PTR, U64));

    // Language & config
    private static final MethodHandle H_SET_LANG    = fn("editor_set_language",   FunctionDescriptor.ofVoid(PTR, PTR));
    private static final MethodHandle H_SET_CONFIG  = fn("editor_set_config_value", FunctionDescriptor.ofVoid(PTR, PTR, PTR));

    // Render
    private static final MethodHandle H_RENDER_JSON = fn("editor_render_frame_json", FunctionDescriptor.of(PTR, PTR));

    // Search
    private static final MethodHandle H_SEARCH_START   = fn("editor_search_start",   FunctionDescriptor.of(PTR, PTR, U64, I32));
    private static final MethodHandle H_SEARCH_NEXT    = fn("editor_search_next",    FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_SEARCH_PREV    = fn("editor_search_prev",    FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_SEARCH_CLEAR   = fn("editor_search_clear",   FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_REPLACE_CURR   = fn("editor_replace_current",FunctionDescriptor.ofVoid(PTR, PTR));
    private static final MethodHandle H_REPLACE_ALL    = fn("editor_replace_all",    FunctionDescriptor.of(U64, PTR, PTR));

    // Folds
    private static final MethodHandle H_FOLD_TOGGLE = fn("editor_fold_toggle",FunctionDescriptor.ofVoid(PTR, U64));
    private static final MethodHandle H_FOLD_ALL    = fn("editor_fold_all",   FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_UNFOLD_ALL  = fn("editor_unfold_all", FunctionDescriptor.ofVoid(PTR));

    // Key input
    private static final MethodHandle H_TYPE_CHAR    = fn("editor_type_char",    FunctionDescriptor.ofVoid(PTR, I32));
    private static final MethodHandle H_KEY_BACKSPACE = fn("editor_key_backspace",FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_KEY_DELETE   = fn("editor_key_delete",   FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_KEY_ENTER    = fn("editor_key_enter",    FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_KEY_TAB      = fn("editor_key_tab",      FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_KEY_SHIFT_TAB= fn("editor_key_shift_tab",FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_MOTION_CODE  = fn("editor_motion_code",  FunctionDescriptor.ofVoid(PTR, I32, I32));
    private static final MethodHandle H_MOVE_UP      = fn("editor_move_up",      FunctionDescriptor.ofVoid(PTR, U64, I32));
    private static final MethodHandle H_MOVE_DOWN    = fn("editor_move_down",    FunctionDescriptor.ofVoid(PTR, U64, I32));

    // Selection
    private static final MethodHandle H_SELECT_WORD  = fn("editor_select_word",   FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_SELECT_LINE  = fn("editor_select_line",   FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_SELECT_ALL   = fn("editor_select_all",    FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_EXPAND_SEL   = fn("editor_expand_selection", FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_ADD_CURSOR_NEXT = fn("editor_add_cursor_at_next_occurrence", FunctionDescriptor.ofVoid(PTR));

    // Clipboard
    private static final MethodHandle H_COPY       = fn("editor_copy",       FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_CUT        = fn("editor_cut",        FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_PASTE      = fn("editor_paste",      FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_CLIP_TEXT  = fn("editor_clipboard_text", FunctionDescriptor.of(PTR, PTR));

    // Macros
    private static final MethodHandle H_MACRO_START   = fn("editor_macro_start",        FunctionDescriptor.of(I32, PTR, U8));
    private static final MethodHandle H_MACRO_STOP    = fn("editor_macro_stop",         FunctionDescriptor.of(I32, PTR));
    private static final MethodHandle H_MACRO_PLAY    = fn("editor_macro_play",         FunctionDescriptor.of(U64, PTR, U8, U64));
    private static final MethodHandle H_MACRO_IS_REC  = fn("editor_macro_is_recording", FunctionDescriptor.of(I32, PTR));
    private static final MethodHandle H_MACRO_EXPORT  = fn("editor_macro_export",       FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_MACRO_IMPORT  = fn("editor_macro_import",       FunctionDescriptor.of(I32, PTR, PTR));

    // Format
    private static final MethodHandle H_FORMAT_DOC   = fn("editor_format_document", FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_FORMAT_SAVE  = fn("editor_format_on_save",  FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_SORT_IMPORTS = fn("editor_sort_imports",    FunctionDescriptor.of(U64, PTR));

    // Stats
    private static final MethodHandle H_WORD_COUNT = fn("editor_word_count",    FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_CHAR_COUNT = fn("editor_char_count",    FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_DOC_STATS  = fn("editor_document_stats",FunctionDescriptor.of(PTR, PTR));

    // Diagnostics
    private static final MethodHandle H_ERROR_COUNT   = fn("editor_error_count",   FunctionDescriptor.of(U64, PTR));
    private static final MethodHandle H_WARNING_COUNT = fn("editor_warning_count", FunctionDescriptor.of(U64, PTR));

    // Decorations
    private static final MethodHandle H_DELTA_DEC   = fn("editor_delta_decorations",FunctionDescriptor.of(PTR, PTR, PTR, PTR));
    private static final MethodHandle H_CLEAR_DEC   = fn("editor_clear_decorations",FunctionDescriptor.ofVoid(PTR, PTR));
    private static final MethodHandle H_GET_DEC     = fn("editor_get_decorations",  FunctionDescriptor.of(PTR, PTR));

    // TextModel
    private static final MethodHandle H_MODEL_LINE  = fn("editor_model_get_line",         FunctionDescriptor.of(PTR, PTR, U64));
    private static final MethodHandle H_MODEL_OFFSET= fn("editor_model_get_offset",       FunctionDescriptor.of(U64, PTR, U64, U64));
    private static final MethodHandle H_MODEL_POS   = fn("editor_model_get_position",     FunctionDescriptor.of(PTR, PTR, U64));
    private static final MethodHandle H_MODEL_RANGE = fn("editor_model_get_value_in_range",FunctionDescriptor.of(PTR, PTR, U64, U64, U64, U64));
    private static final MethodHandle H_MODEL_FIND  = fn("editor_model_find_matches",     FunctionDescriptor.of(PTR, PTR, PTR, U64, U64));
    private static final MethodHandle H_MODEL_WORD  = fn("editor_model_word_at",          FunctionDescriptor.of(PTR, PTR, U64, U64));
    private static final MethodHandle H_EXEC_EDITS  = fn("editor_execute_edits",          FunctionDescriptor.of(U64, PTR, PTR));

    // Extension system
    private static final MethodHandle H_EXT_LIST    = fn("editor_ext_list",              FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_EXT_ACT_STR = fn("editor_ext_activate_startup",  FunctionDescriptor.ofVoid(PTR));
    private static final MethodHandle H_CMD_PALETTE = fn("editor_cmd_palette",           FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_CMD_SEARCH  = fn("editor_cmd_search",            FunctionDescriptor.of(PTR, PTR, PTR));
    private static final MethodHandle H_CMD_EXEC    = fn("editor_cmd_execute",           FunctionDescriptor.of(PTR, PTR, PTR, PTR));
    private static final MethodHandle H_KEY_RESOLVE = fn("editor_key_resolve",           FunctionDescriptor.of(PTR, PTR, PTR, PTR));
    private static final MethodHandle H_THEME_LIST  = fn("editor_theme_list",            FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_THEME_SET   = fn("editor_theme_set",             FunctionDescriptor.of(I32, PTR, PTR));
    private static final MethodHandle H_SNIPPETS    = fn("editor_snippets_for_language", FunctionDescriptor.of(PTR, PTR, PTR));
    private static final MethodHandle H_SNIPPET_EXP = fn("editor_snippet_expand",        FunctionDescriptor.of(PTR, PTR, PTR, PTR));
    private static final MethodHandle H_STATUS_ITEMS= fn("editor_statusbar_items",       FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_STATUS_UPD  = fn("editor_statusbar_update",      FunctionDescriptor.of(I32, PTR, PTR, PTR));
    private static final MethodHandle H_NOTIFS      = fn("editor_notifications_drain",   FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_EVENTS_POLL = fn("editor_ext_poll_events",       FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_EVENTS_DRAIN= fn("editor_ext_drain_events",      FunctionDescriptor.of(PTR, PTR));
    private static final MethodHandle H_DETECT_LANG = fn("editor_detect_language",       FunctionDescriptor.of(PTR, PTR, PTR, PTR));

    // Batch
    private static final MethodHandle H_BATCH       = fn("editor_batch",           FunctionDescriptor.of(PTR, PTR, PTR));

    // Version
    private static final MethodHandle H_VERSION     = fn("editor_version",         FunctionDescriptor.of(PTR));

    // ── Instance ─────────────────────────────────────────────────────────────

    private final MemorySegment handle;
    private boolean closed = false;

    public WaraqEditor() {
        try { handle = (MemorySegment) H_CREATE.invoke(); }
        catch (Throwable e) { throw new RuntimeException(e); }
    }

    public WaraqEditor(String content) {
        try (var arena = Arena.ofConfined()) {
            var s = arena.allocateFrom(content);
            try { handle = (MemorySegment) H_CREATE_STR.invoke(s); }
            catch (Throwable e) { throw new RuntimeException(e); }
        }
    }

    public WaraqEditor(String content, String language) {
        this(content);
        setLanguage(language);
    }

    @Override
    public void close() {
        if (!closed) {
            try { H_DESTROY.invoke(handle); } catch (Throwable e) { /* ignore */ }
            closed = true;
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private MemorySegment allocStr(Arena a, String s) { return a.allocateFrom(s); }

    private String fetchStr(MemorySegment ptr) {
        if (ptr == null || ptr.equals(MemorySegment.NULL)) return null;
        String s = ptr.reinterpret(Long.MAX_VALUE).getString(0, StandardCharsets.UTF_8);
        try { H_FREE_STR.invoke(ptr); } catch (Throwable e) { /* ignore */ }
        return s;
    }

    private JsonNode fetchJson(MemorySegment ptr) {
        String s = fetchStr(ptr);
        if (s == null) return JSON.nullNode();
        try { return JSON.readTree(s); } catch (Exception e) { return JSON.nullNode(); }
    }

    private <T> T invoke(MethodHandle h, Object... args) {
        try {
            @SuppressWarnings("unchecked")
            T result = (T) h.invokeWithArguments(args);
            return result;
        } catch (Throwable e) { throw new RuntimeException(e); }
    }

    // ── Text ──────────────────────────────────────────────────────────────────

    public String getText() { return fetchStr(invoke(H_GET_TEXT, handle)); }
    public String getLine(long lineNum) {
        try (var a = Arena.ofConfined()) {
            return fetchStr(invoke(H_GET_LINE, handle, lineNum));
        }
    }
    public long byteLen()   { return invoke(H_BYTE_LEN,   handle); }
    public long lineCount() { return invoke(H_LINE_COUNT, handle); }

    // ── Mutations ─────────────────────────────────────────────────────────────

    public int insert(long at, String text) {
        try (var a = Arena.ofConfined()) { return invoke(H_INSERT, handle, at, allocStr(a, text)); }
    }
    public int delete(long start, long end) { return invoke(H_DELETE, handle, start, end); }
    public int replace(long start, long end, String text) {
        try (var a = Arena.ofConfined()) { return invoke(H_REPLACE, handle, start, end, allocStr(a, text)); }
    }
    public boolean undo() { return ((int) invoke(H_UNDO, handle)) != 0; }
    public boolean redo() { return ((int) invoke(H_REDO, handle)) != 0; }
    public boolean canUndo() { return ((int) invoke(H_CAN_UNDO, handle)) != 0; }
    public boolean canRedo() { return ((int) invoke(H_CAN_REDO, handle)) != 0; }

    // ── Cursor ────────────────────────────────────────────────────────────────

    public long cursorPos()   { return invoke(H_CURSOR_POS, handle); }
    public long cursorCount() { return invoke(H_CURSOR_COUNT, handle); }
    public void moveCursor(long pos, boolean extend) { invoke(H_CURSOR_MOVE, handle, pos, extend?1:0); }
    public void addCursor(long pos) { invoke(H_CURSOR_ADD, handle, pos); }
    public void collapseCursors() { invoke(H_CURSOR_COLLAPSE, handle); }

    // ── Viewport ──────────────────────────────────────────────────────────────

    public void setViewportHeight(long h)  { invoke(H_SET_VH,      handle, h); }
    public void scrollBy(int delta)        { invoke(H_SCROLL_BY,   handle, delta); }
    public void ensureLineVisible(long l)  { invoke(H_ENSURE_LINE, handle, l); }

    // ── Language ──────────────────────────────────────────────────────────────

    public void setLanguage(String lang) {
        try (var a = Arena.ofConfined()) { invoke(H_SET_LANG, handle, allocStr(a, lang)); }
    }
    public void setConfigValue(String key, String value) {
        try (var a = Arena.ofConfined()) { invoke(H_SET_CONFIG, handle, allocStr(a,key), allocStr(a,value)); }
    }

    // ── Render ────────────────────────────────────────────────────────────────

    public JsonNode renderFrame() { return fetchJson(invoke(H_RENDER_JSON, handle)); }

    // ── Search ────────────────────────────────────────────────────────────────

    /** flags: 0x01=case_sensitive, 0x02=whole_word, 0x04=regex */
    public JsonNode searchStart(String pattern, int flags) {
        try (var a = Arena.ofConfined()) {
            return fetchJson(invoke(H_SEARCH_START, handle, allocStr(a,pattern), (long)pattern.length(), flags));
        }
    }
    public JsonNode searchNext() { return fetchJson(invoke(H_SEARCH_NEXT, handle)); }
    public JsonNode searchPrev() { return fetchJson(invoke(H_SEARCH_PREV, handle)); }
    public void searchClear()    { invoke(H_SEARCH_CLEAR, handle); }
    public void replaceCurrent(String r) {
        try (var a = Arena.ofConfined()) { invoke(H_REPLACE_CURR, handle, allocStr(a,r)); }
    }
    public long replaceAll(String r) {
        try (var a = Arena.ofConfined()) { return invoke(H_REPLACE_ALL, handle, allocStr(a,r)); }
    }

    // ── Folds ─────────────────────────────────────────────────────────────────

    public void toggleFold(long line) { invoke(H_FOLD_TOGGLE, handle, line); }
    public void foldAll()   { invoke(H_FOLD_ALL,   handle); }
    public void unfoldAll() { invoke(H_UNFOLD_ALL, handle); }

    // ── Keys & motion ─────────────────────────────────────────────────────────

    public void typeChar(int codepoint)  { invoke(H_TYPE_CHAR,    handle, codepoint); }
    public void keyBackspace()           { invoke(H_KEY_BACKSPACE, handle); }
    public void keyDelete()              { invoke(H_KEY_DELETE,    handle); }
    public void keyEnter()               { invoke(H_KEY_ENTER,     handle); }
    public void keyTab()                 { invoke(H_KEY_TAB,       handle); }
    public void keyShiftTab()            { invoke(H_KEY_SHIFT_TAB, handle); }
    public void motionCode(int code, boolean extend) { invoke(H_MOTION_CODE, handle, code, extend?1:0); }
    public void moveUp(long lines, boolean extend)   { invoke(H_MOVE_UP,    handle, lines, extend?1:0); }
    public void moveDown(long lines, boolean extend) { invoke(H_MOVE_DOWN,  handle, lines, extend?1:0); }

    // ── Selection ─────────────────────────────────────────────────────────────

    public void selectWord()   { invoke(H_SELECT_WORD,     handle); }
    public void selectLine()   { invoke(H_SELECT_LINE,     handle); }
    public void selectAll()    { invoke(H_SELECT_ALL,      handle); }
    public void expandSelection() { invoke(H_EXPAND_SEL,  handle); }
    public void addCursorAtNextOccurrence() { invoke(H_ADD_CURSOR_NEXT, handle); }

    // ── Clipboard ─────────────────────────────────────────────────────────────

    public void copy()  { invoke(H_COPY,  handle); }
    public long cut()   { return invoke(H_CUT,   handle); }
    public long paste() { return invoke(H_PASTE, handle); }
    public String clipboardText() { return fetchStr(invoke(H_CLIP_TEXT, handle)); }

    // ── Macros ────────────────────────────────────────────────────────────────

    public int  macroStart(char register) { return invoke(H_MACRO_START, handle, (byte)register); }
    public int  macroStop()               { return invoke(H_MACRO_STOP,  handle); }
    public long macroPlay(char register, long count) { return invoke(H_MACRO_PLAY, handle, (byte)register, count); }
    public boolean isMacroRecording()     { return ((int) invoke(H_MACRO_IS_REC, handle)) != 0; }
    public String exportMacros()          { return fetchStr(invoke(H_MACRO_EXPORT, handle)); }
    public int importMacros(String json)  {
        try (var a = Arena.ofConfined()) { return invoke(H_MACRO_IMPORT, handle, allocStr(a,json)); }
    }

    // ── Format ────────────────────────────────────────────────────────────────

    public long formatDocument() { return invoke(H_FORMAT_DOC,   handle); }
    public long formatOnSave()   { return invoke(H_FORMAT_SAVE,  handle); }
    public long sortImports()    { return invoke(H_SORT_IMPORTS, handle); }

    // ── Stats & diagnostics ───────────────────────────────────────────────────

    public long wordCount()    { return invoke(H_WORD_COUNT,    handle); }
    public long charCount()    { return invoke(H_CHAR_COUNT,    handle); }
    public long errorCount()   { return invoke(H_ERROR_COUNT,   handle); }
    public long warningCount() { return invoke(H_WARNING_COUNT, handle); }
    public JsonNode documentStats() { return fetchJson(invoke(H_DOC_STATS, handle)); }

    // ── Decorations ───────────────────────────────────────────────────────────

    public JsonNode deltaDecorations(String removeJson, String addJson) {
        try (var a = Arena.ofConfined()) {
            return fetchJson(invoke(H_DELTA_DEC, handle, allocStr(a,removeJson), allocStr(a,addJson)));
        }
    }
    public void clearDecorations(String owner) {
        try (var a = Arena.ofConfined()) { invoke(H_CLEAR_DEC, handle, allocStr(a,owner)); }
    }
    public JsonNode getDecorations() { return fetchJson(invoke(H_GET_DEC, handle)); }

    // ── TextModel ─────────────────────────────────────────────────────────────

    public String modelGetLine(long lineNumber) { return fetchStr(invoke(H_MODEL_LINE, handle, lineNumber)); }
    public long   modelGetOffset(long line, long col) { return invoke(H_MODEL_OFFSET, handle, line, col); }
    public JsonNode modelGetPosition(long offset) { return fetchJson(invoke(H_MODEL_POS, handle, offset)); }
    public String modelGetValueInRange(long sl, long sc, long el, long ec) {
        return fetchStr(invoke(H_MODEL_RANGE, handle, sl, sc, el, ec));
    }
    public JsonNode modelFindMatches(String search, long flags, long limit) {
        try (var a = Arena.ofConfined()) {
            return fetchJson(invoke(H_MODEL_FIND, handle, allocStr(a,search), flags, limit));
        }
    }
    public JsonNode modelWordAt(long line, long col) { return fetchJson(invoke(H_MODEL_WORD, handle, line, col)); }
    public long executeEdits(String editsJson) {
        try (var a = Arena.ofConfined()) { return invoke(H_EXEC_EDITS, handle, allocStr(a,editsJson)); }
    }

    // ── Extension system ──────────────────────────────────────────────────────

    public JsonNode listExtensions() { return fetchJson(invoke(H_EXT_LIST, handle)); }
    public void activateStartup()    { invoke(H_EXT_ACT_STR, handle); }
    public JsonNode commandPalette() { return fetchJson(invoke(H_CMD_PALETTE, handle)); }
    public JsonNode searchPalette(String query) {
        try (var a = Arena.ofConfined()) { return fetchJson(invoke(H_CMD_SEARCH, handle, allocStr(a,query))); }
    }
    public JsonNode executeCommand(String id, String argsJson) {
        try (var a = Arena.ofConfined()) {
            var argsPtr = argsJson != null ? allocStr(a, argsJson) : MemorySegment.NULL;
            return fetchJson(invoke(H_CMD_EXEC, handle, allocStr(a,id), argsPtr));
        }
    }
    public JsonNode resolveKey(String key, String contextJson) {
        try (var a = Arena.ofConfined()) {
            var ctx = contextJson != null ? allocStr(a, contextJson) : MemorySegment.NULL;
            return fetchJson(invoke(H_KEY_RESOLVE, handle, allocStr(a,key), ctx));
        }
    }
    public JsonNode listThemes() { return fetchJson(invoke(H_THEME_LIST, handle)); }
    public int setTheme(String id) {
        try (var a = Arena.ofConfined()) { return invoke(H_THEME_SET, handle, allocStr(a,id)); }
    }
    public JsonNode snippetsForLanguage(String lang) {
        try (var a = Arena.ofConfined()) { return fetchJson(invoke(H_SNIPPETS, handle, allocStr(a,lang))); }
    }
    public JsonNode expandSnippet(String lang, String prefix) {
        try (var a = Arena.ofConfined()) { return fetchJson(invoke(H_SNIPPET_EXP, handle, allocStr(a,lang), allocStr(a,prefix))); }
    }
    public JsonNode statusBarItems()  { return fetchJson(invoke(H_STATUS_ITEMS, handle)); }
    public int updateStatusBarItem(String id, String text) {
        try (var a = Arena.ofConfined()) { return invoke(H_STATUS_UPD, handle, allocStr(a,id), allocStr(a,text)); }
    }
    public JsonNode drainNotifications() { return fetchJson(invoke(H_NOTIFS, handle)); }
    public JsonNode pollEvents()         { return fetchJson(invoke(H_EVENTS_POLL, handle)); }
    public JsonNode drainEvents()        { return fetchJson(invoke(H_EVENTS_DRAIN, handle)); }
    public String detectLanguage(String filename, String firstLine) {
        try (var a = Arena.ofConfined()) {
            var fl = firstLine != null ? allocStr(a, firstLine) : MemorySegment.NULL;
            return fetchStr(invoke(H_DETECT_LANG, handle, allocStr(a,filename), fl));
        }
    }

    // ── Batch ─────────────────────────────────────────────────────────────────

    public JsonNode batch(String commandsJson) {
        try (var a = Arena.ofConfined()) { return fetchJson(invoke(H_BATCH, handle, allocStr(a,commandsJson))); }
    }
    public JsonNode batch(List<Map<String,Object>> commands) {
        try { return batch(JSON.writeValueAsString(commands)); }
        catch (Exception e) { throw new RuntimeException(e); }
    }

    // ── Version ───────────────────────────────────────────────────────────────

    public static String version() {
        try {
            MemorySegment ptr = (MemorySegment) H_VERSION.invoke();
            return ptr.reinterpret(Long.MAX_VALUE).getString(0, StandardCharsets.UTF_8);
        } catch (Throwable e) { throw new RuntimeException(e); }
    }
}
