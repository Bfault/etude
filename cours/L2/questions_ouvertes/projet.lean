import Mathlib.Data.Nat.Digitsy

def number_of_digits (n : ℕ) (b : ℕ) : ℕ :=
  if b > 1 then
    Nat.digits n b |>.length
  else
    0

theorem parasite_number_length_characteristic
  (b : ℕ)         -- The base
  (hb : b > 1)    -- The base must be greater than 1
  (d : ℕ)         -- The first digit of the given parasite number
  (hd : d < b)    -- The first digit must be less than the base
  (m : ℕ)         -- The multiplier for the parasite number
  (hm : m > 1)    -- The multiplier must be greater than 1
  :
