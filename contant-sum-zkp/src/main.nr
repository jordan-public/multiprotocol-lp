fn main(old_x: pub i64, old_y: pub i64, x: pub i64, y: pub i64) {
    assert(old_x + old_y == x + y); // Enforces constant sum of the two inputs
}

#[test]
fn test_main() {
    main(1, 2, 2, 1);
}
