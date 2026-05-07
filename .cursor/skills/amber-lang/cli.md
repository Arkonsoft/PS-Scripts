# Amber CLI Reference

The `amber` binary exposes seven subcommands: `eval`, `run`, `check`, `build`, `docs`, `test`, `completion`, `grammar-ebnf`.

## `amber run` — compile + execute

Compiles a `.ab` file and executes immediately. No `.sh` artifact written.

```bash
amber run script.ab            # run with no args
amber run script.ab arg1 arg2  # pass args (visible as args[1], args[2])
echo 'echo("piped")' | amber run -    # read from stdin
amber run --no-proc bshchk script.ab  # skip the bshchk postprocessor
amber run --target zsh script.ab      # target Zsh
```

This is the fastest dev loop while iterating on a script.

## `amber build` — compile to `.sh`

Produces a self-contained Bash file. The output is `chmod 755` on Unix.

```bash
amber build script.ab                   # → script.sh
amber build script.ab custom.sh         # explicit output name
amber build script.ab -                 # write to stdout
amber build --minify script.ab          # minified output
amber build --target ksh script.ab script.ksh
amber build --no-proc "*" script.ab     # disable all postprocessors
```

Use `build` for distribution; `run` for local execution.

## `amber check` — static analysis

Parses, typechecks, and runs postprocessors **without** executing. Exit 0 = clean.

```bash
amber check script.ab
amber check --target zsh script.ab
```

Run this in CI for every `.ab` file. Faster than `build` because translation is the only step that requires AST output.

## `amber eval` — inline expression

Compile + run a string of Amber source. Useful for one-liners.

```bash
amber eval 'echo("Hello, World!")'
amber eval 'let x = 42
echo("answer: {x}")'
amber eval --target zsh 'echo("zsh")'
```

## `amber test` — run test blocks

Discovers `test "name" { ... }` blocks across `.ab` files.

```bash
amber test                          # all tests in current dir
amber test tests.ab                 # tests in one file
amber test --test-case add tests.ab # only tests whose name starts with "add"
amber test --target zsh             # run tests against zsh translation
```

Tests use `assert <bool-expr>`. A failing assertion exits non-zero with diagnostic output.

## `amber docs` — generate Markdown

Reads `// # heading` doc-comments above `pub` declarations and emits per-file Markdown.

```bash
amber docs lib.ab                # → docs/lib.md
amber docs lib.ab -              # write to stdout
amber docs --usage lib.ab        # include suggested import lines
```

## Common flags (apply to multiple subcommands)

| Flag | Subcommands | Effect |
|---|---|---|
| `--target <shell>` | run, build, check, eval, test | bash (default), zsh, ksh |
| `--no-proc <pattern>` | run, build, check | Disable postprocessors by name or wildcard |
| `--minify` | build | Compress output |
| `--test-case <prefix>` | test | Filter tests by name prefix |
| `--usage` | docs | Include import-usage examples |

## Exit codes

- `0` — success
- non-zero — compile, type, or runtime error (with diagnostic shown)

## Recommended dev loop

1. Write/edit `.ab` file.
2. `amber check script.ab` — fast feedback on parse + type errors.
3. `amber run script.ab <args>` — execute.
4. When stable: `amber build script.ab` to produce a distributable `.sh`.

## Integration into Make / CI

```makefile
SCRIPTS := $(wildcard scripts/*.ab)
COMPILED := $(SCRIPTS:.ab=.sh)

%.sh: %.ab
	amber build $< $@

check:
	@for f in $(SCRIPTS); do amber check $$f || exit 1; done

build: $(COMPILED)
```

## Shell completion

```bash
amber completion bash > /etc/bash_completion.d/amber
amber completion zsh > ~/.zsh/completions/_amber
```

## Grammar export

```bash
amber grammar-ebnf > grammar.ebnf
```

Useful for editor integrations or formal tools.
