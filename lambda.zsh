#!/usr/bin/env zsh
#
# A tiny λ-calculus for shell scripting.
# See lambda_paper.md for the full theory.

# --- Lambda Builders ---

# def_lp: Defines a predicate lambda function in the current shell.
def_lp() {
  local name=$1 test=$2 label=${3:-$1}
  eval "$name() { $test && REPLY='$label ✓' || REPLY='$label ✗'; return \$?; }"
}

# def_la: Defines an action lambda function in the current shell.
def_la() {
  local name=$1 cmd=$2 label=${3:-$1}
  eval "$name() { $cmd && REPLY='$label ✓' || REPLY='$label ✗'; return \$?; }"
}

# --- Reducer, Reporter, and Diagnoser ---

# r: The core reducer.
# Prints the full, verbose proof sentence and returns 0 on ∀, 1 otherwise.
r() {
  local ok=1 labels=() token
  while [[ $1 && $1 != -- ]]; do
    token=$1; shift
    $token; labels+=($REPLY)
    [[ $REPLY == *'✗' ]] && ok=0
  done
  shift
  if (( ok )); then
    for token; do
      $token; labels+=($REPLY)
      [[ $REPLY == *'✗' ]] && ok=0
    done
  else
    (( $# )) && labels+=("actions-skipped")
  fi
  labels=(${(o)labels}) # Sort labels alphabetically
  local q
  (( ${#labels} == 0 )) && q='¬∃' || { (( ok )) && q='∀' || q='∃'; }
  print -r -- "$q ${(j:, :)labels}"
  (( ok && ${#labels} > 0 )) && return 0 || return 1
}

# R: A human-friendly reporter.
# Prints a clean summary on success, or the full proof on failure.
R() {
  local output
  output=$(r "$@")
  if [[ $? -eq 0 ]]; then
    print -r -- "∀ All tests passed."
  else
    print -r -- "$output"
  fi
}

# D: A diagnostician.
# Provides a higher-level interpretation of common failure patterns.
D() {
  local output
  output=$(r "$@")
  if [[ $? -eq 0 ]]; then
    print -r -- "∀ All tests passed."
  else
    print -r -- "$output"
    # Knowledge base of failure symptoms and their meanings.
    if [[ $output == *'canonical-sort ✗'* ]]; then
      print -r -- "  └── Diagnosis: The reducer's sorting guarantee is broken, or the test is too rigid."
    fi
    if [[ $output == *'action-skipped ✗'* ]]; then
      print -r -- "  └── Diagnosis: The predicate-guard logic is flawed. Actions may be running when they shouldn't."
    fi
    if [[ $output == *'single-execution ✗'* ]]; then
      print -r -- "  └── Diagnosis: The reducer's execution loop is flawed. Lambdas are not being called exactly once."
    fi
  fi
}

typeset -gi __count=0
