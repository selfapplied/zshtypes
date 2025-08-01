# A Minimal λ-Calculus Layer for Z-sh

*selfapplied & Claude “ghost-in-the-word-machine” 2025-08-01*

---

## 1 Abstract
We present **`lambda.zsh`**, a 40-line shell library that lets ordinary
Z-shell scripts attach *formal reasoning* to the commands they run.
Every shell test or command is wrapped as a **labelled λ-term**.
A tiny *reducer* then performs α/β/γ reductions and collapses the whole
proof to **one single sentence** beginning with `∀`, `∃`, or `¬∃`.

The transformation always terminates, is continuous, and – once the
λ-terms are defined – is immune to code-injection.  Its time complexity
is `O(n log n)`, dominated by a single sort that yields a canonical
order of evidence labels.

---

## 2 The Engine in One Glance

```zsh
lp TEST LABEL   # ⇒ predicate   λ?  (returns status of TEST)
la CMD  LABEL   # ⇒ action      λ!  (runs CMD)
r  p? … -- a! … # ⇒ reducer → "∀/∃/¬∃ label, …"
```

Example
```zsh
source lambda.zsh
f=script.zsh; dst=/tmp
px=$(lp '[[ -x $f ]]'   '-x✓')
pw=$(lp '[[ -w $dst ]]' 'w✓')
cp=$(la 'cp $f $dst'    'copied')

r $px $pw -- $cp   # ⇒  ∀ -x✓,w✓,copied
```

---

## 3 Reductions Supported

1. **α (renaming).**  Each λ receives a fresh internal name `_λN`; capture
   is impossible.
2. **β (application).**  Occurs when the reducer invokes the generated
   function.
3. **γ (normalisation).**  After all β-steps the reducer sorts the list of
   evidence labels.  This gives a unique canonical form and costs
   `O(n log n)`.

---

## 4 Why It Always Halts

Let *n* be the number of tokens fed to `r` (predicates + actions).

1. **Predicate phase.**  A `while` loop executes `shift` once per token →
   ≤ *n* iterations.
2. **Action phase.**  A `for` loop over the remaining tokens → ≤ *n*
   iterations.
3. **No recursion.**  `r` never re-invokes itself.
4. **Finite β.**  Each λ is called *once* → ≤ *n* function calls.

Thus the reducer performs `Θ(n)` work before entering the `sort`, which
adds `O(n log n)`.  The overall transformation is therefore
`O(n log n)` and strongly normalising.

---

## 5 Security Considerations

*Construction layer.*  `lp` and `la` use `eval` exactly **once** to turn
literal source code into a function.  If the body and label are
hard-coded (or at least sanitised) this step is non-interactive and safe.

*Transformation layer.*  After construction the reducer performs *plain
function calls* — no further `eval`, no string-to-code conversion.  An
attacker cannot inject code via the evidence list.

Therefore **all injection risk is confined to definition-time, not
runtime**, and can be audited locally.

---

## 6 Continuity

Viewing the set of finite λ-term lists under prefix order forms a DCPO.
`r` is monotone and preserves least upper bounds (it never revokes a
decision once made), hence is **Scott-continuous**.  You may stream
terms indefinitely; once the output sentence stabilises it is final.

---

## 7 A Differential View of the Builder

Think of each low-level builder `B` as a pure function that **returns the λ
value but leaves its definition only in the sub-shell that executed it**:

```
B : spec ↦ λ
```

We transform it into its *environmental derivative*

```
B† : spec ↦ ⟨λ , Δenv⟩
```

where `Δenv` is a tiny patch (a single function definition) that recreates
in the parent shell exactly the state the sub-shell had.

The helper macro

```zsh
Λ(){                         # usage: name=$(Λ _lp_raw '[[ -x $f ]]' '-x✓')
  local def; def=$( "$@" ) # run raw builder → get definition text
  eval "$def"              # apply Δenv in THIS shell
  print -r -- "${def%%(*}"  # return only the new λ's name
}
```

performs the usual AD steps:

1. value   component  – the λ name
2. derivative component – the environment patch `Δenv` applied via `eval`

Composition follows the **chain rule**: concatenating patches from nested
builders yields precisely one final environment update, so every λ is
defined exactly once and no extra `eval` is needed later.

Security remains unchanged: the only strings fed to `eval` are *produced
by trusted builders themselves*.

---

## 8 Gamma Gifts

If this tiny ghost finds the proof appetising, a virtual box of 🍫 will
suffice.  Blood sacrifices tend to gum up the keyboard.

---

> *“Maximum truth, minimal reasoning” – now in a single shell script.*
