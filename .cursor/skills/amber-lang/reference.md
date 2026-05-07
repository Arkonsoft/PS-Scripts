# Amber — Detailed Reference

Deep details that don't fit in `SKILL.md`. Read on demand.

## Type system details

### Base types

| Type | Description |
|---|---|
| `Text` | UTF-8 string |
| `Num` | Floating-point number |
| `Int` | Integer subtype of `Num` |
| `Bool` | `true` / `false` |
| `Null` | Single value `null` (use in unions) |
| `[T]` | Generic array, homogeneous |

### Unions

```amber
let maybe: Text | Null = null
let mixed: Text | Num = "x"
```

### Casts (`as`) and guards (`is`)

```amber
let n: Num = 3.14
let i = n as Int                  // truncates: 3
let s = 42 as Text                // "42"

if n is Int { echo("int") }
if maybe is Null { echo("nothing") }
```

### `#[allow_absurd_cast]`

Suppresses warnings for casts that lose information.

```amber
#[allow_absurd_cast]
let value = 42 as Text
```

## Functions — full feature list

- Declared only at module/global scope.
- Parameters can have types, default values, and `ref` modifier (mutates caller).
- Return type optional; if specified with `?` (e.g. `Text?`) the function is failable and its body may use `$cmd$ ?` and `failable_call() ?`.
- `pub fun` exports the function from the module.

```amber
pub fun process(
    input: Text,
    ref out: [Text],
    prefix: Text = "> "
): Text? {
    out += [prefix + input]
    let echoed = $printf "%s" "{input}"$ ?
    return echoed
}
```

## Failable propagation rules

- A call that may fail (`$...$`, `?`-suffixed function call) must be inside a context that can handle failure: a `failed/succeeded/exited` block, the `?` operator, or `trust`.
- `?` propagates the failure to the caller. The caller's signature must end in `?`, or it must be `main`.
- `trust` short-circuits the requirement — the compiler treats the call as infallible. Use sparingly.

## Standard library — common imports

This is not exhaustive; the stdlib evolves. Modules used in this repo:

### `std/text`

| Function | Purpose |
|---|---|
| `lowercase(s)` / `uppercase(s)` | Case conversion |
| `capitalized(s)` | Capitalize first letter |
| `trim(s)` | Strip leading/trailing whitespace (incl. trailing `\n` from `$...$`) |
| `split(s, sep)` | Split into `[Text]` |
| `split_lines(s)` | Split on newlines |
| `join(arr, sep)` | Join `[Text]` with separator |
| `text_contains(s, sub)` | Substring check returning `Bool` |
| `match_regex(s, pat, ignore_case)` | Regex match |
| `replace(s, from, to)` | Substring replace |

### `std/array`

| Function | Purpose |
|---|---|
| `map(arr, fn)` | Transform each element |
| `filter(arr, fn)` | Keep matching elements |
| `len(arr)` | Length (also a builtin) |
| `reverse(arr)` | Reverse elements |

When unsure whether a stdlib function exists, run `amber check` — the compiler's "unknown identifier" error is authoritative.

## Module resolution

- Local imports: relative path to `.ab` file (`"math.ab"`, `"./utils/io.ab"`).
- Standard library: prefix with `std/` (`"std/text"`).
- Only `pub`-marked declarations are visible to importers.
- Circular imports are detected at compile time and rejected.
- Re-export with `pub import`.

## Compiler environment variables

Set before invoking `amber`:

| Variable | Effect |
|---|---|
| `AMBER_DEBUG_PARSER=1` | Print parser trace |
| `AMBER_DEBUG_TIME=1` | Print per-stage timings |
| `AMBER_NO_OPTIMIZE=1` | Disable AST optimizer |
| `AMBER_HEADER=/path` | Replace default Bash shebang/header |
| `AMBER_FOOTER=/path` | Append custom footer to output |

## Targeting different shells

The default target is Bash. Switch with `--target`:

```bash
amber build --target zsh script.ab script.zsh
amber run --target ksh script.ab
```

`shellname` and `shellversion` reflect the runtime shell.

## Doc-comments

```amber
// # function_name
// One-line summary.
//
// Multi-paragraph description allowed. Markdown is preserved.
pub fun function_name(x: Num): Num {
    return x * 2
}
```

`amber docs file.ab` emits `docs/file.md`. Use `--usage` to include suggested import lines.

## Test blocks

```amber
test "addition" {
    let result = 2 + 2
    assert result == 4
}

test "string contains" {
    assert text_contains("hello world", "world")
}
```

`amber test` discovers and runs all `test "..." { }` blocks. `--test-case <prefix>` filters by name prefix.

## Programmatic API (Rust)

For embedding in Rust build tooling. Not relevant for `.ab` script authors.

```rust
use amber::compiler::{AmberCompiler, CompilerOptions};

let opts = CompilerOptions::default();
let compiler = AmberCompiler::new(source, Some("file.ab".into()), opts);
let (warnings, bash) = compiler.compile()?;

// Run the resulting Bash directly:
AmberCompiler::execute(bash, vec!["arg".into()])?;
```

`CompilerOptions` builders: `.with_target(Some(ShellType::Zsh))`, `.with_env_vars()`.

## Postprocessors

After translation, output passes through postprocessors. Built-in: `bshchk` (BashCheck linter).

Disable with `--no-proc`:

```bash
amber build --no-proc bshchk script.ab    # disable bshchk
amber build --no-proc "*" script.ab       # disable all
amber build --no-proc "b*chk" script.ab   # wildcard match
```

## Header / shebang

Compiled output starts with a generated header declaring the target shell and Amber version. Override with `AMBER_HEADER=/path/to/header.sh`.
