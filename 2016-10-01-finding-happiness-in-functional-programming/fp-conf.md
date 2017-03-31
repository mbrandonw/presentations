build-lists: true

^ hello

---

## Finding Happiness in Functional Programming

^ I want to talk about some of the things I've been working on with my colleagues for the past few years, and how it's changed the way I approach development.

^ It has allowed us to do things that I simply didn't think was possible a few years ago, and, strangely, allowed me to better interact with my colleagues and the other people involved with making a great product such as designers and product managers.

^ this is going to be quite different from the types of talks i normally give. i'm usually heavy into the theoretical stuff and doing a lot of live coding. this time i want to bring it down to earth and talk about actual tangible things in our codebase.

^ and in fact, a large theme of this talk is about something nebulous, finding happiness and working with my teammates

---

![inline](squad.png)

^ they didnt want to do a group photo so i had to make a brady bunch photo.

^ this is 8 people, 6 engineers, 1 designer, 1 product manager. The engineers backgrounds and experiences are pretty evenly spread across junior (including a former intern) to people doing development for 10+ years.

^ This group does not comprise of an iOS team but a "native" team that does iOS and Android. In fact, 4 of the 6 engineers pictured here have contributed just as much to Android as they have iOS, and the other two will be getting there soon.

---

## Principles that we benefited from

^ before i can start pointing to pieces of code in our codebase (which we will be doing a lot of), i want to describe a few simple principles that we have benefited greatly from, as well a few principles that we had to let go of, or at least not be beholden to them strictly

---

## Separation of effects from purity

^ the first is the separation of effects from purity, and it happens in two parts.

---

### Isolation of side-effects

> An expression is said to have a side-effect if its execution makes an observable change to the outside world.

^ a function without side-effects would be called pure

---

### Isolation of side-effects

```swift
self.titleLabel.text = user.name
```

^ This is a simple side-effecting expression. It effects the outside world by changing a labels text, something anyone can observe.

^ Doing this kind of thing is such a fundamental building block of how we interact with UIKit that we might not even think of it as a side-effect.

---

### Isolation of side-effects

```swift
func update(text: String, forLabel: UILabel) {
  label.text = text
}

update(text: user.name, forLabel: self.titleLabel)
```

^ if how ever we wrote it this way it would be more obvious.

^ in fact, seeing that `update` is a function with no return value means it MUST be side-effecting. it returns nothing and therefore cannot be pure.

---

### Isolation of side-effects

```swift
self.loginButton.enabled = !self.userTextField.text.isEmpty
  && !self.passwordTextField.text.isEmpty
```

^ another example of something we've probably all written

---

### Isolation of side-effects

```swift
func updateLoginButtonEnabled() {
  self.loginButton.enabled = !self.userTextField.text.isEmpty
    && !self.passwordTextField.text.isEmpty
}

func emailChanged() {
  self.updateLoginButtonEnabled()
}

func passwordChanged() {
  self.updateLoginButtonEnabled()
}
```

^ this is can be seen as an attempt to isolate side-effects. others might see it as a form of DRY, but i'll get to that later.

---

### Isolation of side-effects

```swift
// Pure, functional world
let emailChanged: Signal<String, NoError>
let passwordChanged: Signal<String, NoError>

let loginButtonEnabled = combineLatest(emailChanged, passwordChanged)
  .map { !$0.isEmpty && !$1.isEmpty }

// Side-effect world
loginButtonEnabled.observeNext { [weak self] in
  self?.loginButtonEnabled.enabled = $0
}
```

^ this is roughly equivalent to the previous version but with some benefits

^ it's clear where the pure parts are, and they are very testable

^ it's clear where the side-effects are, everything in `observeNext` as it's simply a function that takes an emitted value and returns nothing

^ in fact, it's the escape-hatch from the functional reactive world to the side-effecting world

---

### Isolation of side-effects

```swift
// Pure, functional world
let emailChanged: Signal<String, NoError>
let passwordChanged: Signal<String, NoError>

let loginButtonEnabled = combineLatest(emailChanged, passwordChanged)
  .map { !$0.isEmpty && !$1.isEmpty }

// Side-effect world
self.loginButton.rac.enabled = loginButtonEnabled
```

---

### Surfacing of co-effects

>

^ before i said the word "side-effects" cause that is the common term for it, but let's just call that an effect. no need to say side.

^ a co-effect would be the dual notion to that... so what is that

---

### Surfacing of co-effects

> ????????????????

^ yeah ok i dont have a great definition, and in fact this is a active area of research

^ i talked a bit about duality in my last FP conf talk where i discussed lenses and their dual prisms, and how prisms is a bit more difficult to grasp

^ gonna try my best with this one

---

### Surfacing of co-effects

> If an effect is a change to the outside world after executing an expression...

^ i'm going to speak in analogy to define this...


---

### Surfacing of co-effects

> If an effect is a change to the outside world after executing an expression...

#

> ...then...

---

### Surfacing of co-effects

> If an effect is a change to the outside world after executing an expression...

#

> ...then...

#

> ...a co-effect is the state of the world that the expression needs in order to execute.

^ so the surfacing of a co-effect means we should bring the context of the world to the place it is needed. it should not be hidden away

^ hopefully that tingles something in the back of your mind that maybe sounds familiar


---

## Surfacing of co-effects
### e.g. Dependency Injection

---

### Surfacing of co-effects
#### Dependency Injection

```swift
func currentUserIsCreator(ofProject project: Project) -> Bool {
  return User.currentUser.id == project.creator.id
}

currentUserIsCreator(ofProject: project) // => true or false
```

^ here is an example with a co-effect

^ This is a pure function, it makes no changes to the outside world.

^ call it multiple times and there will be no observable change in the world

^ that sounds great!

^ however, everyone in here must be cringing at the fact that im reaching into the outside world to grab a singleton value `User.currentUser`.

^ that is precisely a co-effect. we did not provide everything to this function it needed to do its job

---

### Surfacing of co-effects
#### Dependency Injection

```swift
func user(_ user: User, isCreatorOfProject: Project) -> Bool {
  return user.id == project.creator.id
}

user(User.currentUser, isCreatorOfProject: project) // => true or false
```

^ the fix is quite easy! just provide the value to the function!

^ this function is now effect and co-effect free!

---

### Surfacing of co-effects
#### References

* Colin Barrett
  * Functional Swift Conference 2015
  * Structure and Interpretation of Swift Programs

* The work of Tomas Petricek
  * Coeffects: A calculus of context-dependent computation
  * Coeffects: The next big programming challenge

^ this is a very deep, exciting area that i've benefited from exploring.

---

### Effect/Co-effect Duality

^ i also want to say that the effect/co-effect duality are the two sides of what can help or hurt testing

^ if your function has side-effects, the only way to test is to execute the function and then find the thing that was effected and see if it changed in the way you expected. also pray that there were no other side-effects cause good luck trying to track down those!

^ if your function has co-effects, the only way to test is to provide the entire world of context needed, i.e. stub global data. also, pray that you stubbed the entire world so that you know for sure it wasn't secretly depending on something else

^ if your function has both effects and co-effects, well... that does not sound like a happy place to be.

^ just mention the io-monad and oi-comonad

---

> Code to the interface you wish you had, not the interface you were given.
> - Stephen Celis

![45%](stephen.jpg)

^ it can be a very frustrating experience dealing with API's that we do not control

^ UIKit is probably one of the biggest offenders

^ it is a large, stateful API based on very imperative ways of doing things

^ the paradigms it's built off of are a little mixed: notifications, delegates, blocks, etc..., also it has global state and injected state

^ so we want to find a better way to live with UIKit without building a massive abstraction layer on top of it

^ by embracing just functions, we get to work with an API that we enjoy while remaining quite close to the metal

---

### An interface we were given

---

### An interface we were given
#### Storyboards

* Very thick abstraction layer
* Separates code from data
* Constantly catching up to what UIKit can do

---

## An interface we wish we had
### Lenses

^ i talked about lenses last times

^ we now use them EVERYWHERE

^ this is how we get to embrace immutability without it being a pain

---

## An interface we wish we had
### Lenses

```swift
struct Project {
  let creator: User
  let id: Int
  let name: String
}
```

^ we actively use these in our model layer

---

## An interface we wish we had
### Lenses

```swift
Project.lens.name // => Lens<Project, String>
```

---

## An interface we wish we had
### Lenses

```swift
Project.lens.name // => Lens<Project, String>

Project.lens.name .~ "Advanced Swift" // => Project -> Project
```

---

## An interface we wish we had
### Lenses

```swift
Project.lens.name // => Lens<Project, String>

Project.lens.name .~ "Advanced Swift" // => Project -> Project

project
  |> Project.lens.name .~ "Advanced Swift"
```

---

## An interface we wish we had
### Lenses

```swift
project
  |> Project.lens.name .~ "Advanced Swift"
  |> Project.lens.creator.name .~ "Chris Eidhof"
```

^ this permeates our testing throughout

^ it allows us to embrace the idea of mutability while still allowing us to construct values that probe the most subtle of edge cases for tests

^ the most important part: lenses are a very thin abstraction layer on just plain functional getters and setters

---

## An interface we wish we had
### UIKit Lenses

>

---

## An interface we wish we had
### UIKit Lenses

```swift
UIView.lens.backgroundColor // => Lens<UIView, UIColor>
```

---

## An interface we wish we had
### UIKit Lenses

```swift
UIView.lens.backgroundColor // => Lens<UIView, UIColor>

UIView.lens.backgroundColor .~ .redColor() // => UIView -> UIView
```

---

## An interface we wish we had
### UIKit Lenses

```swift
UIView.lens.backgroundColor // => Lens<UIView, UIColor>

UIView.lens.backgroundColor .~ .redColor() // => UIView -> UIView

view
  |> UIView.lens.backgroundColor .~ .redColor()
  |> UIView.lens.layer.cornerRadius .~ 4
  |> UIView.lens.layer.masksToBounds .~ true
```

---

## An interface we wish we had
### UIKit Lenses

```swift
func roundedStyle(cornerRadius: CGFloat) -> (UIView) -> UIView {
  return UIView.lens.layer.cornerRadius .~ 4
    <> UIView.lens.layer.masksToBounds .~ true
}

view
  |> roundedStyle(cornerRadius: 4)
  |> UIView.lens.backgroundColor .~ .redColor()
```

---

## An interface we wish we had
### UIKit Lenses

```swift
let baseButtonStyle =
  roundedStyle(cornerRadius: 4)
    <> UIButton.lens.titleLabel.font .~ UIFont(size: 16)
    <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 6, leftRight: 12)

let greenButtonStyle =
  baseButtonStyle
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .greenColor()
```

---

## An interface we wish we had
### UIKit Lenses

```swift
let bigButtonStyle =
  baseButtonStyle
    <> UIButton.lens.contentEdgeInsets %~ {
      .init(top: $0.top * 2,
            left: $0.left * 2,
            bottom: $0.bottom * 2,
            right: $0.right * 2)
}
```

---

## An interface we wish we had
### UIKit Lenses

```swift
let baseButtonStyle =
  roundedStyle(cornerRadius: 4)
    <> UIButton.lens.titleLabel.font %~~ { _, button in
      button.traitCollection.verticalSizeClass == .Compact
        ? UIFont(size: 12)
        : UIFont(size: 14)
    }
    <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 6, leftRight: 12)
```

^ UIKit lenses are in our code base and everyone uses them, from junior to senior

^ we use this in other ways such as strings

---

### Principles that we did not benefit so much from:

* D.R.Y.
* S.R.P.
* S.O.L.I.D.
* Objects

^ DRY: made us prematurely extract things when we didnt understand why. we now embrace repetition until we cant stand it. i dont mind a pure function that has been repeated a few times

^ SRP: this principle tends to come down to personal preferences and usually concerns where things should live. pure functions by defintion have a single responsibitily

^ SOLID: again most of these principles are not super applicable to pure functions and functional programming

^ Objects: i've never met an object i liked. things we thought were supposed to be objects turned out to be just pure functions, like pagination

---

# The Result

---

# Testing

---

# Test-Driven Development

---

# Test-Driven Bug Fixing

---

# Playground-Driven Development

---

# Screenshot testing

---

# Event Tracking

---

# Event Tracking

![inline](tweet.png)

---

# Accessibility

^ for example, using voice over to change the UI and having tests for that

---

# Love for UIKit

---

### Better working relationship with Product Managers, Designers and Engineers

![inline](squad.png)

---

## Finding Happiness in Functional Programming

---

## Finding Happiness in Functional Programming

### brandon@kickstarter.com
