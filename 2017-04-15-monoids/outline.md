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


```swift
infix operator <> : AdditionPrecedence

protocol Semigroup {
  static func <> (lhs: Self, rhs: Self) -> Self
}

// **AXIOM**: a <> (b <> c) == (a <> b) <> c for all a, b, c
```

We already know quite a few examples of semigroups:

```swift
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
```

You can use this quite easily:

```swift
1 <> 2
[1, 2, 3] <> [4, 5, 6]
```

This is pretty powerful. It has completely abstracted away the idea of computation so that you can treat
many disparate ideas of computation on equal footing.

A quick use of this abstraction is that we can write a form of `reduce` on arrays that doesnt require an
accumulator:

```swift
func sconcat <S: Semigroup> (_ xs: [S], _ initial: S) -> S {
  return xs.reduce(initial, <>)
}
```

And we can use it as so:

```swift
sconcat([1, 2, 3], 0)
sconcat([[1, 2, 3], [3, 4, 5], [5, 6, 7]], [])
```

We still need an initial value. There is another algebraic structure that has a distinguished element. It's
called a monoid and we can define it in Swift as:


```swift
protocol Monoid: Semigroup {
  static var e: Self { get }
}

// **AXIOM**: a <> e == e <> a for all a
```

All the semigroups we considered previously are also monoids:

```swift
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
```

Because of this distinguished element we can define another version of reduce that doesnt need an initial
value or an accumulator:

```swift
func mconcat <M: Monoid> (_ xs: [M]) -> M {
  return sconcat(xs, M.e)
}
```

And we can use it like so:

```swift
mconcat([1, 2, 3, 4])
mconcat([[1, 2, 3], [4, 5, 6]])
```

All of these monoids are quite basic. There are more interesting ones we can cook up. For example, the type
of all functions from `A` to `A`, also called endomorphisms forms a monoid:

```swift
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
```

We can cook up some simple endomorphisms and then compose them together:

```swift
let square: Endo<Int> = Endo { $0 * $0 }
let incr = Endo { $0 + 1 }
let mod3 = Endo { $0 % 3 }
```

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









