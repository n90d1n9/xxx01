// benches/editing_bench.rs
//
// Criterion benchmarks for the core editing operations.
// Run with: cargo bench

use criterion::{black_box, criterion_group, criterion_main, BenchmarkId, Criterion};
use waraq_editor_core::core::buffer::Buffer;
use waraq_editor_core::core::types::ByteOffset;
use waraq_editor_core::{EditOp, Editor};

// ── Buffer construction ───────────────────────────────────────────────────────

fn bench_buffer_from_str(c: &mut Criterion) {
    let mut group = c.benchmark_group("buffer_from_str");
    for size in [1_000, 10_000, 100_000, 1_000_000] {
        let content: String = "x".repeat(size);
        group.bench_with_input(BenchmarkId::from_parameter(size), &content, |b, s| {
            b.iter(|| Buffer::from_str(black_box(s)));
        });
    }
    group.finish();
}

// ── Insert at various positions ───────────────────────────────────────────────

fn bench_insert(c: &mut Criterion) {
    let mut group = c.benchmark_group("insert");

    // Insert at beginning of a large file
    let content: String = (0..10_000).map(|i| format!("line {}\n", i)).collect();
    let text = "inserted text\n";

    group.bench_function("insert_at_start_10k_lines", |b| {
        b.iter(|| {
            let mut buf = Buffer::from_str(black_box(&content));
            buf.apply_op(&EditOp::insert(0, black_box(text)));
        });
    });

    group.bench_function("insert_at_middle_10k_lines", |b| {
        b.iter(|| {
            let mut buf = Buffer::from_str(black_box(&content));
            let mid = buf.len_bytes() / 2;
            buf.apply_op(&EditOp::insert(mid, black_box(text)));
        });
    });

    group.bench_function("insert_at_end_10k_lines", |b| {
        b.iter(|| {
            let mut buf = Buffer::from_str(black_box(&content));
            let end = buf.len_bytes();
            buf.apply_op(&EditOp::insert(end, black_box(text)));
        });
    });

    group.finish();
}

// ── Sequential typing simulation ─────────────────────────────────────────────

fn bench_sequential_typing(c: &mut Criterion) {
    c.bench_function("sequential_typing_1000_chars", |b| {
        b.iter(|| {
            let mut ed = Editor::new();
            for (i, ch) in "hello world foo bar baz qux quux corge grault garply waldo fred "
                .chars()
                .cycle()
                .take(1000)
                .enumerate()
            {
                ed.apply(EditOp::type_char(i, ch));
            }
        });
    });
}

// ── Undo/redo stack ───────────────────────────────────────────────────────────

fn bench_undo_redo(c: &mut Criterion) {
    let mut group = c.benchmark_group("undo_redo");

    group.bench_function("undo_100_edits", |b| {
        b.iter(|| {
            let mut ed = Editor::new();
            for i in 0..100 {
                ed.apply(EditOp::insert(ed.buffer.len_bytes(), "x"));
            }
            for _ in 0..100 {
                ed.undo();
            }
        });
    });

    group.bench_function("undo_redo_interleaved_50", |b| {
        b.iter(|| {
            let mut ed = Editor::new();
            for _ in 0..50 {
                ed.apply(EditOp::insert(0, "abc"));
            }
            for _ in 0..25 {
                ed.undo();
            }
            for _ in 0..25 {
                ed.redo();
            }
        });
    });

    group.finish();
}

// ── Coordinate conversion ─────────────────────────────────────────────────────

fn bench_coordinate_conversion(c: &mut Criterion) {
    let content: String = (0..10_000).map(|i| format!("line {:05}\n", i)).collect();
    let buf = Buffer::from_str(&content);
    let mid_offset = ByteOffset(buf.len_bytes() / 2);

    let mut group = c.benchmark_group("coordinates");

    group.bench_function("offset_to_line_col_mid", |b| {
        b.iter(|| buf.offset_to_line_col(black_box(mid_offset)));
    });

    let mid_lc = buf.offset_to_line_col(mid_offset);
    group.bench_function("line_col_to_offset_mid", |b| {
        b.iter(|| buf.line_col_to_offset(black_box(mid_lc)));
    });

    group.finish();
}

// ── Search ────────────────────────────────────────────────────────────────────

fn bench_find_all(c: &mut Criterion) {
    let content: String = (0..5_000)
        .map(|i| format!("let variable_{} = {};\n", i, i))
        .collect();
    let buf = Buffer::from_str(&content);

    let mut group = c.benchmark_group("search");

    group.bench_function("find_all_common_5k_lines", |b| {
        b.iter(|| buf.find_all(black_box("variable")));
    });

    group.bench_function("find_all_rare_5k_lines", |b| {
        b.iter(|| buf.find_all(black_box("variable_4999")));
    });

    group.finish();
}

// ── Render frame ──────────────────────────────────────────────────────────────

fn bench_render_frame(c: &mut Criterion) {
    let content: String = (0..50_000)
        .map(|i| format!("    let x_{} = {};\n", i, i))
        .collect();
    let ed = Editor::from_str(&content);

    c.bench_function("render_frame_50k_lines", |b| {
        b.iter(|| ed.render_frame());
    });
}

// ── Tokenizer ─────────────────────────────────────────────────────────────────

fn bench_tokenize(c: &mut Criterion) {
    let code = r#"
use std::collections::HashMap;
use anyhow::Result;

pub struct Config {
    pub name: String,
    pub value: i32,
    pub enabled: bool,
}

impl Config {
    pub fn new(name: &str, value: i32) -> Self {
        Self {
            name: name.to_owned(),
            value,
            enabled: true,
        }
    }

    pub fn is_valid(&self) -> bool {
        !self.name.is_empty() && self.value >= 0
    }
}

fn process_configs(configs: &[Config]) -> Result<HashMap<String, i32>> {
    let mut map = HashMap::new();
    for cfg in configs {
        if cfg.is_valid() {
            map.insert(cfg.name.clone(), cfg.value);
        }
    }
    Ok(map)
}
"#;
    // Repeat to make a bigger file
    let large_code = code.repeat(100);
    let buf = Buffer::from_str(&large_code);

    c.bench_function("tokenize_rust_400_lines", |b| {
        use waraq_editor_core::syntax::tokenizer::Tokenizer;
        b.iter(|| {
            let mut tok = Tokenizer::new();
            tok.tokenize_full(black_box(&buf), "rust")
        });
    });
}

criterion_group!(
    benches,
    bench_buffer_from_str,
    bench_insert,
    bench_sequential_typing,
    bench_undo_redo,
    bench_coordinate_conversion,
    bench_find_all,
    bench_render_frame,
    bench_tokenize,
);
criterion_main!(benches);

// ── Word wrap ─────────────────────────────────────────────────────────────────

fn bench_word_wrap_map(c: &mut Criterion) {
    let mut group = c.benchmark_group("word_wrap");
    use waraq_editor_core::core::config::WordWrap;
    use waraq_editor_core::core::wordwrap::WrapEngine;

    for size in [100, 1_000, 10_000] {
        let content: String = (0..size)
            .map(|i| {
                format!(
                    "This is line {} with some content that might wrap at certain column widths.\n",
                    i
                )
            })
            .collect();
        let buf = Buffer::from_str(&content);

        group.bench_with_input(BenchmarkId::new("build_map", size), &buf, |b, buf| {
            b.iter(|| {
                let mut engine = WrapEngine::new(WordWrap::Column(80));
                engine.total_visual_lines(black_box(buf))
            });
        });
    }
    group.finish();
}

// ── Indent guides ─────────────────────────────────────────────────────────────

fn bench_indent_guides(c: &mut Criterion) {
    use waraq_editor_core::core::indent_guide::IndentGuideEngine;

    let src: String = (0..1_000)
        .map(|i| {
            let indent = "    ".repeat(i % 5);
            format!("{}line {}\n", indent, i)
        })
        .collect();
    let buf = Buffer::from_str(&src);
    let engine = IndentGuideEngine::new(4, false);

    c.bench_function("indent_guides_1k_lines", |b| {
        b.iter(|| engine.guides_for_viewport(black_box(&buf), 0, 99, 50));
    });
}

// ── Git gutter ────────────────────────────────────────────────────────────────

fn bench_git_diff(c: &mut Criterion) {
    use waraq_editor_core::core::git_gutter::GitGutter;
    let mut group = c.benchmark_group("git_diff");

    for size in [100, 1_000, 10_000] {
        let head: String = (0..size).map(|i| format!("line {}\n", i)).collect();
        let current: String = (0..size)
            .map(|i| {
                if i % 50 == 0 {
                    format!("modified line {}\n", i)
                } else {
                    format!("line {}\n", i)
                }
            })
            .collect();

        group.bench_with_input(
            BenchmarkId::new("diff", size),
            &(head.clone(), current.clone()),
            |b, (h, c)| {
                b.iter(|| GitGutter::diff(black_box(h), black_box(c)));
            },
        );
    }
    group.finish();
}

// ── Search (regex + literal) ──────────────────────────────────────────────────

fn bench_search_regex(c: &mut Criterion) {
    use waraq_editor_core::core::search::SearchQuery;
    let mut group = c.benchmark_group("search");

    let content: String = (0..10_000)
        .map(|i| format!("fn function_{i}() {{ let x_{i} = {i}; }}\n"))
        .collect();
    let mut ed = Editor::from_str(&content);

    group.bench_function("literal_10k_lines", |b| {
        b.iter(|| {
            ed.search_start(SearchQuery::literal(black_box("fn function")));
        });
    });

    group.bench_function("regex_word_boundary_10k", |b| {
        b.iter(|| {
            let mut q = SearchQuery::literal("fn ");
            q.regex = true;
            ed.search_start(black_box(q));
        });
    });
    group.finish();
}

// ── Decoration delta ──────────────────────────────────────────────────────────

fn bench_decoration_delta(c: &mut Criterion) {
    use waraq_editor_core::core::decoration::{DecorationOptions, DecorationSet, DecorationSpec};
    use waraq_editor_core::core::types::Range;

    let mut group = c.benchmark_group("decorations");

    group.bench_function("delta_add_100", |b| {
        b.iter(|| {
            let mut ds = DecorationSet::new();
            let specs: Vec<(DecorationSpec, String)> = (0..100)
                .map(|i| {
                    (
                        DecorationSpec {
                            range: Range::new(i * 10, i * 10 + 5),
                            options: DecorationOptions::default(),
                        },
                        "bench".to_owned(),
                    )
                })
                .collect();
            ds.delta(&[], black_box(&specs))
        });
    });

    group.bench_function("adjust_for_edit_100_decorations", |b| {
        let mut ds = DecorationSet::new();
        let specs: Vec<(DecorationSpec, String)> = (0..100)
            .map(|i| {
                (
                    DecorationSpec {
                        range: Range::new(i * 100 + 50, i * 100 + 60),
                        options: DecorationOptions::default(),
                    },
                    "bench".to_owned(),
                )
            })
            .collect();
        ds.delta(&[], &specs);

        b.iter(|| {
            let mut ds_clone = DecorationSet::new();
            ds_clone.delta(&[], &specs);
            ds_clone.adjust_for_edit(black_box(0), 0, 5)
        });
    });
    group.finish();
}

// ── Notebook operations ───────────────────────────────────────────────────────

fn bench_notebook(c: &mut Criterion) {
    use waraq_editor_core::notebook::{IpynbDocument, KernelRegistry, NotebookDocument};
    let mut group = c.benchmark_group("notebook");

    group.bench_function("create_python_notebook", |b| {
        b.iter(|| {
            let reg = KernelRegistry::new();
            let spec = reg.get("python3").unwrap();
            NotebookDocument::for_kernel(black_box(spec))
        });
    });

    let reg = KernelRegistry::new();
    let spec = reg.get("python3").unwrap();
    let mut nb = NotebookDocument::for_kernel(spec);
    for i in 0..50 {
        nb.cells_mut()[0].set_source(&format!("x_{} = {}", i, i));
        nb.insert_cell_below(waraq_editor_core::notebook::CellType::Code);
    }
    let ipynb = IpynbDocument::from_notebook(&nb);
    let json = ipynb.to_json_pretty();

    group.bench_function("ipynb_roundtrip_50_cells", |b| {
        b.iter(|| {
            let doc = IpynbDocument::from_json(black_box(&json)).unwrap();
            doc.to_notebook()
        });
    });
    group.finish();
}

criterion_group!(
    benches,
    bench_buffer_from_str,
    bench_insert,
    bench_sequential_typing,
    bench_undo_redo,
    bench_coordinate_conversion,
    bench_find_all,
    bench_render_frame,
    bench_tokenize,
    bench_word_wrap_map,
    bench_indent_guides,
    bench_git_diff,
    bench_search_regex,
    bench_decoration_delta,
    bench_notebook,
);
criterion_main!(benches);
