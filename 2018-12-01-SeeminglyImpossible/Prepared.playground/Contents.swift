/*:
 # Seemingly Impossible Swift Programs
 */

/*:
 Today we've heard, and will hear, a lot of great talks about how to use interesting functional programming
 concepts in every day code. I spend a lot of my time doing the same, both in my work on Point-Free and
 when consulting with clients. I've also given lots of talks about this, including at all the functional
 Swift conferences. There are a lot of wonderful ideas in functional programming that can be
 understood by everyone and can help make everyone's day-to-day code more extensible, transformable and
 testable.

 Today I'm going to do the opposite of that. I'm going to talk about something that is entirely
 impratical and not useful for everyday coding. No one here will be able to go back home or to work and
 use any of these ideas in any reasonable way, most likely.

 However, it's still really fascinating stuff. It's basically a math talk disguised as a programming talk,
 and the end result is going to feel really magical. And I think seeing this result is important because
 it can give a true sense of awe at what can be accomplished in computing, and what role mathematics plays
 in that.

 So today we are going to be implementing seemingly impossible Swift programs. That is, we are going to
 implement some programs using Swift that for all intents and purposes should be absolutely impossible
 to implement. In fact, the mind kind of boggles when confronted with the implenentation because it seems
 so outlandish and outside the realm of reality.

 Also, I should preface this by saying that none of the content in this talk is original material by me.
 I learned of these ideas in some papers and I will share those at the end of the talk. The only thing
 original in this talk is the narrative to try to ease us into these ideas, because the papers are a little
 dense.

 ## Completely possible programs

 In order to implement the seemingly impossible we have to take a few small steps to work up to it. So let's
 start with something super possible in Swift. As of Swift 4.2 we have had access to this `allSatisfy`
 method on collections which checks if every element of the collection satisfies a predicate:
 */

[1, 2, 3]
  .allSatisfy { $0 >= 2 }
[2, 3, 4]
  .allSatisfy { $0 >= 2 }

/*:
 There is a "dual" version of this operation that we could call `anySatisfy`, and sadly Swift doesn't come
 with it. However, it's easy enough to implement:
 */
/*
extension Array {
  func anySatisfy(_ p: (Element) -> Bool) -> Bool {
    for x in self {
      if p(x) { return true }
    }
    return false
  }
}
 */

/*:
 We could also be a little fancy here and implemeny `anySatisfy` in terms of `allSatisfy`. This is possible
 via De Morgan's Law, which says that the negation of a disjunction is the conjection of the negations:

 // !(a || b) = !a && !b

 Using this we can rewrite `anySatisfy` as:
 */

extension Array {
  func anySatisfy(_ p: (Element) -> Bool) -> Bool {
    return !self.allSatisfy { !p($0) }
  }
}

/*:
 And we can use it:
 */

[1, 2, 3]
  .anySatisfy { $0 >= 2 }
[1, 2, 3]
  .anySatisfy { $0 >= 4 }

/*:
 So here we have some completely possible programs implemented in Swift. This is _so_ possible that they even
 come in the Swift standard library!

 ## Approaching impossible programs

 Let's inch towards the impossible now. What if we wanted to define `allSatisfy` not on just collections, but
 entire types? That is, we want to answer the question of whether or not a predicate is satisfied on every
 value of a type. That sounds intense, so let's start small. How about defining it on booleans?
 */

extension Bool {
  static func allSatisfy(_ p: (Bool) -> Bool) -> Bool {
    return p(true) && p(false)
  }
}

Bool
  .allSatisfy { $0 == true }  // false
Bool
  .allSatisfy { $0 == false } // false
Bool
  .allSatisfy { $0 || !$0 }   // true

/*:
 That was pretty easy. Let's kick it up a notch. There's a protocol that is poorly named `CaseIterable`, and
 it describes types we can enumerate all of its values. We can easily define `allSatisfy` on such types:
 */

extension CaseIterable {
  static func allSatisfy(_ p: (Self) -> Bool) -> Bool {
    return self.allCases.allSatisfy(p)
  }
}

enum Direction: CaseIterable {
  case up, down, left, right
}

Direction
  .allSatisfy { $0 == .up }

extension Direction {
  var rotatedLeft: Direction {
    switch self {
    case .up:    return .left
    case .left:  return .down
    case .down:  return .right
    case .right: return .up
    }
  }

  var rotatedRight: Direction {
    switch self {
    case .up:    return .right
    case .left:  return .up
    case .down:  return .left
    case .right: return .down
    }
  }
}

Direction
  .allSatisfy { $0.rotatedLeft.rotatedRight == $0 }

/*:
 ## Impossible programs

 Ok, now that we are comfortable with the possible, let's try the impossible.

 Can we implement `allSatisfy` on `Int`?
 */

extension Int {
  static func allSatisfy(_ p: (Int) -> Bool) -> Bool {
    fatalError()
  }
}

/*
Int
  .allSatisfy { $0 % 2 == 0 } // false
Int
  .allSatisfy { $0 > 0 } // false
Int
  .allSatisfy { $0 % 2 == 0 || $0 % 2 == 1 } // true
*/

/*:
 We can't possible implement this. `Int` is too big. Technically it just holds a gigantic number of values,
 but we should also think of it as the type representing _all_ integers and so really it holds infinitely
 many values.

 Another type that has infinitely many values is `String`... surely this is also impossible to implement:
 */

extension String {
  static func allSatisfy(_ p: (String) -> Bool) -> Bool {
    fatalError()
  }
}

/*
String
  .allSatisfy { $0 == "cat" }   // false
String
  .allSatisfy { $0.count > 0 }  // false
String
  .allSatisfy { $0.count >= 0 } // true
*/
/*:
 But there's no way we could ever hope to enumerate all the strings and check the predicate on each value.
 That's just impossible.

 These functions may seem silly, but they are connected to a very real problem of determining if two
 functions are equal. For if we could implement the above functions, then we could implement equality
 between, say, functions `(Int) -> Int`:
 */

func == (lhs: (Int) -> Int, rhs: (Int) -> Int) -> Bool {
  return Int.allSatisfy { lhs($0) == rhs($0) }
}

/*:
 This is yet another impossible function to implement. All of these functions are provably impossible to
 implement. You can mathematically prove it.

 ## Seeimingly impossible programs

 Now that we have surveyed the possible and impossible for implementing a certain type of function, let's look at something that _should_ be impossible, yet somehow is not.

 Consider the following types:
 */

enum Bit {
  case one
  case zero
}

struct BitSequence {
  let atIndex: (UInt) -> Bit
}

/*:
 `Bit` is a simple type that holds two values, and `BitSequence` is the type of functions from non-negative integers into `Bit`. The reason it is called `BitSequence` is because it is kind of like an infinite sequence of `Bit` values, in which you are able to ask what is the value at an index using the `atIndex` method.

 We can easily define values of `BitSequence` by just providing a closure to map `UInt`'s to `Bit`'s:
*/

let xs = BitSequence { _ in .one }
let ys = BitSequence { $0 < 1_000 ? .zero : .one }
let zs = BitSequence { $0 % 2 == 0 ? .zero : .one }

xs.atIndex(0)
xs.atIndex(1)
ys.atIndex(0)
ys.atIndex(1)
zs.atIndex(0)
zs.atIndex(1)


/*:
 You can probably even conform `BitSequence` to the `Sequence` protocol. I'll save that as an exercise.

 And although we cannot concatenate two infinite sequences together, we can push a new head onto an existing sequence. I'm going to overload `+` for this purpose:
 */


/*
 func + (head: Bit, tail: BitSequence) -> BitSequence {
  return BitSequence { $0 == 0 ? head : tail.atIndex($0 - 1) }
}
 */
func + (head: Bit, tail: @escaping @autoclosure () -> BitSequence) -> BitSequence {
  return BitSequence { $0 == 0 ? head : tail().atIndex($0 - 1) }
}

.zero + xs

/*:
 The `BitSequence` type holds infinitely many values. In fact, it holds an unconscionable number of values. It has more values than `Int` and `String` do. It holds so many values that it cannot be [counted](https://en.wikipedia.org/wiki/Uncountable_set) with the natural numbers. It's an infinity that is even larger than the infinitude of natural numbers. It's so large that it can hold an infinite number of copies of the natural numbers inside it!

 So, given how massive this type is, I hope it will be surprising to everyone here to learn that we can define the `anySatisfy` and `allSatisfy` functions on it, and they will exhaustively search the entire type in a finite amount of time. This means we are searching an infinite space of values (a HUGE infinite on top of that) in a finite amount of time. Further, because we can implement `anySatisfy`, we can also implement equality of functions on `BitSequence`s. That's absurd. We can check, in a finite amount of time, if two functions are equal.

 ## Achieving the seemingly impossible

 How on earth could we ever expect to be able to do this? `BitSequence` is unimaginably large.

 Well, let's take it one step at a time. Let's first see if we could define an `allSatisfy` function:
 */

/*
extension BitSequence {
  static func allSatisfy(_ p: (BitSequence) -> Bool) -> Bool {
    fatalError()
  }
}
 */

/*:
 This functions definitively answers the question of whether a given predicate evaluates to `true` for *every* value inside `BitSequence`. Well, this seems difficult, so let's kick the can down the road and appeal to a hypothetically defined `anySatisfy` by using De Morgan's law again:
 */

extension BitSequence {
  static func allSatisfy(_ p: @escaping (BitSequence) -> Bool) -> Bool {
    return !BitSequence.anySatisfy { !p($0) }
  }
}

/*:
 So, now we just have to define `anySatisfy`. Let's first get the signature set up:
*/

/*
extension BitSequence {
  static func anySatisfy(_ p: (BitSequence) -> Bool) -> Bool {
    fatalError()
  }
}
 */

/*:
 This seems just as difficult as `allSatisfy`, so what have we gained? Let's introduce a little twist.

 Suppose now there existed a hypothetical `find` function such that when given a predicate on `BitSequence` it would find a `BitSequence` that satisfies the predicate, and if no such value exists it would just return any sequence, the contents of which don't really matter. Let's write the signature of such a function:
 */

/*
extension BitSequence {
  static func find(_ p: (BitSequence) -> Bool) -> BitSequence {
    fatalError()
  }
}
 */

/*:
 If such a function existed, we could then implement `anySatisfy` with:
*/

/*
extension BitSequence {
  static func anySatisfy(_ p: @escaping (BitSequence) -> Bool) -> Bool {
    return p(BitSequence.find(p))
  }
}
*/
extension BitSequence {
  static func anySatisfy(_ p: @escaping (BitSequence) -> Bool) -> Bool {
    let found = BitSequence { n in BitSequence.find(p).atIndex(n) }
    return p(found)
  }
}

/*:
 We first `find` a sequence satisfying `p`, if it exists, and then feed it into the predicate `p`. This means that if it does exist we'll get `true`, and if it does not exist we'll get `false`, just like we expect.

 It probably feels like we're just kicking the responsibilities even further down the road without accomplishing anything, but we've now boiled down this seemingly impossible program to implementing the `find` function.

 How can we find a sequence satisfying the predicate `p`? Turns out we can actually construct it recursively. For say there exists a sequence `s` such that the "larger" sequence `.zero + s` is satisfied by the predicate. Then we construct the sequence `.zero + ` the sequence that was found to satisfy. And if no sequence is satisfied by that, then we can try `.one + s`. Let's give that a shot in code:
*/

extension BitSequence {
  static func find(_ p: @escaping (BitSequence) -> Bool) -> BitSequence {
    if BitSequence.anySatisfy({ s in p(.zero + s) }) {
      return .zero + find({ s in p(.zero + s) })
    } else {
      return .one + find({ s in p(.one + s) })
    }
  }
}

/*:
 This now actually compiles in Swift! But it's really mysterious. In fact, is there any reason to believe this function will ever terminate? Not only does it recursively call itself, but it also calls `anySatisfy` which also calls `find`.

 In fact, Swift is giving us a warning to let us know this isn't quite right. As of Swift 4.X (todo: ask codafi) the compiler can prove that all paths through a function will call itself, and hence never terminate:

 ⚠️ All paths through this function will call itself

 We need to introduce some laziness into our functions so that we do not try to compute everything at once, but instead compute only as much as we need. The recursive calls to `find` happen in each of the `if`/`else` branches, and happen to the right of the concatenation operator `+`. In order for this function to ever terminate you would need to hope that at some point the right side of `+` does not need to be executed anymore. So, we can lazily defer that by making the right side of `+` an `autoclosure`:

 [do the autoclosure thing above]

 Looks a little uglier, but now it's lazy, and the Swift warning went away! However, there's still a recursive call happening that will never terminate, and Swift cannot yet detect this one. In order for `find` to do its work, it needs to call out to `anySatisfy`, but then that immediately calls `find` again. We have to make `anySatisfy` less eager by hiding some of its work inside a closure. Rather than calling out to `find` directly, let's construct a whole new `BitSequence` that calls `find` under the hood:

 [do that above]

 This is now sufficiently lazy for Swift to be able to run this program! It's going to seem incredible, almost magical, but be assured you there are no tricks involved.

 Let's take this for a spin. Let's define a predicate on `BitSequence` that evaluates to `true` if the first 4 even indices of the sequence evaluate to `.one`:

 */

let someSequence = BitSequence.find { s in
  s.atIndex(0) == .one
    && s.atIndex(2) == .one
    && s.atIndex(4) == .one
    && s.atIndex(6) == .one
    && s.atIndex(8) == .one
}

/*:
 This is incredible, but in finite time, and in fact quite quickly, we have searched the *entire* space of `BitSequence` values and constructed an instance that satisfies the predicate we provided. There are a lot of such sequences, but we only wanted to find one of them. Don't believe it? Let's evaluate it to verify:
 */

/*
someSequence.atIndex(0)
someSequence.atIndex(1)
someSequence.atIndex(2)
someSequence.atIndex(3)
someSequence.atIndex(4)
someSequence.atIndex(5)
someSequence.atIndex(6)
someSequence.atIndex(7)
someSequence.atIndex(8)
someSequence.atIndex(9)
someSequence.atIndex(10)
someSequence.atIndex(11)
 */

/*:
 Incredible! We are exhaustively searching an uncountably infinite space in finite time.

 Now, it's also doing a TON of work. If we look at the run counts above we'll see we're calling some of these
 functions many thousands of times.

 Let's comment out the above lines for a moment to give the playground a break.

 [do that]

 We can also ask to see if _every_ bit sequence satisfies some predicate, or if _any_ bit sequence satisfies it. For example:

 */

/*
BitSequence
 .allSatisfy { s in s.atIndex(0) == .zero }
BitSequence
  .allSatisfy { s in s.atIndex(0) == .zero || s.atIndex(1) == .one }
BitSequence
  .allSatisfy { s in s.atIndex(0) == .zero || s.atIndex(0) == .one }

BitSequence
  .anySatisfy { s in s.atIndex(4) == s.atIndex(8) }
*/

/*:
 Wow, that last one had to do a lot of work to confirm that, but it worked! Here we have successfully verified that there is at least one bit sequence whose 4th value is equal to its 8th value.

 We can keep going. Now that we have the `allSatisfy` function at our disposal, we can define equality between functions that have `BitSequence` as their domains:
 */

func == <A: Equatable> (lhs: @escaping (BitSequence) -> A, rhs: @escaping (BitSequence) -> A) -> Bool {
  return BitSequence.allSatisfy { s in lhs(s) == rhs(s) }
}

/*:
 This is able to deterministically, and in finite time, determine when two functions on `BitSequence`'s are equal. This is completely impossible to do with `Int`'s and `String`'s, but here we have done it for `BitSequence`, a type that an infinitude of values more. Let's give it a spin:
*/

let const1: (BitSequence) -> Int = { _ in 1 }
let const2: (BitSequence) -> Int = { _ in 2 }

const1 == const1
const2 == const2
const1 == const2

/*:
 Ok those were pretty simple functions, but the equality worked!

 To come up with some more complicated functions let's introduce a helper that converts a `Bit` value into
 an integer:
 */

extension Bit {
  var toUInt: UInt {
    switch self {
    case .one:  return 1
    case .zero: return 0
    }
  }
}

/*:
 With that helper defined, we can cook up some more complicated looking functions on `BitSequence`'s:
 */

let f: (BitSequence) -> UInt = { s in
  s.atIndex(1).toUInt * s.atIndex(2).toUInt
}

let g: (BitSequence) -> UInt = { s in
  s.atIndex(1).toUInt + s.atIndex(2).toUInt
}

/*:
 These functions just evaluate the bit sequence at a few points and then sum or multiple the results together. Pretty simple.

 Let's try a few weirder ones:
 */

let h: (BitSequence) -> UInt = { s in
  switch (s.atIndex(1), s.atIndex(2)) {
  case (.zero, _), (_, .zero):
    return 0
  case (.one, let other), (let other, .one):
    return other.toUInt
  }
}

let k: (BitSequence) -> UInt = { s in
  (((s.atIndex(2).toUInt + 142) + (s.atIndex(1).toUInt + 766)) % 4) / 2
}

/*:
 Now let's see which of these are equal to each other. Well of course we would expect each function
 to be equal to itself:
 */

f == f
g == g
h == h

/*:
 And it sure seems like `f` and `g` aren't equal:
 */

f == g

/*:
 But what about the other combos:
 */

g == h
f == h
f == k


/*:
 Ok, I don't know about you, but when I first came across these functions I was absolutely blown away. I had a hard time believing the paper I was reading and had to implement it myself. Thankfully we can use Swift to do this, and even better we can use playgrounds to explore.

 Now that we achieved the seemingly impossible we must ask how??? how on earth are we able to do this? what is the grand explanation of it?

 This leads us to the 6th and final section of this talk:

 # Topology

 It turns out that the reason this is possible has been known in mathematics since the mid-to-late 1800s. I'd like to try my best to draw a line from the pure mathematics to what we just witnessed here. I can't show you a rigorous proof of these ideas, but I hope I can at least tell enough of a story to convince you that a rigorous proof exists.

 It begins with a field of mathematics known as topology, which is concerned with the study of topological spaces and their properties. Intuitively a topological space is an object that comes equipped with a notion of when points in the space are near each other. The rigorous definition of topological spaces is far more abstract, and at first glance wouldn't seem connected at all to what we just described, but that's just the nature of pure mathematics.

 Just as in programming we see that functions between types tell us a lot about the types themselves, such is true of functions between topological spaces. However, we can't allow just any function. We want those functions that "preserve" the structure of the space, and that is precisely what a continuous function is. Intuitively, a continuous function f is one such that if x and y are "close" enough, then f(x) and f(y) can be made arbitrary "close", where "close" can be made precise in terms of the topological spaces' structure. Again, the rigorous definition probably seems nothing like what we have just described, but it is indeed the very general definition of continuity, and in fact subsumes the definition of continuity that you may have learned in calculus.

 Now that we know the basic objects we are studying (topological spaces), and the functions that we allow between them (continuous functions), we want to understand their properties. Topological spaces in the large are [varied](todo) and [wild](todo). There's a subset of spaces that have some nice properties called ["compact"](todo) topological spaces. Intuitively these are spaces that have a kind of "finite" quality about them, and for many intents and purposes behave like finite sets. This definition can be made very precise.

 There's another really nice subset of topological spaces known as "meterizable" spaces, in which not only can you loosely say when points are "close" but you can actually measure it with a real number. You can say x and y are distance 2 apart, for exampe.

 Finally, also want to know of some nice subsets of continuous functions, for even though continuous functions seem to be well-behaved in that they preserve closeness of points, there are still some truly [wild](todo) examples of them. There's a subset of continuous functions on meterizable spaces known as ["uniformly continuous"](todo), and they have a lot of nice properties. Intuitively these are functions that not only preserve the closeness of points, but the closeness of the points in the range of the function doesn't depend on the location of the points in the domain. Uniform continuity is a much stronger property.


 Once you know of the objects and functions you are playing with, and some nice subsets of those things that are well-behaved, you want to start proving some theorems. And the most important [theorem](todo) for our seemingly impossible functions is stated as such:

 > If X is a compact metric space and Y is any topological space, then every continuous function f: X -> Y is uniformly continuous.

 This is a very powerful theorem. It states that even though it is far from true that continuous functions are uniformly continuous, if the domain of the function is compact, then both types of functions coincide: continuous implies uniformly continuous.

 Now why on earth am I talking about all of this mathematics nonsense, what could this ever have to do with programming and what we just did here??

 Well, as some of you might know, there is a very deep and far reaching connection between math and computation known as the curry-howard correspondence. It's roots are in constructive mathematics, and says that any proposition in constructive mathematics can be translated into a type, and any proof can be translated into a value of that type. And the correspondence works the other way too.

 Constructive mathematics is kind of weird. It's a lot like the classical mathematics some of you may have learned, except it throws out a fundamental axiom: the law of excluded middle, which says that for any proposition P, either P is true or it is not true. By throwing that out a lot of proofs in classical mathematics are no longer valid in constructive mathematics. In fact, a lot of theorems are no longer true!

 For example, in constructive mathematics it is not true that every real number is either less than zero or greater than zero or equal to zero. It's also not false, it's just not provable.

 Even weirder, every function in constructive mathematics is continuous. You simply cannot construct a non-continuous one.

 And that brings us back to our work above with the `BitSequence`. It turns out that `BitSequence` is a perfectly fine topological space. In fact, it's even compact. It also has a different name in mathematics, it's known as the Cantor set. This set is constructed by taking the unit interval, and removing the middle third. And then removing the middle third of each the intevals left over. And then removing this middle third of all of those intervals. And so on to infinity. The set that is left after doing all of that is called the Cantor set.

 This now means that since every function you can define on a `BitSequence` is continuous, due to how constructive mathematics works, it is also uniformly continuous. And as I said before, uniformly continuous functions can control how close points are in the range as long as they are close in the domain, regardless of where they are in the domain. And using a result known as the Fan theorem from Brouwer one can show if two such functions are equal on a finite set of a particular size, then they will be equal everywhere. And that is exactly what is happening here.

 */
