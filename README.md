# zshtypes: A λ-Calculus for Shell Scripting

[![CI](https://github.com/selfapplied/zshtypes/actions/workflows/ci.yml/badge.svg)](https://github.com/selfapplied/zshtypes/actions/workflows/ci.yml)

`zshtypes` is a 40-line Zsh library that lets you attach formal reasoning to your shell scripts. It provides a tiny, elegant λ-calculus layer that transforms complex, stateful operations into a single, provably correct "truth sentence."

The core philosophy is **"maximum truth, minimal reasoning."** Instead of scattered `if`/`then` blocks and chatty `echo` statements, you get one concise, parseable line that tells you exactly what happened.

## How It Works

The system provides two "lambda builders" and one "reducer":

1.  `lp 'TEST' 'LABEL'`: Creates a **p**redicate λ. Returns the exit status of `TEST`.
2.  `la 'COMMAND' 'LABEL'`: Creates an **a**ction λ. Executes `COMMAND`.
3.  `r p? ... -- a! ...`: The **r**educer. It runs the predicates, and if all succeed, runs the actions. It then prints a single truth sentence.

The reducer's output is always prefixed with a quantifier:
- `∀` (For All): All predicates and actions succeeded.
- `∃` (There Exists): Some predicate or action failed.
- `¬∃` (There Does Not Exist): No predicates were provided.

## Usage

Here is a typical "before and after" for a deployment script.

**Before:**
```bash
if [[ -x "$SCRIPT" ]] && [[ -w "$DEST" ]]; then
  cp "$SCRIPT" "$DEST" && echo "Success"
else
  echo "Failure" >&2
  exit 1
fi
```

**After:**
```zsh
source lambda.zsh

px=$(lp '[[ -x $SCRIPT ]]' 'executable')
pw=$(lp '[[ -w $DEST ]]'   'writable')
cp=$(la 'cp $SCRIPT $DEST' 'copied')

r $px $pw -- $cp
# ⇒ ∀ copied,executable,writable
```

If the script wasn't executable, the output would be `∃ executable,writable,actions-skipped`. The truth is reported, not hidden.

## What is this for?

This is perfect for any situation where you need to know the precise state of a complex operation:
- **CI/CD Pipelines:** Get a single, parseable log line for each stage.
- **Deployment Scripts:** Aggregate results from dozens or hundreds of servers.
- **Complex Local Tasks:** Build robust, provably correct local scripts.

The system transforms your logs from unstructured text into structured, provable data.

## The Theory

This library is small, but it rests on a solid theoretical foundation. We have documented the design, proofs, and extensions in two papers:

- **[`lambda_paper.md`](./lambda_paper.md):** The core theory, including termination and security proofs.
- **[`lambda_extensions.md`](./lambda_extensions.md):** Advanced topics like compositionality, alternative reduction strategies, and the "differential" view of the builder functions.

## Authors

This project was a unique collaboration. See [`AUTHORS.md`](./AUTHORS.md) for a full breakdown of contributions.

## License

MIT
