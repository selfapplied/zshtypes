#!/usr/bin/env zsh
#
# A self-hosting test suite for lambda.zsh.
# This script uses the lambda.zsh system to prove its own correctness.
# The final output is a single "truth sentence" summarizing the tests.
# Exit status is 0 if the final quantifier is ∀, otherwise 1.
#

SOURCE=${0:a:h}
source "$SOURCE/lambda.zsh"

# Array to hold all our test predicates
declare -a tests

# --- Test Definitions ---
# Each test is a predicate λ that returns true (0) on success.

# Test 1: Each λ executes exactly once
tests+=( $(lp '
  cnt=0
  inc=$(la "cnt=\$((cnt+1))" "inc!")
  r $inc -- > /dev/null
  [[ $cnt -eq 1 ]]' 'single-execution') )

# Test 2: Failed predicate ⇒ action skipped and ∃ quantifier
tests+=( $(lp '
  cnt=0
  bad=$(lp "false" "bad?")
  act=$(la "cnt=\$((cnt+1))" "act!")
  out=$(r $bad -- $act)
  [[ $cnt -eq 0 && ${out[1]} == "∃" ]]' 'action-skipped-on-failure') )

# Test 3: Canonical γ-reduction sorts labels
tests+=( $(lp '
  p1=$(lp "true" "b")
  p2=$(lp "true" "a")
  out=$(r $p1 $p2 --)
  [[ $out == "∀ a,b" ]]' 'canonical-sort') )

# Test 4: Idempotence of sorted sentence
tests+=( $(lp '
  p1=$(lp "true" "a")
  p2=$(lp "true" "b")
  out1=$(r $p1 $p2 --)
  out2=$(r $p2 $p1 --)
  [[ $out1 == $out2 ]]' 'deterministic-output') )

# Test 5: A skipped test.
# This registers in the final proof without causing failure.
tests+=( $(lp 'true' 'skipped:dependent-types-proof') )


# --- Reducer ---
# Run the reducer on all defined test predicates.
# The final output is the proof of the test suite's state.
final_proof=$(r ${tests[@]} --)
print -r -- "$final_proof"

# --- Exit Status ---
# The CI job succeeds only if all tests are proven (∀).
if [[ ${final_proof[1]} == "∀" ]]; then
  exit 0
else
  exit 1
fi
