import Parasite.Basic
import Mathlib.Tactic

/-- A structure to represent a parasitic number.

A parasitic number `n` in base `b` with multiplier `m` satisfies the property that when you
multiply `n` by `m`, the digits of the resulting number, when rotated to the left by one position,
are the same as the digits of `n`.
-/
structure ParasiticNumber (b m : ℕ) where
  /-- The parasite number. -/
  n : ℕ
  hb : b > 1
  hn : n > 0
  hm : m > 1
  /-- The property of a parasitic number. -/
  h_parasitic : n * m = Nat.ofDigits b (Nat.digits b n |>.rotate 1)

def ParasiticNumber.length {b m : ℕ} (p : ParasiticNumber b m) : ℕ :=
  Nat.digits b p.n |>.length

/-- An equivalent property of h_parasitic which uses algebraic manipulation instead of list
operations.
-/
theorem ParasiticNumber.algebraic_property {b m : ℕ} (p : ParasiticNumber b m) :
  p.n * m = (p.n / b) + (p.n % b) * b^(p.length - 1) := by
  set d := p.n % b with hd
  set y := p.n / b with hy
  set l := p.length with hl
  set n := p.n with hn
  set n' := n * m with hn'
  have h_parasitic := p.h_parasitic
  rw [← hn'] at h_parasitic
  have h_len : (b.digits y).length = (b.digits n).length - 1 := by
    rw [Nat.digits_def' p.hb p.hn, List.length_cons, Nat.add_sub_cancel]
  calc
    n' = Nat.ofDigits b ((b.digits n).rotate 1) := by rw [h_parasitic]
    _ = Nat.ofDigits b ((d :: b.digits y).rotate 1) := by rw [Nat.digits_def' p.hb p.hn]
    _ = Nat.ofDigits b ((b.digits y) ++ [d]) := by
      rw [List.rotate_eq_drop_append_take]
      · rfl
      · exact Nat.succ_le_succ (Nat.zero_le (b.digits y).length)
    _ = Nat.ofDigits b (b.digits y) + b^(b.digits y).length * Nat.ofDigits b [d] :=
      by rw [Nat.ofDigits_append]
    _ = y + d * b^(l - 1) := by
      rw [Nat.ofDigits_digits, Nat.ofDigits_singleton, h_len]
      ring_nf
      rfl

lemma mul_div_cancel_dvd {d gcd m : ℕ} (hdvd : gcd ∣ d) :
  gcd * (d / gcd * m) = d * m := by
  have h_cancel : gcd * (d / gcd) = d := Nat.mul_div_cancel' hdvd
  rw [← mul_assoc, h_cancel]

/-- The main theorem we want to prove about parasitic numbers. It states that for a given base `b`,
multiplier `m` and a unit digit `d`, for all `m`-parasitics numbers with unit digit `d`, have their
length of digits in base `b` divisible by the order of `b` in the ring
`(b * m - 1) / gcd (b * m - 1) (b - 1)`. -/
theorem parasitic_number_length_characterization
  (b m : ℕ)
  (hb : b > 1)
  (hm : m > 1)
  :
  ∀ (p : ParasiticNumber b m),
  ∃ (k : ℕ), p.length = orderOf (b : ZMod ((b * m - 1) / Nat.gcd (b * m - 1) (p.n % b))) * k := by

  intro p

  set d := p.n % b with hdp
  set n := p.n with hn
  set n' := n * m with hn'
  set l := p.length with hl
  set y := n / b with hy

  have hbm : b * m > 1 := by nlinarith
  have halg := p.algebraic_property
  rw [← hdp] at halg
  rw [← hn, ← hy, ← hl, ← hn'] at halg

  have h_dec : n = b * y + d := by rw [hy, hdp, Nat.div_add_mod n b]
  have hy_pos : 0 ≤ y := by positivity

  have hd_pos : 0 < d := by
    by_contra h_not_pos
    have hd_zero : d = 0 := by omega

    have h_eq : n * m = y := by
      calc
        n * m = y + d * b^(l - 1) := halg
        _ = y + 0 * b^(l - 1)     := by rw [hd_zero]
        _ = y                     := by ring

    have h_n_eq : n = b * y := by
      calc
        n = b * y + d := h_dec
        _ = b * y + 0 := by rw [hd_zero]
        _ = b * y     := by ring

    have hn_pos := p.hn
    have hm_gt_1 := p.hm
    have hb_gt_1 := p.hb

    nlinarith [h_eq, h_n_eq]

  -- The case l = 0 is trivial but is need to avoid issues with the definition of b^(l - 1)
  -- when l = 0
  rcases Nat.eq_zero_or_pos l with hl | hl_pos
  · use 0
    rw [hl]
    ring

  have h_y_isolation_eq : n' = n * m ↔ (y * (b * m - 1)) = (d * (b^(l - 1) - m)) := by
    have h_led: d * m ≤ d * b^(l - 1) := by nlinarith
    have h_le : m ≤ b^(l - 1) := Nat.le_of_mul_le_mul_left h_led hd_pos
    constructor <;> intro h
    · rw [h_dec, halg] at h
      zify [hbm, hy_pos, h_le] at h ⊢
      linear_combination -h

    · rw [h_dec, halg]
      zify [hbm, h_le] at h ⊢
      linear_combination -h

  have h_y_isolation : (y * (b * m - 1)) = (d * (b^(l - 1) - m)) := h_y_isolation_eq.mp hn'

  have h_mod : (d * m) ≡ (d * b^(l - 1)) [MOD (b * m - 1)] := by
    rw [Nat.modEq_iff_dvd]
    have h_led: d * m ≤ d * b^(l - 1) := by nlinarith
    have h_le : m ≤ b^(l - 1) := Nat.le_of_mul_le_mul_left h_led hd_pos

    rw [← Nat.cast_sub h_led]
    rw [← Nat.mul_sub]
    norm_cast
    rw [← h_y_isolation]
    norm_num

  set gcd := Nat.gcd (b * m - 1) d with hgcd
  have h_gcd_ne_zero : gcd ≠ 0 := by
    rw [hgcd]
    simp [ne_of_gt hd_pos]

  have h_mod_div_gcd : ((d * m) ≡ (d * b^(l - 1)) [MOD (b * m - 1)]) →
  ((d/gcd * m) ≡ (d/gcd * b^(l - 1)) [MOD (b * m - 1) / gcd]) := by
    have h_mul_div_gcd_d := @mul_div_cancel_dvd d gcd m (hgcd ▸ Nat.gcd_dvd_right (b * m - 1) d)
    have h_mul_div_gcd_bl1 := @mul_div_cancel_dvd d gcd (b^(l - 1))
      (hgcd ▸ Nat.gcd_dvd_right (b * m - 1) d)
    have h_mul_div_gcd_bm1 := @Nat.mul_div_cancel' gcd (b * m - 1)
      (hgcd ▸ Nat.gcd_dvd_left (b * m - 1) d)
    intro h
    rw [← h_mul_div_gcd_d, ← h_mul_div_gcd_bl1, ← h_mul_div_gcd_bm1] at h
    exact Nat.ModEq.mul_left_cancel' h_gcd_ne_zero h

  have h_pow_mod_one : ((d * m) ≡ (d * b^(l - 1)) [MOD (b * m - 1)]) →
  b^l ≡ 1 [MOD (b * m - 1) / gcd] := by
    intro h
    have h_mod_pos : 0 < (b * m - 1) := by omega

    have h_m_eq_pow := Nat.ModEq.cancel_left_div_gcd h_mod_pos h
    have h_bm_eq_bl := Nat.ModEq.mul_left b h_m_eq_pow

    rw [mul_pow_sub_one (zero_lt_iff.mp hl_pos)] at h_bm_eq_bl
    have h_bm_eq_one : b * m ≡ 1 [MOD (b * m - 1) / gcd] := by
      symm
      rw [Nat.modEq_iff_dvd]
      use gcd
      have hh := (Nat.div_mul_cancel (hgcd ▸ Nat.gcd_dvd_left (b * m - 1) d)).symm
      omega
    have hh := Nat.ModEq.trans h_bm_eq_bl.symm h_bm_eq_one
    exact hh

  have h_zmod : (b : ZMod ((b * m - 1) / gcd))^l = 1 := by
    have h := h_pow_mod_one h_mod
    rw [Nat.modEq_iff_dvd, ← ZMod.intCast_eq_intCast_iff_dvd_sub] at h
    exact_mod_cast h

  obtain ⟨k, hk⟩ := orderOf_dvd_of_pow_eq_one h_zmod
  use k
