
/*:
 # Monoids!

 ---

 ## Brandon Williams

 **Email:** brandon@kickstarter.com

 **Twitter:** @mbrandonw
 */



/*:
 Today we're going to talk about semigroups and monoids.

 Monoids are a nice introduction to getting into abstract mathematics.

 They are defined in quite an abstract way, and require certain axioms to hold, but it's easiy to construct
 and play with them.

 We start with the definition of a semigroup. A semigroup is the simplest idea of computation around. It
 only describes how to combine two values of the same time to obtain a single value. The manner of
 combining two values has to satisfying associativity too.

 In Swift we could define it like so:
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
[1, 2, 3] <> [4, 5, 6]

func sconcat <S: Semigroup> (_ xs: [S], _ initial: S) -> S {
  return xs.reduce(initial, <>)
}

sconcat([1, 2, 3], 0)
sconcat([[1, 2, 3], [3, 4, 5], [5, 6, 7]], [])

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

func mconcat <M: Monoid> (_ xs: [M]) -> M {
  return sconcat(xs, M.e)
}

mconcat([1, 2, 3, 4])
mconcat([[1, 2, 3], [4, 5, 6]])

struct Endo<A>: Monoid {
  let call: (A) -> A

  static var e: Endo {
    return Endo { x in x }
  }

  static func <> (lhs: Endo, rhs: Endo) -> Endo {
    return Endo { x in
      return rhs.call(lhs.call(x))
    }
  }
}

let square: Endo<Int> = Endo { $0 * $0 }
let incr = Endo { $0 + 1 }
let mod3 = Endo { $0 % 3 }

mconcat([square, incr, mod3]).call(2)

struct FunctionM<A, M: Monoid>: Monoid {
  let call: (A) -> M

  static func <> (lhs: FunctionM, rhs: FunctionM) -> FunctionM {
    return FunctionM { x in
      return lhs.call(x) <> rhs.call(x)
    }
  }
  static var e: FunctionM {
    return FunctionM { _ in M.e }
  }
}

/* 
 Digresssion:

 struct Function <A, B> {}
 
 extension Function: Monoid where B: Monoid {}
 
 (->)
 
 extension (A -> B): Monoid where B: Monoid {}
 
 extensions (A -> A): Monoid {}
 */

typealias Predicate<A> = FunctionM<A, Bool>

let isEven = Predicate<Int> { $0 % 2 == 0 }
let isLessThan10 = Predicate<Int> { $0 < 10 }
//let isLessThan = { x in Predicate<Int> { $0 < x } }

isEven <> isLessThan10

func isLessThan <C: Comparable> (_ x: C) -> Predicate<C> {
  return Predicate { $0 < x }
}

func isNil <A> () -> Predicate<A?> {
  return Predicate { $0 == nil }
}

extension Array {
  func filtered(by predicate: Predicate<Element>) -> Array {
    return self.filter(predicate.call)
  }
}

Array(0...200).filtered(by: isEven <> isLessThan10)
Array(0...200).filtered(by: isEven <> isLessThan(10))
["foo", "bar", "baz", "qux"].filtered(by: isLessThan("f"))

[1, 2, nil, 3, nil, 4].filtered(by: isNil())

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

  static let e = Ordering.eq
}

typealias Comparator<A> = FunctionM<(A, A), Ordering>

extension Comparable {
  static func comparator() -> Comparator<Self> {
    return Comparator.init { $0 < $1 ? .lt : $0 > $1 ? .gt : .eq }
  }
}

Int.comparator()

extension Array {
  func sorted(by comparator: Comparator<Element>) -> Array {
    return self.sorted { comparator.call($0, $1) == .lt }
  }
}

[4, 6, 2, 8, 1, 2].sorted(by: Int.comparator())

extension Ordering {
  func reversed() -> Ordering {
    return self == .lt ? .gt : self == .gt ? .lt : .eq
  }
}

// possible todo: use this to describe monoid (homo)morphisms

// Should work but doesnt 
// ----------------------
//extension Comparator {
//  func reversed() -> Comparator {
//    return Comparator { pair in
//      self.f(pair).reversed()
//    }
//  }
//}

extension FunctionM where M == Ordering {
  func reversed() -> FunctionM {
    return FunctionM { self.call($0).reversed() }
  }
}

Int.comparator().reversed()

[4, 6, 2, 8, 1, 2].sorted(by: Int.comparator().reversed())

Project.lens.creator.name

extension Lens where Part: Comparable {
  var comparator: Comparator<Whole> {
    return Comparator { lhs, rhs in
      self.view(lhs) < self.view(rhs) ? .lt
        : self.view(lhs) > self.view(rhs) ? .gt
        : .eq
    }
  }
}

Project.lens.creator.location.name.comparator

projects
  .sorted(by: Project.lens.state.comparator
    <> Project.lens.creator.location.name.comparator
    <> Project.lens.name.comparator
  )
  .map { "\($0.state) : \($0.creator.location.name) : \($0.name)" }


//spell out sorting things that are not typically comparable




"done"










/*:
 # Thanks!
 
 ### Brandon Williams
 
 **Email:** brandon@kickstarter.com
 
 **Twitter:** @mbrandonw
 */


















