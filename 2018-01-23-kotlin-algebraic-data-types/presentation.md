build-lists: true

# [fit] Algebraic Data Types

^ Hello! The title of this talk is Algebraic Data Types.

---

# Hello! 👋

## Brandon Williams

@mbrandonw

mbw234@gmail.com

^ But first things first, a little about myself. My name is brandon, i worked at Kickstarter for a long time doing iOS and Android, and for awhile even worked with Lisa.

^ now i haven't done a toooon of kotlin, but i've done my fair share of swift, and have a general interest in functional programming. and luckily what i'm going to be talking about today applies to nearly every programming language ever made. it's a very universal idea. i could just as easily give this talk in swift, haskell, elm, purescript, ocaml, typescript, ...

---

# [fit] Algebraic Data Types

^ We are going to be talking about Algebraic Data Types. Turns out, there is a very nice correspondence between types in a programming language and algebra. Understanding this connection can help you model data in more precise ways, allow you to transform data into ways that are hard to see without knowing this connection, and even remove invalid states from your data so that supposedly impossible values are provably impossible by the compiler. There's a lot to unpack there so let's start with something simple.

---

# `Pair<A, B>`

^ Doesn't get much simpler than a pair. `Pair` is a type that allows you to hold values of two other types.

---

# `Pair<A, B>`

```kotlin
data class Pair<out A, out B>(
  val first: A,
  val second: B
)
```

^ it's a simple data class that is generic over `A` and `B`, has two fields named `first` and `second`. it's important to note that we are using data classes and not a regular class. data classes are perfect for just being dumb bags of data with no logic or state or mutation bundled up into it.

---

# `Pair<Boolean, Boolean>`

```kotlin
Pair<Boolean, Boolean>(true, false)
```

^ and then we can create a pair like so. here we have a pair with a boolean value in the first and second field.

---

# `Pair<Boolean, Boolean>`

```kotlin
Pair(true, true)
Pair(true, false)
Pair(false, true)
Pair(false, false)
```

^ we can even enumerate all the possible values in `Pair<Boolean, Boolean>`. this is all of em! this type holds no more values.

^ now, there's something interesting happening here, but it's hard to see because `Boolean` only contains two values. let's try this:

---

# `Pair<Three, Boolean>`

```kotlin
enum class Three { ONE, TWO, THREE }

Pair(Three.ONE, true)
Pair(Three.ONE, false)
Pair(Three.TWO, true)
Pair(Three.TWO, false)
Pair(Three.THREE, true)
Pair(Three.THREE, false)
```

^ here we have defined an enum that holds exactly three values, and then we have enumerated all of the values of `Pair<Three, Boolean>`. The `Three` type has 3 values, the `Boolean` type has 2 values, but the `Pair` of them has 6 values!

---

# `Pair<Three, Boolean>`

# 3 * 2 = 6

---

# `Unit`

```kotlin
val x: Unit = Unit
```

^ there's also this weird value in kotlin called `Unit`. it is the type that contains only one value, and so it doesn't really matter what that value is. in kotlin the name `Unit` with an uppercase `U` serves as both the type and the value so you can use them interchangebly.

---

# `Pair<Unit, Boolean>``

```kotlin
Pair(Unit, false)
Pair(Unit, true)
```

^ What happens when we pair `Unit` with `Boolean`? There are only two possible values.

---

# `Pair<Unit, Unit>``

```kotlin
Pair(Unit, Unit)
```

^ And if we pair `Unit` with `Unit` there's only one possible value!

---

# `Nothing`

```kotlin
public class Nothing private constructor()

val x: Nothing
```

^ there's another weird value in kotlin called `Nothing`. it's the "uninhabited" type, the type with no values. you can never instantiate this type! what happens when we try to pair it?

---

# `Pair<Nothing, Boolean>`

```kotlin
Pair(???, true)
Pair(???, false)
```

^ we can't create a pair value if we are pairing a `Nothing`, because `Nothing` has no values! there's nothing we can put into the `???` spots. so in fact, `Pair<Nothing, Boolean>` is also uninhabited, and has no values!

---

# What is going on here?

^ so what is going on here? if lift up a level of abstraction, and wipe away any domain knowledge about the types, and instead only care about the number of values inside the types, we can see a correspondence between the pair type, and multiplication.

---

Kotlin World|Algebra World
---|---
`Nothing` | `0`
`Unit` | `1`
`Boolean` | `2`
`Three` | `3`
`Pair<A, B>` | `A * B`

^ we see that there is a correspondence between the number of values in a type, and that forming `Pairs` is like multiplying types together. Here `Unit` corresponds to `1`, .....

^ Now we have completely erased the meanings of the type in the algebra world, but that's ok. we want to operator in a higher abstraction in the algebra world that is free from the baggage of names and semantic meanings, so that we are unencumbered to explore what algebra can give us. then, once we build up some results and intuition in the algebra world, we'll try to lower back down to the kotlin world and see what kind of new stuff we can do.

---

# Consequence of correspondence

Kotlin World|Algebra World
---|---
`Pair<Unit, A> = A` | `1 * A = A`
`Pair<A, Unit> = A` | `A * 1 = A`
`Pair<Nothing, A> = Nothing` | `0 * A = 0`
`Pair<A, Nothing> = Nothing` | `A * 0 = 0`

^ and in fact, we can already clearly see one easy consequence of this correspondence. if you pair Unit with any type `A` you havent really changed anything. it's just like multiplying `A` by `1`, which also does nothing!

^ and on the other hand pairing `Nothing` with anything has the effect of turning the pair also into a `Nothing`, because multiplying anything by `0` results in `0`.

---

## If `Pair` corresponds to `*`...

## ...what does `+` correspond to?

---

# Sealed classes!

^ These are kotlin's answer to having types that can be exactly one of a particular set of types, but nothing else. "you have something of type A OR type B OR type C ..."

^ we are going to create a first class type to represent the choice of having either an `A` or `B`. it's kind of the dual to our `Pair` data class.

---

# `Either<A, B>`

```kotlin
sealed class Either<out L, out R> {
  data class Left<out L>(val left: L) : Either<L, Nothing>()
  data class Right<out R>(val right: R) : Either<Nothing, R>()
}
```

^ we will call this type `Either`!

^ here we have defined a sealed class that can't be instantiated. but it has two inner classes that you can instantiate, and they are called left and right.

^ a value of this type holds either a value of type `A` or type `B`, whereas a pair held a value of type `A` and type `B`.

^ now before we go construct some values of this type, we gotta take a moment and reflect that there's a lot of stuff here. we are trying to express a very simple idea, and this is how kotlin forces us to write this type. it's pretty unfortunate.

---

# Swift `Either`

```swift
enum Either<A, B> {
  case left(A)
  case right(B)
}
```

^ over in the swift world we can write our `Either` type like this. it's called an enum, and it has a case for each possible value the type can take.

^ but, if you wanna see what it looks like when a language really embraces this concept, look no further than haskell:

---

# Haskel `Either`

```haskell
data Either a b = Left a | Right b
```

^ that's kinda wonderful!

---

# `Either<Boolean, Boolean>`

```kotlin
Either.Left(true)
Either.Left(false)
Either.Right(true)
Either.Right(false)
```

^ ok here is how we can construct some values of an `Either<Boolean, Boolean>`. there's four possibilities

---

# `Either<Three, Boolean>`

```kotlin
Either.Left(Three.ONE)
Either.Left(Three.TWO)
Either.Left(Three.THREE)
Either.Right(true)
Either.Right(false)
```

^ and here we have constructed every value of `Either<Three, Boolean>`. there are 5 values.

---

# `Either<Nothing, Boolean>`

```kotlin
Either.Left(true)
Either.Left(false)
```

^ here we have constructed the only two values of `Either<Nothing, Boolean>`. notice that we didnt have the same problem that `Pair` did because the `Nothing` went into the left case, and we can just ignore it.

---

# `Either<Unit, Boolean>`

```kotlin
Either.Left(Unit)
Either.Right(true)
Either.Right(false)
```

^ and here we have constructed every value of `Either<Unit, Boolean>`, and there are 3 such values.

^ putting `Unit` in for one of the generic params of `Either` is particularly interesting and a lil more should be said about it.

---

# `Either<Unit, A>`

^ this type says that we either have a value `A` or we have the unit value. and the unit value doesn't really matter or have any intrinsic importance. it's just a placeholder for the single value sitting inside `Unit`.

^ really, what we have here is our own discovery or reinvention of something that kotlin gives first class support for:

---

# `A?`

^ nullable types! by annotating `A` with this question mark, kotlin is creating a whole new type that contains all the values from `A`, but with one additional value: `null`!

---

# `A? = Either<Unit, A>`

^ so it's not a stretch to say that abstractly, these two types are equal in some sense

---

Kotlin World|Algebra World
---|---
`Nothing` | `0`
`Unit` | `1`
`Boolean` | `2`
`Three` | `3`
`Pair<A, B>` | `A * B`
`Either<A, B>` | `A + B`

^ so now we can add `Either` to our kotlin-algebra dictionary because it corresponds to addition over in the algebra world.

---

# Consequence of correspondence

Kotlin World|Algebra World
---|---
`Pair<Unit, A> = A` | `1 * A = A`
`Pair<Nothing, A> = Nothing` | `0 * A = 0`
`Either<Nothing, A> = A` | `0 + A = A`
`Either<A, Nothing> = A` | `A + 0 = A`
`A?` | `A + 1`

^ and also here are all the consequences we've seen so far.

---

# Algebra of types

* `Boolean * Boolean`
* `Boolean + Boolean`
* `Int * String`
* `Int + String`
* `[Int] + [String]`

^ we have now built up enough intuition that pair corresponds to multiplication and either corresponds to addition, that we can just go all into performing algebra of types.

^ we should no longer gasp at taking the product of two boolean types for that just means a pair of two booleans.

^ nor at taking the sum of two boolean types, because that just means we either have a boolean on the left or a boolean on the right.

^ but we should also be comfortable performing algebraic manipulations with even more exotic types

^ but why would we do this?!

---

# Case study

```kotlin
class Api {
  fun get(path: String,
          completion: (data: Data?, error: Error?) -> Unit) {
    // ...
  }
}
```

^ here's a real piece of code we might right. we have some kind of API class that does network requests or something. it has a `get` function that takes a path to get, and then a completion handler that will be invoked with some optional data that we loaded from the network, and an optional error in case there's an error.

---

# Case study

```kotlin
api.get("/user") { data, error in
  if (data != null) {
    // do something with non-null data
  } else if (error != null) {
    // do something with non-null error
  }
}
```

^ and here's how we might use it. we'd first check if `data` is not null, and if its not then we know the request was successful and so we can do something with that data.

^ if the data is `null`, the apparently something must have gone wrong. but, we have an optional error, so we need to first check if its `null` before we can use it.

^ so what's wrong with this?

---

# Case study

```kotlin
api.get("/user") { data, error in
  if (data != null) {
    // do something with non-null data
  } else if (error != null) {
    // do something with non-null error
  }

  // What happens if both data and error are null?
  // What does it mean if both are NOT null?!
}
```

^ well, what happens if both data and error are null?

^ What does it mean if both are NOT null?!

---

# Case study
### Use algebra to unravel the types

* `(Data?) * (Error?)`
* `(Data + 1) * (Error + 1)`
* `Data * Error + Data * 1 + 1 * Error + 1 * 1`
* `Data * Error + Data + Error + 1`

^ this is a classic case study of reaching for the product of types because we are so used to them, when really the sum of types might have been more appropriate.

^ to see this, let's do a little bit of algebraic manipulation to see what went wrong

---

# Case study
### Use algebra to unravel the types

```
Data * Error + Data + Error + 1
```

^ this shows exactly what is wrong. there are two whole summands here that dont many any sense. the `Data * Error` and `1`. we want to completely exclude those values from the possible values that can come back from the API. to do that, we use either!

---

# Case study

```kotlin
class Api {
  fun get(path: String,
          completion: Either<Error, Data> -> Unit) {
    // ...
  }
}
```

^ this should have been our API from the beginning. the completion handler will be invoked with either an error or data. you are guaranteed, BY THE COMPILER, that you will get precisely one of these values.

---

# Case study

```kotlin
api.get("/user") { errorOrData in
  when(errorOrData) {
    is Either.Left -> ...
    is Either.Right -> ...
  }
}
```

^ and then you can use it like this. no need to do any `if null` matching, you can just `when` pattern match on the sealed class.

---

# A few more examples

^ ok, i better start wrapping up. but there are two more examples i want to cover, but i'm going to go fast so it's gonna be a real whirlwind.

---

# [fit] Functions correspond to exponents

Kotlin World|Algebra World
---|---
`Function<A, B>` | `B^A`

^ it turns out that functions from `(A) -> B` correspond to exponentiation in algebra, `B^A`. to see this i would recommend writing out all the different functions between a few small types, like say `Boolean` to `Unit`, `Unit` to `Boolean`, and maybe even `Boolean` to the `Three` type.

---

# [fit] Recursion correspond to infinite series

Kotlin World|Algebra World
---|---
`List<A>` | `1 + A + A*A + A*A*A + A*A*A*A + A*A*A*A*A + ...`

^ also turns out that recursion in data types corresponds to infinite series, aka infinite sums of products.

^ there's a way of looking at `List` as a recursive data type. it's essentially either empty, or it's a value with the rest of its values in the tail, and that tail is a list of itself. hence its recursive.

^ this recursion corresponds to taking infinitely many sums of products! we can even kinda read it off. here it's saying that list is either `1` (the empty list), or a single `A` value, or two `A` values, or three `A` values, and so on. that's precisely what a list is!

---

# [fit] Zippers correspond to derivates

Kotlin World|Algebra World
---|---
`(List<A>, List<A>)` | `d/dA (1 + A + A*A + ...)`

^ also zippers correspond to derivatives of data types! a zipper is a functional data structure that allows you to traverse over a structure while updating its contents efficiently. the zipper of a list is just two lists: the portion of the list you have already processed, and the portion of the list you have left to process.

^ there is a way of proving that this corresponds directly to the derivative of the infinite series that defines list.

---

Kotlin World|Algebra World
---|---
`Nothing` | `0`
`Unit` | `1`
`Pair<A, B>` | `A * B`
`Either<A, B>` | `A + B`
`Function<A, B>` | `B^A`
`List<A>` | `1 + A + A*A + A*A*A + A*A*A*A + A*A*A*A*A + ...`
`(List<A>, List<A>)` | `d/dA (1 + A + A*A + ...)`

^ oh boy, that was a lil deep, but it's really amazing! there's even more to cover, but i gotta stop somewhere. i'll just end by putting back up our kotlin-to-algebra correspondence, and i've even added one more row.

^ Thanks!
