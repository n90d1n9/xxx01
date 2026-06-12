// bindings/java/WaraqEditorTest.java
//
// JUnit 5 tests for the Java FFM binding.
// Run with: mvn test  OR  gradle test

import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.*;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class WaraqEditorTest {

    // ── Basic lifecycle ───────────────────────────────────────────────────────

    @Test
    void testCreateAndClose() {
        try (var ed = new WaraqEditor()) {
            assertNotNull(ed);
            assertEquals(0L, ed.byteLen());
            assertEquals(1L, ed.lineCount()); // empty doc has 1 line
        }
    }

    @Test
    void testCreateWithContent() {
        try (var ed = new WaraqEditor("hello world")) {
            assertEquals(11L, ed.byteLen());
            assertEquals("hello world", ed.getText());
        }
    }

    @Test
    void testDoubleCloseIsSafe() {
        var ed = new WaraqEditor("test");
        ed.close();
        assertDoesNotThrow(ed::close); // second close is a no-op
    }

    @Test
    void testUseAfterCloseThrows() {
        var ed = new WaraqEditor("test");
        ed.close();
        assertThrows(IllegalStateException.class, ed::getText);
    }

    // ── Text mutations ────────────────────────────────────────────────────────

    @Test
    void testInsert() {
        try (var ed = new WaraqEditor()) {
            assertEquals(0, ed.insert(0, "Hello"));
            assertEquals("Hello", ed.getText());
        }
    }

    @Test
    void testInsertAtMiddle() {
        try (var ed = new WaraqEditor("HelloWorld")) {
            ed.insert(5, ", ");
            assertEquals("Hello, World", ed.getText());
        }
    }

    @Test
    void testDelete() {
        try (var ed = new WaraqEditor("Hello World")) {
            assertEquals(0, ed.delete(5, 11));
            assertEquals("Hello", ed.getText());
        }
    }

    @Test
    void testReplace() {
        try (var ed = new WaraqEditor("Hello World")) {
            assertEquals(0, ed.replace(6, 11, "Rust"));
            assertEquals("Hello Rust", ed.getText());
        }
    }

    @Test
    void testMultilineContent() {
        String content = "line1\nline2\nline3\n";
        try (var ed = new WaraqEditor(content)) {
            assertEquals(3L, ed.lineCount());
            assertEquals("line1", ed.getLine(0));
            assertEquals("line2", ed.getLine(1));
            assertEquals("line3", ed.getLine(2));
        }
    }

    @Test
    void testInsertNewlines() {
        try (var ed = new WaraqEditor("a\nb")) {
            ed.insert(1, "\nnewline\n");
            assertEquals(4L, ed.lineCount());
        }
    }

    // ── Undo / Redo ───────────────────────────────────────────────────────────

    @Test
    void testUndo() {
        try (var ed = new WaraqEditor()) {
            ed.insert(0, "hello");
            assertTrue(ed.canUndo());
            assertFalse(ed.canRedo());
            assertTrue(ed.undo());
            assertEquals("", ed.getText());
            assertFalse(ed.canUndo());
            assertTrue(ed.canRedo());
        }
    }

    @Test
    void testRedo() {
        try (var ed = new WaraqEditor()) {
            ed.insert(0, "abc");
            ed.undo();
            assertTrue(ed.redo());
            assertEquals("abc", ed.getText());
        }
    }

    @Test
    void testRedoClearedAfterNewEdit() {
        try (var ed = new WaraqEditor("hello")) {
            ed.insert(5, " world");
            ed.undo();
            assertTrue(ed.canRedo());
            ed.insert(5, " rust");
            assertFalse(ed.canRedo());
            assertEquals("hello rust", ed.getText());
        }
    }

    @Test
    void testUndoWhenNothingToUndo() {
        try (var ed = new WaraqEditor()) {
            assertFalse(ed.undo()); // returns false, does not throw
        }
    }

    // ── Cursor management ─────────────────────────────────────────────────────

    @Test
    void testCursorMove() {
        try (var ed = new WaraqEditor("hello world")) {
            ed.moveCursor(6, false);
            assertEquals(6L, ed.cursorPos());
        }
    }

    @Test
    void testCursorAdjustsAfterInsert() {
        try (var ed = new WaraqEditor("hello world")) {
            ed.moveCursor(6, false); // cursor at 'w'
            ed.insert(0, "say ");   // 4 bytes inserted before cursor
            assertEquals(10L, ed.cursorPos());
        }
    }

    @Test
    void testMultiCursor() {
        try (var ed = new WaraqEditor("hello\nworld\n")) {
            ed.addCursor(6);
            assertEquals(2L, ed.cursorCount());
            ed.collapseCursors();
            assertEquals(1L, ed.cursorCount());
        }
    }

    // ── Viewport ──────────────────────────────────────────────────────────────

    @Test
    void testViewportHeight() {
        String content = String.join("\n",
            java.util.stream.IntStream.range(0, 200)
                .mapToObj(i -> "line " + i)
                .toArray(String[]::new));
        try (var ed = new WaraqEditor(content)) {
            ed.setViewportHeight(30);
            JsonNode frame = ed.renderFrame();
            assertEquals(30, frame.get("lines").size());
        }
    }

    @Test
    void testScrollBy() {
        String content = String.join("\n",
            java.util.stream.IntStream.range(0, 100)
                .mapToObj(i -> "line " + i)
                .toArray(String[]::new));
        try (var ed = new WaraqEditor(content)) {
            ed.setViewportHeight(20);
            ed.scrollBy(10);
            JsonNode frame = ed.renderFrame();
            assertEquals(10, frame.get("scroll_offset").asInt());
        }
    }

    @Test
    void testEnsureLineVisible() {
        String content = String.join("\n",
            java.util.stream.IntStream.range(0, 200)
                .mapToObj(i -> "line " + i)
                .toArray(String[]::new));
        try (var ed = new WaraqEditor(content)) {
            ed.setViewportHeight(20);
            ed.ensureLineVisible(150);
            JsonNode frame = ed.renderFrame();
            int scrollOffset = frame.get("scroll_offset").asInt();
            assertTrue(scrollOffset <= 150);
            assertTrue(scrollOffset + 20 > 150);
        }
    }

    // ── Search ────────────────────────────────────────────────────────────────

    @Test
    void testFindAll() {
        try (var ed = new WaraqEditor("foo bar foo baz foo")) {
            List<Long> offsets = ed.findAll("foo");
            assertEquals(3, offsets.size());
            assertEquals(0L, offsets.get(0));
            assertEquals(8L, offsets.get(1));
            assertEquals(16L, offsets.get(2));
        }
    }

    @Test
    void testFindAllNoMatch() {
        try (var ed = new WaraqEditor("hello world")) {
            List<Long> offsets = ed.findAll("xyz");
            assertTrue(offsets.isEmpty());
        }
    }

    // ── Render frame ──────────────────────────────────────────────────────────

    @Test
    void testRenderFrameStructure() {
        try (var ed = new WaraqEditor("line one\nline two\n")) {
            JsonNode frame = ed.renderFrame();
            assertTrue(frame.has("lines"));
            assertTrue(frame.has("cursors"));
            assertTrue(frame.has("tokens"));
            assertTrue(frame.has("total_lines"));
            assertTrue(frame.has("scroll_offset"));
            assertTrue(frame.get("total_lines").asLong() >= 2);
            assertEquals("line one", frame.get("lines").get(0).get("text").asText());
        }
    }

    // ── Batch API ─────────────────────────────────────────────────────────────

    @Test
    void testBatchInsertAndRender() throws Exception {
        try (var ed = new WaraqEditor()) {
            JsonNode result = ed.batch("""
                [
                    {"cmd":"insert","at":0,"text":"hello world"},
                    {"cmd":"render_frame"}
                ]
                """);
            assertTrue(result.get("ok").asBoolean());
            assertEquals(1, result.get("ops_applied").asInt());
            assertTrue(result.get("frame").has("lines"));
        }
    }

    @Test
    void testBatchUndoRedo() throws Exception {
        try (var ed = new WaraqEditor()) {
            ed.insert(0, "hello");
            JsonNode result = ed.batch("""
                [{"cmd":"undo"},{"cmd":"render_frame"}]
                """);
            assertTrue(result.get("ok").asBoolean());
            assertEquals("", ed.getText());
        }
    }

    @Test
    void testBatchMultiCursor() throws Exception {
        try (var ed = new WaraqEditor("hello world")) {
            JsonNode result = ed.batch("""
                [
                    {"cmd":"cursor_move","pos":0,"extend":false},
                    {"cmd":"cursor_add","pos":6},
                    {"cmd":"render_frame"}
                ]
                """);
            assertTrue(result.get("ok").asBoolean());
            assertEquals(2L, ed.cursorCount());
        }
    }

    @Test
    void testBatchInvalidJsonReturnsError() throws Exception {
        try (var ed = new WaraqEditor()) {
            JsonNode result = ed.batch("this is not json {{");
            assertFalse(result.get("ok").asBoolean());
            assertTrue(result.get("errors").size() > 0);
        }
    }

    // ── Language / Syntax ─────────────────────────────────────────────────────

    @Test
    void testSetLanguage() {
        try (var ed = new WaraqEditor("fn main() { let x = 1; }")) {
            // Should not throw — even if tree-sitter is not compiled in
            assertDoesNotThrow(() -> ed.setLanguage("rust"));
        }
    }

    // ── Unicode ───────────────────────────────────────────────────────────────

    @Test
    void testUnicodeContent() {
        String content = "café\nnaïve\n日本語\n";
        try (var ed = new WaraqEditor(content)) {
            assertEquals(content, ed.getText());
            assertEquals("café", ed.getLine(0));
            assertEquals("naïve", ed.getLine(1));
            assertEquals("日本語", ed.getLine(2));
        }
    }

    @Test
    void testUnicodeInsert() {
        try (var ed = new WaraqEditor("hello")) {
            ed.insert(5, " 世界");
            assertTrue(ed.getText().contains("世界"));
        }
    }

    // ── Large document ────────────────────────────────────────────────────────

    @Test
    void testLargeDocument() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 50_000; i++) {
            sb.append(String.format("    let variable_%d = %d;\n", i, i * i));
        }
        try (var ed = new WaraqEditor(sb.toString())) {
            assertEquals(50_000L, ed.lineCount());
            // Insert in the middle
            long mid = ed.byteLen() / 2;
            ed.insert(mid, "// inserted\n");
            assertEquals(50_001L, ed.lineCount());
            // Undo
            assertTrue(ed.undo());
            assertEquals(50_000L, ed.lineCount());
        }
    }

    // ── Version ───────────────────────────────────────────────────────────────

    @Test
    void testVersion() {
        String version = WaraqEditor.version();
        assertNotNull(version);
        assertFalse(version.isEmpty());
        // Should look like semver: "0.1.0"
        assertTrue(version.matches("\\d+\\.\\d+\\.\\d+.*"));
    }
}
