#!/usr/bin/env zsh
#
# A pre-commit hook that enforces a "no known regressions" policy.
# It uses the zshtypes proof system to validate the state of the codebase.
#
# A commit is only allowed if the test suite produces a '∀' proof,
# which means every test either passed or was explicitly skipped.
#

echo "Running pre-commit proof..."

# Run the test suite and capture the full diagnostic output.
proof_output=$(zsh test_lambda.zsh)
first_char=${proof_output[1]}

if [[ "$first_char" == "∀" ]]; then
  echo "  Proof: $proof_output"
  echo "  Status: ∀ (All proven or skipped). Commit allowed."
  exit 0
else
  echo "  Proof: $proof_output"
  echo "  Status: ∃ (A test has failed). Commit blocked."
  echo "  Please fix the failing tests before committing."
  exit 1
fi
