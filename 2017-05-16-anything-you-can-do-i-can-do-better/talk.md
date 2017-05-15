build-lists: true
theme: Ostrich, 1

### Anything you can do
### I can do **better**.

^ Hello! I'm Brandon, and [I'm] Lisa, we're engineers on the native team at Kickstarter, doing both iOS and Android. We're a pretty small team of engineers, ranging from junior to senior, and we've been on a journey for the past 2 years of unifying our foundations across iOS and Android.

^ For example, I was originally hired as an iOS engineer at Kickstarter, but jumped onto Android when we started working on our 1.0

^ My esteemed colleague Lisa on the other hand was hired as an Android engineer, but happily started writing Swift when we started on our rewrite and re-architecture.

^ But we always had a few core ideas that we held closely so that we could share knowledge while working on two platforms even though we couldn't necessarily share code.

^ However, that doesn't mean there isn't still a bit of identity involved. I would still say I primarily identify as an iOS engineer in my day-to-day, and Lisa would probably identify as an android engineer, even though she's given talks at more iOS conferences than Android and has made a guest appearance on Chris and Florian's swift talks :D

^ So, Lisa and I would like to give you a tour of our platforms of choice to show off their strengths and weaknesses, but still hoping to convey that really we're all just doing the same thing if you embrace a few core ideas.

---

# Open sourced

> https://github.com/kickstarter/ios-oss
> https://github.com/kickstarter/android-oss

^ [Lisa] Oh also worth noting that all of our code is open sourced and so you can go see all of our code and see how we use all of the things we are going to talk about.

--- 

### Kotlin **&** Swift

^ [Lisa] Let's start with the language we use for our respective platforms.

^ [Lisa] So everyone here is clearly already familiar with Swift, but you may not have heard of Kotlin.

---

# Kotlin

* JVM language
* Built by JetBrains
* 100% interop with Java
* OOP with a bit of FP
* Very expressive

^ [Lisa] It's a JVM language that is built by JetBrains, the makers of Android Studio, the most popular IDE for android, and IntelliJ.

^ [Lisa] Its aim is to have 100% interop with Java, which is a bit different from Swift. They want all Kotlin code to be reachable from Java. This is a great thing, but also holding Kotlin back a bit.

^ [Lisa] It has a similar philosophy as Swift in that it's primarily an OOP language but has given a few small FP features.

^ [Lisa] And it is _very_ expressive in some really beautiful ways that we'll get into soon.

---

# Optionals

![inline 100%](images/optional-swift.png)

^ [brandon] Ok, so one of the nice features of swift is the optional type. It allows you to safely express the idea of the absence of a value. So here, I have an array of integers and I want to add one to the first element. Swift is stopping me from doing this because it cannot know that the array of `xs` is not empty. I have to explicitly handle the case that the array is empty and `first` returns `nil`.

---

# Optionals

![inline 100%](images/optional-kotlin.png)

^ [Lisa] Yeah, optionals and null-safety are great. Fortunately Kotlin has made this a first-class concern. Here we see how we have to explicitly tell kotlin that `x` can hold a `null` value, and in the case of `y` Kotlin has prevented us from storing `null` since we have marked its type as a non-nullable `Int`.

^ [Lisa] We also have an array of intergers and this `firstOrNull` method, which behaves like swift's `first` method, and again kotlin is preventing us from adding `1` to an optional integer.

---

# Structs and Enums

![inline 100%](images/struct-enum-swift.png)

^ [brandon] An important part of functional programming is structs and enums, also known as product types and sum types, or even product and coproducts if you wanna go really deep.

^ [brandon] these types express the idea of having many values at once, or having one choice of many types of values.

^ [brandon] they are also well suited for immutability and statelessness

^ [brandon] Here we have a `User` type that has three fields, and an `Either` type that expresses having either a value of type `A` or type `B`, which we use quite a bit in our code base.

---

## Data classes and Sealed Classes

![inline 100%](images/struct-enum-kotlin.png)

^ [lisa] Over in the kotlin world, stucts and enums are called data classes and sealed classes.

^ [lisa] The data classes have pretty similar style to structs, and they work pretty much the same.

^ [lisa] Sealed classes are how we achieve enum-like functionality in kotlin, and they look a bit different. essentially, we create an un-instantiable type called either, and then have two inner subclasses for modeling the left and right. it's basically an OOP way to do enums.

^ [lisa] the amazing part is that this is 100% interoperable with java, so we can use the `Either` type in our java code, and we do.

^ [lisa] whereas in swift the `Either` enum is not accessible from objective-c at all.

---

### Extensions, Closures and Destructuring

![inline 100%](images/extensions-swift.png)

^ [brandon] Here we are showing off a couple of cool things in Swift. 

^ [brandon] First, we can open up the `Either` type and add functions to it. Here I've added a `map` function, which allows one to transform the type on the right `B` to a different type `C`.

^ [brandon] Second, functions can take functions as arguments, which allows us to pass in this transformation as an argument.

^ [brandon] Third, we have `switch` for destructuring an `Either` in order to process the left and right separately, and getting compile time guarantees that we handled all the cases properly.

^ [brandon] and then we can use it by constructing a right value, and mapping it

---

### Extensions, Closures and Destructuring

![inline 100%](images/extensions-kotlin.png)

^ [lisa] we can do all of this in kotlin too.

^ [lisa] first, to extend a type you just define a new function on the type itself using dot `.`.

^ [lisa] also, functions are supported as values in kotlin so that we can provide the transformation function as an argument to `map`.

^ [lisa] finally, we can use `when` to destructure the `Either` into each of its inner subclasses.

^ [lisa] With `when`, we have compile time safety that we handled both the left and the right cases.

^ [lisa] and finally, we can use it much the same way as we did with swift.

---

### Extensions, Closures and Destructuring
#### Even better...

![inline 90%](images/extensions-bonus-kotlin.png)

^ [lisa] Even better, we can write this function as an expression. We can use this syntax in Kotlin because `when` is treated as an expression.

^ [lisa] and just to remind everyone, this is fully interoperable with java. we can construct `Either` values, call kotlin functions that accept and return `Either`s, all from Java.

--- 

## Operators

![inline 100%](images/operators-swift.png)

^ [brandon] Swift has support for operators which allows us to write expressive code with nice algebraic properties. Here we have defined an arrow operator to represent forward composition of functions. 

^ [brandon] We can then take a couple of lil pure functions, `incr` and `square`, and derive new functions from composition.

^ [brandon] Then, we can use that function to `map` an array of integers to a new array of integers.

---

### Operators

![inline 100%](images/operators-kotlin.png)

^ [lisa] Kotlin doesn't have support for custom operators, but it does allow one to defined infix functions. This means you can define a function that takes two arguments, but use it in an infix manner.

^ [lisa] for example, here we have defined an `andThen` function that takes a function from `A` to `B` on the left, and a function `B` to `C` on the right, and returns a function from `A` to `C`. This allows us to chain the increment and square functions together in any way we want.

^ [lisa] and finally, we can feed that function to `map` to transform an array of integers to a new array of integers.

---

# Tail recursion
### Kotlin

![inline 100%](images/tailrec-kotlin.png)

^ [lisa] Here's a cool feature of Kotlin that allows us to specify when a recursive function can take advantage of tail recursion. Recursion is an important part of functional programming, allowing us to focus on the structure of data.

^ [lisa] First recall that a recursive function is said to be in "tail form" if the return statement of the function contains only a call to the function itself, and nothing else. such recursive functions can be optimized by unrolling the recursion into a plain ol' loop.

^ [lisa] kotlin has direct support for this optimization. if you can write your recursive function in tail form, you can annotate the function with the `tailrec` keyword and kotlin will optimize the function to be a plain ol' for loop. it will even raise a compiler warning if you use the modifier on a function that is not properly in tail form.

^ [lisa] here I have a `sum` function that shows how to recursive define the sum of a list of integers as the sum of the head plus the sum of the tail. it's easy enough to write this in tail form, and now i can sum a list of thousands of integers without worrying about blowing up the stack.

---

# Tail recursion
### Swift 😭

![inline 100%](images/tailrec-swift.png)

^ [brandon] So this is a bit sad for Swift. We have no tail call guarantees. It could happen, but you can't count on it.

^ [brandon] Here I have defined the `sum` function that Lisa defined, but this could very easily blow up the stack since it cannot be guaranteed to be optimized.

---

### Functional Programming

^ In case you haven't already guessed, we like functional programming because it allows for us to leverage functions, immutability, and minimal side effects to write composable and testable code.

^ Swift and Kotlin are not functional languages, but they do offer first-class support for many functional features such as map and filter operators. They are good foundations for building functional frameworks.

---

### Anything you can do
### we can do **together**

^ The features we've talked about today highlight some of the sweet spots between two languages that we work in as native engineers. When we invest so much time in experimenting with ideas, writing libraries and code, we want to be able to share all of our findings with each other.

---

### @**mbrandonw**
### @**luoser**
