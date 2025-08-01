#!/usr/bin/env zsh
#
# A simple, robust, self-hosting test suite for lambda.zsh.
# It tests only the stable, "first-level" features of the system.
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


# --- Reducer ---
# The final output is a proof of the test suite's state.
r test_single_execution \
  test_action_skipped \
  test_canonical_sort \
  test_deterministic_output \
  test_skipped --
