build-lists: true

# What We Talk About When We Talk About Composition

<br>

**Brandon Williams**

twitter.com/mbrandonw

mbw234@gmail.com

^ Hi there, my name is Brandon and thanks for having me. I'm very rarely on the west coast, i live in brooklyn, but i happen to be living in LA for the winter and i'm really glad that I was able to make it to this meet up while in the area. i've always heard very good things about it, and thanks to everyone for coming.

^ Here is some contact information for me in case you want to reach out

---

<!-- ![](pf-square-dark.png) -->
![original](pf-square@6x.png)

### [ **www.pointfree.co** ](#)

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

^ and if you find any of what I talk about tonight interesting then you may also be interested to check out this site here, Point-Free, a video series where my co-host Stephen Celis and I talk about these kinds of things and a lot more.

---

# What is composition?


^ We have a lot to cover, so let's get into it. Today we will be discussing composition. 


^ Composition is one of those words that come up quite a bit in programming, but rarely do we hear a succinct, rigorous definition of the term.

^ And that's a bummer because the word seems to carry a lot of weight in programming communities. As soon as someone mentions that something has composability it has somehow been blessed so that everyone knows it must be really powerful.

^ so it's strange that programmers don't try to settle on an accepted definition of this term. After all most everything they do needs to be well-defined because the compiler needs to be able to understand what they are trying to express. Yet a word like composition is thrown around and everyone has their own personal feeling of what it means

---

# What is composition?

^ So, in this talk we will first try to formulate a definition of composition. This definition should encompass all the examples you already think about when you think about composition, but also maybe will open your eyes to other types of composition that you hadn't yet considered.

^ And we say we are going to *try* to formulate this because it's difficult to do properly without the formalism of mathematics. but i want to try to expose you to as much mathematics as possible without you knowing it's math. And even though it's very mathematically inspired, we will also see that when it comes to programming, composition exists on a spectrum, and the power of a particular type of composition largely depends where on the spectrum it sits.

^ Then once the stage is set for composition, we will then discuss a flurry of examples. Seriously. A bunch. It's going to seem like a fevered dream once we're done.

^ And we hope that by going through this seemingly pedantic exercise you will see how powerful composition is, you might see that there's more to composition than meets the eye, and you might learn how to look for composition in your code today.

---

# Definition of composition

## A process that combines two objects of a type into a third of the same type.

^ So let's start simple and say that composition is nothing more than a process that allows us to combine two objects of a particular type into a third of the same type.

^ Well already we're in a bit of trouble because we are using two terms in this definition that themselves have not be defined: process and objects.

^ However we're going to lean on our experience and intuition to tell ourselves what those things mean. To me process just means function, but to you it may mean some other things. we'll see a few different kinds of processes.

---

# Examples of composition

## Functions

^ So to get our feet wet, let's think about some examples of composition from that definition.

^ Perhaps the most canonical example of composition is functions. When you have a function from `A` to `B` and a function from `B` to `C` you can combine them together to form a brand new function from `A` to `C`

^ Here we are using functions as the "process" and types as the "objects"

---

# Examples of composition

## “Composition over inheritance”

^ However, for many of us the first time we probably heard the word "composition" in programming is due to this adage: prefer composition over inheritance. This is a truism from OOP that says that many times when you think you want to reach for inheritance what you really want is composition. 

^ Composition is usually not rigorously defined, but what they mean is that instead of having class `A` inherit from class `B`, you can create a third class `C` that holds instances of `A` and `B` and exposes an interface that mixes their functionality together in some way.

^ So, when said that way this kind of "object composition" does fit our definition. The "process" is the creating of a new class that wraps two other classes, and the "objects" are classes.

---

# Examples of composition

## Code generation

^ Even code generation could be thought of as a process of composition. Perhaps you have a sourcery template that says when I have two types annotated with something in particular I will generate the code for a third object.

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

^ Let's begin exploring the zoo of composability that exists in the programming world.

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

^ Partial functions compose just as easily as normal functions. Here we are using optional `flatMap` under the hood to be succint, but we could have also written this with an explicit `if let` dance.

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

class POISearcher { ... }

class RecommendationsManager { 
	let manager: LocationManager
	let search: POISearch
}
```

^ As we mentioned before, objects emit a kind of composition too.

^ Say we had a class that encapsulated the behavior of getting a person's current location.

^ And a class that encapsulated the behavior of searching for points of interest

^ And from those we wanted to derive something more domain specific for our application, which is a class that encapsulates the behavior of getting a person's recommendations near where they are right now.

^ If our minds only thought of things in terms of inheritance we may be able to convince ourselves that we could use inheritance so that we take a base class and enchance its functionality. So we inherit from the location manager to enhance its functionality with the idea of being able to search for points of interest, and then we inherit from that to enchance its functionality with the idea of being able to layer in user recomendations.

^ Alternatively, we could just create a third class that holds instances of the other two classes, and then only expose an API that makes sense for that wrapper, and under the hood it can use the other two classes as much as we want.

^ It's worth noting that "composition over inheritance" in OOP is only a guideline, and cannot be codified into a program that takes two classes and produces the third composed class. This is demonstrating that spectrum I mentioned before, certain types of composition are simpler than others, and some are more ad hoc than others.

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

^ There are programming concepts out there that would give us more of a handle on these kinds of things. One approach is higher-kinded types, which would allow us to treat types more like we treat values. Swift will probably never get higher-kinded types directly, but we may get something that gets us close enough.

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

^ Here's another cool non-function example. Swift has the concept of key paths, which in my opinion is one of the most distinguishing features of Swift. Other languages like Haskell wish they had a native feature like key paths.

^ Key paths are like little compiler generated code that bundles up the notion of a getter and setter into a single package, which allows you to write generic algorithms over the shape of data.

^ And amazingly they are composable. If you have a key path from `A` to `B` and a key path from `B` to `C` you can get a key path from `A` to `C`.

^ You can do it abstractly by using the `appending` method, or you can do it for key paths generated using the backslash operator by using dot syntax.

^ This form of composition is much closer to function composition on the spectrum, but it's not quite there. For example, we could never implement the `appending` method ourselves. And there are other key path compositions we might want to do but can't since the compiler is mostly responsible for creating these things.

^ One example is if you had a key path from `A` to `B` and a key path from `A` to `C` you cannot generically construct a key path from `A` to the tuple of `B` and `C`. You can get pretty close to this using some tricks in Swift, but it's still more awkward than just composing functions.

^ So again, certain parts of key paths are out of our hands, whereas with functions everything is in our control and can be defined in user land as opposed to compiler land.

---

# Zoo of composability

^ So already we have taken a pretty impressive tour through the zoo of composability.

^ But we're still only at the entrance of the zoo where they put all the gift shops and obvious zoo animals. let's venture to the other side of the zoo and look at some more exotic things that will push the limits of what we consider to be composition.

---

# Integers

[.code-highlight: 1-4]
[.code-highlight: 1-99]
```
let x = 1
let y = 2

x + y

x * y
```

^ If we take our definition of composition to heart, as a process that combines two things into a third thing, then aren't integers composable since you can add them?

^ In fact, they are even doubly composable because you can also multiply them?

---

# Strings

```
let x = "Hello"
let y = "World"

x + y
```

^ But can't you combine two strings together to form a third too? Does that mean strings are in some sense composable?

^ Seeing these examples in our imaginary zoo of composability is like like having a dedicated exhibit for pigeons at a real zoo. Like sure they are animals, but I see them every day on the streets of new york. Why would I come to a zoo for this? 

^ One might think we are in some way degenerating the concept of composition by letting these examples into our zoo. 

^ It turns out that is not the case, but let's keep pushing for to understand why.

---

# Optionals

```
let x: A?
let y: A?

x ?? y
```

^ Perhaps a little more interesting than strings and integers, but are optionals composable?

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

^ And if optionals are composable, then shouldn't results be too? Afterall they are just a slight generalization of optionals.

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

xs.race(against: ys)
```

^ If we venture out of the standard library area of our imaginary zoo we will find that there are tons of types in the community that emit lots of compositions.

^ If you are comfortable with the idea of streams of values, such as publishers in combine, signals in reactive swift, and observables in rxswift, then you probably know that they are composable. 

^ You can merge two streams into a third one that simply emits all the values from both.

^ But the stream type is so exotic that emits lots of useful forms of composition. You can also combine two streams by concatenating one onto another, which requires that the first ends before the second one starts.

^ And you can also race two streams against each other, which waits until the first one emits and then only takes values from that stream and ignores the values from the other stream.

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

[.code-highlight: 1]
[.code-highlight: 3]
[.code-highlight: 5]
[.code-highlight: 7]
[.code-highlight: 9]
```
zip: ([A], [B]) -> [(A, B)]

zip: (A?, B?) -> (A, B)?

zip: (Result<A, E>, Result<B, E>) -> Result<(A, B), E>

zip: ([K: A], [K: B]) -> [K: (A, B)]

zip: (Stream<A>, Stream<B>) -> Stream<(A, B)>
```

^ When stated that way maybe there are more zips out there besides on just arrays.

^ Zip could transform a tuple of optionals to an optional tuple

^ Or transform a tuple of results into a result of a tuple

^ Or transform a tuple of dictionaries into a dictionary of tuples

^ Or even transform a tuple of streams into a stream of tuples. Even though the standard library doesnt define  all of these zips, it is true that reactive libraries ship with zips for their stream types.

^ And so have we uncovered a whole new world of composition. after all, aren't we combining two objects into a third?

---

# Composition

## A process that combines two objects of the **same type** into a third of the **same type**.

[.code-highlight: 1-99]
[.code-highlight: 2-3, 5]
[.code-highlight: 1-99]
```
zip: (
  [A], 
  [B]
) 
-> [(A, B)]
```

^ But unfortunately it does not quite fit our definition. We specifically said that composition was a process that combines two objects of the same type into a third of the same type.

^ And yes, all of the values in this signature are arrays, but they are not of the same type. We have an array of `A`s and an array of `B`s and ultimate return an array of a tuple of `A`s and `B`s.

^ It's pretty disappointing to see that this does not fall into the purview of composition. It is sooo close. Are we being too pedantic with our definition? Should we just fudge our definition of composition and not necessarily require that the objects be of the same type?

^ Turns out we don't need to. Our current definition of composition is the true foundational formulation, and if we just slightly change our perspective we will be able to recognize `zip` and other things as composition with our more strict definition

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

^ To figure that out, let's start with something simpler, `map`. Most of the things we've considered so far emit a `map` operation. Arrays, optionals, dictionaries, results and streams all have map.

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

^ Rather than thinking of `map` as some operation we call on things by doing "dot map" and passing a function, we can flip things around and see that `map` is nothing more than a way to changing functions that go between plain types into ones that instead go between generic types.

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

^ In your mind you can replace `F` with any of the generic types we've considered so far, optionals, arrays, results, dictionaries, streams, etc.

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
x.flatMap { $0.isMultiple(of: 2) ? $0 * $0 : nil }

let r: Result<Int, Error>
r.flatMap { 
	$0.isMultiple(of: 2) 
		? .success($0 * $0)
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

^ If the only things we knew about `flatMap` came from the standard library, we would think it's signature is this.

^ It says if we have a generic type, and a function that returns that generic type, we can ultimately derive another generic type. 

^ For example we can flatmap an array with a transformation that returns arrays in order to get another array.

^ or we can flatmap an optional with a partial function to get another optional

^ or we can flatmap a result with a failable function to get another result

^ But really there's two separable units inside the concept of flatmap. You have the mapping part, which is what we already talked about, and then we have the flattening part.

^ And this is the thing that flatMap brings to the table. This distinguishes it from map and zip in that those operations are incapable of doing anything like this by themselves.

^ And in this form we can see that we are getting closer to this fitting our definition of composition, the combining of two things into a third thing. The two things we have don't come in the normal form of a pair of objects, but rather come as a nesting of this generic type. But nonetheless, this shows we are in some sense squashing two things into one.

---

# Zoo of composability


^ We've now really opened pandora's box in the great outback of the zoo of composition.

^ If anything that emits a `map`, `zip` or `flatMap` operation is composable, and those versions of composition even require us to tilt our heads a bit to see it for what it is, what does that mean for the kind of code that we write every day?

^ Well, it means that composition is far more pervasive than we might think, and if you are able to define some of the operations we have described above on your own types you will be at the beginning of a wonderful journey towards breaking down your problem into lots of tiny pieces that can be glued together.

^ It may be hard to see this right now because pretty much everything we've considered so far exists in the standard library, and that may lead us to believe that in order to get benefit of composability it must be handed down to us from the core Swift team.

^ To convince ourselves that composition is bountiful out in the world, let's consider a whole bunch of examples that do not ship with the standard library, but are imminently useful 

---

# Random Number Generators

^ consider random number generators.

^ You may know that Swift gave us some powerful random number API's in Swift 4.2, but what you may not know is that it's a wonderful unit of composability.

^ If you only look at what we are given in the standard library you may think that randomness means that some types were blessed with some static functions so that you can just do things like `Bool.random` or `Int.random` and you get some random stuff out the other end.

^ But there are lots of types of things we want to compute random versions of. random passwords, random coordinates in 3d space, random UIImages of generative art, and more.

---

# Random Number Generators

```
struct Gen<A> {
  let run: (inout RandomNumberGenerator) -> A
}
```

^ But at its essence, a random generator is a function that takes a base unit of randomness, in this case a black box that can generate random values in the huge space of `UInt64`, and from that black box we will produce a random `A` value.

^ We are using `inout` because this black box is changed internally everytime we ask it to give us a `UInt64`

---

# Random Number Generators

[.code-highlight: 5-99]
```
struct Gen<A> {
	let run: (inout RandomNumberGenerator) -> A
}

Gen<Int>
Gen<Bool>
Gen<String>
Gen<User>
Gen<UIImage>
Gen<(Int) -> Int>
```

^ And from this single type we can create values that represent the ability to create:
• random integers and booleans, nothing new there really
• but also random strings, random users if we had a `User` model, random `UIImage`s where we randomly draw into a context, and heck even randomly generated functions

---

# Random Number Generators

[.code-highlight: 1]
[.code-highlight: 3-4]
```
map: ((A) -> B) -> (Gen<A>) -> Gen<B>

let int: Gen<Int>
int.map(ordinal) // 5th, 3rd, 1st
```

^ The `Gen` type supports all of the types of composition we have discussed so far

^ You can map on a generator, so for example if you had a generator of integers you could map on it with an oridinal number formatter

---

# Random Number Generators

[.code-highlight: 1]
[.code-highlight: 3-4]
```
zip: (Gen<A>, Gen<B>) -> Gen<(A, B)>

let name: Gen<String>
let user = zip(int, name).map(User.init(id:name))
```

^ The `Gen` type also supports a `zip` operation, where given two generators you can simply run them both and then bundle the results into a tuple.

^ If you pair this with `map` you get all types of fun stuff.

^ Like if you had a random int generator and a random generator of names, you could zip the int generator and name generator and map it with a user initializer to instantly get the notion of a random user model

---

# Random Number Generators

[.code-highlight: 1]
[.code-highlight: 3-99]
```
flatMap: (Gen<A>, (A) -> Gen<B>) -> Gen<B>


func array<A>(of element: Gen<A>,  count: Gen<Int>) -> Gen<[A]> {
  count.flatMap { count in
    Gen<[A]> { rng in
      var array: [A] = []
      for _ in 1...count {
        array.append(self.run(&rng))
      }
      return array
    }
  }
}
```

^ Gen also supports a flat map, which allows us to run a generator to get a random value, and then do something with that value that then produces yet another random value.

^ For example, we can cook up a generator of randomly sized arrays of random values. 

---

# Random Number Generators

[.code-highlight: 1]
[.code-highlight: 3-8]
```
choose: (Gen<A>, Gen<A>) -> Gen<A>

let intBetween1and10: Gen<Int>
let intBetween100and1000: Gen<Int>
choose(
	intBetween1and10,
	intBetween100and1000
)
```

^ And finally `Gen` supports an operation that allows you to combine two generators of `A`s into a single generator of `A`s. It works by just randomly choosing one of the generators we were handed, and then runs it

---

# Random Number Generators

[.code-highlight: 1-4]
[.code-highlight: 6-8]
[.code-highlight: 10-11]
[.code-highlight: 13-14]
[.code-highlight: 1-99]
```
"3DRe0K-Idj1k2-NL160E"
"BWD57f-I6wHry-CF7dvo"
"ApyA65-1s6AYS-FgqzgD"
"Ty3Hlx-yz4WrO-VxfbQY"

let alphanum = element(
	of: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
)

let passwordSegment = array(of: alphanum, count: 6)
  .map { String($0) }

let password = array(of: passwordSegment, count: 3)
  .map { $0.joined(separator: "-") }
```

^ And this kind of composition for random generators is a great way to break a very complex problem down into simpler ones.

^ if we wanted to have a generator of random passwords, like the ones you often see in safari, we could break this down into three steps

^ first we get a generator of random characters that only includes alpha numeric characters

^ then we take six random characters and turn them into a string so that we get one of those segments

^ and then we take 3 random segments and join them with a dash so that we get the whole random password

---

# Parsers

^ But it doesn't stop at random number generators. Parsers also emit all of the above types of composition, amazingly.

^ Currently Swift does not offer a standard library solution for parsing. They provide an extremely powerful set of API's for dealing with strings, substrings and views of strings, which allow you to efficiently express transformations on strings.

^ And foundation has things like scanners, formatters and failable initializers for converting strings into numbers, but many of those API's are old and crufty, though some have been updated in Swift 5, and none of them are built with composition in mind.

---

# Parsers

```
struct Parser<A> {
	let run: (inout String) -> A?
}
```

^ The essence of parsing can be expressed in this simple signature. To run a parser on some input blob of a string means to try to extract out a value of type `A` from the string. 

^ Doing that may fail if the string cannot be parsed, like if you tried parsing the word "dog" into an integer, and if it does succeed you can consume a bit from the input string so that you can continue parsing the input with other parsers.

---

# Parsers

```
let int: Parser<Int>

var input: "123dog"

int.run(&input) // 123
input           // "dog"
```

^ So if you had a parser that could parse integers off the front of a string you could run it on the string "123dog" and it would return back the integer 123, and the input string would have been changed to now only contain "dog" since the number of consumed from the front.

---

# Parsers

[.code-highlight: 1]
[.code-highlight: 3-99]
```
map: ((A) -> B) -> (Parser<A>) -> Parser<B>

let int: Parser<Int>
int.map(ordinal)

var input = "3dog"
int.run("3dog") // "3rd"
input           // "dog"
```

^ And amazingly parsers emit all the compositions we have been discussing so far.

^ It supports a map operation, which means we can take our lowly parser that produces integers into a parser that produces ordinals

---

[.code-highlight: 1]
[.code-highlight: 3-99]
```
zip: (Parser<A>, Parser<B>) -> Parser<(A, B)>

let name: Parser<String>
let user = zip(int, name).map(User.init(id:name))

user.parse("42Blob") // User(id: 42, name: "Blob")
```

^ It also supports the zip operation, where you simply run both of the parsers, and if they both successfully produce a value you bundle them up in a tuple

^ So if we had a parser of integers and strings, we could zip them together to get a parser of users

---

# Parsing

[.code-highlight: 1]
[.code-highlight: 3-99]
```
flatMap: (Parser<A>, (A) -> Parser<B>) -> Parser<B>

let version: Parser<String>

version
  .flatMap {
    $0 == "v1" ? v1Parser
      : $0 == "v2" ? v2Parser
      : legacyParser
}
```

^ It also supports flatmap, which allows you to parse a little bit, inspect the value you parsed in order to them decide how you want to continue parsing.

^ For example, say the string we are parsing started with a little bit of metadata that described what "version" the data was in. Like maybe right at the beginning there's a little `"v1"` or `"v2"` string.

^ Well, if we had a parser to extract just that little bit of info from the string, we could then flat map on it in order to determine which parser we want to use.

---

# Parsing

[.code-highlight: 1]
[.code-highlight: 3-99]
```
oneOf: (Parser<A>, Parser<A>) -> Parser<A>

enum Location {
  case nyc, berlin, london
}

let location: Parser<Location> = oneOf(
  literal("New York City").map { .nyc },
  literal("Berlin").map { .berlin },
  literal("London").map { .london }
 )
```

^ Further, parsers support the notion of combining two parsers into a single one, and it's called the one of parser.

^ We simply run the first parser on the input string, if it succeeds we take that result, and otherwise we run the second parser

---

# Parsing

# 40.446° N, 79.982° W

^ And just like randomness, when we have all of these little forms of composition at our disposal we can break down a large, complex parsing problem into a bunch of tiny problems

^ Take this string format for describing latitude and longitude coordinates. we need to be able to parse the double value from the front, and then the little degree sign, and then an N or S character, which determines if the coordinate is positive or negative, and then we have to do it all over again.

---

# Parsing

[.code-highlight: 1-99]
[.code-highlight: 1]
[.code-highlight: 2-6]
[.code-highlight: 3]
[.code-highlight: 4]
[.code-highlight: 5]
[.code-highlight: 1-6]
[.code-highlight: 8-13]
```
let northSouth = char
  .flatMap {
    $0 == "N" ? always(1.0)
      : $0 == "S" ? always(-1)
      : .never
}

let eastWest = char
  .flatMap {
    $0 == "E" ? always(1.0)
      : $0 == "W" ? always(-1)
      : .never
}
```

^ So let's break it down.

^ We'll start with the parsers that are responsible for turn the N and S characters into a positive or negative one, and the same for the E and W characters.

^ We do this by flat mapping on the character to inspect it, and depending on its value we will return a positive or negative one, but if the character doesnt match a value we expect we can just fail the parser.

---

[.code-highlight: 1-99]
[.code-highlight: 1]
[.code-highlight: 2]
[.code-highlight: 1-2]
[.code-highlight: 4-5]
[.code-highlight: 7]
[.code-highlight: 8-13]
[.code-highlight: 7-13]
```
let latitude = zip(double, literal("° "), northSouth)
  .map { lat, _, latSign in lat * latSign }

let longitude = zip(double, literal("° "), eastWest)
  .map { long, _, longSign in long * longSign }

let coord = zip(latitude, literal(", "), longitude)
  .map { lat, _, long in
    Coordinate(
      latitude: lat,
      longitude: long
    )
}
```

^ Next we construct the parser for the latitude part of the coordinate. This means to first parser the double, then the degree sign, and then the north/south sign, and once we have that info we can just multiply the latitude value with its sign. Notice that we are zipping 3 things, but that's easy to do once you know how to zip two things.

^ We do the same for the longitude, it's pretty much identical.

^ And then we construct the final parser by parsing off the latitude from the beginning of the string, then parsing the comma, and then parsing the longitude.

---

# Parsing

```
coord.run("40.6782° N, 73.9442° W") // {40.6782, -73.9442}
coord.run("40.6782° S, 73.9442° W") // {-40.6782, -73.9442}

coord.run("40.6782° X, 73.9442° W") // nil
```

^ And we can run our parser on some well-formed and malformed coordinates to make sure it behaves correctly. notice that the negative signs are inserted corretly.

---

# Asynchronous values

^ But it keeps going, asynchronous values also fit into this compositional world.

---

# Asynchronous values

```
struct Async<A> {
	let run: ((A) -> Void) -> Void
}
```

^ You may already have a lot of experience with this because this is basically a promise.

^ The essence of an asynchronous value is the ability to hand off control for someone else to tell us when a value is produced. This is the signature that allows for that, where a 3rd party is given the inside `(A) -> Void` callback function, and then they invoke it whenever they want.

^ This type supports all of the same compositions we have been discuss, but we aren't going to spell it out in excruciating detail like we have been

---

# Continuations

```
struct Continuation<R, A> {
	let run: ((A) -> R) -> R
}
```

^ Generalizing the asynchronous value concept is the concept of continuations. If we plug in `R = Void` then we just get an async value, but if we use a non-void `R` value we will get a type that kind of mixes together aspects of synchronous computation and asynchronous computation into a single package. It allows you to run computations, pause them, and then resume them.

^ And of course this type supports all the types of compositions we have been discussing.

---

# Predicates

```
struct Predicate<A> {
	let contains: (A) -> Bool
}
```

^ But then there are types like this. It seems simple enough, it wraps a predicate function from `A` to `Bool`.

---

# Predicates

```
💔 map: ((A) -> B) -> (Predicate<A>) -> Predicate<B>
```

^ Wouldn't it be cool if predicates had a map operation. Like if I have a predicate that works on user models i could map on it so that it works on the id integer of that user model.

^ Unfortunately that does not work, and in fact doesn't make any sense. Just because I have a predicate on users doesnt mean I should be able to derive a predicate on integers. For if someone were to hand me an integer, how would I ask the user predicate if it contains something? Construct a user from scratch with that integer has an id? That seems difficult.

^ It is impossible to implement this function due to how contravariance in functions work.

---

# Predicates

```
😍 pullback: ((B) -> A) -> (Predicate<A>) -> Predicate<B>
```

^ But that's ok, because the thing we really want is this operation, which says that if you tell me how to transform `B`s into `A`s I'll tell you how to transform predicates on `A`s into predicates on `B`s.

^ Notice that the direction flipped. On one side we have a `B` to `A` direction, and on the other side we have an `A` to `B` direction.

^ So if I had a predicate on integers, like say "is even", then I could _pull it back_ to work on users by projecting a user into its id. And then I'd have a predicate on users that checks if their user id is even.

^ This is a whole new type of composition that we haven't yet considered. It's closely related to `map`, yet different.

---

# Predicates

```
💔 flatMap: (Predicate<A>, (A) -> Predicate<B>) -> Predicate<B>
```

^ Predicates also don't support `flatMap`, and it's not clear if we can find a closely related example of `flatMap` that does play nicely with predicates.

---

# Predicates

```
🤷‍♀️ zip: (Predicate<A>, Predicate<B>) -> Predicate<(A, B)>
```

^ And this is even trickier. Technically we can define this operation, but if we dig a little deeper we would find that it's not quite like the `zip` that we know an love from arrays. Instead of it "zipping" things together, it actually divides things apart. So I'll just say that there is a composition story to be told here, but we don't have time to tell it.

^ And what we are really seeing here is that predicates are "contravariant" things, and all the other types we have been considering were covariant. It turns out that we can repeat almost all of the work we did for composition of covariant types, but instead do it for contravariant types, and we'd uncover a whole new world of composition.

^ This is so bizarre that it's hard to relate it to the very strained analogy of a zoo that I've been using so far. If we introduce some sci-fi elements to our zoo, it would be like if there was a magical mirror in the zoo that showed a dual, alternate reality for which everything we know and love in our world has been flipped

^ we would have structs, they would have enums

^ we would have map, they would have pullback

^ we would have zippable things, they would divisible things

---

# Snapshot Testing

[.code-highlight: 0]
```
struct Diffing<Format> {
  let diff: (Format, Format) -> (String, [XCTAttachment])?
  let toData: (Format) -> Data
  let fromData: (Data) -> Format
}

struct Snapshotting<Value, Format> {
  let diffing: Diffing<Format>
  let snapshot: (Value) -> Async<Format>
  let pathExtension: String
}
```

^ So predicates are even weirder than some of the things we've discuss so far, and you may not even think that a dedicated predicate type isn't useful enough to define.

^ So here's an example that is just as weird as predicates, but is definitely useful. It's some types that define the basis for a snapshot testing library that my collaborator Stephen Celis and I created and open sourced a few years ago.

^ You may be familiar with snapshot testing a means for verifying the correctness of UI's. You create a test that loads up a view, you snapshot it to an image on disk, and then subsequent runs of the test will take a new snapshot and compare it with what is on disk. And if a single pixel is off you will get a test failure so that you can check if you really meant for that change to happen

^ But snapshot testing goes well beyond just snapshotting views into images. You can snapshot any kind of value into any kind of format.

---

# Snapshot Testing

[.code-highlight: 0]
```
struct Diffing<Format> {
  let diff: (Format, Format) -> (String, [XCTAttachment])?
  let toData: (Format) -> Data
  let fromData: (Data) -> Format
}

struct Snapshotting<Value, Format> {
  let diffing: Diffing<Format>
  let snapshot: (Value) -> Async<Format>
  let pathExtension: String
}
```

^ Stephen and I personally have experience snapshotting

^ * URLRequests into strings so that you can verify that query params, headers and authorizations are added correctly

^ * Server middleware into a string representation request-to-response lifecycle that shows the exact response that would be output from the server, along with its body

^ * We even snapshot server middlewares into an image of what the website would be rendered to using `WKWebView`

^ * And we have snapshot test animations by snapshotting them into gifs

^ And users of our library have done even more interesting things, like the creator of a PDF library would snapshot his data structures into an actual PDF so that he has proof of what kind of documents his library produces.

---

# Snapshot Testing

```
struct Diffing<Format> {
  let diff: (Format, Format) -> (String, [XCTAttachment])?
  let toData: (Format) -> Data
  let fromData: (Data) -> Format
}

struct Snapshotting<Value, Format> {
  let diffing: Diffing<Format>
  let snapshot: (Value) -> Async<Format>
  let pathExtension: String
}
```

^ So snapshot testing can be super versatile

^ And this is how we designed the libary. We don't have time to discuss the API in detail, but suffice it to say you construct values of these types to describe how you want to turn your values into some format that can be diffed, and then describe how to do the diffing.

---

# Snapshot Testing

[.code-highlight: 1]
[.code-highlight: 3]
[.code-highlight: 5]
[.code-highlight: 7]
[.code-highlight: 9]
[.code-highlight: 11]
```
assertSnapshot(matching: user, as: .dump)

assertSnapshot(matching: user, as: .json)

assertSnapshot(matching: request, as: .curl)

assertSnapshot(matching: viewController, as: .image)

assertSnapshot(matching: document, as: .pdf)

assertSnapshot(matching: canvas, as: .gif(of: animation, duration: 1))
```

^ And once you have a snapshotting value you can start to use the `assertSnapshot` helper. You just say what you want to snapshot and what strategy you want to use, and the helper will take care of the rest

^ you can snapshot any value, no matter what it is, as a dump, which just uses reflection to find all the properties inside the value to print them out

^ but if your value is encodable you can snapshot as json

^ you can also snapshot a URLRequest as a curl representation of the url, so that not only do you verify that the value was constructed correctly but you also get something that you can just copy and paste into terminal

^ of course you can snapshot controllers and views into images

^ but as we mentioned some people have made it possible to snapshot their own types into custom formats, like snapshotting a document data structure into a pdf

^ and we have even done snapshot testing of animations into gifs

---

# Snapshot Testing

```
💔 map: ((A) -> B) -> (Snapshotting<A, Format>) -> Snapshotting<B, Format>
```

^ And so if we were able to snapshot such a wide variety of values into many different formats, we might also hope it's a composable thing.

^ Like if we can transform `A`s into `B`s could we also transform snapshottings of `A`s into snapshottings of `B`s?

^ But unfortunately this is not possible, because like predicates, `Snapshotting` is also a contravariant type.

---

# Snapshot Testing

```
😍 pullback: ((B) -> A) -> (Snapshotting<A, Format>) -> Snapshotting<B, Format>
```

^ But snapshotting does support `pullback`, so we just have to flip our perspective. 

^ If we can transform `B`s into `A`s then we can transform snapshottings of `A`s into `B`s. And although it may seem weird that the direction is flipped, this is the correct way it should be

^ If we have a snapshot strategy on a specific type, we should be able to pull it back to a larger type by projecting out of that larger type and then snapshotting

---

# Snapshot Testing

[.code-highlight: 1]
[.code-highlight: 3]
[.code-highlight: 4-7]
[.code-highlight: 9]
[.code-highlight: 10]
[.code-highlight: 12]
[.code-highlight: 13]
[.code-highlight: 1-99]
```
let image: Snapshotting<UIImage, UIImage> = ...

let layer: Snapshotting<CALayer, UIImage> =
  image.pullback { layer in 
    UIGraphicsImageRenderer(size: layer.bounds.size)
      .image { ctx in layer.render(in: ctx.cgContext) }
}

let view: Snapshotting<UIView, UIImage> = 
  layer.pullback { $0.layer }

let viewController: Snapshotting<UIViewController, UIImage> = 
  view.pullback { $0.view }
```

^ For example, suppose we already have a snapshot strategy for `UIImage`'s in the `UIImage` format. Basically the strategy is responsible for serializing and de-serializing a `UIImage` into a PNG to be saved on disk, and it is responsible for doing a pixel-by-pixel diff on two `UIImage`s to figure out what is different about them. This strategy takes some actual work to implement so we aren't going to show it's implementation, but it's pretty straightforward.

^ But once we have that strategy, we can derive a bunch more strategies with very little work.

^ For example, we can snapshot `CALayer`s. All you do is take the image snapshotting strategy, and pull it back via the transformation that turns layers into images via the `UIGraphicsImageRendered` API.

^ Then once we have that we can derive a snapshot strategy on `UIView`s by taking the layer strategy and pulling it back along the transformation that simply plucks the layer out of a view.

^ And finally we can derive a snapshot strategy on `UIViewController`s by just taking the strategy on views and pulling it back along the transformation that plucks the view out of a view controller.

^ And this is why the operation is called `pullback`. Because we think of it as a means to take a smaller more specific snapshot strategy and _pull it back_ to a larger structure.

^ Nearly all of the snapshot strategies provided by the library are pullbacks of just a few core strategies. And in fact, if you were to use this library and wanted to provide a snapshot strategy, you would most likely define it as a pullback of one of our strategies.

---

# App Architecture

^ Ok, and one final example of composition in the wild outback of our zoo: application architecture

^ If you have found any of the things discussed so far interesting, but perhaps not directly applicable to your day-to-day job, then this might perk you up a bit.

^ What if we could apply all of these wild ideas of composition and breaking large problems into smaller ones to the domain of architecture?

---

# Reducers

^ And in fact we can, as long as we settle on a base unit of our architecture that is composable.

^ Turns out there is something called a reducer that is a pretty popular way to structure applications, and it is super composable.

---

# Reducers

```
struct Reducer<State, Action> {
	let run: (inout State, Action) -> Effect<Action>
}
```

^ The shape of a reducer for an application could look like this

^ It's a struct with two generics, one for the state that your application is currently in, and one for the set of actions that can be performed in your application

^ It wraps a function, that takes an inout state and action. This represents the idea of an action coming into the system, like a user tapping on a button, and from that action we want to run some logic which will ultimately evolve the application's state to its next value. 

^ Further, while executing that business logic we may need to perform some side effects, like fire off an API request or track some analytics, and rather than doing that directly in the reducer we return this effect value, which can be thought of as a publisher/signal/observable that goes out into the real world, executes some work, and feeds more actions back into the system

^ You can totally build an entire application that is run off a single one of these things. just one big ole reducer

---

```
func combine<State, Action>(
  _ lhs: Reducer<State, Action>,
  _ rhs: Reducer<State, Action>
) -> Reducer<State, Action> {
  ...
}
```

^ But of course we wouldn't want to do that, so we would hope there are certain types of composition we could uncover.

^ And indeed, reducers emit many of the kinds of compositions we've been studying.

^ There's a combine function that takes two reducers and return a third. It simply runs the first reducer, then runs the next, and then merges the effects produced by both.

---

# Reducers

```
💔 map: ((S) -> T) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

^ And we'd hope there are more types of compositions, like maybe a `map`.

^ If we have a transformation from state `S` to state `T` could we transform reducers on `S` to reducers on `T`.

^ Well sadly, this is impossible to implement.

---

# Reducers

```
💔 pullback: ((T) -> S) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

^ Even worse, our beloved pullback operator is also impossible to implement

^ So if we flipped our arrow so that we were given a transformation from state `T` to state `S` we _still_ can't transform reducers on `S` to reducers on `T`

^ Does that mean this type isn't as composable as the other ones?

---

# Reducers

```
😍 pullback: (WritableKeyPath<T, S>) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

^ Well, luckily i'm here to tell you that reducers do support a pullback operation, it just doesn't look quite like what we've seen so far

^ It turns out that we can't pullback via a simple function, we need something a little more exotic

^ We need a key path from state `T` to state `S`, and once we have that we can finally transform our `Reducer` on `S` to a reducer on `T`.

^ In practice this means if you have a reducer that works on a lil piece of local state you can _pull it back_ to a reducer that works on a larger piece of state, provided you describe how to get and set local state in the global state

---

# Reducers

```
💔                ((T) -> S ) -> (Reducer<S, Action>) -> Reducer<T, Action>

😍 (WritableKeyPath<T,    S>) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

^ We are seeing yet another exotic form of composition, where we can't even pullback along simple functions, we've gotta use key paths. Should we even allow that?

^ Well yeah definitely, because all of the transformations we've performed in this talk don't intrinsically depend on the exact concept of function, but rather they only depend on the concept that we have some kind of "process" that moves us from type `A` to type `B`. could be a function, could be a key path, could be something else.

^ And here I've used the nebulous term "process" again, but unfortunately without digging into the math that's all i can give you

---

# Reducers

```
💔 map: ((A) -> B) -> (Reducer<State, A>) -> Reducer<State, B>
```

^ But that isn't even the end of composition for reducers. If we are going to transform reducers by their state, we would hope we could do the same for their actions.

^ You can't do it in the simple map way, this is impossible to implement

---

# Reducers

```
💔 pullback: ((B) -> A) -> (Reducer<State, A>) -> Reducer<State, B>
```

^ Even the pullback is impossible to implement

---

# Reducers

```
💔 pullback: (WriteableKeyPath<B, A>) -> (Reducer<State, A>) -> Reducer<State, B>
```

^ Even doing a pullback along a key path isn't quote right! it's possible to implement, but it can be shown that it isn't very useful.

^ so what gives??

---

# Reducers

```
💔 pullback: (?????<B, A>) -> (Reducer<State, A>) -> Reducer<State, B>
```

^ So the question is, is there something like a key path that we could use here to restore composability for reducers and actions?

---

# Reducers

```
💔 pullback: (CasePath<B, A>) -> (Reducer<State, A>) -> Reducer<State, B>
```

^ And it turns out there is, but it requires yet another concept

^ If key paths are great for allowing us to abstractly pick apart and analyze fields of a struct, then we would expect there should be some kind of similar tool for enums.

^ And one can easily discover what the shape of this tool is, and we have called it `CasePath`, and it's the perfect tool for us to pick apart enums and analyze their cases in isolation

^ That's all the time we have to talk about case paths, but suffice it to say once you have that concept you restore composability of reducers

^ And these pullback operations are the key to modularity in application architecture. It says that if you have a reducer that works on a small bit of domain it can be _pulled back_ to work on a large domain. This means you can break down your mega app reducer into a bunch of tiny reducers, each of which lives in its own module, each module only builds the domain and dependencies it cares about, while stil leaving itself open to be pulled back and combined with a whole bunch of other reducers, thus reforming the mega app reducer.

---

# Unifying composition

^ So I hope that now you can see there is a really expansive world of composability out there.

^ We seemingly have many different flavors of composition out there in the world, everything from adding a couple of integers together to zipping parsers together, to even pulling back reducers along key paths and case paths

^ But they are all unified under the umbrella of a single,strict definition of composition, which is the act of combining two objects of the same type into a third object of the same type.

---

# Composition for the working programmer

^ But practically speaking, for you out in the audience that is just trying to make an app and trying to do it in the best way you can, what does this mean for you?

^ Well, if you've ever written a generic type or a generic function in your application or library, it is worth wondering if those constructions support these kinds of compositions.

^ first, does your type support combine two values of it into a third? This is the key to allowing yourself to break large, complex instances of your type down into smaller pieces that glue back together. Your type might even support multiple ways to combine, which means there's even more things to explore that we didn't get a chance to discuss. Like if you have to ways to combine your type, then how do those two ways interact with each other? For example integers have addition and multiplication, but we don't think of them as independent operations. They are intimately related via distribution, `a * (b + c) = a*b + a*c`.

^ next, does your type support `map` operation? If so, it's unique. Turns out a generic type can only support a single `map` operation. If it doesn't support `map`, then does it support `pullback`?

^ Next, does your type support a `zip` operation? This would mean that your construction supports the idea of many instances of it running in parallel, independent of each other, in such a way that you can collect their results into a tuple once they are finished. Even if you find a `zip` operation on your type you may not be done. Some types support multiple zip-like operations, for example streams can be zipped in the standard way of waiting until both streams emit a value and then pairing the values. but you can also zip them with the "combineLatest" operator, which gives you the latest value from each stream anytime one of them emits a value.

^ finally, does your type support a `flatMap` operation? This would mean your construction supports the idea of sequencing it's work. that is, you can break down a large task into many small ones that feed off the result of the previous task.

---

# Composition for the working programmer


^ There is also significant inspiration to be had by looking at existing libraries and trying to find the compositions lurking in the shadows.

^ The snapshot testing library that Stephen and I built is not the first snapshot testing library out there. We were directly inspired by the very famous snapshot testing library that Facebook made back in the day, which was then transfered to Uber for maintenance. 

^ One thing we could have done was to simply port it to Swift since the library is still in Objective-C. Then we could have put a new coat of paint on it by making it "swifty", which would mean giving it better API names that take advantage of Swift's features.

^ Then we could kick it up a notch by trying to abstract the library by introducing some protocols. This would allow 3rd parties to opt into the snapshotting machinery that we provide so that others can snapshot their own types, not just the ones we provide.

^ And this is exactly what we did, and it worked well enough, but it lacked composition. As we have seen, there is definitely the concept of taking a snapshot strategy on a particular type, and then pulling it back so that it works on a completely different type. In fact, the library ships with about 20 snapshot strategies, and every single one of them is a pullback of one of 2 strategies: an image strategy and a string strategy.

^ So we scrapped the protocols and provided the interface that you saw before. That revealed to us that there was a `pullback` operation lurking in the shadows that we just couldn't see before because protocols do not allow for that.

---

## [fit] What We Talk About When We Talk About Composition

![](pf-square-dark.png)

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

# https://www.pointfree.co

^ So this is what the everyday, working programmer can take away from these topics. You are already creating types and functions in order to solve your problems, but if take a new look at those constructions with an eye on composition you may uncover some new tools that you can use. You may be able to break your problems down into even smaller, more understandable units, and you may find ways to apply your solutions to even more problems than you first imagined.

^ So that's the talk. If you find this kind of stuff interesting you might also like to checkout Point-Free, and educational video series. In fact, this talk is really just a fevered re-telling of many things we've discussed in Point-Free, we just haven't yet explicitly drawn a line to connect all of the seemingly disparate topics.
