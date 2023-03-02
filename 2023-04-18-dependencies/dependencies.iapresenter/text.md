# Control your dependencies
### don't let them control you


---
# What is a dependency?

Let’s start with a very simple question: What is a dependency?

This is a surprisingly tricky question to answer, and I can’t claim to have the most universal definition, but for the purposes of this talk we will define dependency as the following…

---

### What is a dependency?
	> The types and functions in your application that need to interact with outside systems that you do not control.

Dependencies are the types and functions in our application that need to interact with outside systems we do not control.

Now that definition may seem a little nebulous, so let’s look at some concrete examples…

---
# Examples of dependencies

---
	_Examples of dependencies_
	### Network API clients
	```swift
	
	
	
	let users = try await apiClient.fetchUsers()
	
	
	
	```

* Network API clients are a “dependency” because they make network requests in order to load data from external servers. Often such servers are not things under your control, such as if you are hitting the Stripe API for payment processing, or Mastodon API for your new Mastodon client. Sometimes the server _is_ under your control, such as if it’s your company’s backend to power your app. Even in those cases we will consider it a dependency because it is an outside system, that is, it exists outside the code base that powers your application.

---
	_Examples of dependencies_
	### Location managers
	```swift
	
	
	
	let manager = CLLocationManager()
	await manager.requestWhenInUseAuthorization()
	let location = try await manager.requestLocation()
	
	
	
	```

* If you have ever used Core Location in your application, then you were using a dependency. Not only do you interact with Apple’s frameworks for fetching location data, which you do not control, but those APIs interact with the GPS instruments in your device in order to triangulate coordinates. That is a major outside system interacting with satellites orbiting the earth.

---
	_Examples of dependencies_
	### File systems
	```swift
	
	
	var data = try Date(contentsOf: URL(…))
	data.append(…)
	try data.write(to: URL(…))
	
	
	```

* If you have ever saved or loaded data to or from disk, then you were using a dependency. The file system is another massive external system because it exists outside your code base. Any application can read and write to it without your knowledge, and so it is not something your application controls.

---
	_Examples of dependencies_
	### Firebase
	```swift
	
	let ref = Database.database().reference()
	self.ref
		.child("users")
		.child(user.uid)
		.setValue(["username": username])
		
	```

* Firebase is another massive dependency. It’s kind of a _mega_ dependency because it acts as a database, acts as a network API client, handles analytics, crash reporting, logging, remote config, authentication, push notifications, storage, and more! All of the code that powers these features is written by Google and hosted on Google’s servers, and so is fully out of your control.

---
	_Examples of dependencies_
	### Clocks and schedulers
	```
	
	try await Task.sleep(for: .seconds(1))
	
	try await ContinuousClock().sleep(for: .seconds(1))
	
	DispatchQueue.main.schedule(after: .now() + 1) {
	  …
	}
	
	```

* If you have ever used a Swift `Clock`, which was introduced in Swift 5.7, or a Combine `Scheduler`, then you were again using a dependency. Those objects speak with the outside world in order to execute work at a later time, and we have no ability to tell those processes do things faster.

---
	_Examples of dependencies_
	### `Date()` and `UUID()`
	```swift
	
	let user = User(
	  id: UUID(),
	  name: “Blob",
	  createdAt: Date()
	)
	
	```

* And then seemingly innocuous things such as `Date` and `UUID` initializers can also be considered dependencies. After all, when you ask Foundation for the current date it reaches out into the real world to get that information. And further, every time you construct a date it is slightly different from the previous time because time is forever marching forward, and sadly we have no control over that. The same is true for `UUID`s. Each time you construct one you get a completely random, cryptic sequence of hex digits, and the process that concocts that value is an external system that we do not control


---
### Examples of dependencies
	#### …and _a lot_ more

* And this is only scratching the surface. There are many, many, _many_ more examples of dependencies, and your code today is probably full of them.

---
## The problem with uncontrolled dependencies

So, if you believe everything I have said so far, then dependencies are seemingly ubiquitous in application development. They are literally everywhere, and if this is the first time you are hearing about “dependencies” then you may wonder what the big deal is. You may be saying to yourself “Ok, my code has dependencies on outside systems, but I’m able to work just fine that way, so why do I care?"

Well, I’m here to tell you there are a lot of problems that occur when you have uncontrolled dependencies, many people may not even realize they are a problem, and other people may have just learned to live with or have adapted to work around the problems.

---
	_The problem with dependencies_
	### Many are slow to compile
	```swift
	import Firebase
	```
	> _Build succeeded  86.9 seconds_

Perhaps the biggest problem with dependencies is that very often they are extremely slow compile. It takes nearly 90 seconds to compile a fresh project with Firebase added to it on my M1 MacBook Pro. That is nearly 90 seconds just to compile Firebase, not including all the code that needs to be built for your application.

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

In the previous example we just considered, the one with the countdown, at least the feature worked in the preview. It was just annoying to use the preview because we had to wait for real world time to pass in order to see the feature’s behavior.

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

We again are seeing that by not controlling our dependencies we are allowing them to control us. We simply are not able to use Xcode previews if we use certain frameworks directly in our code.


---
	_The problem with dependencies_
	#### Some _break_ Xcode previews
	```
	
	```

// contact/location manager will crash without permissions. Probably need SPM package.

---



	_The problem with dependencies_
	#### Accidental interaction with “live” dependencies

---



	_The problem with dependencies_
	#### Difficult or impossible to test


// all the problems we saw with previews are just an omen that we are also going to have problems in tests. tests is a good barometer for the health of your code in the sense that if you are able to construct the various 

// file access bleeds into tests
// 	file access makes it so that not everyone on team sees same preview
// clocks make tests take a long time

---




x

- [ ]  speech recognition demo doesn’t work in preview
- [ ]  countdown app that shows confetti
    - [ ]  use immediate clock
- [ ]  standups app
    - [ ]  file access bleeds into other tests
    - [ ]  can’t see error behavior in speech recongizer
    - [ ]  file access makes it so that everyone on team can’t see same preview
- [ ]  “container pattern” to work around but just creates inert views, no behavior
- [ ]  show that firebase makes project slow and previews break
    - [ ]  slow compile times
- [ ]  uncontrolled dependency can crash previews
    [https://pointfreecommunity.slack.com/archives/C03LPTDEY90/p1676994771975899](https://pointfreecommunity.slack.com/archives/C03LPTDEY90/p1676994771975899)
    This shows how an uncontrolled dependency on contacts framework crashes preview because there is no info plist that describes why the app wants contacts.


---

---

# FAST LOVE
#### iA Presenter in three Minutes

As you can see, regular text paragraphs are *not* visible to your audience. This is by design. Body text is your script. Only you can see it. As you can see later, it will be present in the teleprompter when you present. 

---
### Easy like Sunday morning
## Don’t stuff your slides with text 

Putting a lot of text on a slide and reading it out to the audience is the #1 presentation killer. 

---
## ⇥
	(This is the symbol for Tab)

You can put a lot of text on the slide, but, really, don't do it. Let it go.

---
	*Seriously.* Stop bothering people with walls of text. And if you have to show a lot of text, do not read it all from the slide. It’s a bad habit and a very common one. No one will listen to you if you do this. People will read your slide instead. No one will remember what you said.

	They’ll be too distracted by the text to listen—and too distracted by your voice to remember what they have read. But no rule is without exception! If you have a good reason to show a wall of text, add a tab in front of your paragraph. 

Use text as your script and choose visible elements carefully. Remember: less is more.

---
### Bullet lists
	- Increase cognitive load
	- Look and feel robotic  
	- Are distracting
	- Bore the hell out of everyone
	- Make you predictable
	- Sound and look like notes
	- Should be notes

These should be reading notes. This kind of slide looks like a lot of work, and it directly sabotages your presentation. It's as if you finished your sentences yourself.

---
### Write it, cut it, paste it
## Focus on the story 

To make people listen to you, you need a good story. Stories connect. A good story has the power to make people look at the world through your eyes. The door to make them look through your eyes will not get unlocked with stock images, graphs, and bullet lists, but with your voice. 

You need beginning-middle-end. Your presentation's visuals should help you get attention, make your point, and keep people oriented. With iA Presenter, you don’t *design* your presentation, you *write* it. 

---
https://ia.net/presenter-assets/inspector.png
x: left
y: top

### Use the text Inspector to format.

To write a headline, you add a hash in front of it. To add an image, you drag it into the Editor. Writing bold, you use **two** asterisks. To write a list, You just add a hyphen or a number with a dot. This is called Markdown.

If you play with Markdown for a couple of minutes, you’ll only need help for more difficult matters. Adding a link, footnote, or table requires more skills. To promote familiarity with advanced Markdown, we have added a formatting inspector.  

---
### Keep em separated
## Discern what you say and what you show 

In common presentations, the script is called “notes.” They are squeezed in at the bottom of the page. They’re an afterthought. With iA Presenter, your story is the very essence of every presentation. That doesn't mean that every presentation needs to be a TED talk. But every time you speak, you need to have something to say.

Usually, what you want to say already exists in some form. You can paste an existing text, and you are 50% done. All you need are page breaks and visuals. The story-centered text-first approach is what makes iA Presenter so much faster than graphic presentation tools.

To create a page break, you simply add three hyphens like this: 

---
## ---
	(Type this to create a page break)

---
### Sound and vision
## How to add images

And how do you add an image? Drag and drop.

---
Delete the image below and drag a new one in right below here:

/theme/image1.jpg

You can use regular Markdown or the simpler Content Block syntax with the /andyourfilename.jpg. Or you can use an image from the web. Simply paste the URL of an image from your browser.

---

https://ia.net/presenter-assets/image-inspector.png
x: left
y: top

You can align images top, left, and bottom, or put them in the background. Just click on the little arrow next to the image for image positioning controls. Note: You cannot position them statically but only relatively, as the design will adapt to different screen sizes. What does that mean?

### Use the image inspector on the right to see and manage all your used and unused images and movies.

---
### Let it go
## Auto layout!

You add your text and images, and Presenter picks the right layout for you. 

---

/Theme/image1.jpg
filter: grayscale

/Theme/image2.jpg

Layouts are picked automatically depending on what type of visual elements you add. 

---
/Theme/image1.jpg

/Theme/image2.jpg

/Theme/image3.jpg

Do not try to get it pixel perfect! Layouts are responsive. They adapt to screen size. So, no more pinching on the phone, no more pixel-pushing because you’re presenting on a different monitor.

---
### This is an H3 title

/Theme/image1.jpg

/Theme/image2.jpg

/Theme/image3.jpg

/Theme/image4.jpg

/Theme/image5.jpg

/Theme/image6.jpg

Please note: **You need a line break in between each element.** If you leave out the line break, two elements will share the same cell. It's hard to describe. Just play with the line breaks to see how it works.

---
https://ia.net/presenter-assets/responsive-design-text.png

#### “But I *need* a certain design for my slides!”

You certainly do. But you don't work in a certain medium. If you design a static slide, your layout will break on a tablet, a phone, or wide screen. 

iA Presenter adapts your slides to different devices. So no more static layouts! It takes time to get used to it. But layouts do not matter as much as PowerPoint wants you to believe. What matters is that you have a great story. And that people can enjoy your story wherever with whatever design ever. Welcome to the multi-screen future. Goodbye to static design.

---
https://ia.net/presenter-assets/responsive-design-pictures.png

#### Let it go...

In iA Presenter, the layout adapts to wide screens, different overhead projector ratios, Zoom windows, tablets, phones, watches, and toasters. No more static templates.

---

https://ia.net/presenter-assets/responsive-design-text-cclumn.png

#### Let it go...

Multi-column layouts inevitably break on mobile phones. We have gotten used to websites adjusting to our devices. It's time to do the same for presentations. No more pinching and smudging around on the phone. 

---
### She’s a rainbow
## About that funky multi-color code

We use color to give you an additional hint on where you are inside a presentation. The cursor changes color, too!

**Blue** is a cold start
**Purple** is to warm up
**Red** is when things get heated
**Orange** prepares you for a sweet end
**Gold** is the afterglow

You are not forced to use these colors. We encourage you to deal with the design at the end of your process. You can change the design by picking different themes. Within a theme, you can edit colors, fonts, header, footer, and logo. 


---
https://ia.net/presenter-assets/basel.png
y: top

https://ia.net/presenter-assets/sf.png
y: top

https://ia.net/presenter-assets/tokyo.png
y: top

https://ia.net/presenter-assets/paris.png
y: top

https://ia.net/presenter-assets/milano.png
y: top

https://ia.net/presenter-assets/copenhagen.png
y: top

You can create your own very special theme. You can make a theme for your company, and then everyone's presentation will be spot on CI. But you’ll need some CSS skills. If you get a bunch of licenses, we'll help you.

---
### Too funky for you?
## Changing fonts and colors

Click on the inspector buttons in the title bar. The Design Tab lets you change fonts, colors, headers, and more.

---


https://ia.net/presenter-assets/style.png
y: top

### Our templates are colorful, typographic, and they work on every device. 

---
### Under pressure
## How do I present? 

Press play in the title bar top right to enter presentation mode. You have two windows: A teleprompter for you and the visuals for the audience.

---
### Teleprompter: What you see  

https://ia.net/presenter-assets/teleprompter.png
size: contain

### Visualizer: What they see  

https://ia.net/presenter-assets/visualizer.png
size: contain

We purposely do not go full screen right away. This allows you to work with the editor/teleprompter and presentation window on one screen. Why? 

- So you can prepare and rehearse your presentation on one screen. 
- Most presentations these days are done via video chat on a single-screen device. 
- Managing windows and making them fullscreen is easy and pleasant. Auto-fullscreen is unsettling and hard to manage. 

---
### Back in Black
## Create a text document handout

What do I do after the presentation is done? You can send a PDF to your audience, with or without a script. 

---


https://ia.net/presenter-assets/presentation.png
size: contain

https://ia.net/presenter-assets/handout.png
size: contain

You can also export your presentation as an easily readable regular text document. 


---
### Faster Love 
## Use existing text

If you have a structured Markdown text with images, all you need to do to create a presentation is paste the Markdown and add page breaks. 

You can also just open your existing Markdown file. iA Presenter will ask you if you want to convert it to slides, and your speech will be almost ready: 

---


https://ia.net/presenter-assets/add-media.png
size: contain

To add an image from the web, just paste the URL into the editor. You can do that with YouTube videos, too.

---
### It's like a jungle!
## Okay, but this is way too much default text!

You’re right. Now that you know how it works, you can edit the default text under Preferences > General

---


https://ia.net/presenter-assets/preferences.png
size: contain
y: top

There are more settings there. Check out the Help section for the 999 features we already have before asking for more.

---
### Goosebumps
## Now go and make nice things

And send us your presentations. We love to see what you do with it.

