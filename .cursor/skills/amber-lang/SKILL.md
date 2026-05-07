---
name: amber-lang
description: Reference for the Amber programming language, a statically-typed language that compiles to portable Bash. Covers syntax, types, functions, shell command execution, error handling, modules, and builtins. Use when reading, writing, reviewing, or debugging .ab files, when compiling Amber to Bash, when working with the `amber` CLI (build, run, check, eval, docs, test), or when the user mentions Amber, amber-lang, or .ab scripts.
---

# Amber Language

Amber is a statically-typed scripting language that compiles to portable Bash (also Zsh/Ksh). Source files use the `.ab` extension. The compiler binary is `amber`.

Use this skill whenever editing `.ab` files in this repo. Existing usage lives in `scripts/*.ab`.

## Pipeline

`tokenize → parse → typecheck → translate → (optional) bshchk postprocess`

Output is a self-contained `.sh` script — no Amber runtime needed at execution time.

## Project conventions (this repo)

- Scripts live under `scripts/` (e.g. `scripts/create.ab`).
- Use `main(args)` as the entrypoint; `args[0]` is the script name, real arguments start at `args[1]`.
- Prefer small typed helper functions over inline logic. Wrap shell calls and trim their output.
- Use `silent trust $ ... $` for read-only commands whose output is captured (mirrors `scripts/create.ab`).

## Core syntax

### Variables

```amber
let counter = 0          // mutable, type inferred (Num)
counter = counter + 1
const greeting = "Hello"  // immutable
pub const SHELLS: [Text] = ["bash", "zsh", "ksh"]  // exported from module
```

`let` variables that are never reassigned trigger a compiler warning — use `const` when possible.

### Types

Base types: `Text`, `Num`, `Int`, `Bool`, `Null`, `[T]`. Unions: `Text | Null`. Cast with `as`, runtime-check with `is`.

```amber
let age: Int = 30
let items: [Text] = ["a", "b"]
let i = 3.14 as Int           // 3
if age is Int { echo("int") }
let maybe: Text | Null = null
```

### Text interpolation

Double-quoted strings interpolate `{expr}` for any expression. Arrays join with spaces.

```amber
echo("Hello, {user}! Sum: {1 + 2 + 3}")
```

### Functions

Declared at global scope only. Append `?` to the return type for failable functions.

```amber
fun greet(name: Text): Text {
    return "Hello, {name}!"
}

fun repeat(msg: Text, times: Int = 3): Text { ... }   // default arg

fun push(ref arr: [Text], item: Text) {               // ref param mutates caller
    arr += [item]
}

fun read_file(path: Text): Text? {                    // failable
    let content = $cat "{path}"$ ?
    return content
}

pub fun add(a: Num, b: Num): Num { return a + b }     // exported
```

### Control flow

```amber
if x > 5 { echo("big") } else { echo("small") }

if {                            // if-chain — preferred over nested if/else
    x < 0  { echo("negative") }
    x == 0 { echo("zero") }
    else   { echo("positive") }
}

let label = x > 0 then "positive" else "non-positive"   // ternary
```

### Loops

```amber
for fruit in fruits { echo(fruit) }
for i, fruit in fruits { echo("{i}: {fruit}") }
for i in 0..5 { echo(i) }       // exclusive: 0..4
for i in 1..=3 { echo(i) }      // inclusive: 1..3

while n < 3 { n = n + 1 }
loop {
    if line == "quit" { break }
    continue
}
```

## Shell commands (the critical part)

Shell commands are wrapped in `$ ... $`. They return stdout as `Text`. Non-zero exit is a failure that **must** be handled — the typechecker enforces this.

### Modifiers

| Modifier | Effect |
|---|---|
| `silent $...$` | Suppress stdout AND stderr |
| `suppress $...$` | Suppress stderr only |
| `trust $...$` | Skip the requirement to handle failure (treat as infallible) |
| `sudo $...$` | Prefix with `sudo` |

Modifiers compose: `silent trust $ pwd $` is the idiomatic pattern in this repo for safe info-gathering commands.

### Error handling

Every failable shell call (and failable function call) needs one of these:

```amber
$curl https://example.com$ failed { exit(1) }       // runs on non-zero exit
$ping -c1 8.8.8.8$ succeeded { echo("up") }          // runs on exit 0
$build$ exited(code) { echo("exit {code}") }         // always; captures code
$risky$ failed(status) { echo("err {status}") }      // failed with code

let body = $curl -sf "{url}"$ ?                       // ? propagates failure
                                                     // up the call chain
```

`?` propagates failure to the caller — the caller's call-site must itself handle the failure (with another `?`, a `failed/exited` block, or by being inside `main`).

### Idiomatic capture pattern (used throughout `scripts/create.ab`)

```amber
fun cwd(): Text {
    return trim(silent trust $ pwd $)
}
```

`silent` hides output, `trust` skips error handling, `trim` removes the trailing newline that shell commands always add.

## Imports & modules

```amber
import { add, multiply } from "math.ab"
import * from "utils.ab"
import { connect as db_connect } from "database.ab"
import { split, trim } from "std/text"     // standard library
import { map, filter } from "std/array"
pub import { add } from "math.ab"           // re-export
```

Only `pub` declarations are exported. Circular imports are detected at compile time.

Common stdlib modules used in this repo: `std/text` (`lowercase`, `capitalized`, `match_regex`, `split_lines`, `trim`, `text_contains`).

## Builtins

| Builtin | Purpose |
|---|---|
| `echo(x)` | Print to stdout |
| `len(x)` | Length of array or text |
| `lines(path)` | Read file lines as `[Text]` |
| `ls(path)` | Directory entries as `[Text]` |
| `pwd()` | Current directory |
| `cd(path)` | Change directory |
| `cp/mv/rm/touch(path)` | File ops |
| `sleep(secs)` | Pause |
| `exit(code)` | Terminate |
| `pid` | Current PID |
| `shellname` / `shellversion` | Runtime shell info |
| `nameof(var)` | Variable name as `Text` (used with `read -r`) |

## Common patterns

### Argument validation

```amber
main(args) {
    if len(args) < 2 {
        echo("Usage: {args[0]} <name>")
        exit(1)
    }
    const name = args[1]
}
```

### Capturing command output safely

Always pair captures with `trim()` because shell commands include a trailing newline:

```amber
const ver = trim(silent trust $ composer --version $)
```

### Conditional execution via exit code

```amber
$ grep -q -F "{needle}" "{file}" $ exited(code) {
    if code == 0 {
        $ sed -i "s/{needle}/{repl}/g" "{file}" $?
    }
}
```

### Reading interactive input

`read` writes into a shell variable; pass its name with `nameof`:

```amber
let answer = ""
trust $ read -r {nameof(answer)} $
```

### Logging helpers (project convention)

```amber
fun log_info(msg: Text)    { echo("[INFO] {msg}") }
fun log_error(msg: Text)   { trust $ echo "[ERROR] {msg}" >&2 $ }
```

## Compiling & running

Quick reference — see `cli.md` for full detail and flags.

```bash
amber run script.ab arg1     # compile + execute, no .sh on disk
amber build script.ab        # → script.sh (chmod 755)
amber check script.ab        # static analysis only
amber eval 'echo("hi")'      # one-liner
amber test                   # run `test "..." { }` blocks
amber docs file.ab           # generate docs/file.md from doc-comments
```

Doc-comments are double-slash comments directly above a `pub` declaration:

```amber
// # add
// Adds two numbers together.
pub fun add(a: Num, b: Num): Num { return a + b }
```

## Gotchas

- Functions can only be declared at the **global** scope, not nested.
- Every failable call needs handling — `failed`, `succeeded`, `exited`, `?`, or `trust`. The compiler will reject unhandled ones.
- `?` only propagates inside failable functions or `main`.
- Shell command output always has a trailing newline — `trim()` it before comparisons.
- Use `if-chain` rather than nested `if/else` for multi-branch logic.
- Single-line `if`/`for` bodies can use `:` syntax (`if x == y: return cwd()`), but multi-line requires braces.
- Inside `$ ... $` you can pipe and chain freely; interpolation `{var}` works there too.

## Additional resources

- For full type-system rules, full stdlib modules, env vars, and the Rust `AmberCompiler` API, see [reference.md](reference.md)
- For full CLI flags and postprocessor configuration, see [cli.md](cli.md)
