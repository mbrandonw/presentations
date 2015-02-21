# [fit] λ

---

# λ
# Transducers

---

# Using transducers as a tool to understand functional programming

---

# A few tenets of FP that we’ll explore

* Function composition
* Immutability
* Statelessness


---

# Function composition

* Swift methods are not composable
* we should do everything to promote composition
* curried functions are highly composable

---

# Playground!

---

```swift
infix operator |> {associativity left}
func |> <A, B> (x: A, f: A -> B) -> B {
  return f(x)
}
func |> <A, B, C> (f: A -> B, g: B -> C) -> (A -> C) {
  return { g(f($0)) }
}
func map <A, B> (f: A -> B) -> ([A] -> [B]) {
  return { map($0, f) }
}
func filter <A> (p: A -> Bool) -> ([A] -> [A]) {
  return { filter($0, p) }
}

let xs = Array(1...100)
xs |> map(square) |> map(incr) |> filter(isPrime)
```

---

```swift
xs |> map(square) |> map(incr) |> filter(isPrime)
```

The good:

* very readable
* modeled on flow of data
* expresses what we want to compute, not how we want to compute it.

---

```swift
xs |> map(square) |> map(incr) |> filter(isPrime)
```

The bad:

* this code traverses the `xs` 3 times!
* 3 copies of the array could will be created.

---

```swift
xs |> map(square |> incr) |> filter(isPrime)
```

* Even this still traverses twice
* Due to the signatures of `map` and `filter` we can’t compose any further

---

# Transducers

* Transducers fix the composability problems!
* Makes array operations highly composable
* Reduces # of traversals on arrays

---

# Universality of `reduce` (aka `fold`)

* It all begins with a beautiful idea.
* In a very precise sense, `reduce` is “universal” among all functions that operate on arrays.
* This means every operation you want to do on arrays can be rewritten as a `reduce`!

---

# TO THE PLAYGROUND!

---

# Universality of `reduce`

* Using this idea we can lift all of our adhoc `maps`, `filters`, etc... into the world of `reduce`

* and then maybe there’s hope that we have recovered composability again!

---

Some terms:

* A **reducer** on a type `A` is a function of the form `(C, A) -> C` for some type `C`.

* A **transducer** is a function that takes a reducer on `A` and returns a reducer on `B`:

>> `((C, A) -> C) -> ((C, B) -> C)`

---

# PLAYGROUND!

---

# Specific example

```swift
func squaringTransducer <C> (reducer: (C, Int) -> C) -> ((C, Int) -> C) {
  return { accum, x in
    return reducer(accum, x * x)
  }
}

reduce(xs, 0, +)
reduce(xs, 0, squaringTransducer(+))
```

---

# The `mapping` transducer

* This generalizes `squaringTransducer`
* It lifts any function `A -> B` to a transducer from `B` to `A`.

```swift
func mapping <A, B, C> (f: A -> B) -> (((C, B) -> C) -> ((C, A) -> C)) {
  return { reducer in
    return { accum, a in
      return reducer(accum, f(a))
    }
  }
}
```

---

# The `filtering` transducer

```swift
func filtering <A, C> (p: A -> Bool) -> ((C, A) -> C) -> (C, A) -> C {
  return { reducer in
    return { accum, x in
      return p(x) ? reducer(accum, x) : accum
    }
  }
}
```

---

# How to use?

* Well, we need a reducer to feed into these transducers.
* What’s a common reducer on arrays?
* ... hmmm ...
* `append`!

```swift
func append <A> (xs: [A], x: A) -> [A] {
  return xs + [x]
}
```

---

# TO THE PLAYGROUND!

---

# Punchline

```swift
// All primes of the form n^2+1 for 1 <= n <= 100
reduce(xs, [], append
  |> filtering(isPrime)
  |> mapping(incr)
  |> mapping(square)
)

// Sum of all those ^ primes
reduce(xs, 0, (+)
  |> filtering(isPrime)
  |> mapping(incr)
  |> mapping(square)
)
```

---

# What’s missing?

* It would be nice to have a proper `Transducer<A, B>` type so that we could abstractly manipulate them.
* For example, we could define combinators like
`Transducer<A, B> |> Transducer<B, C> : Transducer<A, C>`
* Swift’s type system isn’t powerful enough to do this
* We can get close, but we need “higher-kinded types” to get all the way.

---

# [fit] λ

---

# Some announcements

---

# We’re going to Ramona’s after this:

![inline](/Users/brandon/Dropbox/Screenshots/Screenshot 2014-12-04 12.16.57.png)

---

# Thanks to Chris Eidhof for helping me organize

![inline](/Users/brandon/Dropbox/Screenshots/Screenshot 2014-12-04 12.19.28.png)

---

# Kickstarter is hiring

![inline](/Users/brandon/Dropbox/Desktop/k.png)

### Get at me: [brandon@kickstarter.com](brandon@kickstarter.com)
