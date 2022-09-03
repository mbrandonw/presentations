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

^ It detects when the binding flips to a non-`nil` value, and with that honest value invokes the `content` closure to get a view for the sheet, and does the work of animating the view onto the screen from the bottom of the screen.

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

---

```
func popover<Item, Content>(
    item: Binding<Item?>,
    content: (Item) -> Content
) -> some View
```

---

```
func bottomMenu<Item, Content>(
    item: Binding<Item?>,
    content: (Item) -> Content
) -> some View
```


---

```
func toast<Item, Content>(
    item: Binding<Item?>,
    content: (Item) -> Content
) -> some View
```


---

```
func sheet<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View
```

---

```
func fullScreenCover<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View
```

---

```
func popover<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View
```







---

# Deep linking

---

# URL routing