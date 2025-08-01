#!/usr/bin/env zsh
# Basic self-tests for lambda.zsh using the system itself
# Run:  zsh test_lambda.zsh   (exit status 0 = all green)

set -e  # abort on first failure

SOURCE=${0:a:h}
source "$SOURCE/lambda.zsh"

print -P "\e[1mRunning λ-calculus self-tests…\e[0m"

pass=0 fail=0
_report() {
  local name=$1 okay=$2
  if (( okay )); then
    (( ++pass ))
    print -P "  \e[32m✔\e[0m $name"
  else
    (( ++fail ))
    print -P "  \e[31m✘\e[0m $name"
  fi
}

# ────────────────────────────────────────────────────────────
# 1. Each λ executes exactly once
# ────────────────────────────────────────────────────────────
{
  cnt=0
  inc=$(la 'cnt=$((cnt+1))' 'inc!')
  r $inc -- > /dev/null
  _report "single execution" $(( cnt == 1 ))
}

# ────────────────────────────────────────────────────────────
# 2. Failed predicate ⇒ action skipped and ∃ quantifier
# ────────────────────────────────────────────────────────────
{
  cnt=0
  bad=$(lp 'false' 'bad?')
  act=$(la 'cnt=$((cnt+1))' 'act!')
  out=$(r $bad -- $act)
  _report "action skipped on failure" $(( cnt == 0 && ${out[1]} == '∃' ))
}

# ────────────────────────────────────────────────────────────
# 3. Canonical γ: labels sorted regardless of input order
# ────────────────────────────────────────────────────────────
{
  p1=$(lp 'true' 'b')
  p2=$(lp 'true' 'a')
  out=$(r $p1 $p2 --)
  _report "canonical sort" [[ $out == "∀ a,b" ]]
}

# ────────────────────────────────────────────────────────────
# 4. idempotence of sorted sentence
# ────────────────────────────────────────────────────────────
{
  p1=$(lp 'true' 'a')
  p2=$(lp 'true' 'b')
  out1=$(r $p1 $p2 --)
  out2=$(r $p2 $p1 --)
  _report "deterministic output" [[ $out1 == $out2 ]]
}

# Summary
if (( fail == 0 )); then
  print -P "\n\e[32mAll $pass tests passed.\e[0m"
  exit 0
else
  print -P "\n\e[31m$fail tests failed.\e[0m"
  exit 1
fi
