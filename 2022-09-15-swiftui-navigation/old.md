










---

---
---
---
---
---

<!-- 
  todo: talk about navigationDestination(isPresented: Binding<Bool>)? 
    - another odd duck

 -->




<!-- 


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


 -->





---
---
---
---


---

[.code-highlight: all]
[.code-highlight: 2,3]
```
func sheet<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View

func fullScreenCover<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View

func popover<Content>(
    isPresented: Binding<Bool>,
    content: @escaping () -> Content
) -> some View
```

^ It's worth mentioning that there are alternate versions of the sheet, full screen cover and popover APIs that take bindings of booleans. 

^ this is for situations where the content of the thing being presented is static, meaning it doesn't need to depend on dynamic data that comes into existence.

^ and this still fits into our mental model of navigation as a mode change where data comes into existence because a boolean can represent the absence or presence of data, it's just that there isn't really anything interesting about the data.


---

[.code-highlight: all]
[.code-highlight: 2,3]
```
func sheet<Content>(
    isPresented: Binding<Void?>,
    content: @escaping (Void) -> Content
) -> some View

func fullScreenCover<Content>(
    isPresented: Binding<Void?>,
    content: @escaping (Void) -> Content
) -> some View

func popover<Content>(
    isPresented: Binding<Void?>,
    content: @escaping (Void) -> Content
) -> some View
```

^ in fact, we can think of booleans as just being optional Void values, afterall both types have exactly two values just with different labels.

^ and thinking of things in that way we can think of the boolean binding APIs as being equivalent to using the optional binding style but just with an optional void value.

^ so, at the end of the day, all of this really is modeling navigation as a mode change when data comes into existence or out of existence. and it can be very powerful to be able to model so many different types of navigation in such a consistent manner.

---
