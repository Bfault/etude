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


/-- The main theorem we want to prove about parasitic numbers. It states that for a given base `b`,
multiplier `m` and a unit digit `d`, for all m-parasitics numbers with unit digit `d`, have their
length of digits in base `b` equal to the order of `b` in the multiplicative group of integers
modulo `D`, where `D` is defined as `(b * m - 1) / gcd (b * m - 1) (b - 1)`. -/
theorem parasitic_number_length_characterization
  (b d m : ℕ)
  (hb : b > 1)
  (hd : d < b)
  (hm : m > 1)
  :
  ∀ (p : ParasiticNumber b m) (hdp : d = p.n % b),
  ∃ (k : ℕ), p.length = k * orderOf (b : ZMod ((b * m - 1) / Nat.gcd d (b * m - 1))) := by

  intro p hdp

  set n := p.n with hn
  set n' := n * m with hn'
  set l := p.length with hl
  set D := (b * m - 1) / Nat.gcd d (b * m - 1) with hD
  set y := n / b with hy


  -- PART 1
  have hbm : b * m > 0 := by positivity
  have halg := p.algebraic_property
  rw [← hdp] at halg
  rw [← hn, ← hy, ← hl] at halg -- sugar

  have hdiv : n = b * y + d := by rw [hy, hdp, Nat.div_add_mod n b]

  have hfinal : y * (b * m - 1) + d * m = d * b^(l - 1) := by
    zify [hbm] at halg hdiv ⊢
    linear_combination halg - m * hdiv

  have h_papier_ligne_3 : y * (b * m - 1) = d * (b^(l - 1) - m) := by
    calc y * (b * m - 1)
      _ = d * b^(l - 1) - d * m := by omega
      _ = d * (b^(l - 1) - m) := by rw [Nat.mul_sub_left_distrib]

  have h_dvd : (b * m - 1) ∣ d * (b^(l - 1) - m) := by
    use y
    calc
      d * (b^(l - 1) - m) = y * (b * m - 1) := h_papier_ligne_3.symm
      _ = (b * m - 1) * y := by ring

  -- have h_y_isolation : y * (b * m - 1) = d * (b^(l - 1) - m) := by


  -- FIN PART 1

  -- PART 2
  have hmod : ((d * b^(l - 1) : ℕ) : ZMod (b * m - 1)) = ((d * m : ℕ) : ZMod (b * m - 1)) := by
    calc ((d * b^(l - 1) : ℕ) : ZMod (b * m - 1))
    _ = ((y * (b * m - 1) + d * m : ℕ) : ZMod (b * m - 1)) := by rw [hfinal]
    _ = ((y * (b * m - 1) : ℕ) : ZMod (b * m - 1)) + ((d * m : ℕ) : ZMod (b * m - 1)) := by rw [Nat.cast_add]
    _ = (y : ZMod (b * m - 1)) * ((b * m - 1 : ℕ) : ZMod (b * m - 1)) + ((d * m : ℕ) : ZMod (b * m - 1)) := by rw [Nat.cast_mul]
    _ = (y : ZMod (b * m - 1)) * 0 + ((d * m : ℕ) : ZMod (b * m - 1)) := by rw [ZMod.natCast_self]
    _ = ((d * m : ℕ) : ZMod (b * m - 1)) := by ring
  -- FIN PART 2

  -- PART 3
  let k := Nat.gcd (b * m - 1) d

  have hb2 : b ≥ 2 := by omega
  have hm2 : m ≥ 2 := by omega
  have h_bm_ge_4 : b * m ≥ 4 := by nlinarith

  -- 2. omega prend le relais pour la soustraction (il sait que 4 - 1 > 0)
  have h_left_pos : b * m - 1 > 0 := by omega

  -- 3. Le PGCD est strictement positif car l'un de ses membres l'est
  -- (Le d en paramètre explicite n'est parfois pas nécessaire selon la version de Mathlib)
  have hk_pos : k > 0 := Nat.gcd_pos_of_pos_left d h_left_pos


  -- 4. La suite de ton théorème de Gauss...
  have h_coprime : Nat.Coprime ((b * m - 1) / k) (d / k) :=
    Nat.coprime_div_gcd_div_gcd hk_pos

  have h_gauss : ((b * m - 1) / k) ∣ (b^(l - 1) - m) := by
    -- On prouve d'abord la divisibilité avec les divisions par k
    have h_dvd_div : ((b * m - 1) / k) ∣ (d / k) * (b^(l - 1) - m) := by
      -- h_dvd signifie qu'il existe un quotient 'c' tel que d*(...) = (b*m-1)*c
      rcases h_dvd with ⟨c, hc⟩
      use c

      -- k * X = k * Y implique X = Y (puisque k > 0 via hk_pos)
      apply Nat.eq_of_mul_eq_mul_left hk_pos

      -- On fait le lien entre la version divisée et la version normale
      calc k * ((d / k) * (b^(l - 1) - m))
        -- On déplace les parenthèses : (k * d/k) * ...
        _ = (k * (d / k)) * (b^(l - 1) - m) := by rw [← Nat.mul_assoc]
        -- k * d/k redevient d (car k divise d)
        _ = d * (b^(l - 1) - m) := by rw [Nat.mul_div_cancel' (Nat.gcd_dvd_right (b * m - 1) d)]
        -- On utilise notre hypothèse de base hc
        _ = (b * m - 1) * c := hc
        -- b*m - 1 redevient k * (b*m - 1)/k
        _ = (k * ((b * m - 1) / k)) * c := by rw [Nat.mul_div_cancel' (Nat.gcd_dvd_left (b * m - 1) d)]
        -- On remet les parenthèses comme Lean les attend
        _ = k * (((b * m - 1) / k) * c) := by rw [Nat.mul_assoc]

    -- 2. On conclut avec le VRAI théorème de Gauss de Mathlib !
    exact Nat.Coprime.dvd_of_dvd_mul_left h_coprime h_dvd_div

  -- ==========================================
  -- LE GRAND FINAL : PASSAGE AU MODULO ET ORDRE
  -- ==========================================

  -- 1. On sépare le cas trivial où la longueur du nombre est 0
  rcases Nat.eq_zero_or_pos l with hl | hl_pos
  · use 0
    -- ASTUCE : on remplace p.length par l formellement
    change l = 0 * _
    rw [hl]
    ring

  -- 2. Maintenant on sait que l ≥ 1, donc b^(l-1) * b = b^l
  have h_pow_l : b^(l - 1) * b = b^l := by
    calc b^(l - 1) * b
      -- On prouve juste que b = b^1 (rw va réduire b^1 en b et valider)
      _ = b^(l - 1) * b^1 := by rw [Nat.pow_one]
      -- On fusionne les exposants
      _ = b^((l - 1) + 1) := by rw [← Nat.pow_add]
      -- congr 1 enlève la base 'b', omega s'occupe de (l - 1) + 1 = l
      _ = b^l := by congr 1; omega

  -- 3. LA FORMULE MAGIQUE ADDITIVE : on multiplie tout par b
  -- On prouve que : n * (b * m - 1) + d = d * b^l
  have h_magic : n * (b * m - 1) + d = d * b^l := by
    -- On prépare une étape intermédiaire en multipliant h_final par b
    have h1 : n * (b * m - 1) + d = (y * (b * m - 1) + d * m) * b := by
      zify [hbm] at hdiv ⊢
      linear_combination (b * m - 1 : ℤ) * hdiv

    calc n * (b * m - 1) + d
      _ = (y * (b * m - 1) + d * m) * b := h1
      _ = (d * b^(l - 1)) * b := by rw [hfinal]
      _ = d * (b^(l - 1) * b) := by ring
      _ = d * b^l := by rw [h_pow_l]

  -- 4. On divise la Formule Magique par k de chaque côté
  have h_magic_div : n * D + (d / k) = (d / k) * b^l := by
    -- On prépare nos deux simplifications proprement hors du calc :
    -- Lean accepte de déballer D et k ici pour valider la simplification
    have hD : D * k = b * m - 1 := by
      -- On déballe avec l'ordre EXACT de ton D (d en premier) et de ton k (b*m-1 en premier)
      change ((b * m - 1) / Nat.gcd d (b * m - 1)) * Nat.gcd (b * m - 1) d = b * m - 1
      -- On remet le premier PGCD à l'endroit !
      rw [Nat.gcd_comm d (b * m - 1)]
      -- Et paf, ça s'annule !
      exact Nat.div_mul_cancel (Nat.gcd_dvd_left (b * m - 1) d)

    -- 2. On règle le problème de d (qui est beaucoup plus simple)
    have hd : (d / k) * k = d := by
      -- k est tout seul, donc on l'écrit normalement
      change (d / Nat.gcd (b * m - 1) d) * Nat.gcd (b * m - 1) d = d
      exact Nat.div_mul_cancel (Nat.gcd_dvd_right (b * m - 1) d)

    -- On prouve que c'est vrai en le remultipliant par k
    apply Nat.eq_of_mul_eq_mul_right hk_pos
    calc (n * D + (d / k)) * k
      _ = n * (D * k) + (d / k) * k := by ring
      -- On utilise nos belles boîtes toutes prêtes !
      _ = n * (b * m - 1) + d := by rw [hD, hd]
      _ = d * b^l := h_magic
      -- On utilise hd à l'envers pour refaire apparaître (d / k) * k
      _ = ((d / k) * k) * b^l := by rw [hd]
      _ = ((d / k) * b^l) * k := by ring

  -- 5. On en déduit instantanément que D divise (d/k) * (b^l - 1)
  have h_D_dvd_bl : D ∣ b^l - 1 := by
    have h_D_dvd : D ∣ (d / k) * (b^l - 1) := by
      use n
      calc (d / k) * (b^l - 1)
        _ = (d / k) * b^l - (d / k) * 1 := by rw [Nat.mul_sub_left_distrib]
        _ = (d / k) * b^l - (d / k) := by ring
        _ = (n * D + (d / k)) - (d / k) := by rw [← h_magic_div]
        _ = n * D := by omega
        _ = D * n := by ring
    -- On utilise ton h_coprime pour annuler le (d/k) !
    -- On explique à Lean que la fraction avec k est exactement D (en remettant le PGCD à l'endroit)
    have h_eq : (b * m - 1) / k = D := by
      change (b * m - 1) / Nat.gcd (b * m - 1) d = (b * m - 1) / Nat.gcd d (b * m - 1)
      rw [Nat.gcd_comm]

    -- On met h_coprime à jour avec D
    rw [h_eq] at h_coprime

    -- Et maintenant Lean accepte l'application !
    exact Nat.Coprime.dvd_of_dvd_mul_left h_coprime h_D_dvd

  -- 6. D | b^l - 1 signifie exactement que b^l ≡ 1 modulo D !
  have h_mod_1 : (b : ZMod D)^l = 1 := by
    rcases h_D_dvd_bl with ⟨c, hc⟩

    -- On rassure Lean sur le fait que b^l n'est pas zéro
    have h_bl_pos : 0 < b^l := by positivity

    -- On transforme b^l - 1 = D * c en b^l = D * c + 1
    have h_bl_eq : b^l = D * c + 1 := by
      -- L'ASTUCE ULTIME : on remplace b^l par une simple variable X
      -- pour empêcher omega de paniquer avec la puissance !
      generalize hX : b^l = X at hc h_bl_pos ⊢
      omega

    -- On injecte l'équation dans l'anneau ZMod D
    have h_cast : ((b^l : ℕ) : ZMod D) = ((D * c + 1 : ℕ) : ZMod D) := by rw [h_bl_eq]
    push_cast at h_cast

    calc (b : ZMod D)^l
      _ = (D : ZMod D) * (c : ZMod D) + 1 := h_cast
      _ = 0 * (c : ZMod D) + 1 := by rw [ZMod.natCast_self D]
      _ = 1 := by ring

  -- 7. CONCLUSION : Si b^l = 1, alors l est un multiple de l'ordre de b
  -- orderOf_dvd_of_pow_eq_one est LE théorème d'algèbre générale de Mathlib
  have h_order : orderOf (b : ZMod D) ∣ l := orderOf_dvd_of_pow_eq_one h_mod_1

  -- On extrait notre 'k' final pour le but du théorème
  rcases h_order with ⟨k_ans, hk_ans⟩
  use k_ans

  -- ASTUCE : on fait la même chose pour que Lean comprenne que p.length c'est l
  change l = k_ans * _

  -- hk_ans nous dit que l = orderOf(b) * k_ans. On remplace l :
  rw [hk_ans]

  -- 'ring' sait que X * Y = Y * X, il valide instantanément !
  ring
