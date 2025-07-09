// Minimal toy-ECDSA that compiles with Scarb & Cairo 1.1

// ---------- constants ----------
const P: u128 = 97;
const A: u128 = 2;
const Gx: u128 = 3;
const Gy: u128 = 6;
const N: u128 = 5;

// ---------- point type ----------
#[derive(Copy, Drop)]
struct Point { x: u128, y: u128 }

// pow-mod with square-and-multiply (uses /2 , no shifts)
fn pow_mod(mut base: u128, mut exp: u128, m: u128) -> u128 {
    let mut res: u128 = 1;
    base = base % m;
    while exp != 0 {
        if exp & 1 == 1 { res = (res * base) % m; }
        base = (base * base) % m;
        exp = exp / 2;                    // was : >> 1
    }
    res
}

// Fermat inverse (P is prime)
fn modinv(a: u128, p: u128) -> u128 { pow_mod(a, p - 2, p) }

// ---------- curve arithmetic ----------
fn ec_add(p1: Point, p2: Point) -> Point {
    if p1.x == p2.x && p1.y == (P - p2.y) % P { return Point { x: 0, y: 0 }; }

    let mut s: u128 = 0;
    if p1.x == p2.x && p1.y == p2.y {
        let num = (3 * p1.x * p1.x + A) % P;
        let den = modinv((2 * p1.y) % P, P);
        s = (num * den) % P;
    } else {
        let num = (p2.y + P - p1.y) % P;
        let den = modinv((p2.x + P - p1.x) % P, P);
        s = (num * den) % P;
    }

    let x3 = (s * s + P - p1.x + P - p2.x) % P;
    let y3 = (s * ((p1.x + P - x3) % P) + P - p1.y) % P;
    Point { x: x3, y: y3 }
}

fn ec_mul(mut k: u128, mut addend: Point) -> Point {
    let mut res = Point { x: 0, y: 0 };            // ∞
    while k > 0 {
        if k & 1 == 1 {
            res = if res.x == 0 && res.y == 0 { addend } else { ec_add(res, addend) };
        }
        addend = ec_add(addend, addend);
        k = k / 2;                                 // was : >> 1
    }
    res
}

// ---------- verification ----------
fn ecdsa_verify(r: u128, s: u128, z: u128, Q: Point) -> bool {
    if r == 0 || r >= N || s == 0 || s >= N { return false; }

    let w  = modinv(s, N);
    let u1 = (z * w) % N;
    let u2 = (r * w) % N;

    let G  = Point { x: Gx, y: Gy };
    let P  = ec_add(ec_mul(u1, G), ec_mul(u2, Q));

    (P.x % N) == r
}

// ---------- unit test ----------
#[test]
fn sanity() {
    let Q = Point { x: 3, y: 6 };                  // made-up key
    let ok = ecdsa_verify(3, 4, 1, Q);
    assert(ok, 'sig failed');                      // 2-arg assert
}
