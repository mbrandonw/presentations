build-lists: true

# [fit] Things I have gotten use from in Swift...
### ...and some things that haven't been as useful

<br><br><br><br><br>

**Brandon Williams**
[twitter.com/mbrandonw](#)
[mbw234@gmail.com](#)

^ Hello, I'm Brandon, thanks for having me.

^ I've got some contact information here in case you want to reach out to ask questions or discuss more.

---

![original](assets/pf-square@6x.png)

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

### [ **www.pointfree.co** ](#)

^ If you don't know anything about me, I do consulting with companies under my company Point-Free, which I run with my collaborator Stephen Celis. We also run an educational video series here, and you might want to check it out if you find any of what i'm going to talk about tonight interesting.

---

# [fit] Things I have gotten use from in Swift...
### ...and some things that haven't been as useful

<br>

* Data over protocols
* Composition
* Mutation

^ And what i'd like to talk about tonight are some things in Swift that I have gotten a ton of use and mileage out of, and then a few things that haven't been quite as useful. That doesn't mean they are _useless_ and we should discard them. Sometimes those things are necessary, but often we can reach for a closely related, but different tool that brings more benefits.

^ First we are going to talk about data types and protocols. Protocols are an incredibly powerful feature of Swift, but they have their shortcomings, and so it'd be nice to know what alternatives there are.

^ Then we are going to talk about composition, which is a term used  a lot in programming, but rarely given a succint definition. And knowing this definition can help you uncover new forms of composition, and provide the language necessary to do a systematic study of how to break large problems into small problems.

^ Then we will discuss mutation. And some of you may know that I have a fondness for functional programming, and so you may not think mutation is any friend of mine, but it can be made reasonable and powerful

^ I've never given this talk before, it's kinda composed of some other talks all in one, so it may run a little long, and I may not get through it all. So let's dive in

---

# Data over Protocols

^ Let's start with certainly the most controversial, data over protocols. This is something I've spoken about at a conference last year, and something we've covered in great detail on Point-Free, and in the interest of time I'm going to give the quick distillation of the idea

^ Protocols are great! I love them, and I bet you love them, and Apple certainly loves them. I think that every single year since Swift was announced there has been a WWDC talk touting the amazing capabilities of protocols, and how they are a powerful tool for abstraction. I'm sure everyone here has seen the eponymous WWDC talk on protocol-oriented programming featuring the loveable Crusty.

^ I think it's completely reasonable that we would all come away from those presentations thinking that protocols can solve quite a few problems, and so the more we use them the better off our code will be. They will allow us to be maximally generic and we'll be able to share and reuse so much code. Everything will be great!

---

# Protocols

> 🛑 Protocol can only be used as a generic constraint because it has Self or associated type requirements

^ Unfortunately that isn't quite true, primarily because there are quite a few things that protocols can't do. Perhaps the gnarliest of all of protocols shortcomings is this one, in which the moment you use an associated type or Self with a capital S in your protocol, it no longer acts in the way you would expect. You can't use it as a type for a variable, you can't create an array of values from that protocol, amongst other things.

^ And this is probably the first protocol shortcoming people come across. But there are more.

---

# Protocols

[.code-highlight: 1-6]
[.code-highlight: 7-12]
[.code-highlight: 13-99]
```
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
    for a in A.allCases {
      if lhs(a) != rhs(a) { return false }
    }
    return true
  }
}
```

^ you can't extend `Void` to conform to protocols

^ more generally you can't extend tuples to conform to protocols. not only because you can't extend tuples, but also because you can't introduce generics in tuples so that you even have access to this `A` and `B`

^ and you can't extend functions to conform to protocols

^ These things are all reasonable things to do, yet completely impossible, and the swift team certainly wants to add this someday, but I don't think there is a timeline of when we'll get it.

---

# Protocols

[.code-highlight: 1-4]
[.code-highlight: 6-99]
```
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

```
protocol ProtocolA {}
protocol ProtocolB {}

extension ProtocolA: ProtocolB {}
```

> 🛑 Extension of protocol 'ProtocolA' cannot have an inheritance clause

^ There's also this defect of protocols, which i have a very simplified version of it.

^ In short, you cannot extend a protocol to make it conform to another protocol, even if you provide all of its requirements right in the extension. I don't know of any legitimate reason this isn't possible, I think it just hasn't been proposed and designed yet.

^ Now some of problems will most likely be fixed some day, like protocols with associated types. There have been mumblings on the evolution forums to fix some other things, but there's no timeline or sense of urgency.

---

# [fit] Non-protocol forms of abstraction

^ So, if protocols are the primary form of abstraction in Swift, and Apple pushes it hard, but there are significant problems with protocols, what are we to do?

^ Turns out, there is a very simple process in which you can convert most (if not all) protocols into very simple, concrete data types. And when you do that some of their problems go away and the problems that remain become a bit clearer why they are troublesome in the first place.

^ But most importantly, in my opinion, is that new transformations appear that were previously difficult or impossible to see when living in the world of protocols. And that's what I find most exciting.

^ And you may be worried about going against the guidance of apple, but even apple has tweaked their language around protocols. 

---

![inline](assets/start-with-a-protocol.png)

^ they used to say "start with a protocol". that is, when you are sitting down to create your application you would write protocols for your domain so that you would be maximal abstract with your interface and implementation.

^ But as we saw, protocols have significant problems, and so last year the language evolved to

---

![inline](assets/dont-start-with-a-protocol.png)

^ Now they say "Don't literally start with a protocol"

---

![inline](assets/generic-type.png)

^ they even say that a generic, concrete types are a good substitute

---

# De-protocolization

^ And that is exactly what we are going to do.

^ We are going to describe a real world case study of a set of protocol that were useful, but not quite as useful as they could be. and show the process of deprotocolizing to concrete types, and see what kind of cool stuff comes out the other side.

---

# [fit] Case Study: Snapshot Testing

https://github.com/pointfreeco/swift-snapshot-testing

![100%](assets/github-snapshot-testing.png)

^ It's a snapshot testing library that I open sourced with my collaborator Stephen Celis, and it's been open source and in production use by us for over 2 years, but we officially released the 1.0 in december 2018.

^ The pre-1.0 version was built with protocols, and it served us well enough, although there were a few drawbacks.

^ Finally, those drawbacks became annoying enough that we decided to scrap the protocols, use simple data types, and we started uncovering all types of cool things, and that's what we released as the 1.0

---

# What is snapshot testing?

^ Usually at this point I would give a whole spiel about what snapshot testing is, but I know y'all do a ton of it, so I can mostly skip this.

^ The only thing I will say is that if you think of screenshots when I say "snapshot testing", then there are lot more types of snapshot testing out there. You can snapshot any kind of value into any kind of format, not just controllers and views into png images.

---

### What is snapshot testing?

```
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

# [fit] Protocol-oriented snapshot testing

[.code-highlight: 1-99]
[.code-highlight: 1-5]
[.code-highlight: 2]
[.code-highlight: 3]
[.code-highlight: 4]
[.code-highlight: 7-11]
[.code-highlight: 8]
[.code-highlight: 9]
[.code-highlight: 10]
```
protocol Diffable {
  static func diff(old: Self, new: Self) -> (String, [XCTAttachment])?
  var data: Data { get }
  static func from(data: Data) -> Self
}

protocol Snapshottable {
  associatedtype Format: Diffable
  var snapshot: Format { get }
  static var pathExtension: String { get }
}
```

^ We ended up with two protocols. First there was the `Diffable` protocol, that expresses the idea of a type that can be diffed for testing. That means it can be serialized and de-serialized to disk, and that can be diffed for testing. The most common conformers of this type are string, where diffing happens on a line-by-line basis like what git does to your source code, and UIImage, which does a pixel-by-pixel diff.

^ Then we have a `Snapshottable` protocol, which expresses the idea of types that can be snapshot. It has an associated type that represents the diffable format that we can snapshot into. It has a path extension so that we know what type of file to save to disk. And then we have a way of turning our type into an actual diffable format.

---

# [fit] Protocol-oriented snapshot testing

```
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

^ * Some types want to be snapshot in multiple ways. URL requests could be snapshot in the format we just showed, or could be snapshot in the cURL format, or could have even be snapshot as an HTML document or image of what the server responds with when sent that request. This is very useful for server side swift development.
* There are also some types we want to snapshot that are not possible to with the protocols. like we can't extend `Encodable` to be snapshottable, thus allowing us to snapshot any model into a json file, because again protocols cannot be extended to conform to other protocols.

---

# Scrapping the protocols

[.code-highlight: 1-99]
[.code-highlight: 1, 10]
[.code-highlight: 2, 11]
[.code-highlight: 3, 12]
[.code-highlight: 4, 13]
```
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

^ So, let's scrap the protocols for our library and convert them to simple generic types. We'll do them one at a time. This process is very mechanical, and the tricks we use to convert diffable and snapshottable to concrete types can be used for most protocols out there.

^ First we have the `Diffable` protocol. The first thing we do is rename it to `Diffing` and introduce a generic to represent the `Self` with a capital S of the protocol. Usually protocols are named with the "-able" suffix to signify that types conform to it are blank-able, like diffable. We use the "-ing" suffix to signify that instances of this type represent the process of diffing the value generic.

^ The static `diff` function becomes a simple function field, and notice that it takes a `Value` argument for each of the arguments of the static method, and that's it. There is no implicit self in a static method.

^ And the `data` computed property becomes a function field from `Value` to `Data` because computed properties have an implicit self attached to them.

^ Similarly the static `from` method becomes a simple function field from `Data` to `Value`.

^ Already I think this is quite a bit simpler than the protocols. It makes it very clear that diffing just means there is a way to serialize and de-serialize to data, and a way to diff into failure messages.

---

# Scrapping the protocols

[.code-highlight: 1-99]
[.code-highlight: 1, 10]
[.code-highlight: 2, 10]
[.code-highlight: 2, 11]
[.code-highlight: 3, 12]
[.code-highlight: 4, 13]
```
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

# Scrapping the protocols

```
func assertSnapshot<Value, Format>(
  matching: Value,
  as: Snapshotting<Value, Format>
) {
  // ...
}
```

^ Now that we have our concrete types, we can rewrite our assert snapshot helper so that instead of constraining the generic to `Snapshottable` types, we require an explicit snapshotting value. The implementation of this function looks almost identical to the one that used protocols.

---

# Snapshot Strategies

^ The library comes with tons of snapshot strategies. It's so easy to create new strategies, and you don't have to be afraid of conforming a type to a protocol and solidfying in time forever that types one single conformance. Some types, like `UIView` and `UIViewController` have many many many conformances

^ Let's take a little tour of some strategies:

---

# Snapshot Strategies: `dump`

```
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

```
assertSnapshot(matching: user, as: .json)
```

```
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

# [fit] Snapshot Strategies: URLRequest `raw`

```
assertSnapshot(matching: request, as: .raw)
```

<br>  

```
POST http://localhost:8080/account
Cookie: pf_session={"userId":"1"}

email=blob%40pointfree.co&name=Blob
```

^ There are also some domain specific strategies, like this one that is specifically tuned for snapshotting URLRequests. It does some extra work to nicely format and it even renders the POST body as json if possible.

---

# [fit] Snapshot Strategies: URLRequest `curl`

```
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
```
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

# Snapshot Strategies: `pdf`

#### [https://github.com/WeirdMath/SwiftyHaru](#)

<br><br>

```
assertSnapshot(matching: document, as: .pdf)
```

^ This is a fun one, it's a 3rd party snapshot strategy. This comes from an open source projects that provides a Swift wrapper around LibHaru, a PDF generation C library that is cross platform. They created a custom snapshot strategy to snapshot their Swift data structures into an actual PDF document. 

^ So in the repo they have a ton of PDF artifacts that show exactly how certain pages render, which is great not only for testing but also for documentation and reference.

^ And they are getting tons of coverage on their library that would have other been very tedious to do by hand because the commands that back a PDF are very very verbose.

---

# Snapshot Strategies: `gif`

```
assertSnapshot(
  matching: canvas, 
  as: .gif(of: animation, duration: 1, framesPerSecond: 60)
)
```

![inline 100%](assets/animation-snapshot.gif)

---

# Snapshot Strategies: `gif`

![inline 100%](assets/animation-snapshot-slow.gif)

---

# Snapshot Strategies: `gif`

![inline 100%](assets/animation-snapshot-gif.gif)

---

# Snapshot Strategies: `onion`

[.code-highlight: 3]
```
assertSnapshot(
  matching: canvas,
  as: .onion(of: circleAnimation, frames: 20)
)
```

![inline 100%](assets/animation-snapshot-onion.png)


---

# Data over protocols

^ That right there is a quick introduction to the idea. There is a ton more to say, but I just wanted to give you a peak into the idea of how protocols can often be replaced by concrete types that are quite simple and help clear away some of the fog introduced by protocols.

^ And again, I'm not saying that protocols aren't useful, just that their use may sometimes be overstated, and so understanding the alternatives to protocols can only strenghten your tool site for attacking problems

^ We actually have one more thing to say about the topic, but in order to understand it we need to take a quick tour through...

---

# Composition

^ This is the next thing I get a lot of use out of in Swift.

^ Composition is one of those words that come up quite a bit in programming, but rarely do we hear a succinct, rigorous definition of the term.

^ And that's a bummer because the word seems to carry a lot of weight in programming communities. As soon as someone mentions that something has composability it has somehow been blessed so that everyone knows it must be really powerful.

^ so it's strange that programmers don't try to settle on an accepted definition of this term. After all most of their time is trying to describe in clearest terms possible what the compiler or computer should do. Yet a word like composition is thrown around and everyone has their own personal feeling of what it means

^ What I'm about to say about composition is a condensed version of a talk I'm giving at the swift language user group tomorrow evening, so if you are interested in learning more you could check that out

---

# Definition of composition

> A process that combines two objects of a type into a third of the same type.

^ So let's start simple and say that composition is nothing more than a process that allows us to combine two objects of a particular type into a third of the same type.

^ This is an incredibly simplistic way of looking at composition, but we will see that pretty much everything we think of as composition today abides by this definition

^ Further, although the definition of composition can be disilled into this simple definition, the ergonomics and power of a particular type of composition is not captured here. As we consider lots of examples of composition we will see that composition exists on a spectrum, and the power of a particular type of composition largely depends where on the spectrum it sits.

---

# Zoo of composability

^ And with that definition in hand, let's start exploring the zoo of composability in the programming world

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

^ functions are composable, and let's write down exactly what that means. We can write a completely generic function that takes any two functions, as long as the output of one matches the input of the other, and we can combine them into a third function.

^ This is the most canonical, simple example of composition out there. On the composition spectrum it is definitly on the far side of powerful and ergonomic. The fact that we could so simply write such a generic function that works with any function speaks to that

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

^ for many of us the first time we probably heard the word "composition" in programming is due to this adage: prefer composition over inheritance. This is a truism from OOP that says that many times when you think you want to reach for inheritance what you really want is composition. 

^ Composition is usually not rigorously defined, but what they mean is that instead of having class `A` inherit from class `B`, you can create a third class `C` that holds instances of `A` and `B` and exposes an interface that mixes their functionality together in some way.

^ Say we had a class that encapsulated the behavior of getting a person's current location.

^ And a class that encapsulated the behavior of searching for points of interest

^ And from those we wanted to derive something more domain specific for our application, which is a class that encapsulates the behavior of getting a person's recommendations near where they are right now.

^ If our minds only thought of things in terms of inheritance we may be able to convince ourselves that we could use inheritance so that we take a base class and enchance its functionality. So we inherit from the location manager to enhance its functionality with the idea of being able to search for points of interest, and then we inherit from that to enchance its functionality with the idea of being able to layer in user recomendations.

^ Alternatively, we could just create a third class that holds instances of the other two classes, and then only expose an API that makes sense for that wrapper, and under the hood it can use the other two classes as much as we want.

^ It's worth noting that "composition over inheritance" in OOP is only a guideline, and cannot be codified into a program that takes two classes and produces the third composed class. This is demonstrating that spectrum I mentioned before, certain types of composition are simpler than others, and some are more ad hoc than others.

---

# Code generation

<br>

^ Even code generation could be thought of as a process of composition. Perhaps you have a sourcery template that says when I have two types annotated with something in particular I will generate the code for a third object.

^ This is just as valid of a "process" to compose things.

^ But also, it's super complex. This requires you have build infrastructure in place so that you can be sure to generate new code exactly when necessary, and never too early or too late.

^ This makes this kind of composition quite a bit less powerful and ergonomic than the other kinds we have seen so far.

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

# Optionals

```
let x: A?
let y: A?

x ?? y
```

---

# Results

[.code-highlight: 1-6]
[.code-highlight: 1-14]
```
func choose<A, E>(_ lhs: Result<A, E>, _ rhs: Result<A, E>) -> Result<A, E> {
  switch lhs {
  case .success:  return lhs
  case .failure:  return rhs
  }
}

let x: Result<A, E>
let y: Result<A, E>

choose(x, y)
```

---

# Arrays

```
let xs: [A]
let ys: [A]

xs + ys
```

---

# Dictionaries

```
let xs: [K: V]
let ys: [K: V]

xs.merge(ys)
```

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

# `map`

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

---

# `zip`

```
zip: ([A], [B]) -> [(A, B)]
```

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

---

# `flatMap`

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

---

# Random Number Generators

```
struct Gen<A> {
  let run: (inout RandomNumberGenerator) -> A
}
```

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

---

# Random Number Generators

[.code-highlight: 1]
[.code-highlight: 3-4]
```
map: ((A) -> B) -> (Gen<A>) -> Gen<B>

let int: Gen<Int>
int.map(ordinal) // 5th, 3rd, 1st
```

---

# Random Number Generators

[.code-highlight: 1]
[.code-highlight: 3-4]
```
zip: (Gen<A>, Gen<B>) -> Gen<(A, B)>

let name: Gen<String>
let user = zip(int, name).map(User.init(id:name))
```

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

---

# Parsers

```
struct Parser<A> {
  let run: (inout String) -> A?
}
```

---

# Parsers

```
let int: Parser<Int>

var input: "123dog"

int.run(&input) // 123
input           // "dog"
```

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

---

[.code-highlight: 1]
[.code-highlight: 3-99]
```
zip: (Parser<A>, Parser<B>) -> Parser<(A, B)>

let name: Parser<String>
let user = zip(int, name).map(User.init(id:name))

user.parse("42Blob") // User(id: 42, name: "Blob")
```

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

---

# Parsing

## 40.446° N, 79.982° W

<br>

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

```
struct Async<A> {
  let run: ((A) -> Void) -> Void
}
```

^ But it keeps going, asynchronous values also fit into this compositional world.

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

# Snapshot Testing

```
💔 map: ((A) -> B) -> (Snapshotting<A, Format>) -> Snapshotting<B, Format>
```

^ And let's bring things back to a topic we talked about earlier: snapshot testing. what if snapshot testing supported a map operation?

^ if it did it would allow us to take an existing snapshot strategy on some value `A` and then somehow transform it into an all new snapshot strategy on `B`, via some transformation relating `A`s and `B`s.

^ But unfortunately this is not possible. It is in fact impossible to implement this function, i recommend you try!

---

# Snapshot Testing

```
😍 pullback: ((B) -> A) -> (Snapshotting<A, Format>) -> Snapshotting<B, Format>
```

^ But, snapshot testing does support a closely related operation, called `pullback`.

^ This signature is very similar to the `map` signature, but with one small change: notice that we are given a function from `B` to `A`, yet somehow we are transforming snapshots of `A` into snapshots of `B`

^ The direction of the first function is flipped, it goes in the opposite diretion we are used to. And it may seem counterintuitve, but this is simply the way things are, we have no choice here. We have actually stumbled upon another form of composition here, and it's even weirder than the other ones.

^ The way to think about this is if we have a snapshot strategy on a specific type, we should be able to pull it back to a larger type by projecting out of that larger type and then snapshotting

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

# Build systems

> **Build Systems à la Carte**
> 
Andrey Mokhov, Neil Mitchell, Simon Peyton Jones
<br>
> 
> [https://www.microsoft.com/en-us/research/uploads/prod/2018/03/build-systems.pdf](#)

^ And I'll end with a quick reference to yet another example of this principle of searching composition, and that is build systems. It is kind of amazing that the search for composition can unite so many disparate topics, such as randomness, parsing, snapshot testing, app architecture and build systems

^ But this paper here does a systematic study of how one would model a build system in terms of its fundamental units, just like we did for all the previous examples

^ Once the base units are defined, their compositional properties are explored, and all types of wonderful insights are gained.

^ Once you create the formal language for build systems you can start to really figure out what distinguishes one build system from another. 

^ For example, in trying to model Buck in this formal language one discovers that you can define a `zip`-like operation, but you cannot define `flatMap`, and this is because Buck does a topological sort of its tasks. 

^ On the other hand, for Nix you can define a `flatMap` operation because Nix handles tasks by building them when necessary and suspending dependent tasks.

---

# App Architecture

---

# Reducers

---

# Reducers

```
struct Reducer<State, Action> {
  let run: (inout State, Action) -> Effect<Action>
}
```

---

# Reducers

```
func combine<State, Action>(
  _ lhs: Reducer<State, Action>,
  _ rhs: Reducer<State, Action>
) -> Reducer<State, Action> {
  ...
}
```

---

# Reducers

```
💔 map: ((S) -> T) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

---

# Reducers

```
💔 pullback: ((T) -> S) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

---

# Reducers

```
😍 pullback: (WritableKeyPath<T, S>) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

---

# Reducers

```
💔                ((T) -> S ) -> (Reducer<S, Action>) -> Reducer<T, Action>

😍 (WritableKeyPath<T,    S>) -> (Reducer<S, Action>) -> Reducer<T, Action>
```

---

# Reducers

```
💔 map: ((A) -> B) -> (Reducer<State, A>) -> Reducer<State, B>
```

---

# Reducers

```
💔 pullback: ((B) -> A) -> (Reducer<State, A>) -> Reducer<State, B>
```

---

# Reducers

```
💔 pullback: (WriteableKeyPath<B, A>) -> (Reducer<State, A>) -> Reducer<State, B>
```

---

# Reducers

```
💔 pullback: (?????<B, A>) -> (Reducer<State, A>) -> Reducer<State, B>
```

---

# Mutation

^ The next useful thing in Swift I want to talk about is mutation. And not just mutation in general, but a very specific type of mutation that Swift has codified into the language

---

# `inout`

^ In particular, the `inout` feature of swift.

^ You may already be familiar with `inout`, and you may already have strong opinions on it. Beyond just its basic definition I'd like to demonstrate that it is a part of a much larger pattern in programming that has simply been given special compiler support by swift.

---

# `inout`

[.code-highlight: 1-3]
[.code-highlight: 5-99]
```
func increment(_ x: inout Int) {
  x += 1
}

let x = 1
increment(x) // 🛑 Cannot pass immutable value as inout argument

var y = 1
increment(&y) // ✅
```

^ So, just in case you are not familar with `inout`, it is an annotation you can put on an argument of a function to indicate that the function is allowed to make mutations to that value that are observable to the caller of the function

^ Without this annotation it is impossible for the function to mutate `x` in anyway knowable to whoever calls this function. at best it can make a local copy and mutate that, but no one would ever see that

^ But that's only half the store, the other half happens at the call site. it is not enough to pass a value to a function wanting `inout`, you must also annotate your variable with an ampersand in order to tell the compiler that you acknowledge that this function can mutate your value.

^ So the caller of this function is entering a contract with the implementer of the function. One is saying I require a mutable value for you to be able to call me, and the other is saying I will allow mutation to this value I am passing you.

---

# `inout`

```
func increment(_ x: inout Int) {
  x += 1

  DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
    // 🛑 Escaping closure captures 'inout' parameter 'x'
    x -= 1
  }
}
```

^ And this contract is even stronger than it sounds at first. The contract says not only do both parties have to agree on mutation, but also the mutation must happen at the time of invoking the function and cannot happen at any other time.

^ Say I tried to do something silly and sneak in a little bit of async work that waited for a second and then tried to decrement the value, thus undoing the work we just did

^ `inout` forbids this from happening. The mutation is not allowed to escape out into another scope that is executed at another time. This code simply will not compile

---

# Reference mutation

[.code-highlight: 1]
[.code-highlight: 3-5]
[.code-highlight: 7-99]
```
class IntRef { var value: Int }

func increment(_ x: IntRef) {
  x.value += 1
}

let x = IntRef(value: 1)
increment(x) // ✅
```

^ This is **wildly** different from the world of reference mutation. Mutating references can happen anywhere, anytime, and no one can know what is happening without reading the actual implementation of a function

^ Here we have a reference type wrapping an integer

^ And a function that increments the value in that reference

^ And we can pass a reference to the function

^ Notice that the function and the call site don't need any special decoration to indicate we plan on making mutations

---

# Reference mutation

```
func increment(_ x: IntRef) {
  x.value += 1

  DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
    // ✅
    x.value -= 1
  }
}
```

^ And there are no restrictions on when the mutation can happen. We can sneak in this code so that it undoes our work after a second

^ And this kind of behavior is incredibly confusing. We could invoke this increment button with our reference, immediately after verify that indeed the value is exactly what we expect, and then magically the reference gets reset after a second

^ And worse, _everyone_ that holds onto this reference will also experience this magical mutation. This is what people mean when they say things like "action at a distance". This function has the abililty to make changes to references that are used in every dark corner of our application, and no one will even know where those mutations came from

---

# `inout`

^ And now we see we've got value mutations, which are only locally scoped, can only be observed in that scope, and cannot leak out until other parts of the program

^ And you've got reference mutations, which you have to assume are globally scoped, can be observed by anyone, and can leak into any part of the app

^ So clearly if you can get away with doing only value type mutations you will be in a much better situation. 

^ But what Swift has done is taken something that has some compile-time safety built in, and made it more ergonomic. That is exactly what `inout` is

---

# Essence of mutation

^ To see this, we need to understand the basic shape of what mutation is trying to express in our program

^ at its core you have some piece of state at hand, and you want to do a computation with that state in order to produce some result. But in the process of doing that computation you may also want to change the current state you are in.

---

# Essence of mutation

```
(State) -> (Result, State)
```

^ You could literally distill that description i just said into a function signature. Mutation is a function that takes the current state, produces a result from it while also potentially changing the current state.

^ However, this is how one would approach mutation in an immutable language, and the ergonomics of this signature leave much to be desired. You must always return a state value from this function, even if you don't want to perform any mutations. Or worse, say you did want to mutate on tiny part of the state, you would still be responsible for constructing a whole new value from scratch in order to return it from this function

^ And this shape of function appears a shocking number of times in programming. It is the base unit of many important things

---

# Randomness

### `(State) -> (Result, State)`

<br><br>

```
struct Gen<A> {
  let run: (Rng) -> (A, Rng)
}
```

^ Randonmess has this shape, as we've already discuss. To compute a random value of type `A` we need to plug in our base unit of randomness, a black box that produces values in the huge space of `UInt64`s, and then from that we will get our random `A` value, as well as a new black box that can be used for subsequent random values.

---

# Parsers

### `(State) -> (Result, State)`

<br><br>

```
struct Parser<A> {
  let run: (String) -> (match: A?, rest: String)
}
```

^ Parsers also have this shape, where you run a parser on a string and you get the match you made (which could be `nil`), and you get the rest of the string that needs to be parsed

---

# Reducers

### `(State) -> (Result, State)`

<br><br>

```
struct Reducer<State, Action> {
  let run: (State, Action) -> (Effect<Action>, State)
}
```

^ And even reducers have this shape, where you run a reducer on your current state and some user action, and you get back the list of effects that need to be run, as well as the next state of the application

^ There are tons of these examples, and it a super common shape in programming.

---

# Essence of mutation

```
(State) -> (Result, State)

👇

(inout State) -> Result
```

^ And so what `inout` does is allow us to write this function in an equivalent way, but that is much easier to use

^ Instead of taking a state in as input, and returning a whole new state as output, `inout` allows us to get rid of the return value, and just allow an in-place mutation of the input argument

^ These two signatures are equivalent in the sense that you can literally write a generic swift function that converts from what style to the other, and if you convert from inout and then to inout you would get back exactly where you started.

---

# Essence of mutation

```
struct Gen<A> {
  let run: (inout Rng) -> A
}

struct Parser<A> {
  let run: (inout String) -> A?
}

struct Reducer<State, Action> {
  let run: (inout State, Action) -> Effect<Action>
}
```

^ And the types for gen, parser and reducer can all be changed to use inout 

^ And in each of these cases the use of `inout` improves the ergonomics of the api, for you can just make mutations directly to values without construct brand new ones from scratch

^ it also has the potential to improve the performance, for we also don't need to make copy of values, many times the swift compiler can optimize `inout` mutations to happen directly in place.

---

# `inout`

```
(A, B) -> (A, C) ⟿ (inout A, B) -> C
```

^ And the pattern applies more generally. Essentially, if you have two types appearing a single type on the let and right side of the function array you can remove the output type at the cost of introducing an `inout` to your input type

---

# Ownership

^ And `inout` is only one facet of a much larger movement to increase the power of the type system so that it allows us to do seemingly unsafe things, but in a safe and ergonomic way.

^ Another example is the idea of ownership. It is generally very complex to hand objects off to threads or to other objects that might retain them.

^ You run the risk of race conditions, corrupted memory, retain cycles, amongst other things

^ ARC was one attempt at making this situation more ergonomic so that we no longer had to do the book keeping of retain and release. but it's a runtime feature, though parts of it could be statically analyzed to provide warnings.

^ but ownership can be made much stronger. it can be encoded directly into the type system so that you are not even allowed to compile your program unless you prove certain things to the compiler, much like how we did with `inout` and escaping closures

---

# Ownership

```
class IntRef {
  var value: Int

  func foo() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      // 🛑 Reference to property 'value' in closure requires explicit 
      //    'self.' to make capture semantics explicit
      value += 1
    }
  }
}
```

^ And right now swift can detect some of the most basic versions of this problem.

^ For example, it is not allowed to implicitly use `self` in an escaping closure, because this code looks like you are doing something really innocent, but really you are allowing a mutable reference to leak out into the world, which could cause a retain cycle if you dont know who is holding onto your reference


---

# Ownership

```
class IntRef {
  var value: Int

  func foo() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      // ✅
      self.value += 1
    }
  }

  func bar() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      // ✅
      self?.value += 1
    }
  }
}
```

^ So Swift requires you to be explicit by either using `self` or capturing `self` in a weak way or an unowned way.

^ But this idea could go so much further. what if you could prove certain things to the compiler about how lifetimes of objects will be used so that you don't need to do this dance?

^ For example, although the closue handed to `asyncAfter` must be escaping, it does not have any meaningful lifetime of its own. It just waits an amount of time, executes, and then its done. It's tear down isn't dependent on other objects that could complicate this situation. So capturing `self` here will never lead to a retain cycle.

^ So if we had a way to prove that to the compiler, we wouldn't need to do anything special with this closure, we could just access instance variables inside like normal, and we could rest assured that we would not have a retain cycle

---

# Mutation

^ and that concludes the section about mutation

^ I think Swift has done something really amazing by giving us a safe version of mutation, and has given us tools that improve the ergonomics of mutation

^ And we haven't even heard the end of `inout`. There's a new feature coming someday known as `modify` and `yield` that improve the performance of `inout` greatly, making it even more of the obvious choice for API design

---

# [fit] Things I have gotten use from in Swift...

### ...and some things that haven't been as useful

<br><br><br><br><br>

**Brandon Williams**
[https://www.pointfree.co](#)

![](assets/pf-square-dark.png)