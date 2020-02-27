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

## A process that combines two objects into a third.

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

^ But now let's go offroad and start to consider some truly exotic things that will push the limits of what we consider to be composition.




---

<!-- 

how to fit map and flatmap an dzip into composability?

well map means we can enhance functions betwen our types into the composable world

so does flat map

and zip does this for multiple arguments

 -->


---

# Definition of composition

## A process that creates a new object from an existing object and some other piece of data.

^ So perhaps we should tweak our definition of composition a bit, so that it's not just combining two objects into a third, but rather taking an existing object, and some other piece of data, and from that deriving an all new object.

^ This definition seems to subsume the previous definition, because that "other data" could certainly just be another object.

^ And so it's more general to use this definition, and will perhaps open us up to a few new things.

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
