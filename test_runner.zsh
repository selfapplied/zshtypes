#!/usr/bin/env zsh
#
# Test runner for zshtypes multi-file proof calculus.
# Discovers all *.zst files and aggregates their proofs.
#

SOURCE=${0:a:h}
source "$SOURCE/lambda.zsh"

all_ok=1 proof_lines=() test_count=0

print -P "\e[1mRunning zshtypes proof calculus...\e[0m"

# Discover and run all test files
for file in $(print -rl tests/**/*.zst | sort); do
  ((test_count++))
  print -P "  \e[36m↯\e[0m running $file"
  
  # Each test file must set $proof (a single r… sentence)
  proof=""
  source $file
  
  if [[ -n $proof ]]; then
    proof_lines+=("$proof")
    # Check if this individual test passed (∀)
    if [[ $proof == "∀"* ]]; then
      print -P "    \e[32m✓\e[0m $proof"
    else
      print -P "    \e[31m✗\e[0m $proof"
      all_ok=0
    fi
  else
    print -P "    \e[31m✗\e[0m No proof generated"
    all_ok=0
  fi
done

print -r -- ""
print -r -- "──────────── aggregate proof ────────────"

# Use the Diagnoser for the final, human-readable output
if (( all_ok )); then
  print -r -- "∀ All tests passed."
else
  # Show the full proof details for debugging
  for proof in $proof_lines; do
    print -r -- "$proof"
  done
fi

print -r -- ""
print -P "Ran $test_count test files."

exit $(( all_ok ? 0 : 1 )) 