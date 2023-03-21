# Control your dependencies
### don't let them control you

Hello, today we are going to talk about dependencies, as well as all the ways they can wreak havoc in your code, and then show how you can take back control over your dependencies and not let them control you.

---

#### Brandon Williams
	
	brandon@pointfree.co 
	:@mbrandonw
	:&nbsp;
	
#### Stephen Celis
	
	stephen@pointfree.co
	: @stephencelis

/assets/pf-cover.png
background: true
filter: darken

But first a little bit of information about myself. Here is my email and Twitter handle in case you want to get in touch or have questions.

Also, this talk is joint work with my collaborator Stephen Celis, and so here is his information too. You can reach out to either one of us.

---

# Point-Free
	www.pointfree.co

/assets/pf-cover.png
background: true
filter: darken

And if you weren't already aware, Stephen and I run a site called Point-Free, where we go deep into topics like the one I am about to discuss today, and a whole bunch more. I encourage you to check it out if anything in today's talk catches your eye.

---
# What is a dependency?

Let’s start with a very simple question: What is a dependency?

This is a surprisingly tricky question to answer, and I can’t claim to have the most universal definition, but for the purposes of this talk we will define dependency as the following…

---

### What is a dependency?
	> The types and functions in your application that need to interact with outside systems that you do not control.

Dependencies are the types and functions in our application that need to interact with outside systems we do not control.

---
# Examples of dependencies

Now that definition may seem a little nebulous, so let’s look at some very concrete examples…

---
	_Examples of dependencies_
	### Network API clients
	```swift
	
	
	
	let users = try await apiClient.fetchUsers()
	
	
	
	```

Network API clients are a “dependency” because they make network requests in order to load data from external servers. Often such servers are not things under your control, such as if you are hitting the Stripe API for payment processing, or Mastodon API to load new toots. 

And sometimes the server _is_ under your control, such as if it’s your company’s backend to power your app. Even in those cases we will consider it a dependency because it is an outside system, that is, it exists outside the code base that powers your application.

---
	_Examples of dependencies_
	### Location managers
	```swift
	
	
	
	let manager = CLLocationManager()
	
	await manager.requestWhenInUseAuthorization()
	
	let location = try await manager.requestLocation()
	
	
	
	```

If you have ever used Core Location in your application, then you were using a dependency. Not only do you interact with Apple’s frameworks for fetching location data, which you do not control, but those APIs interact with the GPS instruments in your device in order to triangulate coordinates. That is a major outside system interacting with satellites orbiting the earth.

---
	_Examples of dependencies_
	### File systems
	```swift
	
	var data = try Date(contentsOf: URL(…))
	
	data.append(…)
	
	try data.write(to: URL(…))
	
	```

If you have ever saved or loaded data to or from disk, then you were using a dependency. The file system is another massive external system because it exists outside your code base. Any application can read and write to it without your knowledge, and so it is not something your application controls.

This also extends to user defaults too. Anytime you read or write to user defaults you are indeed interacting with the file system, and so that is a dependency.

---
	_Examples of dependencies_
	### Firebase
	```swift
	import FirebaseDatabase
	
	let ref = Database.database().reference()
	self.ref
		.child("users")
		.child(user.uid)
		.setValue(["username": username])
	```

Firebase is another massive dependency. It’s kind of a _mega_ dependency, because it acts as a database, acts as a network API client, handles analytics, crash reporting, logging, remote config, authentication, push notifications, storage, and more! All of the code that powers these features is written by Google and hosted on Google’s servers, and so is fully out of your control.

---
	_Examples of dependencies_
	### Clocks and schedulers
	```
	
	try await Task.sleep(for: .seconds(1))
	
	DispatchQueue.main.schedule(after: .now + 1) {
	  …
	}
	
	```

If you have ever used a Swift `Clock`, which was introduced in Swift 5.7, or a Combine `Scheduler`, then you were again using a dependency. Those objects speak with the outside world in order to execute work at a later time, and we have no ability to tell those processes to do things in a different manner.

---
	_Examples of dependencies_
	### `Date()` and `UUID()`
	```swift
	
	let user = User(
	  id: UUID(),
	  name: "Blob",
	  createdAt: Date()
	)
	
	```

And then seemingly innocuous things such as `Date` and `UUID` initializers can also be considered dependencies. After all, when you ask Foundation for the current date it reaches out into the real world to get that information. 

And further, every time you construct a date it is slightly different from the previous time because time is forever marching forward, and sadly we have no control over that. 

The same is true for `UUID`s. Each time you construct one you get a completely random, cryptic sequence of hex digits, and the process that concocts that value is an external system that we do not control


---
	_Examples of dependencies_
	### …and _a lot_ more

And this is only scratching the surface. There are many, many, _many_ more examples of dependencies, and your code today is probably full of them.

---
## The problem with uncontrolled dependencies

So, if you believe everything I have said so far, then dependencies are seemingly ubiquitous in application development. They are literally everywhere, and if this is the first time you are hearing about “dependencies” then you may wonder what the big deal is. 

You've been coding for years, apparently using dependencies left and right, yet you've never stopped to think about it and you get along just fine. So, why should you care?

Well, I’m here to tell you there are a lot of problems that occur when you have uncontrolled dependencies. You probably have these problems in your code base right now, but you may not know that dependencies are to blame for it.

And you may have also come up with all types of work arounds for the problem, or just learned to adapt and live with the problems.

---
	_The problem with dependencies_
	### Many are slow to compile
	```swift
	import Firebase
	```
	> _Build succeeded  86.9 seconds_

Perhaps the biggest problem with dependencies is that very often they are extremely slow compile. It takes nearly 90 seconds to compile a fresh project with Firebase added to it on my M1 MacBook Pro. That is nearly 90 seconds just to compile Firebase, not including all the code that needs to be built for your application.

This means every time you do a clean on your project you incur a minimum 90 second cost to rebuild. Or if you change branches to work on a different feature, again you are most likely going to incur that 90 second cost again. This time really starts to add up.

Now this does not apply to Apple’s frameworks because those frameworks are all pre-compiled and included automatically. There is no compile-time penalty to using Core Location. It’s just ambiently always there. This downside mostly applies to 3rd party frameworks, such as Firebase, or web socket libraries, and more.


---
	_The problem with dependencies_
	### Some make it annoying to run your code

Another problem with dependencies is that they can just make your code more annoying to work with. Because they reach out to uncontrolled external systems you are at the mercy of those systems in order to see how your code even runs.

I have a demo for this. I’m going to switch over to the simulator, where I have an app running that has lots of demos that we will be playing around with in this talk. The first demo is this “Countdown” feature.

I can drill down to it, and we will see a counter starting at 10, going down to 0, and when it reaches 0 a little bit of confetti bursts out of the center.

So that’s fun, but let’s take a quick look at the code for this feature. We will see it `ZStack`s a bunch of confetti views on top of the counter, and when the view appears the `.task` modifier is executed at the end, where we use structured concurrency to sleep in an infinite loop in order to execute our logic.

The read flag to us is this line right here:

try? await Task.sleep(for: .seconds(1))

That is reaching out to a global, uncontrolled dependency that asks the system clock to sleep for 1 second. That means to run our feature in the simulator we have no choice but to literally wait many seconds to pass by.

For example, I don’t know if anyone noticed, but when the confetti burst it was actually _behind_ the counter number. I would prefer it to be on top, and luckily that is a very easy fix by just swapping the order on the `ZStack`.

However, in order to see that change I need to run the feature in the simulator, wait another 10 seconds, and then finally I get to see that indeed the confetti is on _top_ of the number. However, say I got distracted while it was counting down and I missed the burst? Well, I guess I would have no choice but to run the application in the simulator all over again and wait another 10 seconds.

That is a real pain. 

Also, SwiftUI previews are supposed to be the amazing tool that allows us to play with our feature in isolation without booting up the simulator and navigating all the way to the thing we want to actually test. However, even it is not super helpful here. When running the preview we _still_ have to wait 10 seconds to pass before we get to see our confetti burst, which means we have completely destroyed the quick iterative cycle that Xcode previews promises us. Any tweak we may want to make to this feature incurs the cost of 10 seconds, which is not great.

Now some of y’all may already be thinking about some potential workarounds. For example, if we wanted to iterate on just the _design_ of the confetti then we could pull out the `ForEach` with the `ConfettiView`s into its own view so that it can be previewed in isolation. And sure that would work, but also we are creating this extra view only to workaround an issue with using `Task.sleep`. Our feature doesn’t need that extra view. It just wants to show some confetti. So we are being forced to maintain extra code just to make it easier to work with, and all code is a liability in that it gives you new ways to get something wrong.

So, I wouldn’t want to maintain an extra view just for that. Further, even that extra view doesn’t help with the first problem we had which is how the confetti view _integrates_ with the rest of the feature. In particular, we wanted to make sure it appears _over_ the countdown. One thing we could work around the timing problem at the integration level is to hard code the `countdown` variable to start at something smaller, like say 1 or even 0.

However, we are setting real production values with test values just so that we can reasonably preview this feature. What if we forget to change it back to 10? Then the feature is completely busted. In general it is not a good idea to hack in little changes just to get your preview running.

So, we are now seeing in very concrete terms that by not controlling this dependency, the `Task.sleep`, we are letting it control us. It is forcing us to contort ourselves in weird ways just so that we can make code that touches `Task.sleep` less annoying to use

---
	_The problem with dependencies_
	### Some do not work in Xcode previews

Ok, so already it’s seeming pretty bad to not control your dependencies, but things get far, far worse.

In the previous example we just considered, at least the feature worked in the preview. It was just annoying to use the preview because we had to wait for real world time to pass in order to see the feature’s behavior.

But there are many dependencies that simply do not work in Xcode previews, and that completely ruins your ability to iterate on designs, functionality, fix bugs and more.

In fact, _most_ of the 1st party frameworks that Apple gives us access to simply do not work in previews, including Core Location, Core Motion, speech recognizers, Store Kit, the Contacts and Address Book frameworks, Game Center, and a whole bunch more.

If you indiscreetly sprinkle direct access to those frameworks in your code, you have a good chance at just completely ruining your ability to quickly iterate on your features in previews.

I have a demo to show exactly how this can happen. Let’s go back to the simulator, and this time let’s go into the “Location Demo”.

What we will find is a very simple feature that shows a map that by default is zoomed in on the New York City area. There’s also a button in the bottom right that when tapped is going to ask for location permissions, and if you grant permission then we refocus the map on your current location.

Pretty simple, and the code is quite simple too. We have an `ObservableObject` so that we can create a location manager and set up a delegate. When the location button is tapped we check the current authorization status, and if authorized we request location, and otherwise we request authorization. Further, when authorization is granted we then request the user’s location. And finally, when a location update is delivered to the delegate we mutate the current `coordinateRegion`. It’s pretty straightforward stuff.

But let’s try running it in the preview. Well, the map does show with NYC centered, but tapping on the location button does nothing. No authorization prompt comes up and the map does not re-focus anywhere.

This is happening because location authorization simply does not work in previews. No alert can be shown, therefore we can’t grant location permissions, therefore we are never given an updated locations from Core Location, and therefore the map does not refocus.

This preview is basically inert. Now you may be thinking: “well, at least this screen shows and we can iterate on its design.” Well, yes that is true, we can certainly make tweaks here, such as the button size, and we do see it immediately update.

But there is a whole world of logic and behavior in this feature beyond just this static map. What if we had some interesting behavior we wanted to iterate on for when location permissions are granted or denied. We can not get access to any of that in the preview, and instead have to load up the full app in the simulator, navigate to the feature, and _then_ see how our feature behaves. Further, if you wanted to test the exact situation of _granting_ permission or _denying_ permission, then you would have to fully delete the application between each run. Once you have granted or denied location permission there is no way to get iOS to ask you again.

There are even some dependencies that don’t even work in _simulators_. For example, Core Motion has some interesting APIs for reading accelerometer and gyroscope events from the device, but none of that works in the simulator. You have no choice but to actually run the app on your device if you want to play around with that behavior.

We are again seeing that by not controlling our dependencies we are allowing them to control us. We simply are not able to use Xcode previews if we use certain frameworks directly in our code.


---
	_The problem with dependencies_
	### Some _break_ Xcode previews

So, it’s a pretty big bummer that previews become less helpful as you start to use certain dependencies in your code base.

But things get much, _much_ worse. Some dependencies just completely break previews entirely. To demonstrate this lets head back over to the simulator and take a look at the “Contacts demo."

This is a very simple demo showing how to interact with the Contacts framework by loading the names of all the contacts on the device. When we drill down to the demo we are instantly asked to grant permissions, and if we allow then we will see some contacts fill the screen.

The code is extremely simple. There’s just some state to hold the names of users, which we show in a `List`, and in `onAppear` we interact with `CNContactStore` to request all of the contacts on the device.

So, that’s great, but let’s see what happens I run this in the preview. It’s just a blank screen. No alert asking for permission, and no list of contacts. This is because the Contacts framework simply does not work in previews, just like Core Location. It does not support showing the permissions alert.

So, the preview is inert just as we saw with our location demo, but it at least runs. If there were other things in this UI we could at least iterate on _their_ design and functionality in the preview.

However, let’s now do a very simple thing. I want to move this feature to its own module. Modularizing code bases is becoming very popular in the community and it is one of the most impactful things you can do to decrease build times, decouple features, and run features in isolation without building the full application.

So, I will literally copy-and-paste this code into a new file of the SPM package I have stubbed out.

Now when I run the preview it just crashes. We don’t get to see the UI at all. This is happening because in order for us to be able to interact with the Contacts framework’s APIs we must have an entry added to the info.plist of the application. We did that in the main application, and I guess the Xcode previews for the main application get the info.plist automatically from the surrounding app target.

However, previews inside an SPM package have no surrounding app target, hence have no concept of an info.plist, and hence it is simply not possible to add the entry to the plist. This means this preview is just completely busted for us. We are not able to work on the design of anything inside this feature due to the crash. Even things that have nothing to do with the list of contacts. It is just broken.

Now some of you may know of a workaround for this. What if we just created a whole new view that holds only the data but does not interact with the Contacts framework at all, and then the main view can wrap that new pure data view?

Well, it’s certainly possible, but I think it sounds better in theory than it works in practice. First, most views are not just simple, inert representations of data. Most views have behavior, such as buttons to tap, textfields to enter text into, gestures to perform, and more.

Supporting all of those features is going to bloat the “core” view, make it easier to get things wrong or hook things up incorrectly, and at the end of the day this “core” view is only a mere shadow of the feature. A mirage. We are cramming data into it to make something appear in the preview, but the code path that is actually responsible for getting the data is not being exercised at all in the preview, and therefore we have no choice but to still run the full application in the simulator if we _truly_ want to see how this screen behaves.

So we are again maintaining a bunch of additional code just to work around the fact that we have an uncontrolled dependency in our codebase. 

And the code needed to maintain all of these little inert views that only hold onto data vastly outweighs the amount of code needed to control your dependencies. There may be 20 views out there that need to use a dependency, and each one of them is going to need this extra "inner" view to make the preview usable. Whereas you only need to control a dependency a single time and _all_ views get to benefit.

And right now we are seeing a situation where the dependency just completely crashes the preview, but the preview is still running. There are also some dependencies out there that will make it so that your previews just do not run at all. You will get cryptic errors when running the preview and it is very hard to diagnose. The more you control your dependencies, the less code you need to compile in your features, which means Xcode can do a much better job at showing you your previews.

---

	_The problem with dependencies_
	### Accidental interaction with “live” dependencies

We’ve so far covered a lot of very in-your-face and pernicious problems when using dependencies without abandon in your code. Next I want to talk about a much more subtle problem that can remain hidden from you for a long time until it finally bites you in the butt.

And that is accidentally using “live” dependencies when you don’t mean to. To explore this, lets head back to the simulator yet again to check out the “Analytics demo".

This demo is identical to the location demo, but with one key difference: it has an analytics client for sending certain events to a backend service so that we can aggregate user behavior and make business decisions based off of that data. The feature has also been instrumented in various places that we are interested in, such as when buttons are tapped, when we get authorization from the user, and more.

We can run the application in the simulator and see that logs are printed to the console showing that analytics are indeed being tracked how we expect.

The problem is when we run this feature in the preview. Unbeknownst to me, while I am running this preview over and over and over, and tapping on buttons, I am secretly tracking analytics events and sending those to my backend server. Over the course of working on this feature for an afternoon I can _easily_ refresh this preview hundreds of times. Each preview refresh tracks a new analytic event, and that is going to muddy up our data. We can no longer confidently make business decisions based on this data because it now holds events that didn’t actually come from our end users and instead came from our developers building new features.

---

	_The problem with dependencies_
	### Difficult or impossible to unit test and UI test

And if _all_ of that wasn’t bad enough, it gets worse.

I saved this one for last because testing isn’t exactly a top priority in the iOS community. I think that is a little unfortunate, and I would highly encourage everyone to really understand what testing brings to a codebase and consider what it would take to make your code testable.

Tests are a great barometer for the health of your code. If you are able to construct the various objects in your code base in a fully isolated environment, run their logic, and then assert on how they behave, then you can be confident that your features are decoupled from the outside world and that you have the ability to alter their execution environment so that you can test really subtle and nuanced user flows.

And in fact, all the problems we just saw with our previews are an omen that we are going to have problems with testing. Previews are kind of like tests in that they run your features in an altered, isolated execution environment that is quite a bit different from the simulator and device. 

Playgrounds are another example of a minimized execution environment. How cool would it be to be able to construct the various objects in your codebase and play around with them in isolation without needing to run your application in the simulator or on a device?

Unit tests take this idea to the extreme. Unit tests completely remove the concept of a simulator or device entirely, and it’s just your code running in an expansive, empty vacuum.

I have yet another demo to show off this problem, but this time we are going to look at a code sample from Apple.

Apple has this great tutorial called “Scrumdinger” which builds a surprisingly complex application from scratch. I say “surprisingly” because often Apple’s code samples are there to highlight some very specific features of SwiftUI and other frameworks, but doesn’t exactly build a cohesive application that you can learn from as a whole. I think the Fruta and Food Truck demos are interesting for learning certain things, but they don’t deal with any of the real complexities one comes across in every day development.

The Scrumdinger app, on the other hand, deals with multiple forms of navigation, persistence of data and complex side effects such as timers and speech recognizers. It’s pretty cool.

But also it isn’t exactly built with testing in mind, and  it is very difficult to write tests for the app due to the use of uncontrolled dependencies. All the problems we discussed previously pertain to this application, such as previews not being all that useful because most of the dependencies don’t work in previews.

But, one way to get _some_ test coverage on an application regardless of the manner in which it was built is UI tests. UI tests allow you to literally boot up your app in the simulator and emulate a script of user actions on the screen so that you can assert on what happens.

Well, I gave this a shot in Apple’s Scrumdinger app by writing a test to exercise the flow of the user tapping the “+” button, filling in some details, hitting “Add”, and then asserting that the root list has a single row with the details that were just entered into the form.

So, let’s run the test… and it passes!

But, let’s run the test again… and now it fails!

What’s going on?

Well, one of the features of this application is that it persists data to disk so that next time you launch you have all of your meetings from last time. That’s a great feature to have, but it’s also making testing complicated because now when we run this test it is loading up data from _previous_ runs of the test. Our dependency on the global file system is bleeding over from test to test.

So we have no choice but to actually _weaken_ what we are testing here. We can’t test that when we go through this user flow a single item was added to the list that matches “Engineering”, but rather we can only test that there is at _at least_ one item with “Engineering”. There may be more, and probably will be!

So, if we ever accidentally introduce a bug that causes more than one item to be added to the list our test will happily pass and we will be none the wiser unless we happen to actually load up the app and witness this behavior.

---

# Death by 1,000 paper cuts

So we have seen over and over again that seemingly reasonable code can lead to some very unfortunately results. Everyone here probably at least one version of these problems in your code base today. 

Maybe it’s a preview that doesn’t work very well due to complex behavior and so you just run it in the simulator. 

Or maybe you have a feature that uses a dependency that doesn’t work in the simulator and so you are constantly running it on your actual device just to play around with its most basic behavior.

Or maybe you have an application that takes a long time to build so you just make sure to never accidentally clean the project, or you keep multiple versions of your repo checked out so that you don’t have to switch branches.

And maybe over time you’ve just grown to understand that these are the peculiarities of your application and learn to deal with it. You may have some tricks you employ to get around certain annoyances, and for the most part you are able to be productive throughout the day. 

And that may be OK for you, but this does not scale at all, especially when you are on a team with multiple people because _then_ you need to distribute your little bag of tricks that you employ daily so that everyone on the team can use them too and not be blocked by these quirks.

What I’m trying to say here is that uncontrolled dependencies can make it really, _really_ annoying to work in a code base. Each of these in isolation is maybe not a huge deal, but it’s easy to have lots of uncontrolled dependencies that cause more and more problems, and the problems start compounding on each other.

---
# What can we do about it?

So, that was just a lot of time spent on negativity. We saw problem after problem with various code snippets, so now we will devote time to some positivity. What can we do to fix the problem?

// TODO: talk about the fix falling into two buckets:
//   * First you take control of the dependency
//   * Second you must make it ergonomic to access dependencies

---
	_What can we do about it?	_
# In short:
### Don't reach out to code you don't own and can't control

Well, in short: stop reaching out to code that you don't own and can't control from the outside. This includes interacting directly with the 3rd party APIs, such as Core Location, URL Session, file systems, Firebase, clocks, schedulers, date and UUID initializers, and more.

All of those things talk to external systems and so the moment you interact with one of those APIs directly in you feature code you are susceptible to the vagaries of the outside world.

I'm going to further extend this advice to not just include reaching out to code you don't own, but also reaching out to code you can't _control_. In essence this means using singletons. In our analytics demo we saw a moment ago I was using an `AnalyticsClient` "shared" singleton in the `ObservableObject` in order to instrument the feature. 

By using a singleton we have completely frozen that piece of functionality into the feature and it can never be changed. That feature, no matter how it is run, whether in a preview, simulator, device or test, will _always_ use the same instance of the analytics client, which means making a real network request to send real data to our analytics backend. We have absolutely no ability to swap out that client for something that _doesn't_ track analytics for certain situations.

Let's see some concrete examples of this in the demo we have been using to see all the problems with dependencies.

---
	_Controlling dependencies_
	### Time
	
	```swift
	
	
	let clock: any Clock<Duration>
	
	try await clock.sleep(for: .seconds(1))
	
	
	```


Let's start with the "Countdown" demo. It's main problem is that we had to wait for real time to pass in order to see the confetti animation, and it was that way because we reached out to the global, uncontrolled `Task.sleep` method.

What if instead we passed in an explicit clock so that we can control time. By default we will use a `ContinuousClock`, but in the preview we can provide an "immediate" clock that squashes all of time into a single instant. When you tell it to sleep it just ignores you and doesn't suspend at all.

Let's go back to the simulator, and secretly at the bottom of the root view I have some more demos. These are replicas of all the demos we have already gone through, but now we will control their dependencies.

Let's go to the controlled countdown demo's code, and add an explicit clock to the view. Now that the view holds onto a concrete clock we can use it in the feature code rather than reaching out to the global, uncontrolled `Task.sleep`.

And then the most important part is that when we construct this view for the preview we now have the power to supply a clock that is not the `ContinuousClock`, which waits for actual, real world time to pass.

But, unfortunately, Swift does not come with any `Clock` conformances that can help us out here. The only two conformances are the `ContinuousClock` and the `SuspendingClock`, but we want something like an "immediate" clock.

Well, luckily Stephen and I maintain a library of helpful `Clock` conformances, and so we can import `Clocks` here and then construct an `ImmediateClock`.

Now we see that the countdown zips down to 0 instantly and see the confetti. This has completely fixed the problem we were seeing before without changing how the app behaves in the simulator. The simulator will still use a live, continuous clock and will actually wait for a full 10 real seconds to pass.

And we accomplished this by just adding 1 single line of code and changing 1 other line of code. If we had decided to maintain one of those "core", inert views that just holds data then we would have added _dozens_ of lines of code and could have easily gotten something wrong that breaks the app but looks fine in the simulator.

Alright, so this is looking really promising. We've seen the very basics of controlling a dependency:

* Supply the dependency explicitly to the type that wants to use it.
* Then actually use that dependency instead of reaching to the global, uncontrollable dependency.

So, rather than reaching out to `Task.sleep` directly, we instead add a clock to the view and use that.

This turned out to be really simple in this case, but I don't want to lead you to believe it's always this easy. We are lucky here because we happen to want to control a dependency that is already abstracted with a protocol, `Clock`, which means it easy to add an `any Clock` to the view and then substitute any number of implementations at runtime.

---
	_Controlling dependencies_
	### Analytics
	
	```swift
	
	
	
	let analytics: any Analytics = LiveAnalytics()
	
	analytics.track("Authorization granted")
	
	
	
	```

Most of the time we have to put in a little bit of extra work to actually control our dependencies.

Take for example the analytics demo we showed off before. It had the problem of using an uncontrolled dependency for tracking analytics events, and that mean that we tracked real events when running the app in the preview. This will flood our analytics backend with fake events that do not actually correspond to things our user is doing in the app.

The fix is to take back control over this dependency rather than letting it control us, but this time we have to do a bit more work.

At the bottom of this file we have sketched out a protocol that acts as an abstraction layer over the analytics client. Now, if you have followed my and Stephen's work for any amount of time you will know that we do not reach for protocols for this level of abstraction. There are simpler tools that offer a lot of power, but that is a whole other topic that will just muddy what I want to get at here.

I think far more people are familiar with this style, so let's roll with it. In addition to the protocol definition I have two conformances. One is the "live" conformance, which would be the thing that actually makes a network request. Right now it just logs to the console because this is just a demo, but you can imagine right in here is a call out to `URLSession`.

Right below the live implementation we have the "no-op" implementation. This is a conformance of the `Analytics` protocol that doesn't do any actual tracking. It won't ever make a network request, and we don't even print anything to the console. It just does absolutely nothing when you tell it to track an event.

So, let's start using this controllable dependency. We can add a property to our `ObservableObject` so that an analytics client can be passed in from the _outside_, and then we can be strict with ourselves to only use it and never reach out to the global, uncontrollable dependency.

If we do that then we can create the view for the preview in a very particular configuration. In particular, when creating the model we will pass along the `NoopAnalytics` client so that no matter what happens in the preview it will never track a real life analytics event. And we can see that plain as day by running the preview and seeing that there's nothing in the logs.

So that's great!

But, even this dependency wasn't so hard to control. The analytics client has a very simple interface, just a single `track` client, and so it was very straightforward to slap a protocol in front of it and then pass it explicitly to the model.

---
	_Controlling dependencies_
	### Apple Frameworks

This is not always the case, and things get more complicated as the dependency gets more complicated.

Take the location demo from earlier. Interacting with a `CLLocationManager` is a lot more complicated than that analytics client. It has multiple methods we need to call, and it has a delegate that feeds us a stream of events. It takes more work to control this dependency, but the benefit is that you can immediately use it in any feature without making many changes, and you can develop those features in basically the regular way. No need to create additional, inert, data-only views just so that you can see how things behave in a preview.

We aren't going to do this from scratch because we don't have enough time in a single talk, but I have the work already done. At the bottom of the file we have a `LocationClient` protocol that exposes most of the basic functionality. The most interesting part is that the delegate is exposed as an `AsyncStream` that we can subscribe to.

Below the interface I have a "live" implementation that does actually call out to a `CLLocationManager` under the hood, but then most interesting, I have a "mock" client just below that. It allows you to emulate a location client, but rather than calling out to a `CLLocationManager` it just returns data to you right away. So if you ask it to authorize it just immediately says "sure you're authorized". And when you ask it for a location it immediately says "sure here's a location." 

Let's give that a spin. In the preview we can substitute a mock for the location client that emulates being in Los Angeles. So, when we start the preview it is first centered in NYC, but as soon as we tap the location button it re-centers around LA. So we are now getting to actually see the behavior of the feature in the preview, not just look at its inert, lifeless graphical representation. This means we do not have to run this in the simulator just to check out this behavior, and that will be a huge productivity boon.

We have another example of this over in the contacts demo. Here we have put another interface in front of using the bare Contacts framework APIs, and we have a live implementation of the interface as well as a "mock" one that simply pretends everything is already authorized and immediately gives you back some contacts.

This now lets us run the preview and see some data actually populating the list, but even better, we can copy-and-paste all of this code over to the Swift package where, if you remember, previous the preview simply crashed due to incorrectly configured Info.plist. It wasn't actually possible to fix that plist problem in the package, and so we were out of luck. Now that we have a mock dependency we are not touching any Contacts framework code at all, and the preview works just fine.

---

# Dependencies controlled

So, things are looking pretty great!

We have defined what dependencies are, we have seen how they can cause all types of problems in real code, and we have seemingly fixed those problems.

You just need to identify your dependencies, make them controllable by putting an interface in front of them so that you have the freedom to swap out live and mock implementations, and then provide different implementations depending on the situation. When running your app in the simulator or on device you will probably want to use the live implementation, and then in previews and tests you will probably want to use a mock implementation.

---

# Safety & Ergonomics

Well, it all sounds great, but unfortunately things are more complicated than they seem at first.

If what we have discussed so far is all I told you about dependencies and you went out and tried wrangling in the dependencies in your application, you would run into many ergonomics problems, and it would probably be such a pain that you just wouldn't even bother.

---
### Safety
	```swift
	
	
	
	init(
	  analytics: any Analytics = LiveAnalytics(),
	  location: any LocationClient = LiveLocationClient()
	) {
	  // ...
	}
	
	
	
	```

The first problem is safety.

Because we didn't want to break existing code we provided a default when we wanted to pass in a dependency. This is extremely ergonomic to use in practice because we just don't have to worry about these arguments unless we want to actually control dependencies.

So, that seems good, but also severely hinders the safety of this code. 

First, in a more real world application, you will have many objects that need dependencies, and they will nest inside each other. By supplying defaults to these arguments we make it possible, and very easy, to accidentally supply explicit dependencies to one part, but then not another part. That will mean part of your application is using the default, live dependencies and some other part is suddenly using modified or controlled dependencies. That can cause very strange, subtle bugs and is most likely not what you want.

So that's bad, but also since it is possible to create an object without supplying any dependencies, and more importantly, even possible to create an object while being completely _ignorant_ of the dependencies that _could_ be supplied, it is still easy for us to accidentally reach out to live dependencies when we don't mean to.

For example, in the analytics demo it is completely fine for me to leave off the analytics argument, the preview works just fine, but now we are secretly tracking live analytics to our backend. This means we have to be intimately knowledgable about the internals of all views and objects in our application to know when we should override the analytics client for previews. But worse, if someone updates a view that previously did not have analytics and added analytics, then that preview would start tracking live event data and we would be none the wiser.


---

#### Ergonomics
	```swift
	
	init(
	  analytics: any Analytics,
	  locationClient: any LocationClient
	) {
	  // ...
	}
	
	```

So, safety is a really big issue, and that may be reason enough for us to abandon the defaults entirely and just require all dependencies to be passed explicitly.

But that brings up all new problems of its own. If we drop the defaults and require all dependencies to be explicitly passed in, then the simple act of adding a dependency to a feature will reverberate throughout the entire application.

Suppose this little location demo was many layers deep in the application. Maybe you have to switch to a tab, drill down to a screen, open up a sheet, and then drill down again to finally get to this feature. Well, if we add a single dependency to the location feature we are going to have to also add that same dependency to every single feature that touches the location feature, as well as every feature that touches a feature that touches the location feature, and on and on. 

Adding a dependency has turned into a viral event in which you are not updating objects in your code pass to take a dependency just so that you can pass it down the line, and the object doesn't even have any need for that dependency.

---

	> Defaults are **ergonomic**, but not **safe**.
	> Requirements are **safe**, but not **ergonomic**.

What we are seeing is the unfortunate dichotomy between safety and ergonomics. Often things that are safe are not ergonomic, and things that are ergonomic are not safe. You have to give up a little of one to get some of the other, and it's a real bummer!

This is the exact reason why people turn to "dependency injection" frameworks. It's not because people don't know how to pass explicit dependencies to the objects that need them.

It's because if you do that _literally_ you are going to make a mess of your code base, and it's going to be so painful to add new dependencies that you simply will not do it. This is one of the reasons that "dependency injection" gets a bad wrap.

---

# “Dependency injection” library

This is what leads people to adopt what is known as a "dependency injection" library. The sole purpose of a dependency injection library is to make it possible to give our objects the dependencies it needs to do its job.

But also, crucially, do it in a way that is in some sense safe _and_ ergonomic. That is any dependency injection library's 1st goal, above all else. Now, it's not really possible to offer full safety and full ergonomics at the same time, and so every library has to make tradeoffs.

And then the stance the library takes on safety versus ergonomics will dictate what other kinds of features the library offer you for overriding and controlling dependencies in interesting ways.

---

	* Cleanse
	* Factory
	* Needle
	* Swinject
	* Weaver
	* ...

There are a decent number of dependency injection frameworks out there in the Swift community. Here are just a few, and each of these has their own trade offs based on what they choose to prioritize.

If you decide to control your dependencies, and I hope I have somewhat convinced you that it is worthwhile doing, then you may want to research all the various options out there and see how they can help you solve the problems you are having with your dependencies.

---

	## github.com/pointfreeco/
	## swift-dependencies

And it just so happens that Stephen and I main a dependency library. I am in no way suggesting you use our library. We have made certain trade offs and decisions that are a top priority for us but maybe don't make a lot of sense for you.

In particular, we wanted to fully embrace structured programming and structured concurrency when overriding dependencies, and so we use Swift's new `@TaskLocal` machinery to power the dependencies under the hood. This brings a lot of power when used correctly, but also completely prevents certain features that other dependency libraries have.

So, let's quickly see how our dependencies library can help improve upon the safety and ergonomics of how we are currently handling dependencies in our demo application.

Let's start with the countdown demo. Rather than passing an explicit clock to the `CountdownView` we will declare our dependency on a clock using the `@Dependency` property wrapper. The library comes with a bunch of common dependencies ready to use in a controllable fashion, and clocks are one. We can pluck out a controllable clock out of thin air, and with that we no longer need an initializer for passing in an explicit clock. One will be provided to the view automatically.

Outside of the initializer everything works exactly as it did before. We can reference `clock` anywhere in the view and use it like normal. So already this version of this feature is slightly more ergonomic that the previous because we no longer even need to maintain an initializer just so that someone can pass it a non-continuous clock.

But then you may ask: how can we use a non-continuous clock with this set up? Well, that's where the real magic comes happens. You can alter the execution context a view operates in by simply wrapping its creation in a `withDependencies` call. So, down in the preview, we will use this tool to override its dependencies and provide an `ImmediateClock`. That's all it takes.

When the application runs in the simulator or device it will still use the real life `ContinuousClock`, but down in this preview we get to choose what kind of clock we want to use just for this one specific preview. We can even have two previews side-by-side each with different dependencies, which is great for being able to see how your features behavior with a bunch of different dependency combinations.

Let's look at the next demo. We've actually combined both the location and analytics demo into just one. We are now using the `@Dependency` wrapper twice, once for the analytics dependency and again for the location client dependency. And best of all we no longer need an initializer, and no longer need to decide between providing a default for dependencies are not.

This object can be created without explicitly passing in any dependencies, so it's very ergonomic to create this object, yet it's still possible to control the dependencies.

We technically could do this using the `withDependencies` tool that we showed off in the countdown demo, but there is something even better we can do. If we scroll down to the preview we will see we are creating the model object without overriding dependencies at all. That seems really bad. Won't that mean that we are accidentally tracking live analytics events to our backend and that the preview will be mostly non-functional since since Core Location doesn't work well in previews?

Well, we can run the preview to see that is not the case. The preview is completely functional and we can check the logs to see that nothing is being printed to the console which means analytics events are definitely not being sent to our backend.

How can that possibly be? 

Well, our dependencies library has the concept of "preview" dependencies. When you register a dependency with the library so that it can be used with the `@Dependency` property wrapper you get to specify 3 implementations: the one to be used when running the app in the simulator or on device, called the "live" implementation, one to be used when running in previews, and one to be used when running in tests.

When registering the analytics and location client with the dependencies library we chose to provide implementations that do not reach out to the outside world. So we no longer have to ever worry about accidentally tracking real life analytics events when running in a preview. That possibility has been completely ruled out due to how the library is structured.

And if you want to further tweak the dependencies for the feature you can always wrap everything in a `withDependencies` and override anything you want.

So this is a _huge_ ergonomic improvement over the explicit dependency passing we explored earlier in the talk. We don't have to explicitly pass dependencies around and yet we can still be very safe. A feature is free to add analytics without worrying about accidentally tracking bad data in previews.

Further, while we're here, let's also show that we can add a new dependency without any fuss. Let's say this feature started needing access to the current date. We can do that easily, and everything still compiles without having to make a single change. We could have dozens or hundreds of other features needing to construct this feature, and we wouldn't have to update a single one.

---

# Extra code just for dependencies?




// TODO: some might say that doing the extra work to control you dependencies is not right because you are writing extra code for testing. That is completely wrong. Controlling your dependencies allows you to code in the style that we all want to do naively. We all just want to call out to apple framework code immediately and get some data back so that we can be on our way and work on our actual feature for our users.
// 
// well, controlling your dependencies allows you to do exactly that. While we did have to put in a little bit of upfront work to put an interface in front of the dependency, after that you are free to use the dependency exactly as you would call out directly to Apple's frameworks. The same cannot be true of building inert, data-only views just so that previews can work again. That is you doing work that truly only serves the purpose of getting previews to be functional again. 





---

# This is just the beginning

So, I hope that this talk has helped you understand what dependencies, why they can be so pernicious in a code base, and what you can do to start controlling them.

However, I must warn that although we have covered a lot in this talk, it's really only just the beginning. We've discussed enough for you to be dangerous, but there's is still so much to learn to truly master the topic.

---

# Advanced topics
	* Designing dependencies
	* Overriding dependencies
	* Propagating dependencies
	* Testing

Here are just a few topics that are important to dive into to fully master dependencies.

First there's "designing dependencies". By this I mean the techniques that guide one in creating the interfaces and wrapper types that you put in front of a dependency in order to make it controllable. We showed off a few examples of this, such as the `LocationClient` and `ContactsClient`, but we didn't actually build those types from scratch in this talk. 

There is a lot to about how those clients were designed, and how to make them maximally flexible for testing and previews. It is also important to know when it is appropriate to model something as a dependency and when it is not. Not _everything_ should be a dependency, and on the flip side, some things should be dependencies that don't at first seem like dependencies.

Next there is the idea of overriding dependencies. We have already seen a glimpse of this for previews where we used the `withDependencies` tool to override dependencies just for the preview. But there are so many more cool things we can do.

For example, suppose you have an onboarding experience that teaches a person how to use a particular feature of your application. It would be great if you could allow them use the actual real feature but without worrying about accidentally write data to disk, or sending data to the server, or tracking analytics that aren't meant to be tracked. And so our library also provides tools that allow you to accomplish this. You can construct just one small part of your application that runs in an altered execution context, and it will not affect the rest of the application. That is incredibly powerful.

Next is the concept of propagating dependencies, which is closely related to overriding dependencies. If you want to be able to have the full power of what I just mentioned, that is, the ability to override dependencies just for one small part of a larger application, then you need to make sure dependencies are propagated throughout your application correctly. It would be really bad if somehow the controlled dependency in your onboarding flow accidentally leaked to other parts of your application, causing a mock file system to be used in place of the real one. Our dependencies library also provides tools for this.

And finally there is testing. We didn't directly show how our dependencies library enables testing, but it isn't too different from what we did in previews. You use the `withDependencies` tool to set up your  dependencies, and then execute your test in that controlled environment.

But the library goes a step beyond too. If you access a dependency in a testing context that you have _not_ explicitly overridden, then you get a testing failure letting you know it is not OK to use live dependencies in tests. This prevents you from accidentally tracking analytics, writing data to disk, or any number of things while testing. All of those things can be tests bleed into each other causing mystifying failures, or can cause your tests to become slow and flakey. It also means that if you suddenly start to use a new dependency in a feature, then you will be notified when running your test that there is more to assert on. It's incredibly powerful.

---

# github.com/pointfreeco/
# swift-dependencies

And there is even more to discuss beyond everything discuss so far, and so I highly encourage you to check out our dependencies project. There is a ton of documentation, and we even have a full application built using the library. We took Apple's Scrumdinger app, which we demo'd earlier in the talk to show the problems of testing with live dependencies.

Well, we controlled every dependency in that application, and that unlocked all new powers from Xcode previews, and made testing very easy.

But also I want to highly encourage you to check out the other dependency libraries out there in the community. We know that ours is not going to be for everyone. We take a pretty drastic stance by building it on top of Swift's `@TaskLocal` machinery, and in some ways that severely limits it, but in other ways also gives it power.

You may not want those limitations and/or powers, and so it will be good to see what the other dependency libraries have to offer.

---

## Thank you

#### Brandon Williams
	- brandon@pointfree.co 
	- @mbrandonw
	- www.pointfree.co


/assets/pf-cover.png
background: true
filter: darken





