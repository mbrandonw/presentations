build-lists: true

# Testing Swift macros

^ Hello!

^ Macros are a wonderful new tool provided by Swift as of version 5.9 that can add all new super powers to your code.

^ Most people here have probably mostly interacted with macros by using ones already provided by Apple, such as the `@Observable` macro and `@Model` macro from SwiftData.

^ However, there will eventually come a time where you will finally want to write a macro yourself, but it can be quite difficult to do so correctly. Because macros are essentially little Swift programs that analyze existing Swift code in order to generate all new Swift code, it is easy to accidentally generate invalid code.

^ So, today we will be discussing how one tests macros.

---

# 👋

## Brandon Williams
### brandon@pointfree.co

## Stephen Celis
### stephen@pointfree.co

^ But first, we are Brandon and Stephen, and here is some contact info for everyone.

---

# Point-Free

### [www.pointfree.co](#)

![](pf-bg.jpeg)

^ You may know of us from our website Point-Free, a weekly video series that covers advanced topics in the Swift programming language, such as what we are going to discuss here today. If you find today's talk interesting then you may also find our videos very interesting.

---

# What is a macro?

^ Let's start with the basics. What is a macro?

^ Now we are not going to go in great detail about all the different flavor of macros, how they are used, or how to implement them. We are going to assume you know the basics and that you are familiar with some of the material from last year's WWDC.

^ In this talk we will mostly concentrate on the testing of macros. 

---
[.build-lists: false]

# What is a macro?

* A compiler plugin
  * Swift executable
  * `.macro` SPM target


^ So, we will just say that at a very high level, macros are compiler plugins, in fact they are executables, that are invoked as Swift is compiling your application's code. They are defined in the SPM Package.swift file, and they even have their own kind of target.

---

[.build-lists: false]

# How to use a macro?

* Attached to existing Swift code:

```swift
@Observable
class FeatureModel { … }
```

^ Macros can be applied in one of two ways.

^ It can be either attached directly to existing code, in which case an `@` symbol is used to indicate a macro.

^ Perhaps the most popular and most used macro in the Swift ecosystem is the `@Observable` macro, which enhances any class type with extra capabilities that allow any outside system to observe changes that happen inside the class.

---

[.build-lists: false]

# How to use a macro?

* Attached to existing Swift code:

```swift
@Observable
class FeatureModel { … }
```

* …or freestanding:

```swift
#Preview {
  FeatureView(…)
}
```

^ But also macros can be completely freestanding and not attached to any existing code.

^ In such cases the macro is prefixed with the `#` symbol.

--- 

# What does a macro do?

* Generates new Swift code

* Generate diagnostics and fix-its

* Applies more macros

^ And what can macros do?

^ Well, first and foremost a macro simply inserts more Swift code into your application that gets compiled right along the rest of your Swift code.

^ But also macros are capable of rewriting existing code in your application.

^ Macros can also generate diagnostics, such as warnings and errors that are surfaced in Xcode, as well as "fix-its", which gives uses a nice UI in Xcode for altering incorrect code into the correct format.

^ And finally, macros can apply more macros to your code, allowing the process to continue a few more times. However, macros cannot be recursively applied, so the process does always end at some point.

---

# Examples of macros

^ Let's quickly look at some examples of macros, starting with a few that Apple ships with Swift and platform SDKs.

---

```swift
import Observation

@Observable
class FeatureModel {
  var count = 0
}
```

^ First there's the `@Observable` macro that is part of the open source Swift project. You can go to GitHub right now and see how this macro is implemented.

---

[.code-highlight: all]
[.code-highlight: 6]
[.code-highlight: 7-18]
[.code-highlight: 19-28]
[.code-highlight: 30]
[.code-highlight: 1-4, 6, 29]
```swift
import Observation
 
@Observable
class FeatureModel {
  @ObservationTracked
  var count = 0
  {
    @storageRestrictions(initializes: _count)
    init(initialValue) { _count  = initialValue }
    get {
      access(keyPath: \.count )
      return _count
    }
    set {
      withMutation(keyPath: \.count ) { _count  = newValue }
    }
  }
  @ObservationIgnored private  var _count  = 0
  @ObservationIgnored private let _$observationRegistrar = ObservationRegistrar()
  internal nonisolated func access<Member>(keyPath: KeyPath<FeatureModel , Member>) {
    _$observationRegistrar.access(self, keyPath: keyPath)
  }
  internal nonisolated func withMutation<Member, MutationResult>(
    keyPath: KeyPath<FeatureModel , Member>,
    _ mutation: () throws -> MutationResult
  ) rethrows -> MutationResult {
    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
  }
}
extension FeatureModel: Observable {}
```

^ If we expand the macro in Xcode we will see everything it adds.

^ In essense it works by swapping out the stored property of `count` for a computed property and underscored stored property. this allows the class to tell the observation framework whenever the property is accessed and mutated so that it can notify any listeners that changes have happened.

^ the macro also adds some other properties and methods

^ as well as extends the class to conform to the `Observable` protocol.

^ This is quite a bit of code that is generated for us by the macro. It would be a bummer if we had to maintain all of this code ourselves, and it pays of even more as the class becomes more complex.

---

```swift
import SwiftData

@Model
class FeatureModel {
  var count = 0
  init(count: Int = 0) {
    self.count = count
  }
}
```

^ Here's another example, the `@Model` macro from SwiftData.

---

[.code-highlight: all]
[.code-highlight: 5, 7-22, 26-41, 43, 44]
[.code-highlight: 1-4, 6, 23-25, 42]
```swift
import SwiftData
 
@Model
class FeatureModel {
  @_PersistedProperty
  var count = 0
  {
    @storageRestrictions(accesses: _$backingData, initializes: _count)
    init(initialValue) {
        _$backingData.setValue(forKey: \.count, to: initialValue)
        _count = _SwiftDataNoType()
    }
    get {
        _$observationRegistrar.access(self, keyPath: \.count)
       return self.getValue(forKey: \.count)
    }
    set {
      _$observationRegistrar.withMutation(of: self, keyPath: \.count) { self.setValue(forKey: \.count, to: newValue) }
    }
  }
  @Transient
  private var _count: _SwiftDataNoType = _SwiftDataNoType()
  init(count: Int = 0) {
    self.count = count
  }
  @Transient
  private var _$backingData: any BackingData<FeatureModel> = FeatureModel.createBackingData()
  public var persistentBackingData: any BackingData<FeatureModel> {
    get { _$backingData }
    set { _$backingData = newValue }
  }
  static var schemaMetadata: [Schema.PropertyMetadata] {
    return [Schema.PropertyMetadata(name: "count", keypath: \FeatureModel.count, defaultValue: 0, metadata: nil)]
  }
  required init(backingData: any BackingData<FeatureModel>) {
    _count = _SwiftDataNoType()
    self.persistentBackingData = backingData
  }
  @Transient
  private let _$observationRegistrar = ObservationRegistrar()
  struct _SwiftDataNoType {}
}
extension FeatureModel: PersistentModel {}
extension FeatureModel: Observable {}
```

^ When expanded you get this, which is even more code that the `@Observable` macro. 

^ We can even highlight only the code expanded by the macro and we will see it's the vast majority of the code in the class now.

^ We would of course never want to write all of this code, but allowing a macro to generate it for us automatically gives us all kinds of super powers with SwiftData.

---

```swift
import CasePaths

@CasePathable
enum Event {
  case empty
  case response(User)
  case loading(percent: Double)
  case error(Error)
}
```

^ Here's another example, this time from one of our libraries. We maintain a popular library called "CasePaths", which allows one to use key path syntax for enums and their cases.

^ By applying the `@CasePathable` macro you get key paths generated for each case, and you can use those key paths for all types of interesting things. But that isn't important, what's important right now is what code is generated by this macro…

---

[.code-highlight: all]
[.code-highlight: 10-999]
[.code-highlight: 1-9]
```swift
import CasePaths

@CasePathable
enum Event {
  case empty
  case response(User)
  case loading(percent: Double)
  case error(Error)

  public struct AllCasePaths {
    public var empty: CasePaths.AnyCasePath<Event, Void> {
      CasePaths.AnyCasePath<Event, Void>(
        embed: { Event.empty },
        extract: {
          guard case .empty = $0 else { return nil }
          return ()
        }
      )
    }
    public var response: CasePaths.AnyCasePath<Event, User> {
      CasePaths.AnyCasePath<Event, User>(
        embed: Event.response,
        extract: {
          guard case let .response(v0) = $0 else { return nil }
          return v0
        }
      )
    }
    public var loading: CasePaths.AnyCasePath<Event, Double> {
      CasePaths.AnyCasePath<Event, Double>(
        embed: Event.loading,
        extract: {
          guard case let .loading(v0) = $0 else { return nil }
          return v0
        }
      )
    }
    public var error: CasePaths.AnyCasePath<Event, Error> {
      CasePaths.AnyCasePath<Event, Error>(
        embed: Event.error,
        extract: {
          guard case let .error(v0) = $0 else { return nil }
          return v0
        }
      )
    }
  }
}
public static var allCasePaths: AllCasePaths { AllCasePaths() }
```

^ …which is all of this. Each case of the enum becomes a computed property on an inner type that is added by the macro. That is what gives us key path syntax for each case of the enum.

---

![fit](case-pathable-error.png)

^ Also the macro performs a bit of validation in order to make sure you are using it correctly. For example, it does not make sense to apply the `@CasePathable` macro to a struct, and so the macro will emit an error if you try to do so.

---

```swift
import DependenciesMacros

@DependencyClient
struct APIClient {
  var fetchUser: (Int) async throws -> User
  var saveUser: (User) async throws -> Void
}
```

^ Here's one last macro, also from one of our libraries. This is in our dependency injection library, and it generates some boilerplate associated with defining dependency interfaces in your application. The details aren't important though, what is important is what code is generated…

---

[.code-highlight: all]
[.code-highlight: 5, 7-23, 25-49]
[.code-highlight: 1-4, 6, 24, 50]
```swift
import DependenciesMacros

@DependencyClient
struct APIClient {
  @DependencyEndpoint
  var fetchUser: (Int) async throws -> User
  {
    @storageRestrictions(initializes: _fetchUser)
    init(initialValue) {
        _fetchUser = initialValue
    }
    get {
        _fetchUser
    }
    set {
        _fetchUser = newValue
    }
  }
  private var _fetchUser: (Int) async throws -> User = { _ in
    XCTestDynamicOverlay.XCTFail("Unimplemented: 'fetchUser'")
    throw DependenciesMacros.Unimplemented("fetchUser")
  }
  @DependencyEndpoint
  var saveUser: (User) async throws -> Void
  {
    @storageRestrictions(initializes: _saveUser)
    init(initialValue) {
        _saveUser = initialValue
    }
    get {
        _saveUser
    }
    set {
        _saveUser = newValue
    }
  }
  private var _saveUser: (User) async throws -> Void = { _ in
    XCTestDynamicOverlay.XCTFail("Unimplemented: 'saveUser'")
    throw DependenciesMacros.Unimplemented("saveUser")
  }
  init(
    fetchUser: @escaping (Int) async throws -> User,
    saveUser: @escaping (User) async throws -> Void
  ) {
    self.fetchUser = fetchUser
    self.saveUser = saveUser
  }
  init() {
  }
}
```

^ …which is all of this code. Again this is a ton of code being generated that we never have to worry about. And as our `APIClient` gets more complex and has more endpoints, the code generated will also become much bigger.

---

![inline](dependency-client-fix-it.png)

^ The macro also emits a diagnostic with a fix-it.

^ If one of your dependency endpoints doesn't have any type information supplied, then an error is emitted with a fix-it.

---

![inline](dependency-client-fix-it-applied.png)


^ And if you apply the fix-it a type annotation placeholder will be inserted into the code letting you know exactly what needs to be done.

---

# A lot can go wrong when expanding macro code

^ So we now see that macros can generate a lot of code for us so that we can concentrate on our core domain without worrying about a bunch of boilerplate.

^ That's great.

^ But the downside is that the more code we generate with a macro the more things that can go wrong. And it is very, _very_ easy for something to go wrong when implementing a macro.

---

```swift
@Observable
class FeatureModel {
  var count = 0
  var isEven: Bool { count.isMultiple(of: 2) }
}
```

^ For example, the `@Observable` macro needs to be careful to only transform _stored_ properties of the class, and leave _computed_ properties alone.

---

let vs var

---

access control



---

overloaded enum case

---

????

--- 

# Apple's method of testing macros

---

# Snapshot testing macros





---




---

# Lessons learned from writing _lots_ of macros

---

# Better to surface errors than generate bad Swift code

^ Xcode has a bad habit of not surfacing syntax errors for invalid Swift code generated by macros.

^ So, if you can detect before hand that you are going to be forced to generated bad Swift code, like was the case for the overloaded enum cases, 

---

# Write _lots_ of tests 

---

# Exercise Swift oddities

* Closures with named arguments
* Overloaded case names
* more????

---

# Protocol requirements and access control

if macro generates requirements for a public protocol, always make the members public.

```swift
public extension Feature {
  @Reducer
  enum Destination {
    // ...
  }
}
```

---

# Report bugs to Apple

^ Most bugs can be filed just with GitHub issues since it's part of the open source Swift repo.

^ But anything Xcode specific should also be filed with Feedback


<!-- 
---

## Columns

Using the **[.column]** command you can create two or more columns of content, like so:

[.column]

* You can place some content above an image

![inline](https://deckset-assets.s3.amazonaws.com/colnago2.jpg)

[.column]

1. Isn't it cool to have two lists?
2. Isn't it cool to have two lists?

---

# This works with plain text as well!

[.column]

You can add longer paragraphs of text just like this. And then split them into two columns!

[.column]

Just like this! You can also add lists here like so:

* Column item below paragraph
* Column item below paragraph
 -->