#!/usr/bin/env zsh
#
# lambda.zsh — minimal λ-calculus proof reducer for zsh
# -----------------------------------------------------
# Three helpers:
#   lp TEST  LABEL   -> predicate λ?  (returns exit status of TEST)
#   la CMD   LABEL   -> action    λ!  (executes CMD)
#   r  p? … -- a! … -> reducer; prints "∀/∃/¬∃ label, …"
#
# Reductions
#   α — fresh internal name (_λN) for each lambda (capture–free renaming)
#   β — actual invocation when the reducer calls the lambda
#   γ — canonicalisation: reducer sorts evidence labels (O(n log n))
#
# Example:
#   f=script.zsh; dst=/tmp
#   px=$(lp '[[ -x $f ]]'   '-x✓')
#   pw=$(lp '[[ -w $dst ]]' 'w✓')
#   cp=$(la 'cp $f $dst'    'copied')
#   r $px $pw -- $cp
#   # ⇒ ∀ -x✓,w✓,copied
# -----------------------------------------------------

# internal counter for α-conversion
typeset -gi _λn=0

# lp — build a predicate λ?
lp() {
  local test=$1 label=${2:-$1} id=_λ$((++_λn))
  eval "$id(){ $test; local _r=\$?; print -r -- \"$label\"; return \$_r; }"
  print -r -- $id
}

# la — build an action λ!
la() {
  local cmd=$1 label=${2:-$1} id=_λ$((++_λn))
  eval "$id(){ $cmd; local _r=\$?; print -r -- \"$label\"; return \$_r; }"
  print -r -- $id
}

# r – reducer (normal-order)
r() {
  local ok=1 labels=() token
  # predicates
  while [[ $1 && $1 != -- ]]; do
    token=$1; shift
    labels+=("$($token)")
    $token || ok=0
  done
  shift  # eat “--”
  # actions
  if (( ok )); then
    for token; do
      labels+=("$($token)")
      $token || ok=0
    done
  else
    (( $# )) && labels+=("actions-skipped")
  fi
  # γ-reduction: canonicalise evidence (stable, O(n log n))
  labels=($(print -rl -- $labels | LC_ALL=C sort))
  local q
  (( ${#labels} == 0 )) && q='¬∃' || { (( ok )) && q='∀' || q='∃'; }
  print -r -- "$q ${(@j:, :)labels}"
}
