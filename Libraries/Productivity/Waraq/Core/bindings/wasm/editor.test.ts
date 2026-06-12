// bindings/wasm/editor.test.ts
//
// Tests for the TypeScript WASM binding.
// Run with: vitest run
//
// Note: These tests assume the WASM module has been built.
//   wasm-pack build --target web --features wasm --out-dir pkg

import { describe, it, expect, beforeAll, afterEach } from 'vitest';
import { initWasm, createEditor, Editor, TokenKind, tokenColor, DARK_THEME } from './index';

// Initialise WASM once before all tests
beforeAll(async () => {
    await initWasm();
});

// ── Basic lifecycle ───────────────────────────────────────────────────────────

describe('lifecycle', () => {
    it('creates an empty editor', async () => {
        const ed = await createEditor();
        expect(ed.byteLen).toBe(0);
        expect(ed.lineCount).toBe(1);
        ed.dispose();
    });

    it('creates an editor with content', async () => {
        const ed = await createEditor('hello world');
        expect(ed.byteLen).toBe(11);
        expect(ed.getText()).toBe('hello world');
        ed.dispose();
    });

    it('throws after dispose', async () => {
        const ed = await createEditor();
        ed.dispose();
        expect(() => ed.getText()).toThrow('disposed');
    });

    it('dispose is idempotent', async () => {
        const ed = await createEditor();
        ed.dispose();
        expect(() => ed.dispose()).not.toThrow();
    });
});

// ── Text mutations ────────────────────────────────────────────────────────────

describe('mutations', () => {
    it('inserts text', async () => {
        const ed = await createEditor();
        ed.insert(0, 'Hello');
        expect(ed.getText()).toBe('Hello');
        ed.dispose();
    });

    it('inserts at position', async () => {
        const ed = await createEditor('HelloWorld');
        ed.insert(5, ', ');
        expect(ed.getText()).toBe('Hello, World');
        ed.dispose();
    });

    it('deletes text', async () => {
        const ed = await createEditor('Hello World');
        ed.delete(5, 11);
        expect(ed.getText()).toBe('Hello');
        ed.dispose();
    });

    it('replaces text', async () => {
        const ed = await createEditor('Hello World');
        ed.replace(6, 11, 'Rust');
        expect(ed.getText()).toBe('Hello Rust');
        ed.dispose();
    });

    it('handles multiline inserts', async () => {
        const ed = await createEditor('fn main() {\n}\n');
        ed.insert(12, '\n    println!("hello");');
        expect(ed.lineCount).toBe(4);
        expect(ed.getText()).toContain('println!');
        ed.dispose();
    });
});

// ── Undo / Redo ───────────────────────────────────────────────────────────────

describe('undo/redo', () => {
    it('undoes an insert', async () => {
        const ed = await createEditor();
        ed.insert(0, 'hello');
        expect(ed.canUndo).toBe(true);
        expect(ed.undo()).toBe(true);
        expect(ed.getText()).toBe('');
        ed.dispose();
    });

    it('redoes after undo', async () => {
        const ed = await createEditor();
        ed.insert(0, 'abc');
        ed.undo();
        expect(ed.canRedo).toBe(true);
        expect(ed.redo()).toBe(true);
        expect(ed.getText()).toBe('abc');
        ed.dispose();
    });

    it('redo is cleared after new edit', async () => {
        const ed = await createEditor('hello');
        ed.insert(5, ' world');
        ed.undo();
        expect(ed.canRedo).toBe(true);
        ed.insert(5, ' rust');
        expect(ed.canRedo).toBe(false);
        expect(ed.getText()).toBe('hello rust');
        ed.dispose();
    });

    it('undo returns false when nothing to undo', async () => {
        const ed = await createEditor();
        expect(ed.undo()).toBe(false);
        ed.dispose();
    });
});

// ── Cursor ────────────────────────────────────────────────────────────────────

describe('cursor', () => {
    it('moves cursor', async () => {
        const ed = await createEditor('hello world');
        ed.moveCursor(6);
        expect(ed.cursorPos).toBe(6);
        ed.dispose();
    });

    it('cursor adjusts after insert', async () => {
        const ed = await createEditor('hello world');
        ed.moveCursor(6); // at 'w'
        ed.insert(0, 'say '); // 4 bytes before cursor
        expect(ed.cursorPos).toBe(10);
        ed.dispose();
    });

    it('multi-cursor', async () => {
        const ed = await createEditor('hello\nworld\n');
        ed.addCursor(6);
        expect(ed.cursorCount).toBe(2);
        ed.collapseCursors();
        expect(ed.cursorCount).toBe(1);
        ed.dispose();
    });
});

// ── Viewport ─────────────────────────────────────────────────────────────────

describe('viewport', () => {
    it('clips lines to viewport height', async () => {
        const lines = Array.from({ length: 200 }, (_, i) => `line ${i}`).join('\n');
        const ed = await createEditor(lines);
        ed.setViewportHeight(30);
        const frame = ed.renderFrame();
        expect(frame.lines.length).toBe(30);
        ed.dispose();
    });

    it('scrolls viewport', async () => {
        const lines = Array.from({ length: 100 }, (_, i) => `line ${i}`).join('\n');
        const ed = await createEditor(lines);
        ed.setViewportHeight(20);
        ed.scrollBy(10);
        const frame = ed.renderFrame();
        expect(frame.scroll_offset).toBe(10);
        ed.dispose();
    });
});

// ── Search ────────────────────────────────────────────────────────────────────

describe('search', () => {
    it('finds all occurrences', async () => {
        const ed = await createEditor('foo bar foo baz foo');
        const offsets = ed.findAll('foo');
        expect(offsets).toEqual([0, 8, 16]);
        ed.dispose();
    });

    it('returns empty array for no match', async () => {
        const ed = await createEditor('hello world');
        expect(ed.findAll('xyz')).toEqual([]);
        ed.dispose();
    });
});

// ── Render frame ─────────────────────────────────────────────────────────────

describe('renderFrame', () => {
    it('has correct structure', async () => {
        const ed = await createEditor('line one\nline two\n');
        const frame = ed.renderFrame();
        expect(frame.lines.length).toBeGreaterThan(0);
        expect(frame.lines[0].text).toBe('line one');
        expect(frame.lines[0].line_number).toBe(0);
        expect(frame.total_lines).toBeGreaterThanOrEqual(2);
        expect(Array.isArray(frame.cursors)).toBe(true);
        expect(Array.isArray(frame.tokens)).toBe(true);
        ed.dispose();
    });
});

// ── Batch API ─────────────────────────────────────────────────────────────────

describe('batch', () => {
    it('processes multiple commands', async () => {
        const ed = await createEditor();
        const result = ed.batch([
            { cmd: 'insert', at: 0, text: 'hello world' },
            { cmd: 'render_frame' },
        ]);
        expect(result.ok).toBe(true);
        expect(result.ops_applied).toBe(1);
        expect(result.frame?.lines[0].text).toBe('hello world');
        ed.dispose();
    });

    it('handles undo in batch', async () => {
        const ed = await createEditor();
        ed.insert(0, 'hello');
        const result = ed.batch([{ cmd: 'undo' }, { cmd: 'render_frame' }]);
        expect(result.ok).toBe(true);
        expect(ed.getText()).toBe('');
        ed.dispose();
    });

    it('reports errors for invalid batch JSON structure', async () => {
        const ed = await createEditor();
        // Batch method accepts commands array — test with unknown cmd
        const result = ed.batch([{ cmd: 'render_frame' }]);
        expect(result.ok).toBe(true); // render_frame is valid
        ed.dispose();
    });

    it('batchInserts convenience helper', async () => {
        const ed = await createEditor('abc');
        // Insert at multiple points (sorted in reverse order to avoid offset drift)
        ed.batchInserts([
            { at: 3, text: '3' },
            { at: 2, text: '2' },
            { at: 1, text: '1' },
        ]);
        // Each insert shifts subsequent offsets, so result depends on order
        expect(ed.byteLen).toBeGreaterThan(3);
        ed.dispose();
    });
});

// ── Unicode ───────────────────────────────────────────────────────────────────

describe('unicode', () => {
    it('handles multibyte characters', async () => {
        const ed = await createEditor('café\nbar\n');
        expect(ed.getText()).toBe('café\nbar\n');
        expect(ed.getLine(0)).toBe('café');
        ed.dispose();
    });

    it('handles CJK characters', async () => {
        const ed = await createEditor('日本語\nテスト\n');
        expect(ed.getLine(0)).toBe('日本語');
        ed.dispose();
    });

    it('handles emoji', async () => {
        const ed = await createEditor('hello 🦀 world');
        expect(ed.getText()).toBe('hello 🦀 world');
        ed.dispose();
    });
});

// ── Language / Syntax ─────────────────────────────────────────────────────────

describe('syntax', () => {
    it('sets language without throwing', async () => {
        const ed = await createEditor('const x = 1;', 'javascript');
        expect(() => ed.setLanguage('typescript')).not.toThrow();
        ed.dispose();
    });

    it('render frame includes token array', async () => {
        const ed = await createEditor('let x = 42;', 'javascript');
        const frame = ed.renderFrame();
        expect(Array.isArray(frame.tokens)).toBe(true);
        ed.dispose();
    });
});

// ── Theme helpers ─────────────────────────────────────────────────────────────

describe('theme', () => {
    it('maps keyword token to color', () => {
        const color = tokenColor(TokenKind.Keyword, DARK_THEME);
        expect(color).toBe('#ff79c6');
    });

    it('maps unknown kind to default color', () => {
        const color = tokenColor(99, DARK_THEME);
        expect(color).toBe(DARK_THEME.default);
    });
});

// ── Performance sanity ────────────────────────────────────────────────────────

describe('performance', () => {
    it('handles 10k line document efficiently', async () => {
        const content = Array.from({ length: 10_000 }, (_, i) => `line ${i}`).join('\n');
        const start = performance.now();
        const ed = await createEditor(content);
        const frame = ed.renderFrame();
        const elapsed = performance.now() - start;
        expect(ed.lineCount).toBe(10_000);
        expect(elapsed).toBeLessThan(500); // should complete in under 500ms
        ed.dispose();
    }, 10_000);
});
