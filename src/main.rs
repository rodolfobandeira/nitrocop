use std::process;

use clap::Parser;

use nitrocop::cli::Args;

fn main() {
    // Use 32 MB stacks for rayon worker threads (default is ~8 MB).
    // Pathological Ruby files (e.g. mruby regression tests with 250+ nesting levels)
    // overflow the default stack during Prism AST visitor traversal.
    rayon::ThreadPoolBuilder::new()
        .stack_size(32 * 1024 * 1024)
        .build_global()
        .ok();

    let args = Args::parse();
    match nitrocop::run(args) {
        Ok(code) => process::exit(code),
        Err(e) => {
            eprintln!("error: {e:#}");
            process::exit(3);
        }
    }
}
