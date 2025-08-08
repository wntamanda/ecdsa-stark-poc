# ECDSA Proof of Concept (Toy Curve – Cairo 1.1)

This is a **minimal** implementation of ECDSA signature verification using a toy elliptic curve, written in **Cairo 1.1** and compiled with **Scarb**.

⚠️ **Not a full implementation. Not secure. Just for fun & learning.**

## Curve Parameters

Toy curve over a small prime field:

- Prime: `P = 97`
- Curve: `y² = x³ + 2x + b` (simplified with custom base point)
- Base point `G = (3, 6)`
- Curve order: `N = 5`

## What It Does

- Implements basic modular math (Fermat inverse, pow_mod)
- Defines point operations (`ec_add`, `ec_mul`)
- Implements **ECDSA signature verification**
- Includes a sanity test (`#[test]`)

## How to Run

Make sure you have **Scarb** and **Cairo 1.1** set up. Then:

```bash
scarb test
```

## Example

```rust
#[test]
fn sanity() {
    let Q = Point { x: 3, y: 6 }; // Made-up public key
    let ok = ecdsa_verify(3, 4, 1, Q);
    assert(ok, 'sig failed');
}
```

## Notes

- Curve is **not cryptographically safe**
- Uses tiny field for readability and ease of testing
- Optimized for clarity, not performance