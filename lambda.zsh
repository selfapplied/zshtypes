#!/usr/bin/env zsh
#
# A tiny λ-calculus for shell scripting.
# See lambda_paper.md for the full theory.

# --- Lambda Builders ---

# def_lp: Defines a predicate lambda function in the current shell.
# Usage: def_lp my_predicate '[[ -f file ]]' 'file-exists'
def_lp() {
  local name=$1 test=$2 label=${3:-$1}
  eval "$name() { $test && REPLY='$label ✓' || REPLY='$label ✗'; return \$?; }"
}

# def_la: Defines an action lambda function in the current shell.
# Usage: def_la my_action 'cp a b' 'copied'
def_la() {
  local name=$1 cmd=$2 label=${3:-$1}
  eval "$name() { $cmd && REPLY='$label ✓' || REPLY='$label ✗'; return \$?; }"
}

# --- Reducer ---

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
}

typeset -gi __count=0
