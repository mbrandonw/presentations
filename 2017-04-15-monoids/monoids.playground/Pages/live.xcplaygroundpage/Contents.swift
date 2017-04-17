
/*:
 # Monoids!

 ---

 ## Brandon Williams

 **Email:** brandon@kickstarter.com

 **Twitter:** @mbrandonw
 */


infix operator <> : AdditionPrecedence

protocol Semigroup {
  static func <> (lhs: Self, rhs: Self) -> Self
}

extension Int: Semigroup {
  static func <> (lhs: Int, rhs: Int) -> Int {
    return lhs + rhs
  }
}

1 <> 2 <> 3



extension Array: Semigroup {
  static func <> (lhs: Array, rhs: Array) -> Array {
    return lhs + rhs
  }
}

extension String: Semigroup {
  static func <> (lhs: String, rhs: String) -> String {
    return lhs + rhs
  }
}

extension Bool: Semigroup {
  static func <> (lhs: Bool, rhs: Bool) -> Bool {
    return lhs && rhs
  }
}

1 <> 2
"sdf" <> "gdfsg"
[1,2] <> [4, 5]

func concat <S: Semigroup> (_ xs: [S], _ initial: S) -> S {
  return xs.reduce(initial, <>)
}

concat([1, 2, 3], 0)
concat([[1, 2], [4, 5]], [])


protocol Monoid: Semigroup {
  static var e: Self { get }
}


extension Int: Monoid {
  static let e = 0
}

extension Array: Monoid {
  static var e: Array {
    return []
  }
}

extension String: Monoid {
  static let e = ""
}

extension Bool: Monoid {
  static let e = true
}

func concat <M: Monoid> (_ xs: [M]) -> M {
  return xs.reduce(M.e, <>)
}


concat([1, 2, 3])

struct Endo<A>: Semigroup, Monoid {
  let call: (A) -> A

  static var e: Endo<A> {
    return Endo { $0 }
  }

  static func <> (lhs: Endo, rhs: Endo) -> Endo {
    return Endo { rhs.call(lhs.call($0)) }
  }
}

let incr = Endo<Int> { $0 + 1 }
let square = Endo<Int> { $0 * $0 }
let mod3 = Endo<Int> { $0 % 3 }

concat([incr, square, mod3]).call(3)

struct FunctionM<A, M: Monoid>: Monoid {
  let call: (A) -> M

  static func <> (lhs: FunctionM, rhs: FunctionM) -> FunctionM {
    return FunctionM { a in
      return lhs.call(a) <> rhs.call(a)
    }
  }

  static var e: FunctionM {
    return FunctionM { _ in M.e }
  }
}

// struct Function<A, B>
// extension Function: Monoid where B: Monoid
// extension (A -> B): Monoid where B: Monoid


typealias Predicate<A> = FunctionM<A, Bool>

let isEven = Predicate<Int> { $0 % 2 == 0 }
let isLessThan10 = Predicate<Int> { $0 < 10 }

isEven <> isLessThan10

func isLessThan <C: Comparable> (_ x: C) -> Predicate<C> {
  return Predicate { $0 < x }
}

isLessThan(10)

extension Array {
  func filtered(by predicate: Predicate<Element>) -> [Element] {
    return self.filter(predicate.call)
  }
}

Array(0...100).filtered(by: isEven <> isLessThan(10))

["foo", "bar", "qux"].filtered(by: isLessThan("f"))

enum Ordering: Monoid {
  case lt
  case eq
  case gt

  static func <> (lhs: Ordering, rhs: Ordering) -> Ordering {
    switch (lhs, rhs) {
    case (.lt, _): return .lt
    case (.gt, _): return .gt
    case (.eq, _): return rhs
    }
  }

  static var e: Ordering { return .eq }
}

typealias Comparator<A> = FunctionM<(A, A), Ordering>

extension Comparable {
  static func comparator() -> Comparator<Self> {
    return Comparator { lhs, rhs in lhs < rhs ? .lt : lhs > rhs ? .gt : .eq }
  }
}

Int.comparator()
String.comparator()

extension Array {
  func sorted(by comparator: Comparator<Element>) -> Array {
    return self.sorted { comparator.call($0, $1) == .lt }
  }
}

[1, 3, 2, 7, 5, 3].sorted(by: Int.comparator())

extension Ordering {
  func reversed() -> Ordering {
    return self == .lt ? .gt : self == .gt ? .lt : .eq
  }
}

extension FunctionM where M == Ordering {
  func reversed() -> FunctionM {
    return FunctionM { self.call($0).reversed() }
  }
}

Int.comparator().reversed()


Project.lens.creator.location.name

extension Lens where Part: Comparable {
  func comparator() -> Comparator<Whole> {
    return Comparator { lhs, rhs in self.view(lhs) < self.view(rhs) ? .lt : self.view(lhs) > self.view(rhs) ? .gt :  .eq }
  }
}


Project.lens.creator.location.name.comparator()

let sorts = [
  Project.lens.state.comparator()
    , Project.lens.creator.location.name.comparator().reversed()
    , Project.lens.name.comparator()
]
projects
  .sorted(by: concat(sorts))
  .map { "\($0.state) : \($0.creator.location.name) : \($0.name)" }


























































/*:
 # Thanks!

 ### Brandon Williams

 **Email:** brandon@kickstarter.com

 **Twitter:** @mbrandonw
 
 kickstarter.com/jobs
 */


