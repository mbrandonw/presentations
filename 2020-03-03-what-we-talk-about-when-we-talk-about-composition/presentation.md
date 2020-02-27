build-lists: true

# What We Talk About When We Talk About Composition

## Brandon Williams

@mbrandonw
[https://www.pointfree.co](https://www.pointfree.co)

^ Hi there, my name is Brandon and today we will be discussing composition. 

^ First here is some contact information for me, and if you find any of what I talk about tonight interesting then you may also be interested to check out this site here, Point-Free, where my co-host Stephen Celis and I talk about these kinds of things and a lot more.

---

# What is composition?

^ Composition is one of those words that come up quite a bit in programming, but rarely do we hear a succinct, rigorous definition of the term.

^ And that's a bummer because the word seems to carry a lot of weight in programming communities. As soon as someone mentions that something has composability it has somehow been blessed so that everyone knows it must be really powerful.

^ It's strange that programmers don't try to settle on an accepted definition of this term. Afterall most everything they do needs to be well-defined because the compiler needs to be able to understand what they are trying to express.

---

# What is composition?

^ First we will try to formulate a definition of composition. This definition should encompass all the examples you already think about when you think about composition, but also maybe will open your eyes to other types of composition that you hadn't yet considered.

^ And we say we are going to try to formulate this because it's difficult to do properly without the formalism of matheamtics. but i want to try to expose you to as much mathematics as possible without you know it's math

^ So once the stage is set for position we will then discuss a huge amount of examples. We will show that when it comes to programming, composition exists on a spectrum, and the power of a particular type of composition largely depends where on the spectrum it sits.

^ And we hope that by going through this exercise you will see how powerful composition is TODO

---

# Definition of composition

## A process that combines two objects of a type into a third of the same type.

^ So let's start simple and say that composition is nothing more than a process that allows us to combine two objects into a third.

^ Well already we're in a bit of trouble because we are using two terms in this definition that themselves have not be defined: process and objects.

^ However we're going to lean on our experience and intuition to tell ourselves what those things mean. To me process just means function, but to you it may mean some other things.

---

# Examples of composition

## Functions

^ So to get our feet wet, let's think about some examples of composition from that definition.

^ Perhaps the most canonical example of composition is functions. When you have a function from `A` to `B` and a function from `B` to `C` you can combine them together to form a brand new function from `A` to `C`

---

# Examples of composition

## “Composition over inheritance”

^ However, for many of us the first time we probably hear the word "composition" in programming is due to this adage: prefer composition over inheritance. This is truism from OOP that says that many times when you think you want to reach for inheritance what you really want is composition. 

^ Composition is usually not rigorously defined, but what they mean is that instead of having class `A` inherit from class `B`, you can create a third class `C` that holds instances of `A` and `B` and exposes an interface that mixes their functionality together in some way.

^ So, when said that way this kind of "object composition" does fit our definition. We have two classes and we decide to create a third class that holds the functionality of the other two.

---

# Examples of composition

## Code generation

^ Even code generatino could be thought of as a process of composition. Perhaps you have a sourcery template that says when I have two types annotated with something in particular I will generate the code for a third object.

^ This is just as valid of a "process" to compose things.

---

# The spectrum of composability

## Functions > Objects > Code Generation

^ And now we are starting to see the beginnings of a spectrum of composability. Not all forms of composition are created equal. the power of a particular composition is in some sense proportional to the complexity of the process you use to compose.

^ Because although functions, objects and code generation can be seen as forms of composition, that is processes that combine two things into a third, some of these are more difficult to work with than others.

---

# The spectrum of composability

## Functions > Objects > Code Generation

^ Function composition is perhaps the easiest. We can literally write a generic function that takes two functions as arguments and produces a third as a result. It will work with any functions you hand it, as long as the types match up.

^ Then you have object composition, which is more ad hoc. We have to sit down and define a whole new type that represents the composition of the two classes. And it will only work for those two particular classes, there is no concept of a truly generic composition of classes.

^ And then you have code generation, perhaps the most complicated. This requires you to have build infrastructure in place so that you can be sure to generate the new code exactly when necessary.

---

# The spectrum of composability

## Functions > Objects > Code Generation

^ It's worth keeping this in mind when trying to understand why one form of composition might be preferable to another form.

---

# Zoo of composability

^ Let's begin exploring the zoo of composability that exists in Swift.

---

# Functions

```
func compose<A, B, C>(
	_ f: (A) -> B,
	_ g: (B) -> C
) -> (A) -> C {
	return { g(f($0)) }
}
```

^ As we've already mentioned, functions are composable, and let's write down exactly what that means. We can write a completely generic function that takes any two functions, as long as the output of one matches the input of the other, and we can combine them into a third function.

^ This is the most canonical, simple example of composition out there.

---

# Partial Functions

```
func compose<A, B, C>(
	_ f: (A) -> B?,
	_ g: (B) -> C?
) -> (A) -> C? {
	return { f($0).flatMap(g) }
}
```

^ In fact, functions are so composable that we can often tweak their input or outputs and still get functions that compose.

^ Partial functions are ones that have optionals as their output. They are called partial because for some inputs you get a real output, but sometimes you get nothing.

---

# Failable/exceptional Functions

```
func compose<A, B, C, E>(
	_ f: (A) -> Result<B, E>,
	_ g: (B) -> Result<C, E>
) -> (A) -> Result<C, E> {
	return { f($0).flatMap(g) }
}
```

^ Generalizing partial functions we have failable functions. Not only can these functions sometimes decide to not return a value, but in the absence of a value they will give you an error.

^ Such functions also compose, and in fact its implementation is identical to composition of partial functions. You just apply the first function, and then flatmap with the second function.

^ That's no coincidence.

---

# Objects

[.code-highlight: 1-99]
[.code-highlight: 1]
[.code-highlight: 3]
[.code-highlight: 5-8]
[.code-highlight: 1-99]
```
class LocationManager { ... }

class LocationSearcher { ... }

class RecommendationsManager { 
	let manager: LocationManager
	let search: LocationSearch
}
```

^ As we mentioned before, objects emit a kind of composition too.

^ Say we had a class that encapsulated the behavior of getting a person's current location.

^ And a class that encapsulated the behavior of searching for locations

^ And from those we wanted to derive something more domain specific for our application, which is a class that encapsulates the behavior of getting a person's location and searching for some recommendations nearby.

^ If our minds only thought of things in terms of inheritance we may be convince ourselves that we could use inheritance so that we take a base class and enchance its functionality. So we inherit from the location manager to enhance its functionality with the idea of being able to search locations, and then we inherit from that to enchance its functionality with the idea of being able to layer in user recomendations.

^ Alternatively, we could just create a third class that holds instances of the other two classes, and then only expose an API that makes sense for that wrapper, and under the hood it can use the other two classes as much as we want.

^ It's worth noting that "composition over inheritance" in OOP is only a guideline, and cannot be codified into a program like we could for function composition. This is demonstrating that spectrum I mentioned before, certain types of composition are simpler than others.

---

# Protocols

```
typealias ComparableCollection
	= Comparable & Collection
```

^ Here's another non-function example of composition. People often say that protocols in Swift are composable, and so what does that mean?

^ Well, it means that there is this `&` operator for which you can just take two protocols and combine them into a single one. It simply takes the union of all their requirements so that if you conform to this new protocol you have to implement the requirements from each.

^ This is super lightweight, but again it's adhoc. We couldn't possibly define this `&` operator ourselves in Swift, only the compiler team can do that.

^ This is showing that certain constructs in Swift are manipulable by us, like functions and values, and other things only the compiler can do.

^ This is again demonstrating the spectrum of composition. We can't generically work with this composition, we can just do it in an adhoc fashion of taking two concrete protocols and smashing them together.

^ There are programming concepts out there that would give us more of a handle on these kinds of things. e approach is higher-kinded types, which would allow us to create types more like we treat values. Swift will probably never get higher-kinded types directly, but we may get something that gets us close enough.

---

# Key Paths

[.code-highlight: 1-2]
[.code-highlight: 1-3]
[.code-highlight: 1-6]
[.code-highlight: 1-8]
```
let kp1: KeyPath<A, B> = ...
let kp2: KeyPath<B, C> = ...
let kp3 = kp1.appending(kp2)

struct User { let name: String }
\User.name.count

🛑 (KeyPath<A, B>, KeyPath<A, C>) -> KeyPath<A, (B, C)>
```

^ Here's another cool non-function example. Swift has the concept of key paths, which in my opinion is what of the most distinguishing features of Swift. Other languages like Haskell wish they had a native feature like key paths.

^ Key paths are like little compiler generated code that bundles up the notion of a getter and setter into a single package, which allows you to write generic algorithms over the shape of data.

^ And amazingly they are composable. If you have a key path from `A` to `B` and a key path from `B` to `C` you can get a key path from `A` to `C`.

^ You can do it abstractly by using the `appending` method, or you can do it for key paths generated using the backslash operator by using dot syntax.

^ This form of composition is much closer to function composition on the spectrum, but it's not quite there. For example, we could never implement the `appending` method ourselves. And there are other key path compositions we might want to do but can't since the compiler is mostly responsible for creating these things.

^ One example is if you had a key path from `A` to `B` and a key path from `A` to `C` you cannot generically construct a key path from `A` to the tuple of `B` and `C`.

^ So again, certain parts of key paths are out of our hands, whereas with functions everything is in our control and can be defined in user land as opposed to compiler land.

---

# Zoo of composability

^ So already we have taken a pretty impressive tour through the zoo of composability.

^ But now let's go to the other side of the zoo and look at some more exotic things that will push the limits of what we consider to be composition.

---

# Optionals

```
let x: A?
let y: A?

x ?? y
```

^ If we take our definition of composition to heart, as a process that combines two things into a third thing, then aren't optionals composable?

^ After all, we have the double question mark operator, which simply returns the first non-`nil` value.

---

# Results

[.code-highlight: 1-9]
[.code-highlight: 1-14]
```
func choose<A, E>(
	_ lhs: Result<A, E>,
	_ rhs: Result<A, E>
) -> Result<A, E> {
	switch lhs {
	case .success:	return lhs
	case .failure:	return rhs
	}
}

let x: Result<A, E>
let y: Result<A, E>

choose(x, y)
```

^ And if optionals are composable, then shouldn't results be too? Afterall they are just a slight generalization of optionals where instead of modeling the absence of something as a void value you model it with a proper error.

^ Here we have defined a function that simply picks the first successful result passed in.

---

# Arrays

```
let xs: [A]
let ys: [A]

xs + ys
```

^ Heck, then aren't arrays composable since you can concatenate them?

---

# Dictionaries

```
let xs: [K: V]
let ys: [K: V]

xs.merge(ys)
```

^ And if arrays are composable then certainly dictionaries are, afterall we can merge them together.

---

# Streams of values
### Combine, ReactiveSwift, RxSwift

[.code-highlight: 1-2]
[.code-highlight: 4]
[.code-highlight: 6]
[.code-highlight: 8]
```
let xs: Stream<A>
let ys: Stream<A>

xs.merge(ys)

xs.concat(ys)

xs.race(ys)
```

^ If we venture out of the standard library pen of the zoo we will find that there are tons of types in the community that emit lots of compositions.

^ If you are comfortable with the idea of streams of values, such as publishers in combine, signals in reactive swift, and observables in rxswift, then you probably know that they are composable. 

^ You can merge two streams into a third one that simply emits all the values from both.

^ But the stream type is so exotic that emits lots of useful forms of composition. You can also combine two streams by concatenating one onto another, which requires that the first ends before the second one starts.

^ And you can also race two streams, which waits until the first one emits and then only takes values from that stream and ignores the values from the other stream.

---

# Zoo of composability

^ So those forms of composition were perhaps a little stranger to us, maybe not things we would typically think of composition.

^ Now let's go even more exotic. Let's go offroad in the zoo and see what we find.

^ In order to go offroad, we need to jump a fence...

---

# `zip`

^ In order to jump the fence we are going to consider the `zip` function, which is going drive a wedge of uncertainty right between us and what we think composition is.

---

# `zip`

```
zip: ([A], [B]) -> [(A, B)]
```

^ If we strip away most of the syntax from the signature of zip in the standard library we will find this shape.

^ It allows you to transform a tuple of arrays into an array of tuples. Notice the flip there, "tuple of arrays", "array of tuples"

---

# `zip`

```
zip: ([A], [B]) -> [(A, B)]

zip: (A?, B?) -> (A, B)?

zip: (Result<A, E>, Result<B, E>) -> Result<(A, B), E>

zip: ([K: A], [K: B]) -> [K: (A, B)]

zip: (Stream<A>, Stream<B>) -> Stream<(A, B)>
```

^ When stated that way maybe there are more zips out there.

^ Zip could transform a tuple of optionals to an optional tuple

^ Or transform a tuple of results into a result of a tuple

^ Or transform a tuple of dictionaries into a dictionary of tuples

^ Or even transform a tuple of streams into a stream of tuples

^ And so have we uncovered a whole new world of composition. afterall, arent' we combining two objects into a third?

---

# Composition

## A process that combines two objects of a type into a third of the same type.

[.code-highlight: 1-99]
[.code-highlight: 2-3]
[.code-highlight: 4]
```
zip: (
	[A], 
	[B]
) -> [(A, B)]
```

^ An unfortunately it does not quite fit our definition. We specifically said that composition was a process that combines two objects of the same type into a third of the same type.

^ An yes, all of the values in this signature are arrays, but they are not of the same type. We have an array of `A`s and an array of `B`s and ultimate return an array of a tuple of `A`s and `B`s.

^ Should we just fudge our definition of composition and not necessarily require that the objects be of the same type?

^ Turns out we don't need to. Our current definition of composition is the true foundational formulation, and if we just slightly change our perspective we will be able to recognize `zip` and other things as composition.

---

# Is `map` compositional?

```
let xs: [Int]
xs.map(String.init)

let y: Int?
x.map(String.init)

let zs: [K: Int]
zs.mapValues(String.init)

let r: Result<Int, E>
r.map(String.init)

let ws: Stream<Int>
ws.map(String.init)
```

^ Let's start with something simpler, `map`. Most of the things we've considered so far emit a `map` operation. Arrays, optionals, dictionaries, results and streams all have map.

^ Many people would say that something is composable if it emits a `map`, but can we rectify these lines of code with our strict definition of composition is supposed to be?

---

# Is `map` compositional?

```
map: ((A) -> B) -> ([A]) -> [B]

map: ((A) -> B) -> (A?) -> B?

map: ((A) -> B) -> (Result<A, E>) -> Result<B, E>

map: ((A) -> B) -> ([K: A]) -> [K: B]

map: ((A) -> B) -> (Stream<A>) -> Stream<B>
```

^ It turns out yes, we can change our perspective so that we see `map` in a new light, and from that perspective we will see `map` as a compositional thing.

^ Rather than thinking of `map` as some operation we call on things by doing "dot map" and passing a function, we can flip things around and see that `map` is nothing more than a way to changing functions that go between plain types so that they instead go between generic types.

^ So a function from A to B becomes a function from array of As to array of Bs

^ And a function from A to B becomes a function from optionals of As to optionals of Bs

^ And a function from A to B becomes a function from results of As to results of Bs

^ and so on

---

# Is `map` compositional?

```
map: ((A) -> B) -> (F<A>) -> F<B>
```

^ If we squint really hard so that all the syntax of array brackets, optional question marks and words like "result" and "stream" blur away, we will see we are left with something like this

^ For a generic type `F` to support a `map` operation it must be able to implement this function.

---

# Is `map` compositional?

[.code-highlight: 1-3]
[.code-highlight: 5]
```
map: ((A) -> B) -> (F<A>) -> F<B>

map: ((A) -> B) -> (G<A>) -> G<B>

map: ((A) -> B) -> (F<G<A>>) -> F<G<B>>
```

^ And now let's suppose we had two such generic types. Both `F` and `G` support a map operation.

^ What if we nested them, say as `F<G<A>>`, or even as `G<F<A>>`. Can we implement a `map` operation on this nested generic type?

^ In concrete terms this would mean can we map on arrays of results, or streams of arrays, or dictionaries of optionals.

^ And it turns out that yes, this is totally possible to do. I encourage everyone to give it a shot for some concrete types like i just described, but unfortunately we can't express this in full generality in swift

^ But regardless, the principle holds. Generic types that emit a map operation are composable because we can combine them into a third generic type that also emits a map operation.

---

# Is `zip` compositional?

```
zip: (F<A>, F<B>) -> F<(A, B)>

zip: (G<A>, G<B>) -> G<(A, B)>

zip: (F<G<A>>, F<G<B>>) -> F<G<(A, B)>
```

^ Using similar reasoning we can extend what we saw for `map` to `zip`.

^ If we have two types that support a `zip` operation, that is it can transform tuples of generic values to generic values of tuples, then indeed we can combine those two generic types together into a third that also supports a `zip` operation.

---

# Is `flatMap` compositional?

^ We've been talking a bunch of `map` and `zip`, but there's a third operation that the standard library gives us on a bunch of types that completes the trio of functional capabilities

^ it's flat map, and it's a little different from `map` and `zip`

^ `map` allowed us to take a generic type, open it up to inspect the value it holds on the inside, transform it to a new value, and then wrap it back up in the generic type

^ `zip` allowed us to do something similar, except we take many generic types, each independent from each other with no knowledge of what any other one is doing, and we get to open them all up, transform all of the values at once, and then wrap it back up in the generic type.

^ whereas `flatMap` allows us to open up a generic type to inspect the value it holds on the inside, transform it into a whole new generic value. This encodes a notion of dependence or sequencing in computations

---

# Is `flatMap` compositional?

[.code-highlight: 1-2]
[.code-highlight: 4-5]
[.code-highlight: 7-12]
[.code-highlight: 14-15]
```
let xs: [Int]
xs.flatMap { [$0, $0 * $0] }

let y: Int?
x.flatMap { $0.isMultiple(of: 2) ? $0 : nil }

let r: Result<Int, Error>
r.flatMap { 
	$0.isMultiple(of: 2) 
		? .success($0)
		: .failure("I only like even numbers")
}

let zs: Stream<Int>
zs.flatMap { api.isPrime($0) }
```

^ By sequencing I mean that literally when you see a chain of flatmaps you often think of it as a sequence of steps.

^ Here we flatmap on an array to consider each integer it holds, and then we turn each integer into two integers, the original one and its square

^ Or if we have a integer that may not exist, we can chain onto a partial function onto it that doesnt return anything if the integer isnt even

^ Or if you have a failable integer, we can chain onto it with a failable function that fails with a message if the integer isnt even

^ And if we have a stream of integers, then for each integer emitted we can chain on an operation that fires off an api request and feeds its values back into the stream

---

# Is `flatMap` compositional?

[.code-highlight: 1]
[.code-highlight: 3]
```
flatMap: (M<A>, (A) -> M<B>) -> M<B>

flatten: M<M<A>> -> M<A>
```

^ And it turns out that flat map is compositional, but in a seemingly different manner than map or zip.

^ If we the only things we knew about `flatMap` came from the standard library, we would think it's signature is this.

^ It says if we have a generic type, and a function that returns that generic type, we can ultimately derive another generic type. 

^ For example we can flatmap an array with a transformation that returns arrays in order to get another array.

^ or we can flatmap an optional with a partial function to get another optional

^ or we can flatmap a result with a failable function to get another result

^ But really there's two separable units inside the concept of flatmap. You have the mapping part, which is what we already talked about, and then we have the flattening part.

^ And this is the thing that flatMap brings to the table. This distinguishes it from map and zip in that those operations are incapable of doing anything like this by themselves.

^ And in this form we can see that we are getting closer to this fitting our definition of composition, the combining of two things into a third thing (TODO)





---

# Zoo of composability


^ We've now really opened pandora's box in the great outback of the zoo of composition.

^ If anything that emits a `map`, `zip` or `flatMap` operation is composable, and those versions of composition even require us to tilt our heads a bit to see it for what it is, what does that mean for the kind of code that we write every day?

---

---









<!--

objects

code generation

(A) -> B
(A) -> B?
(A) -> Result<B, E>

protocols

key paths
	can only be combined, not transformed

Observable

Gen<Value> = (inout RNG) -> Value

Parallel<Value> = ((Value) -> Void) -> Void

Parser<Value> = (inout String) -> Value?

Snapshotting<Value, Format>

Reducer<State, Action>

-->


---

# References

* notions of computation as monoids


