
protocol Semigroup {
  func op(_ s: Self) -> Self
}

extension Int: Semigroup {
  func op(_ s: Int) -> Int {
    return self + s
  }
}

extension Array: Semigroup {
  func op(_ s: Array) -> Array<Element> {
    return self + s
  }
}

extension String: Semigroup {
  func op(_ s: String) -> String {
    return self + s
  }
}

precedencegroup SemigroupPrecedence {
  associativity: right
}

infix operator <> : SemigroupPrecedence

func <> <S: Semigroup> (lhs: S, rhs: S) -> S {
  return lhs.op(rhs)
}

1 <> 2
[1, 2, 3] <> [4, 5, 6]

func sconcat <S: Semigroup> (_ xs: [S], _ initial: S) -> S {
  return xs.reduce(initial, <>)
}

sconcat([1, 2, 3], 0)
sconcat([[1, 2, 3], [3, 4, 5], [5, 6, 7]], [])

protocol Monoid: Semigroup {
  static func e() -> Self
}

extension Int: Monoid {
  static func e() -> Int {
    return 0
  }
}

extension Array: Monoid {
  static func e() -> Array {
    return []
  }
}

extension String: Monoid {
  static func e() -> String {
    return ""
  }
}

func mconcat <M: Monoid> (_ xs: [M]) -> M {
  return xs.reduce(M.e(), <>)
}

mconcat([1, 2, 3, 4])
mconcat([[1, 2, 3], [4, 5, 6]])

extension Bool: Monoid {
  func op(_ s: Bool) -> Bool {
    return self && s
  }
  static func e() -> Bool {
    return true
  }
}

struct Endomorphism<A> {
  let f: (A) -> A
}

extension Endomorphism: Monoid {
  static func e() -> Endomorphism {
    return Endomorphism { x in x }
  }

  func op(_ s: Endomorphism) -> Endomorphism {
    return Endomorphism { x in
      return s.f(self.f(x))
    }
  }
}

let square: Endomorphism<Int> = Endomorphism { $0 * $0 }
let incr = Endomorphism { $0 + 1 }
let mod3 = Endomorphism { $0 % 3 }

mconcat([square, incr, mod3]).f(2)

struct FunctionM<A, M: Monoid> {
  let f: (A) -> M
}

extension FunctionM: Monoid {
  func op(_ s: FunctionM) -> FunctionM {
    return FunctionM { x in
      return self.f(x) <> s.f(x)
    }
  }
  static func e() -> FunctionM {
    return FunctionM { _ in M.e() }
  }
}

typealias Predicate<A> = FunctionM<A, Bool>

struct Max <A: Comparable> {
  let a: A
  init (_ a: A) { self.a = a }
}

struct Min <A: Comparable> {
  let a: A
  init (_ a: A) { self.a = a }
}

enum M <S: Semigroup> {
  case Identity
  case Element(S)
}

extension M : Monoid {
  static func e() -> M {
    return .Identity
  }

  func op(_ b: M) -> M {
    switch (self, b) {
    case (.Identity, .Identity):
      return .Identity
    case (.Element, .Identity):
      return self
    case (.Identity, .Element):
      return b
    case let (.Element(a), .Element(b)):
      return .Element(a <> b)
    }
  }
}

enum Ordering {
  case lt
  case eq
  case gt
}

"done"














