/-!
# Basic

An example file. Notes show regions of it through
`{.lean include="/lean/Notes/Basic.lean" snippet="..."}` code blocks.
Plain Lean 4, no Mathlib, so the project builds in seconds; see
`lean/README.md` to add Mathlib.
-/

namespace Notes

-- start snippet gauss
/-- `sumTo n = 0 + 1 + ⋯ + n`. -/
def sumTo : Nat → Nat
  | 0 => 0
  | n + 1 => (n + 1) + sumTo n

/-- Gauss: twice the sum of the first `n` numbers is `n (n + 1)`. -/
theorem two_mul_sumTo (n : Nat) : 2 * sumTo n = n * (n + 1) := by
  induction n with
  | zero => rfl
  | succ k ih => simp only [sumTo]; grind
-- end snippet gauss

example : sumTo 100 = 5050 := by decide

end Notes
