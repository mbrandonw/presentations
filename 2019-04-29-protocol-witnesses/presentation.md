build-lists: true
theme: Huerta, 5

[.build-lists: false]

# [fit] Protocol Witnesses

* Brandon Williams
* @mbrandonw
* mbw234@gmail.com

^ Hello, today we'll be talking about alternatives to protocols as a means for abstracting and making generic code. The talk will be split into two parts. First we'll cover the theory of protocol witnesses, and then we'll take an in-depth look at an example where the application of this idea really shines.

^ My name is Brandon, this is my contact info if you'd like to ask me any questions at a later time. 

---

<br>
<br>
<br>
<br>
<br>
<br>

# www.pointfree.co
# w/ Stephen Celis (@stephencelis)

![original](assets/pf-square@6x.png)

^ Currently I do consulting for companies, specializing in introducing functional programming concepts to code bases as a means of reigning in complexity.

^ I also work on a side project known as Point-Free, which is a video series that explores functional programming using Swift and playgrounds as a tool for understanding functional ideas.

^ I do this with my colleague and collaborator Stephen Celis, his contact info is here. And everything I'm discussing today is joint work with Stephen, so if you have questions feel free to reach out to either one of us.

^ Also the entire site is built in server side swift, uses all of the ideas discussed in this talk, and is fully open source on GitHub if that interests you.

---

# Protocols

^ Ok, on to the real meat of the talk. Protocols.

^ Protocols are great! I love them, and I bet you love them, and certainly Apple certainly loves them. I think that every single year since Swift was announced there has been a WWDC talk touting the amazing capabilities of protocols, and how they are a powerful tool for abstraction. I'm sure everyone here has seen the eponymous WWDC talk on protocol-oriented programming featuring the loveable Crusty.

^ I think it's completely reasonable that we would all come away from those presentations thinking that protocols can solve quite a few problems, and so the more we use them the better off our code will be. They will allow us to be maximally generic and we'll be able to share and reuse so much code. Everything will be great!

---

# Protocols

> 🛑 Protocol can only be used as a generic constraint because it has Self or associated type requirements

^ Unfortunately that isn't quite true, primarily because there are quite a few things that protocols can't do. Perhaps the gnarliest of all of protocols shortcomings is this one, in which the moment you use an associated type or Self with a capital S in your protocol, it no longer acts in the way you would expect. You can't use it as a type for a variable, you can't create an array of values from that protocol, amongst other things.

^ But this error won't be around forever. The swift team is actively working on improving Swift's type system, and it's gonna keep getting better. There have even been a lot of protocol shortcomings that have been fixed recently. 

---

# Protocols

[.code-highlight: 1-99]
[.code-highlight: 1]
```swift
extension Optional: Equatable where Wrapped: Equatable {
  static func ==(lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    switch (lhs, rhs) {
    case let (.some(lhs), .some(rhs)):
      return lhs == rhs
    case (.none, .none):
      return true
    case (.some, .none), (.none, .some):
      return false
    }
  }
}
```

^ Such as this one here. It may be hard to remember now, but it's actually only been a year and one month since we were even allowed to do this. It came in Swift 4.1, which was 4 years after swift was first announced.

^ This is called conditional conformance, and it allows you to make a generic type conform to a protocol when its generic parameter is constrained.

---

# Protocols

[.code-highlight: 1-99]
[.code-highlight: 1]
[.code-highlight: 7]
[.code-highlight: 13]
```swift
extension Void: Equatable {
  static func ==(lhs: Void, rhs: Void) -> Bool { 
    return true
  }
}

extension (A, B): Equatable where A: Equatable, B: Equatable {
  static func ==(lhs: (A, B), rhs: (A, B)) -> Bool {
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
  }
}

extension ((A) -> B): Equatable where A: CaseIterable, B: Equatable {
  static func ==(lhs: (A) -> B, rhs: (A) -> B) -> Bool {
    return A.allCases.reduce(true) { isEqual, a in 
      isEqual && lhs(a) == rhs(a)
    }
  }
}
```

^ And then there are things like this, which as far as i can tell aren't really on the horizon of being fixed any time soon. Here we are first trying to extend `Void`, the empty tuple type, to be equatable. That totally makes sense, since `Void` only has a single value and it is of course equal to itself. 

^ More generally we'd like to be able to extend tuples that are made up of equatable types to be equatable.

^ Or even wilder, what if we could extend functions to conform to protocols.

^ These things are completely impossible, and the swift team certainly wants to add this someday, but I don't think there is a timeline of when we'll get it.

---

# Protocols


```swift
import XCTest

XCTAssertEqual((1, 1), (2, 2))
```

> 🛑 Global function 'XCTAssertEqual(\_: \_: \_:file:line:)' requires that '(\_, \_)' conform to 'Equatable'

^ And this limitation is a real problem, as many of you probably know if you've ever tried to write a test that deals with tuples. You can't do this because tuples can't be equatable, and hence you must write overloads for every size of tuple you care about.

---

# Protocols

[.code-highlight: 1-99]
[.code-highlight: 7-11]
```swift
indirect enum Tree<A> {
  case empty
  case node(left: Tree<A>, value: A, right: Tree<A>)
}

extension Tree: Sequence {
  // depth first?
  //   in-order?
  //   pre-order?
  //   post-order?
  // breadth first?
}
```

^ Protocols have another limitation in which types are only allowed to conform to a protocol a single time. Here we have a simple tree type and we want to make it a sequence. But there are many valid, mutually incompatible ways of making a tree a sequence. 

^ We could traverse it depth first, and do it in-order, pre-order or post-order. Or we could traverse over it breadth first.

^ None of these is more correct than the others, they are all equally valid depending on what you want to do. But due to the limitations of protocols, if we want trees to be able to participate in all of the generic algorithms that swift gives us for sequences, we have to choose one once and for all.

---

# Protocols

```swift
protocol ProtocolA {}
protocol ProtocolB {}

extension ProtocolA: ProtocolB {}
```

> 🛑 Extension of protocol 'ProtocolA' cannot have an inheritance clause

^ There's also this defect of protocols, which i have a very simplified version of it.

^ In short, you cannot extend a protocol to make it conform to another protocol, even if you provide all of its requirements right in the extension. I don't know of any legitimate reason this isn't possible, I think it just hasn't been proposed and designed yet.

---

# [fit] Non-protocol forms of abstraction

^ So, if protocols are the primary form of abstraction in Swift, and Apple pushes it hard, but there are significant problems with protocols, what are we to do?

^ Turns out, there is a very simple process in which you can convert most (if not all) protocols into very simple, concrete data types. And when you do that some of their problems go away and the problems that remain become a bit clearer why they are troublesome in the first place.

^ But most importantly, in my opinion, is that new transformations appear that were previously difficult or impossible to see when living in the world of protocols. And that's what I find most exciting.

---

# De-protocolization

^ So let's describe this process of "de-protocolization" and see what it gives us. We will start with a protocol, show how to convert it to a very plain, run-of-the-mill data type. And in doing so we will get some interesting things out of it.

---

# Combinable

```swift
protocol Combinable {
  func combine(_ other: Self) -> Self
}
```

^ The protocol in question is this one: `Combinable`. It expresses the idea of a type that can be combined with other values of the same type.

^ Turns out quite a few types that we are familiar with that conform to this protocol.

---

# Combinable

```swift
extension String: Combinable {
  func combine(_ other: String) -> String {
    return self + other
  }
}
```

^ For one thing, obviously strings are combinable by just concatenating them together.

---

# Combinable

```swift
extension Array: Combinable {
  func combine(_ other: Array) -> Array {
    return self + other
  }
}
```

^ Similarly arrays should be combinable in pretty much the same way as strings, we just concatenate the collections together.

^ But we are actually being kinda too specific with this conformance. There is a much larger class of types that could be combinable, and that is the `RangeReplaceableCollection` types. This is a subtype of `Collection` that adds the ability to append collections together.

---

# Combinable

```swift
extension RangeReplaceableCollection: Combinable {
  func combine(_ other: Self) -> Self {
    return self + other
  }
}
```

> 🛑 Extension of protocol 'RangeReplaceableCollection' cannot have an inheritance clause

^ So we may be tempted to do something like this, but unfortunately this isn't possible in swift. we can't extend protocols to conform to other protocols. 

^ So already we are missing out on a whole world of generic, reusable code. 

^ We have to re-define this combinable conformance for every `RangeReplaceableCollection` instance we know of, and the ones that we don't know about will be responsible for defining it themselves.

^ That's a bummer, because this could have be some really really generic code.

---

# Combinable

```swift
extension Int: Combinable {
  func combine(_ other: Int) -> Int {
    return self + other
  }
}

extension Double: Combinable {
  func combine(_ other: Int) -> Int {
    return self + other
  }
}
```

^ All numeric types can also conform to combinable such as integers and doubles by simplying adding.

^ But, there are like a dozen numeric types that ship with swift, so we need to conform each one of them to the combinable protocol.

---

# Combinable

```swift
extension Numeric: Combinable {
  func combine(_ other: Self) -> Self {
    return self + other
  }
}
```

> 🛑 Extension of protocol 'Numeric' cannot have an inheritance clause

^ What we'd really like to do is just make all numeric types comform to combinable. But we can't do this since we can't extend protocols to conform to protocols.

---

```swift
extension Int: Combinable {
  func combine(_ other: Int) -> Int {
    return self * other
  }
}
```

> 🛑 Redundant conformance of 'Int' to protocol 'Combinable'

```swift
extension Double: Combinable {
  func combine(_ other: Int) -> Int {
    return self * other
  }
}
```

> 🛑 Redundant conformance of 'Double' to protocol 'Combinable'

^ But that isn't even the worst part for the numeric types. The worst thing is that numeric types naturally conform to the combinable protocol in two ways, and we can't provide both implementations. There is no concept in swift of allowing a type to conform to a protocol in multiple ways. Sometimes that is a completely valid thing to do.

^ Here we have another conformance of Int and Double to the Combinable protocol, where we use multiplication instead of addition. One of these conformances isn't more important and more canonical than the other, they are both equally valid but we are forced to make a decision.

---

# Combinable

[.code-highlight: 1-99]
[.code-highlight: 1]
[.code-highlight: 2-7]
[.code-highlight: 10]
[.code-highlight: 11-15]
```swift
extension (A, B): Combinable where A: Combinable, B: Combinable {
  func combine(_ other: (A, B)) -> (A, B) {
    return (
      self.0.combine(other.0),
      self.1.combine(other.1)
    )
  }
}

extension ((A) -> B): Combinable where B: Combinable {
  func combine(_ other: (A) -> B) -> (A) -> B {
    return { a in 
      self(a).combine(other(a))
    }
  }
}
```

^ And then in addition to all of these problems, we still have the problem that we cannot conform tuples and functions to protocols.

^ If A and B are combinable, then tuples of A and B are of course combinable. We just combine in each of their components.

^ Further, if B is combinable, then we can even make functions from A into B combinable. We simply take two functions, apply them to the argument a, and then combine those values in B.

---

# Combinable

[.code-highlight: 1]
[.code-highlight: 3-7]
[.code-highlight: 9-13]
```swift
[1, 2, 3, 4].reduce(0, +)

extension Collection where Element: Combinable {
  func reduce(_ initial: Element) -> Element {
    return self.reduce(initial) { $0.combine($1) }
  }
}

[1, 2, 3, 4].reduce(0) // 10

["Hello", " ", "World"].reduce("") // "Hello World"

[[1, 2], [3, 4], [5, 6]].reduce([]) // [1, 2, 3, 4, 5, 6]
```

^ Problems aside, once we have a protocol defined and some conformances, we will want to write some generic algorithms that make use of that protocol. This allows us to build up abstractions which allow us to share code.

^ Here is an example. We are all probably familiar with the reduce function, which allows us to start with an initial value, say 0, and combine all the values from an array into that initial value using a function, such as addition.

^ We can simpify this function in the case that our array is made up of combinable values, because we can just use the combine function for reducing.

^ This makes the call site of this reduction a bit simpler since we get to just leave off the operation.

<!-- 

---

# CombinableWithIdentity

[.code-highlight: 1-3]
[.code-highlight: 5]
```swift
protocol CombinableWithIdentity: Combining {
  static var identity: Self { get }
}

a.combine(.identity) == a
```

^ Before we de-protocolize the combinable protocol, let's make it a little more complicated. let's define another protocol that inherits from it and adds the requirement that the type must come equipped with a special value that has the property that when combined with any other value it leaves that value unchanged.

---

# CombinableWithIdentity

```swift
extension String: CombinableWithIdentity {
  static let identity = ""
}

extension Array: CombinableWithIdentity {
  static var identity: Array { return [] }
}

extension Int: CombinableWithIdentity { 
  static let identity = 0
}

extension Double: CombinableWithIdentity {
  static let identity = 0
}
```

---

# CombinableWithIdentity

[.code-highlight: 1-5]
[.code-highlight: 7-11]
```swift
extension Array where Element: CombinableWithIdentity {
  func reduce() -> Element {
    return self.reduce(Element.identity)
  }
}

[1, 2, 3, 4].reduce()

["Hello", " ", "World"].reduce()

[[1, 2], [3, 4], [5, 6]].reduce()
``` -->

---

# De-protocolizing

^ So, that was a pretty simple protocol, and we ran into some of the protocol problems pretty quickly. In particular, we would have loved if we could make existing protocols conform to the `Combinable` protocol, and we would have loved if certain types could carry multiple conformances, and we would have loved if functions and tuples could conform.

^ Let's now deprotocolize this protocol into a simple data type, and see what that gives us.

---

# De-protocolizing

[.code-highlight: 1-99]
[.code-highlight: 1, 8]
[.code-highlight: 2, 9]
```swift
protocol Combinable {
  func combine(_ other: Self) -> Self
}


👇

struct Combining<A> {
  let combine: (A, A) -> A
}
```

^ Here is how we deprotocolize the combinable protocol. Instead of a protocol we use a simple struct. 

^ We rename it from the -able style suffix to the -ing style suffix. We introduce a generic which represents the types that can conform to this protocol. You can think of A as being like Self in the deprotocolized world.

^ Then the requirement that the type have a combine method that takes a value of type Self and returns a value of type Self becomes a function field on the struct. The function takes two arguments. The first is the implicit self that every method gets for free, and then second argument is the Self that the combine method takes. And finally it returns a value of type A.

---

# De-protocolizing

[.code-highlight: 1-99]
[.code-highlight: 1-7]
[.code-highlight: 9-15]
```swift
extension Int: Combinable {
  func combine(_ other: Int) -> Int {
    return self + other
  }
}

let sum = Combining<Int> { $0 + $1 }

extension String: Combinable {
  func combine(_ other: String) -> String {
    return self + other
  }
}

let concat = Combining<String> { $0 + $1 }
```

^ Then, instead of extending types to conform to this protocol, we simple construct values of the protocol. Here we have created two combining instances, one for integers and one for strings.

^ These values are called witnesses to the protocol. They are the concrete proof that a type conforms to a protocol, and it's just simple data that you can pass around.

^ It's kinda nice we can define these on one line where as the conformance takes multiple lines.

---

# De-protocolizing

[.code-highlight: 1-9]
[.code-highlight: 11-13]
```swift
extension Array {
  func reduce(
    _ initial: Element,
    _ combining: Combining<Element>
    ) -> Element {

      return self.reduce(initial, combining.combine)
  }
}

[1, 2, 3, 4].reduce(0, sum) // 10

[[1, 2], [3, 4]].reduce(0, concat) // [1, 2, 3, 4]
```

^ Then, to write generic algorithms we no longer constrain generics to the combinable protocol, but instead require us to pass in an explicit witness to the protocol. And after that the implementation is basically the same as before.

---

# De-protocolizing

```swift
let sum = Combining<Int> { $0 + $1 }

let prod = Combining<Int> { $0 * $1 }

[1, 2, 3, 4].reduce(1, sum) // 10

[1, 2, 3, 4].reduce(1, prod) // 24
```

^ And because these protocol witnesses are just simple values from a simple data type, we can construct as many of them as we want. This allows us to have multiple "conformances" for all of our types. Like here we have no problem creating a sum and product witness to the combining protocol for integers.

^ So, protocol witnesses solve that problem.

---

# De-protocolizing

[.code-highlight: 1-9]
[.code-highlight: 11-99]
```swift
extension Combining where A: Numeric {
  static var sum: Combining {
    return Combining { $0 + $0 }
  }

  static var prod: Combining {
    return Combining { $0 * $0 }
  }
}

[1, 2, 3, 4].reduce(0, .sum) // 10 as Int

[1, 2, 3, 4].reduce(1, .prod) // 24 as Int

[1.0, 2, 3, 4].reduce(1, .prod) // 24.0 as Double

[CGFloat(1), 2, 3, 4].reduce(1, .prod) // 24.0 as CGFloat
```

^ Witnesses also solve the problem that prevented us from extending the numeric protocol to be combinable. We can generalize the sum and product witnesses we defined on the previous slide. We simply extend the combining data type with its generic constrained to numeric, and add a few statics for the witnesses.

^ These witnesses for summing and taking products now work for _alllll_ numeric types. We define it one single time, and all current and future numeric types get access to this. If someday you created a vector or matrix library and made those types numeric, you would get access to this functionality immediately.

^ This is also nice because it gives us a place to store our witnesses instead of just letting those values float around in the module namespace.

---

# De-protocolizing

```swift
extension Combining where A: RangeReplaceableCollection {
  static var concat: Combining {
    return Combining { $0 + $1 }
  }
}

["Hello", " ", "World"].reduce("", .concat)

[[1, 2], [3, 4]].reduce([], .concat)
```

^ We can also instantly make any range replaceable collection opt into this combining machinery. Now this one single witness can be uses for strings and arrays alike, which is starting to seem pretty powerful.

^ So this is yet another protocol problem that witnesses have solved.

---

# De-protocolizing

[.code-highlight: 1-99]
[.code-highlight: 2-3]
[.code-highlight: 4]
[.code-highlight: 6-11]
[.code-highlight: 1-99]
```swift
func zip<A, B>(
  _ a: Combining<A>,
  _ b: Combining<B>
  ) -> Combining<(A, B)> {

    return Combining { lhs, rhs in 
      (
        a.combine(lhs.0, rhs.0),
        b.combine(lhs.1, rhs.1)
      )
    }
}
```

^ There's even more. Remember how we mentioned it's impossible to extend tuples to conform to protocols? Here we've done just that for witnesses. This function says that if we have a combining witness for types A and B, we can make an all new combining witness for tuples of A and B. We simply combine each component of the tuple independently.

^ It may seem a little weird that I called this function `zip` because you are probably all familiar with the zip function on arrays. I did this because `zip` on arrays is actually a special case of a far more general idea. Said in words, zip on arrays allows you to transform a tuple of arrays into an array of tuples. You can apply that idea to many other types. For example here we are transforming a tuple of combinings into a combining of tuples. You could also transform a tuple of promises into a promise of tuples. Or you could transform a tuple of parsers into a parser of tuples. You could even define zip for transforming a tuple of optionals into an optional tuple. It goes on and on!

^ It is also worth noting that this function is not only expressing the idea of making tuples conform to a protocol, but it also doing conditional conformance, since it says if A and B are combining then tuples (A, B) are combining. In the de-protocolized world, conditional conformance is just a function. Just a function!

^ Also worth noting that this function would have compiled in Swift 1, the very first version of Swift when it was announced. We didn't even get conditional conformance until 4 yrs later, but this could have been used on day 1. Tuple conformance and conditional conformance in one go.

---

# De-protocolizing

```swift
[
  (1, "Hello"),
  (2, " "),
  (3, "World"),
  (4, "!")
  ]
  .reduce(zip(.sum, .concat))

// (10, "Hello World!")
```

^ And this `zip` function is really packing a punch. Here we are zipping the sum and concat combining witnesses to get a combining witness that can process an array of tuples. In one pass of this function it will simultaneously sum the integers in the first component and concatenate the strings in the second.

---

# De-protocolizing

[.code-highlight: 1-99]
[.code-highlight: 2]
[.code-highlight: 3]
[.code-highlight: 5-9]
```swift
func pointwise<A, B>(
  _ b: Combining<B>
  ) -> Combining<(A) -> B> {

    return Combining { f, g in 
      return { a in 
        b.combine(f(a), g(a))
      }
    }
}
```

^ The de-protocolized Combining type also allows us to make functions combining. Here this says that if you tell me how to combine values in B, I will tell you have to combine functions that go into into B.

---

# [fit] Case Study

<br> <br> <br> <br> <br> <br> <br> <br> <br> 

^ So that is the basics of de-protocolizing. There is a lot more we could cover, like figuring out how to translate all of the various protocol concepts to concrete data types. Things like associated types, protocol inheritance and more. Rest assured all of that can be done, but at least you have the basic idea right now.

^ And although we started to see some promise behind the idea, I think it'd be nice to look at an example of where this technique really shines. So we are going to look at a case study of a library that my colleague Stephen Celis and I open sourced.

---

# [fit] Case Study: Snapshot Testing

https://github.com/pointfreeco/swift-snapshot-testing

![100%](assets/github-snapshot-testing.png)

^ It's a snapshot testing library, and it's been open source and in production use by us for nearly 2 years, but we officially released the 1.0 last december.

^ The 1.0 release looks remarkably different from where we started. We started it in the protocol-oriented style, and it served us well enough, although there were a few drawbacks.

^ Finally, those drawbacks became annoying enough that we decided to scrap the protocols, use simple data types, and we started uncovering all types of cool things.

---

# [fit] What is snapshot testing?

^ Snapshot testing is a form of unit testing in which you do not directly assert that the output of some computation is equal to a particular value, but rather you assert that snapshotting the output of the computation matches a snapshot artifact that has been previously saved on disk.

---

# What is snapshot testing?

```swift
import XCTest

XCTAssertEqual(
  42, 
  compute(3)
)
```

^ So instead of doing something like this...

---

# What is snapshot testing?

```swift
import SnapshotTesting

assertSnapshot(matching: compute(3))
```

^ We do something like this.

^ The first time this is run, a snapshot of the output of `compute` will be saved to disk, and the file's location and name is derived from the test name so that it can be uniquely identified. Then subsequent runs of this test will compare the output of this function against the snapshot that was saved to disk. 

---

# What is snapshot testing?

![inline](assets/testView_lang_en_device_phone4_7inch@2x.png)

^ The most popular form of snapshot testing, at least in the ios community, is screenshot testing. This is where you take a screenshot of a UIView or a UIViewController and you save that artifact to disk. Then if you make some changes or do some kind of refactor, you will get verification that not a single pixel in your UI has changed.

^ Here we have a screenshot of a screen that has a dashboard, it's got some stats and a graph.

---

# What is snapshot testing?

![inline](assets/testView_lang_de_device_phone4_7inch@2x.png)

^ You can even screenshot test in a variety of configurations of your app, like for example what does this screen look like when the device is set to german.

---

# What is snapshot testing?

![inline](assets/testView_lang_es_device_phone4_7inch@2x.png)

^ or spanish

---

# What is snapshot testing?

![inline](assets/testView_lang_fr_device_phone4_7inch@2x.png)

^ or french

---

# What is snapshot testing?

![inline](assets/testView_lang_ja_device_phone4_7inch@2x.png)

^ or japanese

^ But screenshot testing isn't the only form of snapshot testing. You can snapshot any kind of value into any kind of format.

---

# What is snapshot testing?

```swift
assertSnapshot(matching: request)
```

```
POST https://api.stripe.com/v1/subscriptions/sub_test?expand%5B%5D=customer
Authorization: Basic aHR0cHM6Ly93d3cucG9pbnRmcmVlLmNv

coupon=&items[0][id]=si_test&items[0][plan]=individual-yearly&items[0][quantity]=1
```

^ For example, you could snapshot test a URLRequest value by printing out all of the properties of the request into a nice textual format, and then save that artifact to disk.

^ Here we have a POST request to a stripe endpoint, and it's doing a bunch of extra work to properly encode the body into a very specific format. We even have all the headers nicely listed.

^ If you were to write this assertion using `XCTAssertEqual` you would be responsible for constructing the entire URLRequest from scratch, with post body and everything, and that would be a real pain. It's such a pain that you probably wouldn't even test this part of your code.

^ But this is a really important part of your code to test. There can be some pretty signficant logic in your networking/API layer in order to construct URL requests, and we should have test coverage on it. It's even more important if you are doing server-side Swift, because there can be subtle differences between foundation on mac and linux, and these snapshot tests can give you very broad coverage with very little work.

---

# Protocol-oriented snapshot testing

^ Here is our first approach to developing this library, fully inspired by protocol oriented programming.

^ We want a set of protocols that express all the requirements necessary for doing snapshot testing. Then, any type can simply conform to the protocols and they will immediately be snapshottable. Magic!

---

# Protocol-oriented snapshot testing

[.code-highlight: 1-99]
[.code-highlight: 1-5]
[.code-highlight: 2]
[.code-highlight: 3]
[.code-highlight: 4]
[.code-highlight: 7-11]
[.code-highlight: 8]
[.code-highlight: 9]
[.code-highlight: 10]
```swift
protocol Diffable {
  static func diff(old: Self, new: Self) -> (String, [XCTAttachment])?
  var data: Data { get }
  static func from(data: Data) -> Self
}

protocol Snapshottable {
  associatedtype Format: Diffable
  static var pathExtension: String { get }
  var snapshot: Format { get }
}
```

^ We ended up with two protocols. First there was the `Diffable` protocol, that expresses the idea of a type that can be diffed for testing. That means it can be serialized and de-serialized to disk, and that can be diffed for testing. The most common conformers of this type are string, where diffing happens on a line-by-line basis like what git does to your source code, and UIImage, which does a pixel-by-pixel diff.

^ Then we have a `Snapshottable` protocol, which expresses the idea of types that can be snapshot. It has an associated type that represents the diffable format that we can snapshot into. It has a path extension so that we know what type of file to save to disk. And then we have a way of turning our type into an actual diffable format.

---

# Protocol-oriented snapshot testing

```swift
func assertSnapshot<A: Snapshottable>(
  matching: A
) {
  // ...
}
```

^ Once we had the protocols we could then implement generic algorithms that work over snapshottable types. In particular, the `assertSnapshot` function does all the work for implementing snapshot testing. Essentially it:

^ * De-serializes the current artifact from disk into an actual value in memory.
* Compares the snapshot of the value passed in to the value that was just de-serialized
* If they differ then we fail the test and print out a nice message
* If they don't differ then the test passes

^ We used this library for a very long time, I think over a year, and it worked really well. We think even in this form it's better than any other snapshot testing library available for the Swift community.

^ But there were definitely some problems. Basically all of the protocol problems we already discussed:

^ * Types couldn't conform to `Snapshottable` multiple times. Most types, if not all types, have many valid ways of snapshotting them. For example that URL request example we showed early could have also been snapshot into the CURL format. When working on server-side swift we wanted to snapshot our webpages both as images and as raw HTML. And there are tons more examples.
* Also there are many types that we wanted to snapshot that we couldn't, like `Any` values and even functions.

---

# Witness-oriented snapshot testing

[.code-highlight: 1-99]
[.code-highlight: 1, 10]
[.code-highlight: 2, 11]
[.code-highlight: 3, 12]
[.code-highlight: 4, 13]
```swift
protocol Diffable {
  static func diff(old: Self, new: Self) -> (String, [XCTAttachment])?
  var data: Data { get }
  static func from(data: Data) -> Self
}


👇

struct Diffing<Value> {
  let diff: (Value, Value) -> (String, [XCTAttachment])?
  let data: (Value) -> Data
  let from: (Data) -> Value
}
```

^ So, let's de-protocolize our snapshotting protocols. We'll do them one at a time.

^ First we have the `Diffable` protocol. It becomes `Diffing`, and it has a generic that represents the type we are diffing.

^ The static `diff` function becomes a simple function field, and notice that it takes a `Value` argument for each of the arguments of the static method, and that's it. There is no implicit self in a static method.

^ And the `data` computed property becomes a function field from `Value` to `Data` because computed properties have an implicit self attached to them.

^ Similarly the static `from` method becomes a simple function field from `Data` to `Value`.

^ Already I think this is quite a bit simpler than the protocols. It makes it very clear that diffing just means there is a way to serialize and de-serialize to data, and a way to diff into failure messages.

---

# Witness-oriented snapshot testing

[.code-highlight: 1-99]
[.code-highlight: 1, 10]
[.code-highlight: 2, 10]
[.code-highlight: 2, 11]
[.code-highlight: 3, 12]
[.code-highlight: 4, 13]
```swift
protocol Snapshottable {
  associatedtype Format: Diffable
  static var pathExtension: String { get }
  var snapshot: Format { get }
}


👇

struct Snapshotting<Value, Format> {
  let diffing: Diffing<Format>
  let pathExtension: String
  let snapshot: (A) -> Format
}
```

^ Next we have the snapshottable protocol. This becomes a `Snapshotting` struct, and again it has a generic that represents the type that is being snapshot.

^ However, we have this associated type hanging out, and that manifests itself as an additional generic in the concrete type.

^ And then `pathExtension` and `snapshot` convert in a very straightforward way.

---

# Witness-oriented snapshot testing

```swift
func assertSnapshot<A>(
  matching: A,
  as: Snapshotting<A>
) {
  // ...
}
```

^ Now that we have our concrete types, we can rewrite our assert snapshot helper so that instead of constraining the generic to `Snapshottable` types, we require an explicit snapshotting witness. The implementation of this function looks almost identical to the one that used protocols.

---

# Snapshot Strategies

^ The library comes with tons of snapshot strategies. It's so easy to create new strategies, and you don't have to be afraid of conforming a type to a protocol and solidfying in time forever that types one single conformance. Some types, like `UIView` and `UIViewController` have many many many conformances, and using witnesses it's very easy to do this!

^ Let's take a little tour of some strategies:

---

# Snapshot Strategies: `dump`

``` swift
assertSnapshot(matching: user, as: .dump)
```

```
▿ User
  - bio: "Blobbed around the world."
  - id: 1
  - name: "Blobby"
```

^ The dump strategy is perhaps the most powerful. It allows you to snapshot _any_ value into a textual format, using Swift's `dump` function under the hood. This is incredible useful to test large data structures so that you don't have to construct values to test against directly in your test.

^ Also worth noting that this strategy literally works on any value, as in the any type with a capital A. That is yet another thing protocols can't handle. You cannot extend the Any type to conform to a protocol, not only because it's a protocol itself but also because it's a special, magical value in the swift compiler.

---

# Snapshot Strategies: `json`

``` swift
assertSnapshot(matching: user, as: .json)
```

``` json
{
  "bio" : "Blobbed around the world.",
  "id" : 1,
  "name" : "Blobby"
}
```

^ If you don't want to use the dump format to snapshot your models, and your types conform to codable, you can also snapshot as json.

^ This strategy was also impossible to implement when using protocols, because we could not extend codable to be snapshottable.

^ Further, json isn't the only way to snapshot a codable thing. We could snapshot as a plist, or any custom encoder.

---

# Snapshot Strategies: URLRequest `raw`

``` swift
assertSnapshot(matching: request, as: .raw)
```

```
POST http://localhost:8080/account
Cookie: pf_session={"userId":"1"}

email=blob%40pointfree.co&name=Blob
```

^ There are also some domain specific strategies, like this one that is specifically tuned for snapshotting URLRequests. It does some extra work to nicely format and it even renders the POST body as json if possible.

---

# Snapshot Strategies: URLRequest `curl`

``` swift
assertSnapshot(matching: request, as: .curl)
```

```
curl \
  --request POST \
  --header "Accept: text/html" \
  --data 'pricing[billing]=monthly&pricing[lane]=individual' \
  --cookie "pf_session={\"user_id\":\"1\"}" \
  "https://www.pointfree.co/subscribe"
```

^ You can also snapshot your requests as actual CURL commands which can be copied and pasted right into terminal.

---

# Snapshot Strategies: `image`

[.code-highlight: 0]
[.code-highlight: 1-4]
[.code-highlight: 6]
[.code-highlight: 8]
```swift
assertSnapshot(
  matching: view,
  as: .image(traits: .init(horizontalSizeClass: .regular))
)

assertSnapshot(matching: vc, on: .iPhoneX(.portrait))

assertSnapshot(matching: vc, on: .iPhoneX(.landscape))
```

^ And of course there are snapshot strategies for capturing UI as an image. 

^ Here we are snapshot testing a plain view, but we can provide some configiruation to the strategy for simulating size classes.

^ We can also snapshot at view controller and simulate a device, like an iPhone X in portrait mode. This will set up the size and size classes of the view controller so that it approximate what thigns would look like on an actual iPhone X.

---

# Snapshot Strategies: `recursiveDescription`

``` swift
assertSnapshot(matching: view, as: .recursiveDescription)
```

```
<UIView; frame = (0 0; 1024 768); autoresize = W+H; layer = <CALayer>>
   | <UILabel; frame = (484.5 20; 55.5 20.5); text = 'What's'; userInteractionEnabled = NO; layer = <_UILabelLayer>>
   | <UILabel; frame = (0 384; 25 20.5); text = 'the'; userInteractionEnabled = NO; layer = <_UILabelLayer>>
   | <UILabel; frame = (985 384; 39 20.5); text = 'point'; userInteractionEnabled = NO; layer = <_UILabelLayer>>
   | <UILabel; frame = (508.5 750; 7.5 18); text = '?'; userInteractionEnabled = NO; layer = <_UILabelLayer>>
```

^ But images aren't the only interesting way to snapshot views. In the react community it is very popular to snapshot virtual dom hierarchies as plain text in order to track how views change. UIKit comes with a debugging function called "recursiveDescription" and we can use that to snapshot UIView hierarchies as text.

---

# Snapshot Strategies: `hierarchy`

``` swift
assertSnapshot(matching: vc, as: .hierarchy)
```

[.code-highlight: 1-99]
[.code-highlight: 1]
[.code-highlight: 2, 5, 7, 9, 11]
[.code-highlight: 3, 4]
```
<UITabBarController>, state: appeared, view: <UILayoutContainerView>
   | <UINavigationController>, state: appeared, view: <UILayoutContainerView>
   |    | <UIPageViewController>, state: appeared, view: <_UIPageViewControllerContentView>
   |    |    | <UIViewController>, state: appeared, view: <UIView>
   | <UINavigationController>, state: disappeared, view: <UILayoutContainerView>
   |    | <UIViewController>, state: disappeared, view: (view not loaded)
   | <UINavigationController>, state: disappeared, view: <UILayoutContainerView>
   |    | <UIViewController>, state: disappeared, view: (view not loaded)
   | <UINavigationController>, state: disappeared, view: <UILayoutContainerView>
   |    | <UIViewController>, state: disappeared, view: (view not loaded)
   | <UINavigationController>, state: disappeared, view: <UILayoutContainerView>
   |    | <UIViewController>, state: disappeared, view: (view not loaded)
```

^ We can even snapshot view controller heirarchies as text. This can be an amazing way to verify that children view controllers are managed correctly.

---

# Snapshot Strategies: `pdf`

## https://github.com/WeirdMath/SwiftyHaru

```swift
assertSnapshot(matching: document, as: .pdf)
```

^ This is a fun one, it's a 3rd party snapshot strategy. This comes from an open source projects that provides a Swift wrapper around LibHaru, a PDF generation C library that is cross platform. They created a custom snapshot strategy to snapshot their Swift data structures into an actual PDF document. 

^ So in the repo they have a ton of PDF artifacts that show exactly how certain pages render, which is great not only for testing but also for documentation and reference.

^ And they are getting tons of coverage on their library that would have other been very tedious to do by hand because the commands that back a PDF are very very verbose.

---

# Snapshot Strategies: `gif`

[.code-highlight: 1-99]
[.code-highlight: 3]
```swift
assertSnapshot(
  matching: canvas, 
  as: .gif(of: animation, duration: 1, framesPerSecond: 60)
)
```

![inline 100%](assets/animation-snapshot.gif)

^ Now this is an experimental snapshot strategy that we haven't made public yet. But we have an animation framework that we been working on, and we of course want test coverage on it. What better way to test an animation than to create a gif of the animation. Then any changes we make to the library we can be certain of how it changes animations.

^ This was an animation that I reproduced from the homepage of Apple's Arcade website. They have a bunch of cute little animations, and so I wanted to see how hard it would be to reproduce them and snapshot test them.

^ You can even customize the snapshot strategy by changing how long you want the animation to be and how many frames per second.

---

# Snapshot Strategies: `gif`

![inline 100%](assets/animation-snapshot-slow.gif)

^ Here I made the animation much longer so that we can get a really zoomed in look at how the animation is coordinated.

---

# Snapshot Strategies: `gif`

![inline 100%](assets/animation-snapshot-gif.gif)

^ This is super useful to have. It allows us to even test some of the fundamental units of the library, such as timing curves. Here is what an ease out animation looks like.

---

# Snapshot Strategies: `onion`

[.code-highlight: 3]
```swift
assertSnapshot(
  matching: canvas,
  as: .onion(of: circleAnimation, frames: 20)
)
```

![inline 100%](assets/animation-snapshot-onion.png)

^ We don't only have to snapshot as a gif either. We could snapshot as a static image, but overlap multiple frames on top of each other with an onion skin effect.

^ This is really only the beginning. There are soooo many things you can snapshot and so many ways you can customize those snapshots. It's really kind of amazing to do. 

^ And I think this is really only possible because of how the snapshot library was designed. It was not appropriate to use protocols for this library, and we got a lot of benefits by scrapping the protocols and just using simple data types.


---

# Transforming existing strategies into new strategies

^ And already all of this is so cool, but it's only the beginning. Turns out that the `Snapshotting` type supports a type of transformation that allows you to derive all new strategies from existing ones.

---

# Pullbacks

[.code-highlight: 1-99]
[.code-highlight: 2]
[.code-highlight: 3]
[.code-highlight: 4]
[.code-highlight: 6-12]
[.code-highlight: 9-11]
```swift
extension Snapshotting {
  func pullback<NewValue>(
    _ f: (NewValue) -> Value
    ) -> Snapshotting<NewValue, Format> {

      return Snapshotting(
        diffing: self.diffing,
        pathExtension: self.pathExtension,
        snapshot: { newValue in 
          self.snapshot(f(newValue))
        }
      )
  }
}
```

^ Here's the operation. It's a lot to take in, so we'll step through it.

^ The operation is called `pullback`. The reason for this name will become clear in a moment.

^ It says that if you have a function that goes from `NewValue` to `Value`, then you can transform your snapshotting strategy on `Value` into one on `NewValue`.

^ You should think of this operation somewhat related to the `map` operation that we all know and love on arrays. Recall that `map` on arrays says that if i have a function from `(A) -> B`, then you can transform arrays of `A`s into arrays of `B`s. You just traverse over the array of `A`s and apply your function to each element. The words we are using to describe `map` and `pullback` are very similar, but the direction has been flipped.

^ To implement this function we can just copy over the `diffing` and `pathExtension` fields from our `self`, and then to snapshot all we have to do is first apply the function `f` to our `newValue`, and then we snapshot.

^ There really is no concept of this operation in protocol land. You can't take a conformance to a protocol on one type and magically transform into into a conformance on another type. That makes no sense.

---

# Pullbacks

[.code-highlight: 1]
[.code-highlight: 3]
[.code-highlight: 4-7]
[.code-highlight: 9]
[.code-highlight: 10]
[.code-highlight: 12]
[.code-highlight: 13]
[.code-highlight: 1-99]
```swift
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

^ Here's how we can use it. Suppose we already have a snapshot strategy for `UIImage`'s in the `UIImage` format. Basically the strategy is responsible for serializing and de-serializing a `UIImage` into a PNG to be saved on disk, and it is responsible for doing a pixel-by-pixel diff on two `UIImage`s to figure out what is different about them. This strategy takes some actual work to implement so we aren't going to show it's implementation.

^ But once we have that strategy, we can derive a bunch more strategies with very little work.

^ For example, we can snapshot `CALayer`s. All you do is take the image snapshotting strategy, and pull it back via the transformation that turns layers into images via the `UIGraphicsImageRendered` API.

^ Then once we have that we can derive a snapshot strategy on `UIView`s by taking the layer strategy and pulling it back along the transformation that simply plucks the layer out of a view.

^ And finally we can derive a snapshot strategy on `UIViewController`s by just taking the strategy on views and pulling it back along the transformation that plucks the view out of a view controller.

^ And this is why the operation is called `pullback`. Because we think of it as a means to take a smaller more specific snapshot strategy and _pull it back_ to a larger structure.

^ Nearly all of the snapshot strategies provided by the library are pullbacks of just a few core strategies. And in fact, if you were to use this library and wanted to provide a snapshot strategy, you would most likely define it as a pullback of one of our strategies.

<!-- 
---

[.header: #000000]
[.background-color: #ffffff]

# Inline Snapshotting

![inline 100%](assets/inline-snapshotting.gif)

^ And then there are things like this. This is a contribution to the project from someone in the community, Robert Chatfield, and it's something we never even considered when making the library.

^ The idea is that although snapshot testing really shines for getting broad test coverage on really large data structures, like UIView hierarchies, it is also useful snapshotting smaller structures, like the URLRequest example.

^ In those cases it may be a little annoying to have the textual output of the snapshot to be saved in an external file when it could fit easily right inline in the test.

^ todo: finish -->

---

# Conclusion

* Protocols are the de facto abstraction tool in Swift

* Protocols still have problems, but they are getting better

* There is a process to turn protocols into concrete data types

* Doing so can fix some protocols problems and expose interesting transformations

^ So, that is protocol witnesses in a nutshell. I want to quickly recap how we got to where we are now, and to discuss the pros/cons of the situation.

^ We started by recalling that protocols are Swift's de facto way of forming abstractions, and that Apple pushes protocols hard.

^ But then we remembered that protocols have a ton of shortcomings. Protocols with associated types are wildly different from protocols without associated types. We can't conform tuples and functions to protocols. We can't extend protocols to conform to other protocols. And there's even more.

^ So we backed up and wondered if there were other ways of forming abstractions that do not use protocols, and hopefully do not have the same problems. 

---

* Pros
  * ✅ Gets around many protocol shortcomings
  * ✅ Encourages multiple conformances
  * ✅ Build new conformances from existing ones
  * ✅ Reveals transformations previously hidden

* Cons
  * 💔 Ubiquitous protocols
  * 💔 Deep protocol hiearchies
  * 💔 Advanced protocols

^ I certainly don't want to discourage people from using protocols entirely. I think they definitely serve a purpose, but many times they can do more harm than good. And so starting more simply with just basic concrete data types may yield more powerful abstractions.

^ The pros of this technique are clear. And in particular we think there are a lot of protocols that benefit from this style, such as protocols that only have 1 or 2 conformances, and protocols where it makes sense for types to have many conformances.

^ There are also of course cons. Since Swift is primarily a protocol-oriented language you are definitely going to get some friction with adopting this style.

^ For one, this style doesn't work super well for protocols that are ubiquitous. For example, you probably wouldn't make `CustomStringConvertible` a concrete type because a large part of its appeal is its ease of use in getting a string representation, like say in string interpolation.

^ Also if you have a deep protocol hiearachy this technique can get a little cumbersome. Essentially protocol inheritance corresponds to nesting of data types. And so you will have deeply nested types that might be a little annoying.

^ Also protocols that use super advanced features of Swift's type system are going to be difficult to model. You probably wouldn't redo the entire sequence and collection API in this style because they use some of the most advanced parts of protocols.

---

[.build-lists: false]

# [fit]Thanks!

<br> <br> <br> <br> 

* Brandon Williams
* @mbrandonw
* www.pointfree.co

![](assets/pf-square@6x.png)


