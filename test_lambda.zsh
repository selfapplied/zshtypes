#!/usr/bin/env zsh
#
# Self-hosting test suite for lambda.zsh
#

SOURCE=${0:a:h}
source "$SOURCE/lambda.zsh"

# --- Test Definitions ---

def_lp test_single_execution '
  __test_cnt=0
  def_la __inc "((__test_cnt++))"
  r __inc -- >/dev/null
  (( __test_cnt == 1 ))' 'single-execution'

def_lp test_action_skipped '
  __test_cnt=0
  def_lp __fail "false"
  def_la __act "((__test_cnt++))"
  r __fail -- __act >/dev/null
  (( __test_cnt == 0 ))' 'action-skipped'

def_lp test_canonical_sort '
  def_lp __p1 "true" "b"
  def_lp __p2 "true" "a"
  out=$(r __p1 __p2 --)
  [[ $out == "∀ a ✓, b ✓" ]]' 'canonical-sort'

def_lp test_deterministic_output '
  def_lp __p1 "true" "a"
  def_lp __p2 "true" "b"
  out1=$(r __p1 __p2 --)
  out2=$(r __p2 __p1 --)
  [[ $out1 == $out2 ]]' 'deterministic-output'

def_lp test_skipped 'true' 'skipped:example'

def_lp test_reporter_success '
  def_lp __p1 "true"
  def_lp __p2 "true"
  out=$(R __p1 __p2 --)
  [[ $out == "∀ All tests passed." ]]' 'reporter-success'

def_lp test_reporter_failure '
  def_lp __p1 "true"
  def_lp __p2 "false" "fail"
  out=$(R __p1 __p2 --)
  [[ $out == "∃ fail ✗, true ✓" ]]' 'reporter-failure'


# --- Reducer & Reporter ---
# Run all defined tests using the core reducer.
# The result of this is the formal proof, used for CI.
proof=$(r test_single_execution \
  test_action_skipped \
  test_canonical_sort \
  test_deterministic_output \
  test_skipped \
  test_reporter_success \
  test_reporter_failure --)

# Use the human-friendly reporter for the final output.
R test_single_execution \
  test_action_skipped \
  test_canonical_sort \
  test_deterministic_output \
  test_skipped \
  test_reporter_success \
  test_reporter_failure --

# --- Exit Status ---
# The CI job succeeds only if the formal proof is a '∀'.
if [[ $proof == '∀'* ]]; then
  exit 0
else
  exit 1
fi
