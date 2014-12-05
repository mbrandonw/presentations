# ADT's

---

# Algebraic Data Types

---

#### *(in Swift, in particular)*

---

# Algebraic Data Types

* Using concepts from algebra to build new data types from existing data types.

* Initially the algebra appears to only be a formality, i.e. a beacon to guide our construction of types.

* But there is a well-defined, rigorous connection between algebra and data types.

---

# Overview of Algebra

* Sum
$$a + b$$, e.g. $$3 + 4 = 7$$
* Product
$$a * b$$, e.g. $$3 * 4 = 12$$
* Exponential
$$a ^ b$$, e.g. $$3 ^ 4 = 81$$

---

# Take this up a level

Replace numbers with sets and see if we can mimic algebra with their cardinality.

---

# Take this up a level

If $$A$$ and $$B$$ are disjoint sets, then

* Union (kinda like sum):
$$|A ∪ B| = |A| + |B|$$
* Product (kinda like multiplication):
$$|A × B| = |A| * |B|$$
* Functions (kinda like exponentiatino):
$$|Func(B, A)| = |A|^{|B|} \ \ \ \ (= |A^B|)$$

^ If you know anything about countability of sets, this exponential object is precisely the way you construct larger infinities.

---

# Back to data types

* A Boolean data type has two possible values: True or False.

```swift
enum Boolean {
  case True
  case False
}
```

* We can think of `Boolean` as a set with two elements: `True`, `False`.

* This is the type-theoretic way of representing the number 2.

---

# Back to data types

* How to represent the number 1?

```swift
enum One {
  case Unit
}
```

* `One` is a type with only one possible value.

* Swift already gives us this, it's the empty tuple:

```swift
let x = ()
```

---

# Back to data types

* How to represent zero?
* This would be a data type which can never be instatiated!

```swift
enum Zero {
}
```

---

# Back to data types

What is the sum of data types?

Sums are represented by enums:

```swift
enum Sum <A, B> {
  case lhs(A)
  case rhs(B)
}
```

We could abstractly write `A + B` to denote this.

---

# Playground

---

# Back to data types

What is the product of data types?

Products are represented by structs:

```swift
struct Product <A, B> {
  let lhs: A
  let rhs: B
}
```

We could abstractly write `A * B` to denote this

---

# Playground

---

# Back to data types

What is the exponentiation of data types?

Exponentiations are just functions again, but this is harder to do in Swift.

```swift
struct Exponentiation <A, B> {
  let f: B -> A
}
```

We could abstractly write `A^B` to denote this.

---

# [fit] All algebraic laws apply to data types:

```swift
enum Sample1 {
  case LHS(Zero)
  case RHS(Int)
}
// = Zero + Int = Int

struct Sample2 {
  let lhs: One
  let rhs: Int
}
// = One * Int = Int

struct Sample3 {
  let lhs: Zero
  let rhs: Int
}
// = Zero * Int = Zero
```

---

# [fit] All algebraic laws apply to data types:

Distribution:

```swift
struct Sample {
  let x: Sum<Bool, One>
  let y: Sum<Int, Float>
}

// = (Bool + One) * (Int + Float)
// = Bool*Int + One*Int + Bool*Float + One*Float
// = Bool*Int + Int + Bool*Float + Float
```

---

# Optional types

```swift
enum Maybe <A> {
  case Nothing
  case Just(A)
}

// Maybe<A> = 1 + A

struct Data {
  let x: Maybe<Int>
  let y: Maybe<Bool>
}

// = (1 + Int) * (1 + Bool)
// = 1 + Int + Bool + Int*Bool
```

---

# Lists

---

# Lists

Naive stab at this...

```swift
enum EmptyList <A> {
  case Nil
}
// = 1

enum List1 <A> {
  case Nil
  case LengthOne(A)
}
// 1 + A

enum List2 <A> {
  case Nil
  case LengthOne(A)
  case LengthTwo(A, A)
}
// 1 + A + A*A
```

---

# Lists

The real data type:

```swift
enum List <A> {
  case Nil
  case Cons(A, List<A>)
}

// List<A> = 1 + A * List<A>
```

---

# Playground

---

# Lists

$$List\langle A \rangle = 1 + A * List \langle A \rangle$$

$$List \langle A \rangle - A * List\langle A \rangle = 1$$

$$List \langle A \rangle * (1 - A) = 1$$

$$List \langle A \rangle = \frac{1}{1 - A}$$

---

# ???
# $$List \langle A \rangle = \frac{1}{1 - A}$$

---

# Lists

Maybe you remember this from calculus:

$$\frac{1}{1 - A} = 1 + A + A^2 + A^3 + \cdots$$

---

# Lists

$$\frac{1}{1 - A} = 1 + A + A^2 + A^3 + \cdots$$

```swift
enum List <A> {
  case Nil
  case LengthOne(A)
  case LengthTwo(A, A)
  case LengthThree(A, A, A)
  case LengthFour(A, A, A, A)
  ...
}
```

---

# Trees

---

# Trees

```swift
enum Tree <A> {
  case Empty
  case Node(Tree<A>, A, Tree<A>)
}

// Tree<A> = 1 + A * Tree<A>^2
```

---

# Playground

---

# Trees

$$0 = 1 - Tree\langle A \rangle + A*Tree\langle A \rangle^2$$

$$Tree\langle A \rangle = \frac{1 - \sqrt{1 - 4A}}{2A}$$

---

# Trees

$$Tree\langle A \rangle = 1 + A + 2A^2 + 5A^3 + 14A^4 + \cdots$$

---

# More craziness

```swift
typealias T = Tree<One>;
```

$$0 = 1 - T + T^2$$

$$T = \frac{1 - \sqrt{-3}}{2}$$

$$T^6 = 1$$

$$T^7 = T$$

---

# [fit] Seven trees in one

# $$T^7 = T$$

---

# Playground
