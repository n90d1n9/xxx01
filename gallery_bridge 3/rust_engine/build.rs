// gallery_bridge_engine/build.rs
//
// Build script for flutter_rust_bridge.
// Runs the FRB code generator whenever the Rust source changes
// so the Flutter bindings are always in sync.
//
// Called automatically by `cargo build`.

fn main() {
    // Tell Cargo to re-run this script if any Rust source changes
    println!("cargo:rerun-if-changed=src/");
    println!("cargo:rerun-if-changed=Cargo.toml");
    println!("cargo:rerun-if-changed=build.rs");

    // flutter_rust_bridge 2.x handles code generation externally via
    // `flutter_rust_bridge_codegen generate`. This build.rs only sets up
    // the linking metadata needed by the dylib.

    // Platform-specific linking
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    match target_os.as_str() {
        "macos" | "ios" => {
            println!("cargo:rustc-link-lib=framework=Foundation");
            println!("cargo:rustc-link-lib=framework=Security");
        }
        "android" => {
            println!("cargo:rustc-link-lib=log");
            println!("cargo:rustc-link-lib=android");
        }
        "windows" => {
            println!("cargo:rustc-link-lib=user32");
        }
        _ => {}
    }
}
