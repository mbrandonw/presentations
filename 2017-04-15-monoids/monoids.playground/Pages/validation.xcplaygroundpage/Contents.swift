
protocol Monoid {
  func op(_ x: Self) -> Self
  static var e: Self { get }
}

extension Optional: Monoid {
  func op(_ x: Optional<Wrapped>) -> Optional<Wrapped> {
    return self ?? x
  }
  static var e: Optional {
    return nil
  }
}

1
