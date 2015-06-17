# Proof in Functions

^ We're gonna do a lot of crazy stuff

---

# Brandon Williams

* iOS at **Kickstarter**
* @mbrandonw
* brandon@kickstarter.com

---

# Brandon Williams

* Went to grad school for math
* Did the weird kind of math

^ never find out about all the cool CS stuff until towards the end of grad school

---

# Generics Primer

* Generics allow us to write functions that take and return values from a wide class of types.
* Typical example is the `sort` function.

---

# Sorting

```swift
func sort (xs: [Int]) -> [Int] {
  // implementation
}
```

---

# Sorting

```swift
func sort (xs: [Int]) -> [Int] {
  // implementation
}

func sort (xs: [String]) -> [String] {
  // implementation
}
```

---

# Sorting

```swift
func sort (xs: [Int]) -> [Int] {
  // implementation
}

func sort (xs: [String]) -> [String] {
  // implementation
}

func sort (xs: [User]) -> [User] {
  // implementation
}
```

^ at this point you have to step back and say there is a better way. generics allow us to write this for a more general situation.

---

# Sorting

```swift
func sort <A: Comparable> (xs: [A]) -> [A] {
  // implementation
}

sort([4, 2, 7, 1, 8])
sort(["foo", "bar", "qux", "baz"])
sort([User("sally"), User("john")])
```

---

# `map`, `filter`, ...

```swift
func map <A, B> (xs: [A], f: A -> B) -> [B]

func filter <A> (xs: [A], p: A -> Bool) -> [A]
```

---

# Generics Primer

Generics also allow new types to be generic over any other type:

```swift
struct Pair <A, B> {
  let fst: A
  let snd: B
}

enum Optional <T> {
  case None
  case Some(T)
}
```

---

# Playground coding

---

# What is going on?

* Why do some functions have a unique implementation?
* Why do some functions have *no* implementation?

---

# Propositional Logic

---

# Propositional Logic

* Made of propositions: $$P, Q, R, \ldots$$

---

# Propositional Logic

* Made of propositions: $$P, Q, R, \ldots$$
* Propositions can be true ($$\top$$) or false ($$\bot$$)

---

# Propositional Logic

* Made of propositions: $$P, Q, R, \ldots$$
* Propositions can be true ($$\top$$) or false ($$\bot$$)
* Propositions can be combined to form compound statements

---

# Propositional Logic

* Made of propositions: $$P, Q, R, \ldots$$
* Propositions can be true ($$\top$$) or false ($$\bot$$)
* Propositions can be combined to form compound statements
  * $$P \land Q$$ = “$$P$$ and $$Q$$”
  * $$P \lor Q$$ = “$$P$$ or $$Q$$”
  * $$\lnot P$$ = “not $$P$$”

---

# Propositional Logic

* Implication (if/then) is also an operator

---

# Propositional Logic

* Implication (if/then) is also an operator
* $$P \Rightarrow Q$$: “if $$P$$ is true, then $$Q$$ is true”

---

# Propositional Logic

* Implication (if/then) is also an operator
* $$P \Rightarrow Q$$: “if $$P$$ is true, then $$Q$$ is true”
  * $$P$$ = $$n$$ is even
  * $$Q$$ = $$2*n$$ is even
  * $$P \Rightarrow Q$$

---

# Propositional Logic

Examples of compound statements:

* $$P \Rightarrow P$$

---

# Propositional Logic

Examples of compound statements:

* $$P \Rightarrow P$$
* $$P \land Q \Rightarrow P$$

---

# Propositional Logic

Examples of compound statements:

* $$P \Rightarrow P$$
* $$P \land Q \Rightarrow P$$
* $$P \Rightarrow P \lor Q$$

---

# Propositional Logic

Examples of compound statements:

* $$P \Rightarrow P$$
* $$P \land Q \Rightarrow P$$
* $$P \Rightarrow P \lor Q$$
* $$((P \Rightarrow Q) \land (Q \Rightarrow R)) \Rightarrow (P \Rightarrow R)$$

---

# Similar Shapes

* $$P \Rightarrow P$$

* `(x: A) -> A`

---

# Similar Shapes

* $$P \land Q \Rightarrow P$$

* `(x: A, y: B) -> A`

---

# Similar Shapes

* $$P \Rightarrow P \lor Q$$

* `(x: A) -> Or<A, B>`

---

# Similar Shapes

* $$((P \Rightarrow Q) \land (Q \Rightarrow R)) \Rightarrow (P \Rightarrow R)$$

* `(g: A -> B, h: B -> C) -> A -> C`

^ we replace propositions with types and implication with function arrows

---

# Curry-Howard Correspondence

* One-to-one correspondence between functions and theorems
* The act of implementing a function proves a theorem

^ first observed by the mathematician Haskell Curry in 1934 and later finished by logician William Howard in 1969.

---

# Clarity

^ the curry howard correspondence finally gives us clarity on what is going on. it explains why some functions could be implemented and why others could not.

---

# Clarity

* Why couldn’t `f: A -> B` be implemented?

---

# Clarity

* Why couldn’t `f: A -> B` be implemented?
* Because then the proposition $$P \Rightarrow Q$$ would be true

---

# Clarity

* Why couldn’t `f: A -> B` be implemented?
* Because then the proposition $$P \Rightarrow Q$$ would be true
* That means any proposition implies any other proposition

---

# De Morgan's Law

$$
\lnot (P \lor Q) \Longleftrightarrow \lnot P \land \lnot Q
$$

^ We can prove more interesting theorems in Swift. Though this is pretty much the most interesting.

^ This law can be useful in practice for simplifying gnarly if conditionals

---

# The Atomic Objects

* How to represent the pieces in Swift?
* $$\lnot, P, Q, \lor, \Leftrightarrow, \land$$

---

# How to model $$\lnot P$$

* The type that represents $$\bot$$

```swift
enum False {
}
```

^ first we model false

---

# How to model $$\lnot P$$

* The type that represents $$\bot$$

```swift
enum False {
}
```

* The only proposition $$P$$ for which $$P \Rightarrow \bot$$ is $$P = \bot$$.

---

# How to model $$\lnot P$$

* The type that represents $$\bot$$

```swift
enum False {
}
```

* The only proposition $$P$$ for which $$P \Rightarrow \bot$$ is $$P = \bot$$.
* Therefore we can model $$\lnot P$$ by:

```swift
struct Not <A> {
  let not: A -> False
}
```

---

# How to model $$\land$$

* This is really just tuples `(A, B)`
* But let’s be more explicit:

```swift
struct And <A, B> {
  let left: A
  let right: B
  init (_ left: A, _ right: B) {
    self.left = left
    self.right = right
  }
}
```

^ Initializer is an implementation detail

---

# Playground coding

---

# De Morgan's Law

We’ve now given a computer proof of the law.

---

# De Morgan's Law

There’s a second, “dual”, version of the law:

$$
\lnot (P \land Q) \Longleftrightarrow \lnot P \lor \lnot Q
$$

---

# De Morgan's Law

There’s a second, “dual”, version of the law:

$$
\lnot (P \land Q) \Longleftrightarrow \lnot P \lor \lnot Q
$$

* A computer proof cannot be given of this law.

---

# De Morgan's Law

There’s a second, “dual”, version of the law:

$$
\lnot (P \land Q) \Longleftrightarrow \lnot P \lor \lnot Q
$$

* A computer proof cannot be given of this law.
* Nor can one prove $$\lnot(\lnot P) \Rightarrow P$$

---

# Why?

---

# Why?

* Classical versus Constructive (Intuitionistic) logic

---

# Why?

* Classical versus Constructive (Intuitionistic) logic
* Classical: every proposition is either true or false.

---

# Why?

* Classical versus Constructive (Intuitionistic) logic
* Classical: every proposition is either true or false.
* Constructive: it’s complicated.

---

# Why?

* Classical versus Constructive (Intuitionistic) logic
* Classical: every proposition is either true or false.
* Constructive: it’s complicated.
  * or: a proposition is true only when it is proven true.

---

# Curry-Howard Correspondence

![inline](curry-howard.png)

---

# Exercise

Implement the following function:

```swift
func f <A> (x: A) -> Not<Not<A>> {
  ???
}
```

This proves the theorem: $$P \Rightarrow \lnot(\lnot P)$$

---

# If you liked this...

## [http://www.fewbutripe.com](http://www.fewbutripe.com)

* @mbrandonw
* brandon@kickstarter.com
