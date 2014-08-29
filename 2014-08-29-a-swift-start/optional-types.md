# A Swift Start

## Brandon Williams

![filtered](http://swift-lang.pl/wp-content/uploads/2014/06/swift.jpeg)

---

# Optional Types

^ Might seem kinda mundane, but we are going to see a large cross section of interesting swift concepts along the way.

---

#### Optional Types
# [fit] You could have created optional types

---

#### Optional Types
#### You could have created optional types
# [fit] You would have created optional types

---

#### Optional Types
#### You could have created optional types
#### You would have created optional types
# [fit] Let's re-create optional types!

---

# [fit] Overview of Optional Types

* Given a type "`A`", it's optional type is "`A?`"
* A value of type `A?` holds something of type `A` or nothing, aka `nil`
* e.g.
  * `Int?`
  * `String?`
  * `[Int?]`
  * `[Int]?`

^ * A? is a WHOLE NEW data type

^ * It can be used on ANY data type, including your own

---

# Why?

1. Swift is a strongly typed language
> All values need an explicit type

1. It can be useful to have the absence of a value
> But in a strongly typed language, how does one do that?

1. Objective-C was pretty close to this with `nil`
> But still possibly to smudge types

^ * swift enforces explicit types

^ * answer: create a new data type that either holds a value, or holds nothing

^ * objc you have to do the work to make sure you keep your types explicit.

---

# [fit] How to use?

## *(live coding in playground)*

---

# How to use?

```swift
let colorsByName: [String: Int] = [
  "red": 0xff0000,
]

let redColor: Int? = colorsByName["red"]

if let redColor = redColor {
  redColor / 2
} else {
  redColor == nil
}
```

---

# Real world example

Functions need a well-defined way to accept/return values that might possibly not exist.

```swift
func findInt(xs: [Int], x: Int) -> Int? {
  for (idx, element) in enumerate(xs) {
    if element == x { return idx }
  }
  return nil
}

find([1, 2, 3, 4], 3) // => 2
find([1, 2, 3, 4], 5) // => nil
```

^ back in the day we might have used -1 or NSNotFound

---

# Let's build Optional types

---

# New data type that either has a value, or doesn't.

---

# Enums are perfect for this

^
anytime a data type is the OR composite of two data types you have an enum. anytime a data type is the AND composite of two data types you have a struct. Algebraic Data Types

---

# Enums are perfect for this

```swift
enum Maybe <A> {
  case Just(A)
  case Nothing
}
```

---

# Enums are perfect for this

```swift
enum Maybe <A> {
  case Just(A)
  case Nothing
}

let x = Maybe<Int>.Just(4)
let y = Maybe<String>.Nothing
```

---

# [fit] How to use?

## *(live coding in playground)*

---

# How to use?

```swift
enum Maybe <A> {
  case Just(A)
  case Nothing

  func description () -> String {
    switch self {
    case let .Just(value): return "{Just \(value)}"
    case .Nothing: return "{Nothing}"
    }
  }
}

let x = Maybe<Int>.Just(5)

switch x {
case let .Just(x):
  x * x
case .Nothing:
  "nothing to do"
}
```

---

# Compare with Swift syntactic sugar

```swift
let x: Int? = 2
let y = Maybe<Int>.Just(2)

if let x = x {
  // x is now an honest Int
} else {
  // handle no value
}

switch y {
case let .Just(y):
  // y is now an honest Int
case .Nothing:
  // handle no value
}
```

---

# Function composition

^ * first part was intro. got to see enums, generics, if-lets, switches, case-lets, ...

^ * next part is a little more advanced, but super interesting

^ * in order to wield these things correctly we have to use this stuff

---

# Function composition

```swift
func h: A -> B { /* body */ }
func g: B -> C { /* body */ }
func f: C -> D { /* body */ }

f(g(h(x)))
```

^ the point here being function composition is very important and something to be preserved.

---

Imagine there are methods on arrays of `Int`'s:

```swift
square([1, 2, 3]) // => [1, 4, 9]
addOne([1, 2, 3]) // => [2, 3, 4]
sort([3, 1, 2])   // => [1, 2, 3]
```

Then we can do:

```swift
sort(addOne(square([3, 1, 5, -1])))
// => [2, 2, 10, 26]
```

^ * the point here being function composition is very important and something we should strive to preserve.

^ * funcs are kinda the most basic, atomic unit of code re-usability

---

# `Maybe` values kinda mess up function composition

---

```swift
func squareRoot (x: Float) -> Maybe<Float> {
  if x >= 0 {
    return .Just(sqrtf(x))
  }
  return .Nothing
}

func invert (x: Float) -> Maybe<Float> {
  if x != 0.0 {
    return .Just(1.0 / x)
  }
  return .Nothing
}

invert(squareRoot(2.0)) // won't compile!
```

^ * Swift doesn't know how to feed a `Maybe<Float>` into `invert`.

^ * But there's an obvious way to compose these. If squareRoot returns nothing, then the composition should return nothing.

---

# [fit] Something to fix function composition

---

# [fit] Something to fix function composition

```swift
func >>= <A, B> (x: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B>
```

---

# [fit] Something to fix function composition

```swift
func >>= <A, B> (x: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B>
```

* This operator is called `bind`.
* Think of it as trying to stuff the value on the left into the function on the right.

### *(live coding in playground)*

---

# [fit] Something to fix function composition

```swift
func >>= <A, B> (x: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B> {
  switch x {
  case let .Just(x):
    return f(x)
  case .Nothing:
    return .Nothing
  }
}

let y = squareRoot(2.0)
  >>= { .Just($0 - 1.0) }
  >>= { invert($0) }
  >>= { squareRoot($0) }

# => {Just 1.55377399921417}
```

^ this isn't necessarily a good example of using bind. it's more to show how it works and why it's needed.

---

# A peak into Swift's `Optional`

```swift
enum Optional <T> {
  case None
  case Some(T)
}
```

---

# Conclusion

* We've built our own version of `Optional`

* It can do everything the native `Optional` type can do.

* We don't have Swift's syntactic sugar...

* ...but we created functions to aid in composition
  * those functions could (and should) be defined for Swift's optionals.

---

# For the objc peeps

* The fact that you can pass messages to `nil` is *nearly* `bind`

^ why's it not bind? cause you can smudge the types in objc

---

# For the Ruby peeps

* Ruby's `try` is *nearly* `bind`.
  * `object.try(:method)` will call `method` on `object`, unless `object` is `nil`, in which case it returns `nil`.

* Important note: this `try` has nothing to do with `try/catch`.

^ why's it not bind? cause it will also return nil if object doesn't respond to method
