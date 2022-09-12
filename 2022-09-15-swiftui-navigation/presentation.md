# SwiftUI Navigation & URL Routing

* Brandon Williams
  * brandon@pointfree.co
  * @mbrandonw

^ Hello, my name is Brandon Williams, and today I will be discussing SwiftUI navigation and URL routing.

^ Here's some of my contact information for you all in case you want to reach out with some questions.

---

# SwiftUI Navigation & URL Routing

* Brandon Williams
  * brandon@pointfree.co
  * @mbrandonw
* Stephen Celis
  * stephen@pointfree.co
  * @stephencelis

^ But also everything I am discussing today is joint work with Stephen Celis. And if you were not already aware, Stephen and I run a website called Point-Free where we talk about things like what I'm about to talk about, and a whole lot more.

^ so you may be interested in checking out some of our stuff at that address, pointfree.co

---

# What is navigation?

^ Now, the talk today is about SwiftUI navigation, and then to a lesser extent, URL routing within SwiftUI navigation.

^ but I think the word "navigation" can mean a lot of different things to different people.

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

^ They slide from bottom-to-top instead of right-to-left, but it still takes you from one screen to another screen.

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

^ Afterall, popovers on iPads naturally degrade to sheets on iPhones. If popovers are _not_ navigation, then it means somehow the notion of navigation is a platform specific thing. that is, popovers would be navigation on iOS because they essentially behave like sheets, but then suddenly are not navigation on iPads. 

^ That would be really strange.

---

![autoplay inline mute fill loop](assets/navigation-drill-down.mov)
![autoplay inline mute fill loop](assets/navigation-sheet.mov)
![autoplay inline mute fill loop](assets/navigation-fullscreen-cover.mov)
![autoplay inline mute fill loop](assets/navigation-popover.mov)

^ So, I personally think that drill downs, sheets, full screen covers, and popovers are all forms of navigation.

^ And I think there are even more out there. I would even classify tab views as navigation, and even alerts and action sheets as navigation.

^ and you could even define your own notions of navigation. it doesn't have to be confined only to the tools that Apple gives us in SwiftUI.

^ To me, navigation is a mode change in the application. whether that is drilling down to a new screen, or a sheet flying up, or a popover taking control of the screen, or even an alert appearing.


---

# What is navigation?

> A change of mode in the application.

^ So, this is the loose definition we will use for navigation, but what does it in mean in more technical terms? How can we turn this nebulous idea into actual code?

^ Well, I will further define a "change of mode" as meaning that some piece of state went from not existing to existing.

---

# What is a “change of mode”?

> It’s when a piece of state goes from not existing to existing, or the opposite, existing to not existing.

^ So, when a piece of state switches from not existing to existing, that represents a navigation to a new mode of the application. 

^ And then when that state switches back to not existing, it represents us undoing that navigation and returning back to the previous mode.

^ And the cool thing is that these mode changes can build upon each other. So if you want to navigate two layers deep, it just means there are two pieces of state that come into existence, and the second piece of state is stored inside the first.


^ For example, you could have a drill down to a screen that immediately shows a sheet. There's one piece of state that represents the drill down, and then another piece of state that represents the sheet.

^ I'm using the nebuluous term "existing" here because there are a few ways in which existence of state can be represented in Swift. One of the most prototypical ways is to use optionals, so that `nil` represents no state, and when it switches to something that is non-`nil` that triggers the navigation.

^ but there are also other ways to represent this idea, and we'll be getting more into that later.


---

# Navigation APIs

^ So, we now have a loose definition of navigation, and we know roughly what we want it to mean when we say we are navigating somewhere.

^ Let's see what this means in really concrete terms by looking at the navigation APIs that ship with SwiftUI. Let's start with some of the simpler ones.

---

# Sheets

[.code-highlight: all]
[.code-highlight: 1]
[.code-highlight: 2]
[.code-highlight: 3]
[.code-highlight: all]
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

[.code-highlight: all]
[.code-highlight: 3]
[.code-highlight: 7-9]
[.code-highlight: 11-13]
```
struct UsersView: View {
  @State var users: [User]
  @State var editUser: User?

  var body: some View {
    List {
      ForEach(self.users) { user in 
        Button("Edit") { self.editUser = user }
      }
    }
    .sheet(item: $editUser) { user in 
      EditUserView(user: user)
    }
  }
}
```

^ And this is what it looks like at the call site to use.

^ you hold onto some optional state that represents if the `EditUserView` is presented or not

^ Something somewhere in the view causes the `editUser` state to go from `nil` to non-`nil`. In this case it's a button.

^ That causes the `.sheet` modifier to see the data is not present, and so the sheet's view builder is invoked with that data.

^ What's also cool about this is that you are free to execute some logic before the sheet appears. For example, suppose tapping the button executes a network request to first fetch the newest data for the user, and then once that completes you show the sheet. That would be incredibly simply to do with this API.

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

^ This kind of navigation is just very flexible. You can execute effects or perform validation before showing the sheet, and it all just works since the sheet's presentation and dismissal is all driven off of this one piece of state.


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
    isPresented: Binding<Void?>,
    content: @escaping () -> Content
) -> some View
```

```
func fullScreenCover<Content>(
    isPresented: Binding<Void?>,
    content: @escaping () -> Content
) -> some View
```

```
func popover<Content>(
    isPresented: Binding<Void?>,
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

```
class Model: ObservableObject {
  @Published var child: ChildModel?
}

class ChildModel: Identifiable, ObservableObject {
  @Published var popoverValue: Int?
}
```

^ let's quickly go through the steps. the first two steps are just things you have to do no matter what, whether you support deep linking or not.

^ you will define some observable objects that hold the state, logic and behavior of your features.

^ here i've modeled a kind of "parent" feature that holds onto an optional "child" feature. the optionality of the child model is what determines whether or not we are currently navigated to the child feature.

^ and in the child domaion we hold a value that determines if a popover is shown. presumably that value is used to drive the initial state of the popover somehow.

^ all of this code is of course very basic and not very real world oriented, but these are the basic shapes of problems you would encounter in the real world.

^ now, you may be wondering: "what if i store my state in `@State` variables? or even `@StateObject`s instead of `@ObservedObject`s?" Well, sadly in such cases the options for deep linking are quite limited. The whole point of those property wrappers is to have the source of truth lie locally in the views that holds that value, and hence doesn't exactly mix with the idea of some more root. that's just a trade off you must make when using those tools.

---

# Step 2
### Define the view

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 5]
[.code-highlight: 6-8]
```
struct ContentView: View {
  @ObservedObject var model: Model

  var body: some View {
    Button("Show sheet") { self.model.child = ChildModel() }
      .sheet(item: self.$model.child) { childModel in
        ChildView(model: childModel)
      }
  }
}
```

^ With the domain modeled and the logic implemented, we define the views for the parent and child features using the models we defined before.

^ for example, in the parent feature we can hold onto an observed object for the model

^ and then when a button is pressed we can instantiate the child model to indicate that we want to navigate to the child feature

^ and we can handle that navigation even by using the `.sheet` view modifier to listen to when the child mode becomes non-nil, and when it does display a `ChildView`

^ and that `ChildView` is implemented in basically the same way...

---

# Step 2
### Define the view

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 5-7]
[.code-highlight: 8-10]
```
struct ChildView: View {
  @ObservedObject var model: ChildModel

  var body: some View {
    Button("Show popover") {
      self.model.popoverValue = .random(in: 1...1_000)
    }
    .popover(item: self.$model.popoverValue) { value in
      PopoverView(count: value)
    }
  }
}
```

^ where we hold onto the child model

^ have a button to the optional state into something non-`nil`, in this case we are just choosing a random number.

^ and then we listen for that optional to become non-`nil` in order to show a popover, and we do that by creating this `PopoverView` and handing it its initial value.

---

# Step 2
### Define the view

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 5,6,7]
[.code-highlight: 2]
```
struct PopoverView: View {
  @State var count: Int
  var body: some View {
    HStack {
      Button("-") { self.count -= 1 }
      Text("\(self.count)")
      Button("+") { self.count += 1 }
    }
  }
}
```

^ and here's a peek at what the popover view looks like

^ i want it to have some basic functionality, so it manages a little piece of internal state, and exposes some buttons for mutating that state.

^ now this little bit of code may cause a little tingle in the back of some of y'alls brains. i am specifically leaving this `@State` as uninitialized and allowing its initial state to be determined by the outside.

^ you may have heard somewhere that this is a bad idea. I will say that it has its subtle edge cases, but there really is no perfect way for interacting with `@State`, and the same with `@StateObject`, due to its very nature.

^ the subtlety here is that the lifetime of `@State` is tied to the lifetime of the view, and so it is _really_ only created a single time. after that first creation, even if the parent view tried recreating `PopoverView` with a completely new value, that value would just be discarded and this internal state would stay the same.

^ so, that is tricky, but that's also just the cost of doing business with an object whose whole purpose is to be tied to the lifetime of a view.

---

# Step 2
### Define the view

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 3]
[.code-highlight: 10]
```
struct PopoverView: View {
  @State var count = 0
  let initialValue: Int
  var body: some View {
    HStack {
      Button("-") { self.count -= 1 }
      Text("\(self.count)")
      Button("+") { self.count += 1 }
    }
    .onAppear { self.count = self.initialValue }
  }
}
```

^ some people suggest to "workaround" this strangeness in the following way

^ you force `@State` to have a default value, and just hope there's even a sensible default to use, and then you provide a `let` property for the initial value. that's the value you can initialize the view with from the outside.

^ _then_ you set up an `onAppear` to copy that initial value over to the state value.

^ to me that just seems very strange and i don't think it's actually accomplished anything. you still have the behavior that this view can only _really_ be created with an initial value a single time. later recreations of the view with new values will still have no influence on the state held inside because `onAppear` won't be invoked again.

^ and from the outside this code looks exactly the same as the previous code i had. both can be initialized simply with a single integer. there is no indiciation that something tricky is happening under the hood.

^ so to me I rather use the previous code since there are fewer moving parts and since it has the exact same behavior as this. i say that if you need a view to hold onto `@State` or `@StateObject` and it needs to be initialized with some seed data from the outside, just pass it through directly, but know the caveats forwards and backwards. But, that is just my opinion, not a universal fact.

---

# Step 3
### Construct state to deep link

[.code-highlight: all]
[.code-highlight: 3]
[.code-highlight: 4]
```
ContentView(
  model: Model(
    child: ChildModel(
      popoverValue: 42
    )
  )
)
```

^ phew ok, that was a big step 2. let's get back on track.

^ the final step to deep link into a very particular state of the application, and the thing we basically get for free by properly modeling navigation as state:

^ we can just construct a piece of state that represents where we want to navigate

^ thanks to the fact that the sheet and popover and driven off of this state it all just magically works. swiftui detects that the `childModel` is non-nil and so slides up a sheet, and then it detects that the value is non-`nil` and then shows a sheet.

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

^ and so we have now seen that sheets, full screen covers and popovers all have very similar APIs.

^ they all require you to hand it a binding of some optional data so that the navigation can be driven off of state

^ technically they also have a variation that takes a binding of a boolean, but as we saw a moment ago that is really just a special case of the optinal binding style.

---

# Navigation links

^ and that now brings us to navigation links, which is the thing that probably everybody really thinks of when they think of navigation

^ considering that all other forms of navigation encountered so far were easily expressible with bindings of optional state, we might hope that navigation links worked the same

---

[.code-highlight: all]
[.code-highlight: 2]
[.code-highlight: 3]
```
NavigationLink(
  item: Binding<Item?>,
  destination: (Item) -> Destination, 
  label: () -> Label
)
```

^ perhaps you could hand it a binding of an optional piece of state, and then when it detects that the state becomes non-`nil` it will cause a drill down animation to happen

^ further, the view that shown for that drill down animation would be handed that non-`nil` state so that it could be dynamic based on that state.

^ this sounds great in theory, but it has a problem. this can't possibly work because unlike sheets/covers/popovers, navigation links are meant to be tapped to start the drill down.

^ so the action that causes the state to become non-`nil` needs to be somehow baked into the navigation link's api

---

[.code-highlight: 3]
```
NavigationLink(
  item: Binding<Item?>,
  action: () -> Void,
  destination: (Item) -> Destination, 
  label: () -> Label
)
```

^ which means it just needs to look something like this

^ there is an additional parameter for an action closure that is invoked when the navigation link is tapped. in that action closure you can do whatever necessary to hydrate the state to be something non-`nil`, and then the drill down navigation will occur

---

[.code-highlight: all]
[.code-highlight: 6]
[.code-highlight: 2]
[.code-highlight: 1,4]
```
NavigationLink(item: self.$model.editUser) {
  self.model.editUser = user
} destination: { user in
  EditUserView(user: user)
} label: {
  Text("Edit user")
}
```

^ in practice, that might look something like this.

^ we have a link with a label that says "Edit user"

^ when tapped the action closure is executed which causes the `editUser` state to be hydrated. it may be able to do that synchronously and immediately, or it may need to perform some async work and then update state.

^ but either way, at some later point the `editUser` state will become non-`nil`, and that will allow us to construct the destination with some initial state and start the drill down process.

---

# Navigation odd ducks 🦆

```
NavigationLink(
  destination: () -> Destination, 
  label: () -> Label)

NavigationLink(
  isActive: Binding<Bool>,
  destination: () -> Destination, 
  label: () -> Label)

NavigationLink(
  tag: Hashable, 
  selection: Binding<Hashable?>, 
  destination: () -> Destination, 
  label: () -> Label)
```

^ Well, unfortunately, those APIs are just a pipe dream and not reality at all. instead we have these 3 APIs, and in my opinion is one of the reasons why navigation links seemed so difficult to use since SwiftUI's inception.

^ i think evidence of this is that, in my experience, people don't seem to have the same problems with sheets/covers/popovers the way they do with navigation links. People understand those other APIs pretty intuitively it seems.

^ but alas, these are the APIs we had for a long time, though they are now deprecated. either way, let's take a quick look at them one-by-one.

---

# Navigation odd ducks 🦆

```
NavigationLink(
  destination: () -> Destination, 
  label: () -> Label
)
```

^ first there's this weird one. there's no equivalent to this kind of API over in sheets/covers/popovers.

^ this initailizer only takes builder closures for describing the destination and label for the link. there's no binding whatsoever.

^ this kind of link works in a "fire-and-forget" fashion. if the user taps the link, a drill down animation happens to the destination, but there is no change whatsoever in state to represent this fact. the navigation link manages all of that state internally and we never get to see it.

^ this kind of link can be really handy in a pinch because it's so simple to use, but it also means you have no way whatsoever to programmatically deep link into the destination screen. truly the only way to invoke the drill down is for the user to literally tap on the link. so, if you ever need to navigate to the destination via a deep link URL or a push notification or some other mechanism, this type of link is not for you.

^ that's just the trade off for using this kind of navigation.

---

# Navigation odd ducks 🦆

```
NavigationLink(
  isActive: Binding<Bool>,
  destination: () -> Destination, 
  label: () -> Label
)
```

^ next there's this API, which should seem familiar to us because it takes a binding of a boolean that determines if the navigation link is active or not.

^ this is a state driven API, and the idea of it is that the link will listen for when the boolean becomes `true`, and when it detects that it will perform the drill down animation to the destination view.

^ so that allows us to drive navigation off of boolean state. and in fact, we can even implement that optional item variation i showed just a moment ago in terms of this boolean one, so all is not lost. it just takes some work to do, and so most people are not going to know they need to do that.

---

# Navigation odd ducks 🦆

```
NavigationLink(
  tag: Hashable, 
  selection: Binding<Hashable?>, 
  destination: () -> Destination, 
  label: () -> Label
)
```

^ and finally we have this API. this is the API that kinda allows you to drive navigation off of optional state, but it's quite different from the other optional-state APIs we have seen.

^ it takes something called a tag, which is some hashable data. it's intended to be some kind of identifier for the destination you want to navigate to. for example, if you were capable of navigating to a user screen you might use the user's id for the tag.

^ then it takes a binding of some optional hashable data. When you tap the link it will write the tag to the binding, and then that will trigger the drill down to the destination view.

^ But tapping the link isn't the only way to trigger the navivgation. The link will listen for anytime the seletion goes from `nil` to non-`nil`, even if a tap didn't happen, and that will also trigger the drill down animation.

---

[.code-highlight: all]
[.code-highlight: 3]
[.code-highlight: 9]
[.code-highlight: 10]
```
struct ContentView: View {
  @State var users: [User]
  @State var selectedUserID: User.ID?

  var body: some View {
    List {
      ForEach(self.users) { user in 
        NavigationLink(
          tag: user.id,
          selection: self.$selectedUserID
        ) {
          EditUserView(userID: user.id)
        } label: {
          Text("Edit user")
        }
      }
    }
  }
}
```

^ To me it seems that maybe this API was designed with this use case in mind. You have a list of navigation links and you want a single binding to drive all of those links.

^ here we hold onto a bit of optional state that has the id of the user you want to be able to navigate to

^ and then inside the `List` and `ForEach`  you can construct a navigation link whose tag is the user id that corresponds to the row you are rendering, and then hand it the binding from the root that determines which id is currently selected.


---

# Demo

<!-- todo: demo -->

---

**What NavigationLink could have been**

```
NavigationLink(
  item: Binding<Item?>,
  action: () -> Void,
  destination: (Item) -> Destination, 
  label: () -> Label)

func sheet<Content>(
    item: Binding<Item?>,
    content: @escaping (Item) -> Content) -> some View

func fullScreenCover<Content>(
    item: Binding<Item?>,
    content: @escaping (Item) -> Content) -> some View

func popover<Content>(
    item: Binding<Item?>,
    content: @escaping (Item) -> Content) -> some View
```

^ before moving on i just want to push all the sheet/cover/popover APIs next to the theoretical navigation link API

^ they all would basically work the same. they are all driven by a binding to a piece of optional state where the navigation is triggered once the binding flips to a non-`nil` value.

^ this shows that can be a great deal of consistency when thinking about navigation. basically 4 very different forms of navigation have been unified under the same umbrella, and there's even more types of navigation that fit this pattern

---

# Destination coupling

^ but swiftui didn't go that route, and maybe for good reason.

^ as we've seen just now, driving navigation from state can be incredibly powerful. by putting a bit of upfront work into modeling your domain and properly using the available apis, you instantly unlock the ability to link into basically any state of your application. And it also makes it possible to test navigation logic, which is something we're not going to even have the chance to discuss.

^ state driven navigation is one of _the_ most important concepts to internalize.

^ but there's another concept that is nearly as important, and I think some people would say it's even more important.

^ and that's decoupling of navigation destinations.

---

Destination coupling

```
NavigationLink(
  destination: () -> Destination, 
  label: () -> Label)

func sheet<Content>(
    item: Binding<Item?>,
    content: @escaping (Item) -> Content) -> some View

func fullScreenCover<Content>(
    item: Binding<Item?>,
    content: @escaping (Item) -> Content) -> some View

func popover<Content>(
    item: Binding<Item?>,
    content: @escaping (Item) -> Content) -> some View
```

^ there is something about these API signatures that isn't quite ideal.

^ in all 4, the very act of invoking the API inextricably couples the parent view that wants to perform the navigation to the destination you are navigating to.

^ This means if you have a feature that can navigate to a settings screen, your feature must be able to build the settings feature in order to use these APIs.

---

![200%](assets/coupling-1.png)

^ Here is a visualizastion of what navigation coupling looks like from a dependency perspective.

^ Each box represents a feature, and each curve between boxes represents that you can navigate from one feature to another.

^ If a feature's directly depends on the code of the features it can navigate to, it means we must build all destination features before we can build the parent feature.

^ This means that leaf nodes will build super quickly because they basically have no dependencies, but as you work your work up the tree things will get slower and slower to compile.

---

![200%](assets/coupling-2.png)

^ For example, suppose in user list feature you can navigate either to a particular use or the settings screen. And then in each of those screens you can navigate to a few places.

^ In order to implement new functionality or fix bugs in the `UsersList` feature, we must build all of the other features down below. And the functionality we are trying to implement or the bug we are trying to fix may not have anything to do with any of those features.

^ and that may not seem like a big deal, but over time it can become a big deal. Some of the features lower down in the tree may start to get bloated and take a long time to compile on their own, and that will directly increase the compile times of the `UsersList`.

^ For example, the `Settings` screen could start to depend on a heavy weight 3rd party library, like firebase, in order to sync settings to an external server.

^ Or the `UserEdit` feature could pick up a dependency on an analytics SDK because that team wants to start instrumenting certain user behavior.

^ now you may have never actually even experienced the problem i'm trying to explain here. it tends to affect large teams where it becomes difficult if not impossible to make sure that features don't bloat and take a long time to compile.

^ But there are other benefits to decoupling, such as improving the stability of certain tools. For example, Xcode previews are incredibly powerful, but they can also be brittle. One of the best ways to improve their stability is to build the minimal amount of code necessary for the preview. That can be done by decoupling views and putting each feature in their own isolated module.

---

![200%](assets/coupling-3.png)

^ If you were to decouple your features, then the code dependency tree would look more like this. Essentially, the broader the tree and the less deep the tree, the more it is isolated.

---

![150%](assets/coupling-4.png)

^ This would allow us to implement new functionality and fix bugs in each of these child features without building anything unnecessary things.

^ Now, this all sounds great in theory and in this fancy diagram, but I do want to point out the flip side of this.

^ Decoupling features does come with additional complexity and is not a panacea. It makes it harder to test certain things in isolation.

^ For example, now the only way to play around with the navigation that goes from the settings screen to the push settings screen is to run it in the full `UsersList` feature. This means you would run the app, navigate to the users list, tap the settings button, and then tap the push settings button.

^ Previously you could have run the settings feature in isolation and just wrapped everything in a `NavigationView`. Sure settings and push settings were coupled together, but then that means you can test their coupling in isolation. 

^ With _fully_ decoupled navigation you lose that ability. So, it can still be important to think more about where you truly need to decouple navigation and where it is OK to leave things coupled.

---

# Navigation stacks

^ So, why are we talking so much about navigation coupling?

^ Well, because iOS 16 introduced a brand new API for drill-down navigations that can help decouple navigation destinations. It's called navigation stack, and Apple is so happy with this API that they deprecated all of the navigation link APIs we discussed a moment ago.

^ It's worth mentioning that even with navigation stacks the coupling problem we discussed a moment ago is still possible. For example, suppose the settings feature was not a drill down from the users list feature, but instead poppped up in a sheet. Then you have no choice but to use the `.sheet` view modifier to do that, and once you have done that you have coupled the users list feature to the settings feature.

^ so, it's still on you if you want to decouple your features for all of the other kinds of navigation we have discussed in this talk. But at least for drill-down animations, Apple has provided a tool

---

* `NavigationStack`
* `NavigationLink`
* `navigationDestination`

^ In order to accomplish this decoupling the API for navigation had to be spread across 3 APIs. And that makes sense. If it was all in one single API like it is with the now deprecated `NavigationLink` initializers, then how could things be decoupled?

---

## Decoupling navigation: Data

[.code-highlight: 1-4]
[.code-highlight: 6]
```
NavigationLink(
  <#String#>, 
  value: <#Hashable?#>
)

NavigationLink("Edit user", value: user.id)
```

^ In order to decouple the source and destination of a drill-down navigation, we need the ability to specify a piece of data that _describes_ the navigation without specifying the actual destination view of the navigation.

^ this is doing with a new initializer of `NavigationLink` that takes a string to use for the title of the navigation button, and some hashable value. It can be any hashable value.

^ there's a few other variations of this initializer too, like one that takes a view builder for the label of the navigation link.

^ So, with this initializer we do not describe at all _where_ we are navigating to. We only describe a piece of data that represents where we want to go to. When you tap the link, the data is sent through every view layer all the way up to the root, and that data can be intercepted at any point to actually perform the navigation to the destination.

^ This is one part to the key for decoupling the source of navigation from the destination. We can see plain as day here that the source view holding this navigation link to edit a user does not need to compile the "edit user" feature. There is no mention of any of its symbols.

---

## Decoupling navigation: Destination

```
.navigationDestination(for: User.ID.self) { userID in 
  EditUserView(id: userID)
}
```

^ Then, somewhere up the view heirarchy we can intercept the data that is sent from a navigation link. This can happen in pretty much _any_ parent view.

^ This is the second part to the key for decoupling source and destinations in navigation. Here we are able to intercept this simple user id so that we can trigger a drill-down to the edit user view.

^ We do not need to build the source of the navigation in order for us to describe the destination. The previous slide where we constructed the navigation link, that lives in a view that can be compiled completely independently of this view.

^ this style of navigation has fully decoupled source and destination.

---

## Fire-and-forget

```
NavigationLink("Edit user", value: user.id)

.navigationDestination(for: User.ID.self) { userID in 
  EditUserView(id: userID)
}
```

^ So, we have now shown how drill-down navigation can be fully decoupled, but technically what we have described still falls in the "fire-and-forget" category of navigation rather than the "state-drive".

^ It may seem state driven because after all we are using data to trigger the navigation. But, with the code we have sketched so far, the only way to actually trigger the navigation is for the user to literally tap on a link.

^ there is no way to simply construct a piece of state, hand it over to SwiftUI, and have SwiftUI do its thing to present the final view.










---

## Fire-and-forget navigation

```
NavigationStack {
  NavigationLink("Go to settings") {
    SettingsView()
  }
}
```

^ Before doing that we should remark that fire-and-forget navigation, that is, navigation that does not use state to drive presenting and dismissal, still works the same with navigation stacks.

^ This style of initializer for `NavigationLink` is not deprecated. It just creates a button such that when you tap it, it triggers a drill-down animation to the settings view.

---

## Fire-and-forget navigation

```
NavigationStack {
  List {
    ForEach(self.users) { user in 
      NavigationLink("Edit user", value: user.id)
    }
  }
  .navigationDestination(of: User.ID.self) { userID in 
    EditUser(id: userID)
  }
}
```

^ There's even a new kind of fire-and-forget navigation.

^ 


---

## State-driven `NavigationStack`



---

# URL routing

























<!-- 

todo: there are two things that get conflated when talking about navigation. there is the idea of driving navigation from state, and the idea of decoupling destinations from sources.

these are two completely separate topics. each one can be solved without even thinking about the other.


todo: talk more about how state-driven navigation makes it possible to test navigation without resorting to UI tests.

 -->




