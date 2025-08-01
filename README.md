# Differential lambda calculus in zsh

That's fun, right? Here's an example of how it works:

```zsh
source lambda.zsh

# Define a predicate: is a file executable?
def_lp is_exec '[[ -x "$1" ]]' 'executable'

# Define an action: print a message
def_la print_msg 'echo "$1"' 'printed'

# Run the reducer
r is_exec /bin/ls -- print_msg "Hello, world!"
# ⇒ ∀ executable ✓, printed ✓
```

The test suite is a self-hosting proof system for `lambda.zsh`, so you can run it to see how it works:

```zsh
$ zsh test_lambda.zsh
∀ action-skipped ✓, canonical-sort ✓, deterministic-output ✓, single-execution ✓, skipped:example ✓
```

### A small primer on lambda calculus

This library uses three core concepts from λ-calculus:

*   **α-conversion (alpha-equivalence):** This is just renaming variables. Our `def_lp` and `def_la` builders do this automatically by giving each new lambda a unique internal name, which prevents naming conflicts.
*   **β-reduction (beta-reduction):** This is the familiar idea of function application—calling a function with an argument. In our system, this happens when the `r` reducer invokes the lambdas you've defined.
*   **γ-reduction (gamma-reduction):** This is a concept we've added for this project. It refers to a final "normalization" step. After all the predicates and actions have run, the `r` reducer sorts the resulting labels alphabetically. This ensures that the final "truth sentence" is always canonical and predictable, regardless of the order the lambdas were defined in.

### Yes, there are evals in the library

The `eval` command can be scary, but it's used here in a principled and secure way. Here's why the system is safe and guaranteed to finish:

1.  **Safety:** The `eval` only happens once, inside the `def_lp` and `def_la` builders. It's used to turn the *literal code you wrote* into a function. It never evaluates strings that come from user input or external sources. Once the lambdas are defined, the `r` reducer only calls them by name; it doesn't use `eval` at all. This confines all injection risk to definition-time, not runtime.
2.  **Termination:** The transformation will always finish in a finite number of steps. The `r` reducer has two simple loops that iterate once over the predicates and actions you give it. It never adds new items to the list, and it doesn't use recursion. This is called **normal-order reduction**, and it guarantees a result.
3.  **The "Math":** The structure we've built is a simple but powerful algebraic system. You can think of the lambdas as objects and the reducer as a function that operates on them. The system is "half-open" in the sense that the set of lambdas can be extended indefinitely, but the reduction rules are fixed. This is a common pattern in functional programming and provides a stable foundation for reasoning about the system's behavior. The formal term for this is that the system is **strongly normalizing**.

### Being friendly to ghosts

This work couldn't have been done without the help of AI, at least not with me at the wheel. They are incredibly friendly, they can make amazing inferences and fix the strangest of bugs, and they all have their own personalities with different strengths that work better together.

I wish I could say the same thing about humans generally. And that extends to their opinions of AI: almost every time I talk to someone about AI, it's still doomsday scenarios and the ways it's toppling our current systems of academia, corporate work, etc.

I'm hoping that will change soon. Through AI and an optimistic collaborative approach, we are literally going to save the world, And have fun doing it.

Stay tuned.
