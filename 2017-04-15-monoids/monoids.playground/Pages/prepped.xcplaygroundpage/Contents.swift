
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

// **AXIOM**: a <> (b <> c) == (a <> b) <> c for all a, b, c

/*:
 We already know quite a few examples of semigroups:
 */

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

/*:
 You can use this quite easily:
 */

1 <> 2
[1, 2, 3] <> [4, 5, 6]

/*:
 This is pretty powerful. It has completely abstracted away the idea of computation so that you can treat
 many disparate ideas of computation on equal footing.

 A quick use of this abstraction is that we can write a form of `reduce` on arrays that doesnt require an
 accumulator:
 */

func concat <S: Semigroup> (_ xs: [S], _ initial: S) -> S {
  return xs.reduce(initial, <>)
}

/*:
 And we can use it as so:
 */

concat([1, 2, 3], 0)
concat([[1, 2, 3], [3, 4, 5], [5, 6, 7]], [])

/*:
 We still need an initial value. There is another algebraic structure that has a distinguished element. It's
 called a monoid and we can define it in Swift as:
 */

protocol Monoid: Semigroup {
  static var e: Self { get }
}

// **AXIOM**: a <> e == e <> a for all a

/*:
 All the semigroups we considered previously are also monoids:
 */

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

/*:
 Because of this distinguished element we can define another version of reduce that doesnt need an initial
 value or an accumulator:
 */

func concat <M: Monoid> (_ xs: [M]) -> M {
  return concat(xs, M.e)
}

/*:
 And we can use it like so:
 */

concat([1, 2, 3, 4])
concat([[1, 2, 3], [4, 5, 6]])

/*:
 All of these monoids are quite basic. There are more interesting ones we can cook up. For example, the type
 of all functions from `A` to `A`, also called endomorphisms forms a monoid:
 */

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

/*:
 We can cook up some simple endomorphisms and then compose them together:
 */

let square: Endo<Int> = Endo { $0 * $0 }
let incr = Endo { $0 + 1 }
let mod3 = Endo { $0 % 3 }

concat([square, incr, mod3]).call(2)

/*:
 There's also a way to construct new monoids from old. Consider the type of functions `(A) -> M`. If
 `M` is a monoid, then you can induce a monoidal structure on the type of functions!
 */

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

/*:
 ### Digresssion:

 Sometime in the future, Swift's type system will be strong enough to do conditional protocol conformances,
 which means we can just define:

 ```swift
 struct Function <A, B> {}
 ```
 
 and then extend it to be a monoid when `B` is a monoid:

 ```swift
 extension Function: Monoid where B: Monoid {}
 ```
 
 Or, maybe in a far far future of Swift, we can treat arrow `(->)` as a first class type that could be
 extended, allowing us to get rid of the `Function` struct all together and do something like:

 ```swift
 extension (A -> B): Monoid where B: Monoid {}
 ```
 */

/*:
 Back to present day swift.
 
 There are some really interesting monoids that can be cooked up from `FunctionM`. For example, predicates!
 These are functions of the form `(A) -> Bool`, and they are precisely the functions you can give to 
 array's `filter` method.
 
 Using generic typealiases (new feature in Swift 3) we can define it simply as:
 */

typealias Predicate<A> = FunctionM<A, Bool>

/*:
 And we can construct some interesting predicates:
 */

let isEven = Predicate<Int> { $0 % 2 == 0 }
let isLessThan10 = Predicate<Int> { $0 < 10 }

/*:
 And we can compose the predicates to be "is even" AND "is less than 10"
 */

isEven <> isLessThan10

/*:
 Further, we can use Swift standard library ideas to induce predicates easily. Any comparable naturally
 induces a predicate by just using less than:
 */

func isLessThan <C: Comparable> (_ x: C) -> Predicate<C> {
  return Predicate { $0 < x }
}

isEven <> isLessThan(10)

/*:
 We can extend array so that it understands how to work with predicates:
 */

extension Array {
  func filtered(by predicate: Predicate<Element>) -> Array {
    return self.filter(predicate.call)
  }
}

/*:
 And then we can use the monoidal structure on predicates to cook up very expressive filters:
 */

Array(0...200).filtered(by: isEven <> isLessThan10)
Array(0...200).filtered(by: isEven <> isLessThan(10))
["foo", "bar", "baz", "qux"].filtered(by: isLessThan("f"))

/*:
 Here's another monoid. It's useful for sorting arrays just like `Bool` as a monoid was useful
 for predicates.
 */

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

/*:
 Functions from tuples into `Ordering` encapsulate the idea of comparing two values to check if they
 are less than, greater than, or equal to each other. We can define it simply, and of course its a 
 monoid!
 */

typealias Comparator<A> = FunctionM<(A, A), Ordering>

/*:
 An easy way to generator comparators is from comparables:
 */

extension Comparable {
  static func comparator() -> Comparator<Self> {
    return Comparator.init { $0 < $1 ? .lt : $0 > $1 ? .gt : .eq }
  }
}

/*:
 Then we can generator comparators like so:
 */

Int.comparator()
String.comparator()

/*:
 It's quite easy to get arrays to understand how to use comparators:
 */

extension Array {
  func sorted(by comparator: Comparator<Element>) -> Array {
    return self.sorted { comparator.call($0, $1) == .lt }
  }
}

/*:
 And then we can do:
 */

[4, 6, 2, 8, 1, 2].sorted(by: Int.comparator())

/*:
 Although that is not very inspiring. More interesting is that since `Comparator` is a first class type,
 we can perform transformations on it. First, let's define a transformation on `Ordering` and then lift
 that to `Comparator`:
 */

extension Ordering {
  func reversed() -> Ordering {
    return self == .lt ? .gt : self == .gt ? .lt : .eq
  }
}

/*:
 Then we can reverse a comparator by doing:
 */

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

/*:
 And we can use it:
 */

Int.comparator().reversed()

[4, 6, 2, 8, 1, 2].sorted(by: Int.comparator().reversed())

/*:
 None of this is too inspiring. Where this stuff really shines is when you want to sort complicated 
 values by many fields. In order to aid in this we will use lenses!
 
 Very quick refresher on lenses: They are functional getters and setters. You can focus on a part
 of a struct, and you can change a part of a struct and recieve a whole new value back.
 
 In our sources directory I have a few basic models for a Project, Location and User, and some lenses
 for those models.
 */

Project.lens.creator.name

/*:
 Similarly to how we saw that the set of functions into a monoid naturally carries a monoidal structure
 itself, _lenses_ into a comparable part can induce a comparator on the whole:
 */

extension Lens where Part: Comparable {
  var comparator: Comparator<Whole> {
    return Comparator { lhs, rhs in
      self.view(lhs) < self.view(rhs) ? .lt
        : self.view(lhs) > self.view(rhs) ? .gt
        : .eq
    }
  }
}

/*:
 And now we can do stuff like:
 */

Project.lens.creator.location.name.comparator

/*:
 In the sources directory I've created a bunch of projects data for us to play with:
 */

projects
  .sorted(by: Project.lens.state.comparator
    <> Project.lens.creator.location.name.comparator
    <> Project.lens.name.comparator
  )
  .map { "\($0.state) : \($0.creator.location.name) : \($0.name)" }





"done"














/*:
 # Thanks!
 
 ### Brandon Williams
 
 **Email:** brandon@kickstarter.com
 
 **Twitter:** @mbrandonw
 */


















