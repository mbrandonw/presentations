# SwiftUI Navigation & URL Routing

* Brandon Williams
  * brandon@pointfree.co
  * @mbrandonw

^ Hello, my name is Brandon Williams, and today I will be discussing SwiftUI navigation and URL routing.

^ Here's some contact information for you all in case you want to reach out about some questions.

---

# SwiftUI Navigation & URL Routing

* Brandon Williams
  * brandon@pointfree.co
  * @mbrandonw
* Stephen Celis
  * stephen@pointfree.co
  * @stephencelis

^ But also everything I am discussing today is joint work with Stephen Celis. And if you were not already aware, Stephen and I run a website called Point-Free where we talk about things like what I'm about to talk about, and a whole lot moe.

---

# What is navigation?

^ Now, the talk today is about SwiftUI navigation, but I think even the word "navigation" can mean a lot of different things to different people.

---

# Drill down navigation

![autoplay inline mute fit loop](assets/navigation-drill-down.mov)

^ I think we can all agree that this is navigation. This is perhaps the most prototypical version of navigation. We drill down from one screen to another, and we can then pop back to the first screen.

^ The APIs for performing this kind of navigation even have the word "navigation" right in them, such as `NavigationView`, or `NavigationStack`, or `NavigationLink`, and even back in UIKit we have `UINavigationController`.

^ But, I also think we can expand our horizons a bit when it comes to navigation.

---

# Sheets

![autoplay inline mute fit loop](assets/navigation-sheet.mov)

^ Afterall, if drill down animations constitute navigation, then shouldn't sheets be too?

^ The slide from bottom-to-top instead of right-to-left, but it still takes you from one screen to another screen.

^ Though one difference is that with sheets you can see a tiny bit of the previous screen behind the sheet...

---

# Full screen covers

![autoplay inline mute fit loop](assets/navigation-fullscreen-cover.mov)

^ ...but that's not the case for full screen covers.

^ These are like sheets, but they take over the entire screen. Now this is basically identical to drill-down navigation we saw a moment ago, except it is oriented vertically instead of horizontally.

^ so surely we should consider this navigation even though the APIs to make this happen have no mention whatsoever of the word "navigation". 

---

# Popovers

![autoplay inline mute fit loop](assets/navigation-popover.mov)


^ But if sheets and covers are navigation, then are popovers too?

^ Afterall, popovers on iPads naturally degrade to sheets on iPhones. If popovers are _not_ navigation, then it means somehow the notion of navigation is a platform specific thing, which would be strange.

---

![autoplay inline mute fill loop](assets/navigation-drill-down.mov)
![autoplay inline mute fill loop](assets/navigation-sheet.mov)
![autoplay inline mute fill loop](assets/navigation-fullscreen-cover.mov)
![autoplay inline mute fill loop](assets/navigation-popover.mov)

^ So, I personally think that drill downs, sheets, full screen covers, and popovers are all forms of navigation.

^ And I think there are even more out there. I would even classify tab views as navigation, and even alerts and action sheets as navigation.

^ To me, navigation is a mode change in the application. whether that is drilling down to a new screen, or a sheet flying up, or a popover taking control of the screen, or even an alert appearing.


---

# What is navigation?

> A change of mode in the application.

^ So, this is the loose definition we will use for navigation, but what does it in mean in concrete terms? How can we turn this into actual code?

^ Well, I will further define a "change of mode" as meaning that some piece of state went from not existing to existing.

---

# What is a “change of mode”?

> It’s when a piece of state goes from not existing to existing, or the opposite, existing to not existing.

^ So, when a piece of state switches from not existing to existing, that represents a navigation to a new mode of the application. 

^ And then when that state switches back to not existing, it represents us undoing that navigation and returning back to the previous mode.

^ And the cool thing is that these mode changes can build upon each other. So if you want to navigate two layers deep, it just means there are two pieces of state that come into existence. For example, you could have a drill down to a screen that immediately shows a sheet. There's one piece of state that represents the drill down, and then another piece of state that represents the sheet.

^ I'm using the nebuluous term "existing" here because there are a few ways in which existence of state can be represented in Swift. One of the simplest ways is to use optionals, so that `nil` represents no state, and when it switches to something that is non-`nil` that triggers the navigation.

^ but there are also other ways to represent this idea, and we'll be getting more into that later.


---

# Navigation APIs

^ So, we now have a loose definition of navigation, and we know roughly what we want it to mean when we say we are navigating somewhere.

^ Let's see what this means in really concrete terms by looking at the navigation APIs that ship with SwiftUI. Let's start with some of the simpler ones.

---

# Sheets

```
func sheet<Item, Content>(
    item: Binding<Item?>,
    content: (Item) -> Content
) -> some View
```

^ Sheets can be shown with the following API. It's a view modifier, and you hand a binding of an optional value to it. 

^ It detects when the binding flips to a non-`nil` value, and with that honest value invokes the `content` closure to get a view for the sheet, which means the view can depend on the data, and then does the work of animating the view onto the screen from the bottom of the screen.

^ Further, once it detects that the binding flips back to `nil`, it automatically dismisses the sheet.

^ We are seeing in very concrete terms what it means to have navigation driven off some state coming into existence and then ceasing to exist.

---

# Sheets

```
struct UsersView: View {
  @State var editUser: User?

  var body: some View {
    List {
      // ...
    }
    .sheet(item: $editUser) { user in 
      EditUserView(user: user)
    }
  }
}
```

^ And this is what it looks like at the call site to use.

^ I've omitted the main content of the body for brevity, but you can imagine in there is some user action, say a button is tapped, and that executes some logic that causes the `editUser` variable to flip to an honest user value, triggering the sheet to come up.

^ What's also cool about this is that you are free to execute some logic before the sheet appears. For example, suppose tapping the button executes a network request to first fetch the newest data for the user, and then once that completes you show the sheet.

---

# Sheets

```
Button("Edit") {
  Task {
    let freshUser = try await self.apiClient.fetchUser(user.id)
    self.editUser = freshUser
  }
}
```

^ That might look something like this.

^ This kind of navigation is just very flexible. You can execute effects or perform validation before showing the sheet, and it all just works since the sheet's presentation and dismall is all driven off of this one piece of state.


---

```
func fullScreenCover<Item, Content>(
    item: Binding<Item?>,
    content: (Item) -> Content
) -> some View
```

^ and it turns out that a lot of navigation APIs in SwiftUI follow this form.

^ here's what it looks like to show a full screen cover. again it takes a binding of an optional state so that when it detects the state becomes non-nil the view is presented, and then once the state goes `nil` it is dismissed.

---

```
func popover<Item, Content>(
    item: Binding<Item?>,
    content: (Item) -> Content
) -> some View
```

^ popovers also follow this model.

^ again it takes a binding of an optional and simply detects when the binding becomes non-nil and nil so that it can present and dismiss.

^ if i quickly cycle between these three APIs we will see they are basically identically except for their name

---

```
func bottomMenu<Item, Content>(
    item: Binding<Item?>,
    content: (Item) -> Content
) -> some View
```

^ further, your _own_ UI components can and probably should follow this pattern.

^ so you wanted your own little bottom menu UI that pops up at the bottom of the screen. then a great way to model the showing and hiding of that content is through a binding of an optional value.

---

```
func sheet<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View
```

```
func fullScreenCover<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View
```

```
func popover<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View
```

^ It's worth mentioning that there are alternate versions of the sheet, full screen cover and popover APIs that take bindings of booleans. 

^ this is for situations where the content of the thing being presented is static, meaning it doesn't need to depend on dynamic data that comes into existence.

^ and this still fits into our mental model of navigation as a mode change where data comes into existence because a boolean can represent the absence or presence of data, it's just that there isn't really anything interesting about the data.


---

```
func sheet<Content>(
    isPresented: Binding<Void?)>,
    content: @escaping () -> Content
) -> some View
```

```
func fullScreenCover<Content>(
    isPresented: Binding<Void?)>,
    content: @escaping () -> Content
) -> some View
```

```
func popover<Content>(
    isPresented: Binding<Void?)>,
    content: @escaping () -> Content
) -> some View
```

^ in fact, we can think of booleans as just being optional Void values, afterall both types have exactly two values just with different labels.

^ and thinking of things in that way we can think of the boolean binding APIs as being equivalent to using the optional binding style but just with an optional void value.

^ so, at the end of the day, all of this really is modeling navigation as a mode change when data comes into existence or out of existence. and it can be very powerful to be able to model so many different types of animation in such a consistent manner.

---

# Deep-linking
## as easy as 1-2-3

^ but the benefits to thinking of navigation in this way far exceed just simple aesthetics of API design.

^ for example, deep linking

^ just so that we are all on the same page, when I say "deep linking" i mean the ability to instantly open the application in a particular state. deep linking is most often associated with _URL_ deep linking where you map certain known URLs to parts of your application, but the idea is far more general than that.

^ deep linking can also be important for handling push notifications, where if a specific notification is opened you may want to put your app in a very specific state, such as being drilled down to a screen with a popover open.

^ it can also be useful for state restoration where you record the state of the application when it is closed so that next time you open it up you can restore the UI to how it was last time.

^ when navigation is driven off of state, then deep linking basically comes for free with no additional work.

---

# Step 1
### Define the model

<br>

```
class Model: ObservableObject {
  @Published var child: ChildModel?
}
class ChildModel: Identifiable, ObservableObject {
  @Published var popoverIsPresented: Bool
}
```

^ let's quickly go through the steps. the first two steps are just things you have to do no matter what, whether you support deep linking or not.

^ you will define some observable objects that hold the state, logic and behavior of your features. 

^ here i've modeled a kind of "parent" feature that holds onto an optional "child" feature. the optionality of the child model is what determines whether or not we are currently navigated to the child feature.

^ and in the child domaion we hold a boolean that further determines if a popover is being shown.

^ all of this code is of course very basic and not very real world oriented, but these are the basic shapes of problems you would encounter in the real world.

---

# Step 2
### Define the view

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 5]
[.code-highlight: 6-8]
```
struct ContentView: View {
  @StateObject private var model = Model()

  var body: some View {
    Button("Show sheet") { self.model.child = ChildModel() }
      .sheet(item: self.$model.child) { childModel in
        ChildView(model: childModel)
      }
  }
}
```

^ then we define the views for the parent and child features using the models we defined before.

^ for example, in the parent feature we can hold onto a state object for the model

^ and then when a button is pressed we can instantiate the child model to indicate that we want to navigate to the child feature

^ and we can handle that navigation even by using the `.sheet` view modifier to listen to when the child mode becomes non-nil, and when it does display a `ChildView`

^ and that `ChildView` is implemented in basically the same way...

---

# Step 2
### Define the view

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 5]
[.code-highlight: 6-8]
```
struct ChildView: View {
  @ObservedObject var model: ChildModel

  var body: some View {
    Button("Show popover") { self.model.popoverIsPresented = true }
      .popover(isPresented: self.$model.popoverIsPresented) {
        Text("Hello from popover!")
      }
  }
}
```

^ where we hold onto the child model

^ have a button to flip its boolean to true in order to activate a navigation event

^ and then listen to that boolean in order to show a popover

---

# Step 3
### Construct state to deep link

```
ContentView(
  model: Model(
    child: ChildModel(
      popoverIsPresented: true
    )
  )
)
```

^ and then the final step to deep link into a very particular state of the application, and the thing we basically get for free by properly modeling navigation as state:

^ we can just construct a piece of state that represents where we want to navigate

^ thanks to the fact that the sheet and popover and driven off of this state it all just magically works. swiftui detects that the `childModel` is non-nil and so slides up a sheet, and then it detects that the boolean is `true` and so shows a popover

---

# Deep linking
## Demo

^ let's demo this real quick.

^ i have a project with all of this code already written, as well as a few small additional details that i'm omitting in order to not clutter what we are talking about here

^ go to SheetThenPopoverView and demo

---

# Sheets, 
# covers,
# & popovers

^ and so we have no seen that sheets, full screen covers and popovers all have very similar APIs.

^ they all require you to hand it a binding of some optional data so that the navigation can be driven off of state

^ technically they also have a variation that takes a binding of a boolean, but as we saw a moment ago that is really just a special case of the optinal binding style.

---

# Navigation links

^ and that now brings us to navigation links, which is the thing that probably everybody really thinks of when they think of navigation

^ considering that all other forms of navigation encountered so far were easily expressible with bindings of optional state, we might hope that navigation links worked the same

---

# Navigation odd duck 🦆

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 3]
[.code-highlight: 8]
[.code-highlight: 9]
[.code-highlight: 10]
```
NavigationLink(
  isActive: Binding<Bool>,
  destination: () -> View, 
  label: () -> View
)

NavigationLink(
  tag: Hashable, 
  selection: Binding<Hashable?>, 
  destination: () -> View, 
  label: () -> View
)
```

^ Well, unfortunately that is not the case, and in my opinion is one of the reasons why navigation links seemed so difficult to use since SwiftUI's inception.

^ there is one API that will seem familiar to us, and that is the `isActive` initializer that accepts a binding of a boolean. the idea of this state-driven API is that the link will listen for when the boolean becomes `true`, and when it detects that it will perform the drill down animation to the destination view.

^ so that allows us to drive navigation off of boolean state.

^ however, the API for driving navigtion off of optional state looks very strange.

^ it takes something called a tag, which is some hashable data. it's intended to be some kind of identifier for the destination you want to navigate to. for example, if you were capable of navigating to a user screen you might use an optional user id for the tag.

^ then it takes a binding of some optional hashable data. this what drives the navigation. it listens for when the binding's wrapped value becomes non-nil, and when it does cross references it with the tag, and if those two things equal, it triggers the drill down to the destination.

---

# [fit] What NavigationLink could have been

```
NavigationLink(
  item: Binding<Item?>,
  destination: (Item) -> View, 
  label: () -> View
)
```

---

```
NavigationLink(
  item: Binding<Item?>,
  destination: (Item) -> View, 
  label: () -> View
)

func sheet<Content>(
    item: Binding<Item?)>,
    content: @escaping (Item) -> Content
) -> some View

func fullScreenCover<Content>(
    item: Binding<Item?)>,
    content: @escaping (Item) -> Content
) -> some View

func popover<Content>(
    item: Binding<Item?)>,
    content: @escaping (Item) -> Content
) -> some View
```

---

# Destination coupling





---

# Deep linking

---

# URL routing






















