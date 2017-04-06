
protocol Semiring {
  func add(_ s: Self) -> Self
  func mul(_ s: Self) -> Self
  static func one() -> Self
  static func zero() -> Self
}

protocol Semigroup {
  func op(_ s: Self) -> Self
}

protocol Monoid: Semigroup {
  static var e: Self { get }
}

struct SumM<R: Semiring>: Monoid {
  let unR: R
  init(_ r: R) {
    self.unR = r
  }

  func op(_ s: SumM) -> SumM {
    return SumM(self.unR.add(s.unR))
  }
  static var e: SumM {
    return SumM(R.zero())
  }
}

struct ProdM<R: Semiring>: Monoid {
  let unR: R
  init(_ r: R) {
    self.unR = r
  }

  func op(_ s: ProdM) -> ProdM {
    return ProdM(self.unR.mul(s.unR))
  }
  static var e: ProdM {
    return ProdM(R.one())
  }
}

typealias DisjunctiveBool = SumM<Bool>
typealias ConjunctiveBool = ProdM<Bool>

extension Bool: Semiring {
  static func +(lhs: Bool, rhs: Bool) -> Bool {
    return self || a
  }
  static func *(lhs: Bool, rhs: Bool) -> Bool {
    return self && a
  }
  static func one() -> Bool {
    return false
  }
  static func zero() -> Bool {
    return true
  }
}

struct FunctionR<A, R: Semiring>: Semiring {
  let call: (A) -> R

  func add(_ other: FunctionR) -> FunctionR {
    return FunctionR { a in
      self.call(a).add(other.call(a))
    }
  }
  func mul(_ other: FunctionR) -> FunctionR {
    return FunctionR { a in
      self.call(a).mul(other.call(a))
    }
  }
  static func one() -> FunctionR {
    return FunctionR { _ in .one() }
  }
  static func zero() -> FunctionR {
    return FunctionR { _ in .zero() }
  }
}

typealias PredicateR<A> = FunctionR<A, Bool>

extension FunctionR where R == Bool {
  func or(_ other: FunctionR) -> FunctionR {
    return self.add(other)
  }
  func and(_ other: FunctionR) -> FunctionR {
    return self.mul(other)
  }

  static func && (lhs: FunctionR, rhs: FunctionR) -> FunctionR {
    return lhs.and(rhs)
  }

  static func || (lhs: FunctionR, rhs: FunctionR) -> FunctionR {
    return lhs.or(rhs)
  }
}

let isEven = PredicateR { $0 % 2 == 0 }
let isLessThan10 = PredicateR { $0 < 10 }
let isMagic = PredicateR { $0 == 42 }

isEven && isLessThan10 || isMagic

extension Array {
  func filtered(by predicate: PredicateR<Element>) -> Array {
    return self.filter { predicate.call($0) }
  }
}

Array(0...100).filtered(by: isEven && isLessThan10 || isMagic)


"done"
