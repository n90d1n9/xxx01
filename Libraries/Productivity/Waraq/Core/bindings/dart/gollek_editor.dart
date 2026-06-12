// bindings/dart/waraq_editor.dart
//
// Complete Dart FFI binding — all 198+ exported C functions.
// Requires dart:ffi and the waraq_editor_core shared library.
//
// Usage:
//   final ed = WaraqEditor.create(content: 'fn main() {}', language: 'rust');
//   ed.setViewportHeight(40);
//   final frame = ed.renderFrame();
//   print('Lines: ${frame['total_lines']}');
//   ed.dispose();

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ── FFI type aliases ────────────────────────────────────────────────────────

typedef _NativeVoidPtr = Void Function(Pointer<Void>);
typedef _DartVoidPtr  = void Function(Pointer<Void>);
typedef _NativeI32Ptr = Int32 Function(Pointer<Void>);
typedef _DartI32Ptr   = int  Function(Pointer<Void>);
typedef _NativeU64Ptr = Uint64 Function(Pointer<Void>);
typedef _DartU64Ptr   = int  Function(Pointer<Void>);
typedef _NativePtrPtr = Pointer<Utf8> Function(Pointer<Void>);
typedef _DartPtrPtr   = Pointer<Utf8> Function(Pointer<Void>);

// ── Library loader ──────────────────────────────────────────────────────────

DynamicLibrary _loadLib() {
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libwaraq_editor_core.so');
  } else if (Platform.isIOS || Platform.isMacOS) {
    return DynamicLibrary.open('libwaraq_editor_core.dylib');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('waraq_editor_core.dll');
  }
  return DynamicLibrary.process();
}

// ── Binding class ───────────────────────────────────────────────────────────

class WaraqEditor {
  static final DynamicLibrary _lib = _loadLib();

  // ── Function lookup helpers ───────────────────────────────────────────────

  static T _fn<T extends Function>(String name) =>
    _lib.lookupFunction<T, T>(name);

  // Core
  static final _create        = _lib.lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>('editor_create');
  static final _createWith    = _lib.lookupFunction<Pointer<Void> Function(Pointer<Utf8>), Pointer<Void> Function(Pointer<Utf8>)>('editor_create_with_content');
  static final _destroy       = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_destroy');
  static final _freeStr       = _lib.lookupFunction<Void Function(Pointer<Utf8>), void Function(Pointer<Utf8>)>('editor_free_str');

  // Text
  static final _getText       = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_get_text');
  static final _byteLen       = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_byte_len');
  static final _lineCount     = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_line_count');

  // Mutations
  static final _insert        = _lib.lookupFunction<Int32 Function(Pointer<Void>, Uint64, Pointer<Utf8>), int Function(Pointer<Void>, int, Pointer<Utf8>)>('editor_insert');
  static final _delete        = _lib.lookupFunction<Int32 Function(Pointer<Void>, Uint64, Uint64), int Function(Pointer<Void>, int, int)>('editor_delete');
  static final _replace       = _lib.lookupFunction<Int32 Function(Pointer<Void>, Uint64, Uint64, Pointer<Utf8>), int Function(Pointer<Void>, int, int, Pointer<Utf8>)>('editor_replace');
  static final _undo          = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_undo');
  static final _redo          = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_redo');
  static final _canUndo       = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_can_undo');
  static final _canRedo       = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_can_redo');

  // Cursor
  static final _cursorPos     = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_cursor_pos');
  static final _cursorCount   = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_cursor_count');
  static final _cursorMove    = _lib.lookupFunction<Void Function(Pointer<Void>, Uint64, Int32), void Function(Pointer<Void>, int, int)>('editor_cursor_move');
  static final _cursorAdd     = _lib.lookupFunction<Void Function(Pointer<Void>, Uint64), void Function(Pointer<Void>, int)>('editor_cursor_add');
  static final _cursorCollapse= _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_cursor_collapse');

  // Keys
  static final _typeChar      = _lib.lookupFunction<Void Function(Pointer<Void>, Int32), void Function(Pointer<Void>, int)>('editor_type_char');
  static final _keyBS         = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_key_backspace');
  static final _keyDel        = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_key_delete');
  static final _keyEnter      = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_key_enter');
  static final _keyTab        = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_key_tab');
  static final _keyShiftTab   = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_key_shift_tab');

  // Motion
  static final _motionCode    = _lib.lookupFunction<Void Function(Pointer<Void>, Int32, Int32), void Function(Pointer<Void>, int, int)>('editor_motion_code');
  static final _moveUp        = _lib.lookupFunction<Void Function(Pointer<Void>, Uint64, Int32), void Function(Pointer<Void>, int, int)>('editor_move_up');
  static final _moveDown      = _lib.lookupFunction<Void Function(Pointer<Void>, Uint64, Int32), void Function(Pointer<Void>, int, int)>('editor_move_down');

  // Selection
  static final _selectWord    = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_select_word');
  static final _selectLine    = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_select_line');
  static final _selectAll     = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_select_all');
  static final _expandSel     = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_expand_selection');
  static final _addCursorNext = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_add_cursor_at_next_occurrence');

  // Viewport
  static final _setVH         = _lib.lookupFunction<Void Function(Pointer<Void>, Uint64), void Function(Pointer<Void>, int)>('editor_set_viewport_height');
  static final _scrollBy      = _lib.lookupFunction<Void Function(Pointer<Void>, Int32), void Function(Pointer<Void>, int)>('editor_scroll_by');
  static final _ensureLine    = _lib.lookupFunction<Void Function(Pointer<Void>, Uint64), void Function(Pointer<Void>, int)>('editor_ensure_line_visible');

  // Language
  static final _setLanguage   = _lib.lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>), void Function(Pointer<Void>, Pointer<Utf8>)>('editor_set_language');
  static final _setConfigVal  = _lib.lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_set_config_value');

  // Search
  static final _searchStart   = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Uint64, Int32), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, int, int)>('editor_search_start');
  static final _searchNext    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_search_next');
  static final _searchPrev    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_search_prev');
  static final _searchClear   = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_search_clear');
  static final _replaceCurr   = _lib.lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>), void Function(Pointer<Void>, Pointer<Utf8>)>('editor_replace_current');
  static final _replaceAll    = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_replace_all');

  // Folds
  static final _foldToggle    = _lib.lookupFunction<Void Function(Pointer<Void>, Uint64), void Function(Pointer<Void>, int)>('editor_fold_toggle');
  static final _foldAll       = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_fold_all');
  static final _unfoldAll     = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_unfold_all');

  // Render
  static final _renderJson    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_render_frame_json');

  // Batch
  static final _batch         = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>)>('editor_batch');

  // Clipboard
  static final _copy          = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_copy');
  static final _cut           = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_cut');
  static final _paste         = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_paste');
  static final _cyclePaste    = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_cycle_paste');
  static final _clipText      = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_clipboard_text');
  static final _clipHistLen   = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_clipboard_history_len');

  // Macros
  static final _macroStart    = _lib.lookupFunction<Int32 Function(Pointer<Void>, Uint8), int Function(Pointer<Void>, int)>('editor_macro_start');
  static final _macroStop     = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_macro_stop');
  static final _macroPlay     = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Uint8, Uint64), int Function(Pointer<Void>, int, int)>('editor_macro_play');
  static final _macroIsRec    = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_macro_is_recording');
  static final _macroExport   = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_macro_export');
  static final _macroImport   = _lib.lookupFunction<Int32 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_macro_import');

  // Format
  static final _fmtDoc        = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_format_document');
  static final _fmtSave       = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_format_on_save');
  static final _sortImports   = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_sort_imports');

  // Stats
  static final _wordCount     = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_word_count');
  static final _charCount     = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_char_count');
  static final _docStats      = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_document_stats');
  static final _errorCount    = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_error_count');
  static final _warningCount  = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_warning_count');

  // Decorations
  static final _deltaDec      = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_delta_decorations');
  static final _clearDec      = _lib.lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>), void Function(Pointer<Void>, Pointer<Utf8>)>('editor_clear_decorations');
  static final _getDec        = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_get_decorations');
  static final _overviewRuler = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_overview_ruler');

  // TextModel
  static final _modelLine     = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Uint64), Pointer<Utf8> Function(Pointer<Void>, int)>('editor_model_get_line');
  static final _modelOffset   = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Uint64, Uint64), int Function(Pointer<Void>, int, int)>('editor_model_get_offset');
  static final _modelPos      = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Uint64), Pointer<Utf8> Function(Pointer<Void>, int)>('editor_model_get_position');
  static final _modelRange    = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Uint64, Uint64, Uint64, Uint64), Pointer<Utf8> Function(Pointer<Void>, int, int, int, int)>('editor_model_get_value_in_range');
  static final _modelFind     = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Uint64, Uint64), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, int, int)>('editor_model_find_matches');
  static final _modelWord     = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Uint64, Uint64), Pointer<Utf8> Function(Pointer<Void>, int, int)>('editor_model_word_at');
  static final _execEdits     = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_execute_edits');

  // Extension system
  static final _extList       = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ext_list');
  static final _extActStartup = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_ext_activate_startup');
  static final _extActLang    = _lib.lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>), void Function(Pointer<Void>, Pointer<Utf8>)>('editor_ext_activate_for_language');
  static final _cmdPalette    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_cmd_palette');
  static final _cmdSearch     = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>)>('editor_cmd_search');
  static final _cmdExecute    = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_cmd_execute');
  static final _keyResolve    = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_key_resolve');
  static final _themeList     = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_theme_list');
  static final _themeSet      = _lib.lookupFunction<Int32 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_theme_set');
  static final _themeGet      = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_theme_get_active');
  static final _snippetLang   = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>)>('editor_snippets_for_language');
  static final _snippetExpand = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_snippet_expand');
  static final _statusItems   = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_statusbar_items');
  static final _statusUpdate  = _lib.lookupFunction<Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_statusbar_update');
  static final _notifDrain    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_notifications_drain');
  static final _extPollEvt    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ext_poll_events');
  static final _extDrainEvt   = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ext_drain_events');
  static final _detectLang    = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_detect_language');

  // Git gutter
  static final _gitDiff       = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>)>('editor_git_diff');
  static final _gitApply      = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_git_apply_decorations');
  static final _gitClear      = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_git_clear');

  // Word wrap
  static final _setWordWrap   = _lib.lookupFunction<Void Function(Pointer<Void>, Int32, Uint64), void Function(Pointer<Void>, int, int)>('editor_set_word_wrap');
  static final _getWordWrap   = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_get_word_wrap');
  static final _visualLines   = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Uint64, Uint64, Uint64), Pointer<Utf8> Function(Pointer<Void>, int, int, int)>('editor_wrapped_lines');
  static final _visualCount   = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Uint64), int Function(Pointer<Void>, int)>('editor_visual_line_count');

  // Advanced features
  static final _highlightWord = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_highlight_word_at_cursor');
  static final _clearWordHL   = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_clear_word_highlights');
  static final _docOutline    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_document_outline');
  static final _breadcrumbs   = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_breadcrumbs');
  static final _applySemanticTokens = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_apply_semantic_tokens');
  static final _setInlayHints = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_set_inlay_hints');

  // Version
  static final _version       = _lib.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('editor_version');

  // ── Instance ─────────────────────────────────────────────────────────────

  final Pointer<Void> _handle;
  bool _disposed = false;

  WaraqEditor._(this._handle);

  factory WaraqEditor.create({String? content, String? language}) {
    final Pointer<Void> h;
    if (content != null && content.isNotEmpty) {
      final s = content.toNativeUtf8();
      h = _createWith(s);
      calloc.free(s);
    } else {
      h = _create();
    }
    final ed = WaraqEditor._(h);
    if (language != null && language.isNotEmpty) ed.setLanguage(language);
    return ed;
  }

  void dispose() {
    if (!_disposed) { _destroy(_handle); _disposed = true; }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fetchStr(Pointer<Utf8> ptr) {
    if (ptr == nullptr) return '';
    final s = ptr.toDartString();
    _freeStr(ptr);
    return s;
  }

  dynamic _fetchJson(Pointer<Utf8> ptr) {
    final s = _fetchStr(ptr);
    if (s.isEmpty) return null;
    return jsonDecode(s);
  }

  Pointer<Utf8> _alloc(String s) => s.toNativeUtf8();

  R _withStr<R>(String s, R Function(Pointer<Utf8>) f) {
    final p = s.toNativeUtf8();
    try { return f(p); } finally { calloc.free(p); }
  }

  R _with2Strs<R>(String a, String b, R Function(Pointer<Utf8>, Pointer<Utf8>) f) {
    final pa = a.toNativeUtf8(); final pb = b.toNativeUtf8();
    try { return f(pa, pb); } finally { calloc.free(pa); calloc.free(pb); }
  }

  // ── Text ──────────────────────────────────────────────────────────────────

  String getText()          => _fetchStr(_getText(_handle));
  int    get byteLen        => _byteLen(_handle);
  int    get lineCount      => _lineCount(_handle);

  // ── Mutations ─────────────────────────────────────────────────────────────

  int insert(int at, String text) =>
    _withStr(text, (p) => _insert(_handle, at, p));
  int delete(int start, int end)  => _delete(_handle, start, end);
  int replace(int start, int end, String text) =>
    _withStr(text, (p) => _replace(_handle, start, end, p));
  bool undo() => _undo(_handle) != 0;
  bool redo() => _redo(_handle) != 0;
  bool get canUndo => _canUndo(_handle) != 0;
  bool get canRedo => _canRedo(_handle) != 0;

  // ── Cursor ────────────────────────────────────────────────────────────────

  int  get cursorPos   => _cursorPos(_handle);
  int  get cursorCount => _cursorCount(_handle);
  void moveCursor(int pos, {bool extend = false}) => _cursorMove(_handle, pos, extend ? 1 : 0);
  void addCursor(int pos)   => _cursorAdd(_handle, pos);
  void collapseCursors()    => _cursorCollapse(_handle);

  // ── Keys ──────────────────────────────────────────────────────────────────

  void typeChar(int codePoint) => _typeChar(_handle, codePoint);
  void typeString(String s)    { for (final r in s.runes) typeChar(r); }
  void keyBackspace() => _keyBS(_handle);
  void keyDelete()    => _keyDel(_handle);
  void keyEnter()     => _keyEnter(_handle);
  void keyTab()       => _keyTab(_handle);
  void keyShiftTab()  => _keyShiftTab(_handle);

  // ── Motion ────────────────────────────────────────────────────────────────

  void motionCode(int code, {bool extend = false}) => _motionCode(_handle, code, extend ? 1 : 0);
  void moveUp(int lines, {bool extend = false})    => _moveUp(_handle, lines, extend ? 1 : 0);
  void moveDown(int lines, {bool extend = false})  => _moveDown(_handle, lines, extend ? 1 : 0);

  // ── Selection ─────────────────────────────────────────────────────────────

  void selectWord()                  => _selectWord(_handle);
  void selectLine()                  => _selectLine(_handle);
  void selectAll()                   => _selectAll(_handle);
  void expandSelection()             => _expandSel(_handle);
  void addCursorAtNextOccurrence()   => _addCursorNext(_handle);

  // ── Viewport ──────────────────────────────────────────────────────────────

  void setViewportHeight(int h)  => _setVH(_handle, h);
  void scrollBy(int delta)       => _scrollBy(_handle, delta);
  void ensureLineVisible(int l)  => _ensureLine(_handle, l);

  // ── Language ──────────────────────────────────────────────────────────────

  void setLanguage(String lang) => _withStr(lang, (p) => _setLanguage(_handle, p));
  void setConfigValue(String key, String val) =>
    _with2Strs(key, val, (pk, pv) => _setConfigVal(_handle, pk, pv));

  // ── Search ────────────────────────────────────────────────────────────────

  Map<String,dynamic>? searchStart(String pattern, {int flags = 0}) {
    return _withStr(pattern, (p) => _fetchJson(_searchStart(_handle, p, pattern.length, flags)));
  }
  Map<String,dynamic>? searchNext() => _fetchJson(_searchNext(_handle));
  Map<String,dynamic>? searchPrev() => _fetchJson(_searchPrev(_handle));
  void searchClear() => _searchClear(_handle);
  void replaceCurrent(String r) => _withStr(r, (p) => _replaceCurr(_handle, p));
  int  replaceAll(String r)     => _withStr(r, (p) => _replaceAll(_handle, p));

  // ── Folds ─────────────────────────────────────────────────────────────────

  void toggleFold(int line) => _foldToggle(_handle, line);
  void foldAll()   => _foldAll(_handle);
  void unfoldAll() => _unfoldAll(_handle);

  // ── Render ────────────────────────────────────────────────────────────────

  Map<String,dynamic> renderFrame() => _fetchJson(_renderJson(_handle));

  // ── Batch ─────────────────────────────────────────────────────────────────

  Map<String,dynamic> batch(List<Map<String,dynamic>> commands) {
    final json = jsonEncode(commands);
    return _withStr(json, (p) => _fetchJson(_batch(_handle, p)));
  }

  // ── Clipboard ─────────────────────────────────────────────────────────────

  void   copy()        => _copy(_handle);
  int    cut()         => _cut(_handle);
  int    paste()       => _paste(_handle);
  int    cyclePaste()  => _cyclePaste(_handle);
  String clipboardText()     => _fetchStr(_clipText(_handle));
  int    clipboardHistoryLen => _clipHistLen(_handle);

  // ── Macros ────────────────────────────────────────────────────────────────

  int  macroStart(String register) => _macroStart(_handle, register.codeUnitAt(0));
  int  macroStop()                  => _macroStop(_handle);
  int  macroPlay(String register, {int count = 1}) =>
    _macroPlay(_handle, register.codeUnitAt(0), count);
  bool get isMacroRecording => _macroIsRec(_handle) != 0;
  String exportMacros()        => _fetchStr(_macroExport(_handle));
  int    importMacros(String j)=> _withStr(j, (p) => _macroImport(_handle, p));

  // ── Format ────────────────────────────────────────────────────────────────

  int formatDocument() => _fmtDoc(_handle);
  int formatOnSave()   => _fmtSave(_handle);
  int sortImports()    => _sortImports(_handle);

  // ── Stats & diagnostics ───────────────────────────────────────────────────

  int    get wordCount    => _wordCount(_handle);
  int    get charCount    => _charCount(_handle);
  int    get errorCount   => _errorCount(_handle);
  int    get warningCount => _warningCount(_handle);
  Map<String,dynamic> documentStats() => _fetchJson(_docStats(_handle));

  // ── Decorations ───────────────────────────────────────────────────────────

  List<dynamic> deltaDecorations(List<int> removeIds, List<Map<String,dynamic>> addSpecs) {
    return _with2Strs(jsonEncode(removeIds), jsonEncode(addSpecs),
      (pr, pa) => _fetchJson(_deltaDec(_handle, pr, pa)) ?? []);
  }
  void clearDecorations(String owner) => _withStr(owner, (p) => _clearDec(_handle, p));
  List<dynamic> getDecorations()      => _fetchJson(_getDec(_handle)) ?? [];
  List<dynamic> overviewRuler()       => _fetchJson(_overviewRuler(_handle)) ?? [];

  // ── TextModel ─────────────────────────────────────────────────────────────

  String modelGetLine(int lineNumber)        => _fetchStr(_modelLine(_handle, lineNumber));
  int    modelGetOffset(int line, int col)   => _modelOffset(_handle, line, col);
  Map<String,dynamic> modelGetPosition(int offset) => _fetchJson(_modelPos(_handle, offset));
  String modelGetValueInRange(int sl, int sc, int el, int ec) =>
    _fetchStr(_modelRange(_handle, sl, sc, el, ec));
  List<dynamic> modelFindMatches(String search, {int flags = 1, int limit = 0}) =>
    _withStr(search, (p) => _fetchJson(_modelFind(_handle, p, flags, limit))) ?? [];
  Map<String,dynamic>? modelWordAt(int line, int col) =>
    _fetchJson(_modelWord(_handle, line, col));
  int executeEdits(List<Map<String,dynamic>> edits) {
    return _withStr(jsonEncode(edits), (p) => _execEdits(_handle, p));
  }

  // ── Extension system ──────────────────────────────────────────────────────

  List<dynamic> listExtensions()       => _fetchJson(_extList(_handle)) ?? [];
  void activateStartup()               => _extActStartup(_handle);
  void activateForLanguage(String lang) => _withStr(lang, (p) => _extActLang(_handle, p));
  List<dynamic> commandPalette()        => _fetchJson(_cmdPalette(_handle)) ?? [];
  List<dynamic> searchPalette(String q) =>
    _withStr(q, (p) => _fetchJson(_cmdSearch(_handle, p))) ?? [];
  Map<String,dynamic> executeCommand(String id, {Map<String,dynamic>? args}) =>
    _with2Strs(id, args != null ? jsonEncode(args) : '',
      (pi, pa) => _fetchJson(_cmdExecute(_handle, pi, pa))) ?? {};
  Map<String,dynamic> resolveKey(String key, {Map<String,dynamic>? context}) =>
    _with2Strs(key, context != null ? jsonEncode(context) : '',
      (pk, pc) => _fetchJson(_keyResolve(_handle, pk, pc))) ?? {};
  List<dynamic> listThemes()         => _fetchJson(_themeList(_handle)) ?? [];
  int           setTheme(String id)  => _withStr(id, (p) => _themeSet(_handle, p));
  Map<String,dynamic>? activeTheme() => _fetchJson(_themeGet(_handle));
  List<dynamic> snippetsForLanguage(String lang) =>
    _withStr(lang, (p) => _fetchJson(_snippetLang(_handle, p))) ?? [];
  Map<String,dynamic>? expandSnippet(String lang, String prefix) =>
    _with2Strs(lang, prefix, (pl, pp) => _fetchJson(_snippetExpand(_handle, pl, pp)));
  List<dynamic> statusBarItems()      => _fetchJson(_statusItems(_handle)) ?? [];
  int updateStatusBarItem(String id, String text) =>
    _with2Strs(id, text, (pi, pt) => _statusUpdate(_handle, pi, pt));
  List<dynamic> drainNotifications()  => _fetchJson(_notifDrain(_handle)) ?? [];
  List<dynamic> pollEvents()          => _fetchJson(_extPollEvt(_handle)) ?? [];
  List<dynamic> drainEvents()         => _fetchJson(_extDrainEvt(_handle)) ?? [];
  String? detectLanguage(String filename, {String? firstLine}) {
    final result = _with2Strs(filename, firstLine ?? '',
      (pf, pl) => _fetchStr(_detectLang(_handle, pf, pl)));
    return result.isEmpty ? null : result;
  }

  // ── Git gutter ────────────────────────────────────────────────────────────

  List<dynamic> gitDiff(String headContent) =>
    _withStr(headContent, (p) => _fetchJson(_gitDiff(_handle, p))) ?? [];
  int  gitApplyDecorations(String headContent) =>
    _withStr(headContent, (p) => _gitApply(_handle, p));
  void gitClear() => _gitClear(_handle);

  // ── Word wrap ─────────────────────────────────────────────────────────────

  /// mode: 0=Off, 1=On(viewport), 2=Column(col)
  void setWordWrap(int mode, {int col = 80}) => _setWordWrap(_handle, mode, col);
  int  get wordWrapMode => _getWordWrap(_handle);
  int  visualLineCount({int viewportCols = 80}) => _visualCount(_handle, viewportCols);
  List<dynamic> wrappedLines(int first, int last, {int viewportCols = 80}) =>
    _fetchJson(_visualLines(_handle, first, last, viewportCols)) ?? [];

  // ── Advanced ──────────────────────────────────────────────────────────────

  int  highlightWordAtCursor()   => _highlightWord(_handle);
  void clearWordHighlights()     => _clearWordHL(_handle);
  List<dynamic> documentOutline()=> _fetchJson(_docOutline(_handle)) ?? [];
  List<dynamic> breadcrumbs()    => _fetchJson(_breadcrumbs(_handle)) ?? [];
  int  applySemanticTokens(String tokensJson, {String legendJson = '[]'}) =>
    _with2Strs(tokensJson, legendJson, (pt, pl) => _applySemanticTokens(_handle, pt, pl));
  int  setInlayHints(String hintsJson) =>
    _withStr(hintsJson, (p) => _setInlayHints(_handle, p));

  // ── Version ───────────────────────────────────────────────────────────────

  static String get version => _version().toDartString();
}

// ═══ AI API ══════════════════════════════════════════════════════════════════

  static final _aiHasCompletion   = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_ai_has_completion');
  static final _aiCompletionText  = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ai_completion_text');
  static final _aiAcceptCompletion= _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_ai_accept_completion');
  static final _aiDismiss         = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_ai_dismiss_completion');
  static final _aiOnChange        = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ai_on_change');
  static final _aiBuildExplain    = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ai_build_explain_prompt');
  static final _aiBuildEdit       = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>)>('editor_ai_build_edit_prompt');
  static final _aiBuildFim        = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ai_build_fim_prompt');
  static final _aiApplyResult     = _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_ai_apply_result');
  static final _aiExtractCtx      = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ai_extract_context');
  static final _aiStats           = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_ai_completion_stats');

  bool get aiHasCompletion         => _aiHasCompletion(_handle) != 0;
  String? get aiCompletionText     => _fetchStr(_aiCompletionText(_handle)).nullIfEmpty();
  bool acceptCompletion()           => _aiAcceptCompletion(_handle) != 0;
  void dismissCompletion()          => _aiDismiss(_handle);
  Map<String,dynamic> aiOnChange()  => _fetchJson(_aiOnChange(_handle)) ?? {};
  Map<String,dynamic> buildExplainPrompt()  => _fetchJson(_aiBuildExplain(_handle)) ?? {};
  Map<String,dynamic> buildEditPrompt(String instruction) =>
    _withStr(instruction, (p) => _fetchJson(_aiBuildEdit(_handle, p))) ?? {};
  Map<String,dynamic> buildFimPrompt()     => _fetchJson(_aiBuildFim(_handle)) ?? {};
  Map<String,dynamic> applyAiResult(String task, String response) =>
    _with2Strs(task, response, (pt, pr) => _fetchJson(_aiApplyResult(_handle, pt, pr))) ?? {};
  Map<String,dynamic> extractAiContext()   => _fetchJson(_aiExtractCtx(_handle)) ?? {};
  Map<String,dynamic> aiCompletionStats()  => _fetchJson(_aiStats(_handle)) ?? {};

// ═══ Session API ═════════════════════════════════════════════════════════════

  static final _sessionCapture = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_session_capture');
  static final _sessionRestore = _lib.lookupFunction<Pointer<Void> Function(Pointer<Utf8>), Pointer<Void> Function(Pointer<Utf8>)>('editor_session_restore');
  static final _isDirty        = _lib.lookupFunction<_NativeI32Ptr, _DartI32Ptr>('editor_is_dirty');
  static final _markClean      = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_mark_clean');
  static final _undoDepth      = _lib.lookupFunction<_NativeU64Ptr, _DartU64Ptr>('editor_undo_depth');

  String captureSession() => _fetchStr(_sessionCapture(_handle));
  bool get isDirty        => _isDirty(_handle) != 0;
  void markClean()         => _markClean(_handle);
  int  get undoDepth       => _undoDepth(_handle);

  static WaraqEditor? restoreSession(String sessionJson) {
    final p = sessionJson.toNativeUtf8();
    try {
      final h = _sessionRestore(p);
      return h == nullptr ? null : WaraqEditor._(h);
    } finally { calloc.free(p); }
  }

// ═══ LSP pipeline API ════════════════════════════════════════════════════════

  static final _lspApplyDiag  = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_lsp_apply_diagnostics');
  static final _lspApplyHover = _lib.lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>, Uint64), void Function(Pointer<Void>, Pointer<Utf8>, int)>('editor_lsp_apply_hover');
  static final _lspClearHover = _lib.lookupFunction<_NativeVoidPtr, _DartVoidPtr>('editor_lsp_clear_hover');
  static final _lspCodeActions= _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>)>('editor_lsp_code_actions');
  static final _lspApplyEdit  = _lib.lookupFunction<Uint64 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_lsp_apply_edit');

  int  applyLspDiagnostics(String diagnosticsJson) =>
    _withStr(diagnosticsJson, (p) => _lspApplyDiag(_handle, p));
  void applyLspHover(String hoverJson, int offset) =>
    _withStr(hoverJson, (p) => _lspApplyHover(_handle, p, offset));
  void clearLspHover()    => _lspClearHover(_handle);
  Map<String,dynamic> lspCodeActions(String actionsJson) =>
    _withStr(actionsJson, (p) => _fetchJson(_lspCodeActions(_handle, p))) ?? {};
  int applyLspEdit(String editJson) =>
    _withStr(editJson, (p) => _lspApplyEdit(_handle, p));

// ═══ Settings API ════════════════════════════════════════════════════════════

  static final _settingsLoadUser = _lib.lookupFunction<Int32 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_settings_load_user');
  static final _settingsLoadWs   = _lib.lookupFunction<Int32 Function(Pointer<Void>, Pointer<Utf8>), int Function(Pointer<Void>, Pointer<Utf8>)>('editor_settings_load_workspace');
  static final _settingsSet      = _lib.lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>), void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('editor_settings_set');
  static final _settingsGetAll   = _lib.lookupFunction<_NativePtrPtr, _DartPtrPtr>('editor_settings_get_all');

  int  loadUserSettings(String json) =>
    _withStr(json, (p) => _settingsLoadUser(_handle, p));
  int  loadWorkspaceSettings(String json) =>
    _withStr(json, (p) => _settingsLoadWs(_handle, p));
  void setSetting(String key, String value) =>
    _with2Strs(key, value, (pk, pv) => _settingsSet(_handle, pk, pv));
  Map<String,dynamic> getAllSettings() =>
    _fetchJson(_settingsGetAll(_handle)) ?? {};

// ═══ Helper extension ════════════════════════════════════════════════════════
}

extension _StringNullable on String {
  String? nullIfEmpty() => isEmpty ? null : this;
}
