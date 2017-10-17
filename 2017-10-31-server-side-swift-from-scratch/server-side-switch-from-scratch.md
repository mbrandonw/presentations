# [fit] Server-Side Swift from Scratch

* Brandon Williams

* @mbrandonw

* mbw234@gmail.com

^ Some of y'all may know me for having worked at Kickstarter, open sourcing our apps and doing a bunch of strange functional programming stuff. But, in my 5.5 years at Kickstarter I did a lot of backend work. I believe I was one of the top 5 contributors to the code base before leaving.

^ And today i wanna talk about some future directions of server-side swift that will make it state-of-the-art and ahead most other frameworks out there today.

^ The backend at kickstarter was rails, and that informed a lot of what I thought a web framework was supposed to be like. I think there's a lot of really cool things about rails, some things I even steal directly from them, but I think swift's type system gives us an opportunity to rethink a lot of things, and we can get a much better server side framework in the long run.

^ the stuff i'm going to show you today i find very exciting, and in fact is some of the coolest stuff I've worked on in awhile. there is a lot to cover, so i'm going to have to skip some details and go pretty quickly, but the best part is everything i'm talking about today is open sourced.

---

![](assets/pf-square@6x.png)

^ the reason i got into this stuff is because i'm working on a new project with my colleague stephen celis, called point-free. we're creating a video series on swift and functional programming, and we wanted to build the site in server-side swift, so of course we would build a lot of stuff from scratch.

---

![](assets/pf-square@6x.png)

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

> https://www.pointfree.co
> https://www.github.com/pointfreeco

^ everything we have done is completely open source. if you go to our github organization page you will find a bunch of repos and libraries that we have been working on. absolutely everything in this talk is somewhere there. in fact, the full source to the site is also on github.

---

# The layers of a web server framework

^ There are quite a few layers to a web server framework, and this talk is primarily concerned with only one slice of the full stack. So, to get us all on the same page I'm going to describe the layers a bit.

---
[.build-lists: true]

# Low-level layer

* Socket connections
* HTTP message parsing
* SSL
* Goal is to produce a `URLRequest`
  * `URL`, e.g. `https://www.pointfree.co/episodes/ep1-hello-world`
  * Method, e.g. `GET`
  * Post body of type `Data?`
  * Headers, e.g. `Accept-Language: en-US`

^

^ The goal is to ultimately produce a `URLRequest` that can be given to the high-level framework. This request

---
[.build-lists: true]

# High-level layer

* Interprets the `URLRequest`
* Fetches needed data
* Renders a view
* Goal is to produce a `HTTPURLResponse`
  * Status code, e.g. `
    200 OK`, `302 FOUND`, `404 NOT FOUND`
  * Response headers, e.g.
    `Content-Type`, `Content-Length`, `Set-Cookie`
  * Response body of type `Data?`


^ Interprets the request: this means pick apart all the pieces of the request (url, method, body, headers) to figure out a code execution path to handle the request.

^ Fetch the data needed to build a response. This may mean hitting Postgres, Redis, memcached, loading something off disk, etc. No matter what it is, fetching this data is _always_ a side effect for it depends on the state of the outside world, and so is the source of some real complexity that needs to be dealt with.

^ Once the data is fetched it's time to render a view. This could be HTML, XML, JSON, plain text, raw data, etc.

^ The goal is to produce a `HTTPURLResponse` which consists of:

^ A status code

^ Some response headers

^ And some optional data. Certain types of responses dont have data, like a redirect.

---

<br><br><br><br><br><br><br><br><br><br><br><br><br>

# [fit] `(URLRequest) -> URLResponse`

^ So, on the high level, it is not unreasonable to say that a web server framework is nothing but a function `(URLRequest) -> HTTPURLResponse`. In fact, thinking of it this way can be highly illuminating and expose a lot of wonderful compositions.

^ It's this level that I am most interested in and been doing a lot of work. My goal is to break up this function up into as many small, composable, understandable units as possible. Things like routing, data fetching, middleware, view rendering, etc... can be expressed as very simple pure functions. And when you operate on this level you are able to see some really beautiful compositions and code reuse that is hard to see otherwise.

---
[.build-lists: true]

# [fit] `(URLRequest) -> URLResponse`

**Components**

* Middleware
* Routing
* Data fetching
* View rendering

^ I'll outline some of the components that go into this request-to-response lifecycle, and we'll break down some of them in more detail in this talk.

^ First is middleware. This is the fundamental unit of the composition. We will create a new type to represent the step in the lifecycle process we are in, and then expose functions that allow us to go from one step to another.

^ Next is routing, which is a form of middleware. It plucks apart the request to create a first class value to represent the data that the rest of the middleware can use to do its job. A sufficiently advanced router should be capable of matching against any part of the request, including scheme, host, path, query params, HTTP method, post body, etc...

^ Fetching data, also built as middleware, is where we go into side effect land, and making a nice story out of that is quite difficult. We won't be able to say much about that in this talk, but do know it's possible!

^ And then it's time to render the view. By this time we have gathered all the data we need to render a view, whether it be json, plain text or html. So, we need some mechanism for turning that data into a view.

---
[.build-lists: true]

# [fit] `(URLRequest) -> URLResponse`

**Goals**

* Testable
* Usable in isolation

^ And what are the goals we are trying to accomplish by going this route?

^ We want to produce something that is super testable. This part of the story is perhaps the most interesting and unexplored. Something that rails got right is their investment of time and energy into testing, and it's something we absolutely need to do in server-side swift. we can even leap frog rails in this respect

^ and usable in isolation... todo: say more

---
[.build-lists: true]

# Middleware

* Naive: `(URLRequest) -> HTTPURLResponse`
* Better: `(Conn) -> Conn`
* Even better: `(Conn<A>) -> Conn<B>`
* Great: `(Conn<I, A>) -> Conn<J, B>`

^ Naively we may try to define middleware as a function from request to response, however these functions don't compose, and so they are not a good candidate for an atomic unit we can build our server off of.

^ Better is to create a single type, `Conn`, that holds the request that came in and the response that will go out. Each such function `(Conn) -> Conn` will change a little bit of the response, like filling in the status code, or appending some data, etc...

^ Even better would be to make `Conn` generic so that it could hold first class data. Then each function `(Conn<A>) -> Conn<B>` could compute some new data from previous data and pass it along the chain, e.g. routing could pluck out parts of the request to form a first class value.

^ And then a great way to model middleware adds an additional parameter that is not actually used anywhere in the definition of `Conn`, and is thus sometimes known as a phantom type.

---

# Middleware

* Naive: `(URLRequest) -> HTTPURLResponse`
* Better: `(Conn) -> Conn`
* Betterer: `(Conn<A>) -> Conn<B>`
* Great: `(Conn<I, A>) -> Conn<J, B>`

where

```swift
struct Conn<I, A> {
  let data: A
  let response: HTTPURLResponse
  let request: URLRequest
}
```

^ This allows you to encode a kind of state machine directly into the types.

---

todo: brain meme

^ i believe if i were to represent this in meme form it might look a little something like this

---

# [fit] Middleware states

```swift
enum StatusOpen {}

enum HeadersOpen {}

enum BodyOpen {}

enum ResponseEnded {}
```

^ The state we are going to encode is the stage of building up a response.

---

# [fit] Middleware states
# Status open

```swift
func writeStatus<A>(_ status: Int)
  -> (Conn<StatusOpen, A>)
  -> Conn<HeadersOpen, A> {
    ...
}
```

^ We start in the state of "status open", which means the only functions `(Conn) -> Conn` you can write are ones that set the status code and do nothing else. This means you are forced load up all the data you are going to need for later so that you can set the status to 404 for data you can't find. This also fixes a terrible anti-pattern in rails in which loading of data can be done at any time, often happening directly in the view, which can cause exceptions to be thrown at any moment, resulting in a 404.

---

# [fit] Middleware states
# Headers open

```swift
func writeHeader<A>(_ name: String, _ value: String)
  -> (Conn<HeadersOpen, A>)
  -> Conn<HeadersOpen, A> {
    ...
}

func closeHeaders<A>(conn: Conn<HeadersOpen, A>)
  -> Conn<BodyOpen, A> {
    ...
}
```

^ Once you write the status to the response, you then transition to the headers open state. Then only thing you can do here is write headers, so you better set all your cookies, content type and everything else cause it's yer last chance to do it!

^ When yer done writing headers you have to then transition from the headers open state to the body open state by calling `closeHeaders`

---

# [fit] Middleware states
# Body open

```swift
func send(_ data: Data?)
  -> (Conn<BodyOpen, Data?>)
  -> Conn<BodyOpen, Data?> {
    ...
}

func end<A>(conn: Conn<HeadersOpen, A>)
  -> Conn<ResponseEnded, Data?> {
    ...
}
```

^ Finally we need to write data to the response. we can do that be sending chunks of data to be appended to the response, and then when we are done we can end the whole lifecycle.

^ and then here's the beautiful thing. since middleware is just a function, you already know how to compose these. it's just function composition!

---

```swift
infix operator >>>

// ((A) -> B, (B) -> C) -> (A) -> C

func >>> <A, B, C>(
  _ f: @escaping (A) -> B, _ g: @escaping (B) -> C
  )
  -> (A) -> C {

    return { g(f($0))}
}
```

^ let's define this arrow operator to aid in composing functions

^ it takes a function from `A` to `B` and a function `B` to `C` and outputs a function `A` to `C`.

---

```swift
let incr: (Int) -> Int = { $0 + 1 }
let square: (Int) -> Int = { $0 * $0 }

let f = incr >>> square >>> incr >>> String.init

f(2) // => "10"
```

^ we can use it like so.

---

```swift
writeStatus(200)
  >>> writeHeader("Set-Cookie", "foo=bar")
  >>> writeHeader("Content-Type", "text/html")
  >>> closeHeaders
  >>> send(Data("<html>Hello world!</html>".utf8))
  >>> end
```

^ using this operator we can compose middleware easily, and it's just pure functions. we aren't mutating any data or global state. we are free to plug stuff in and then assert what comes out the other side.

^ we have just created a web page! you can pipe in a request and get a response out on the other side! also because this is so simple and built only on the principles of pure functions, you can use this with any existing web framework like vapor, kitura, perfect, etc...

---

# [fit] `(URLRequest) -> URLResponse`

**Components**

* ✓ Middleware
* Routing
* Data fetching
* View rendering

^ And that is a very quick overview of how we want to think about middleware. There's a lot more to say but we gotta move on. Just know that this is the fundamental atomic unit that our web server is built on.

^ So, going back to our list of components that get us from a request to a response, we've just finished talking about middleware. Phew! there is even more that could be said, but we'll have to stop there.

---

# Routing

^ Next up is routing! There is a wonderful story to tell here, but it's going to have to be brief.

^ Routing is a notoriously tricky problem to solve, and there are a ton of approaches. we are most interested in leveraging as much of the swift type system as possible to give us really nice features.

---
[.build-lists: true]

# Routing Goal: Type-safety

* `(URLRequest) -> A?`
* Changes to `A` result in compiler error
* Changes to route result in compiler error

^ The goal of routing is to transform the nebulous `URLRequest` into a first class value. Routing won't always succeed, and so it maps into an optional value. If it's `nil`, then we should show a 404 page or something.

^ If the value is not `nil`, then we can use it in the next step of the middleware lifecycle by making database requests to get full values.

^ there isn't a definitive definition of type-safe with respect to routing. it's more of a relative scale, where some things are safer than others. most of the routing solutions out there right now are not as safe as they could be

---

# Routing Goal: Type-safety
## Approaches

```swift
app.get("/episodes/:id") { req in
    let id = req.parameters["id"] ?? ""
    // do something with `id` to produce a response
}
```

^ Not very safe! We aren't relating the route string to an actual value, so we don't know how many params we expect to pluck out of the route, or what their types are. In fact, we have to look at the code to determine what type `id` is, which hopefully is right here in the code, but could also be hidden elsewhere.

^ If I edit this route string I will only get errors at runtime, nothing at compile time.

---

# Routing Goal: Type-safety
## Approaches

```swift
router.get("/episodes/:id") { (request, id: Int) -> Response in
  // do something with `id` to produce a response
}
```

^ Here's another approach. Here we now have some types, since this will try to extract the `id` param and cast it to an integer somehow. However, if we add extra params to this string

^ The problem with these routing solutions is that they are too inspired by the things rails and other un-typed frameworks have done rather than looking at what typed languages have accomplished.

---

# Routing Goal
## Invertible

* Given an `A`, produce a `URLRequest`
* Useful for linking to parts of the site

^ Another goal of routing we want is for it to be invertible. This means if we had a first class value, we could generate a request that would route to that value! This is very useful for linking to parts of a site in a type-safe way. The compiler guarantees that the links generated on the site definitely go where we expect. It should be impossible to generate an invalid link.

^ Both of the previous routing approaches have no solution to this.

---
[.build-lists: true]

# Routing Goal
## Invertible

* Given an `A`, produce a `URLRequest`
* Useful for linking to parts of the site

```ruby
episode_path(@episode)
# => /episodes/intro-to-functions

episode_path(@episode, ref: "twitter")
# => /episodes/intro-to-functions?ref=twitter
```

^ Rails does this nicely, but in an untyped and dynamic way. Every route you define gets a dynamic method created that can generate urls to pages in the site. In rails it's still 100% possible to use this in a way that generates errors at runtime.

---

# Routing Goal
## Self-documenting

* Given an `A`, produce a template

^ And finally, another goal is to be able to automatically generate documentation on how to use the routes. It should be able to print a template string of all the params expected, their types, etc..

---

# Routing Goal
## Self-documenting

* Given an `A`, produce a template
* `rake routes`

```
GET /
GET /episodes
GET /episodes/:id
```

^ Rails also has a nice story here, tho again not typed and entirely runtime. You can run `rake routes` and get templates of all the urls the app recognizes.

---

# Routing: `(URLRequest) -> A?`
## Demo

```swift
enum Routes {
  // e.g. /
  case root

  // e.g. /episodes?order=asc
  case episodes(order: Order?)

  // e.g. /episodes/intro-to-functions?ref=twitter
  case episode(param: Either<String, Int>, ref: String?)
}

enum Order {
  case asc
  case desc
}
```

^ And the amazing thing I'm here to tell you is that it's possible to accomplish all of the goals, even with types like in Swift. I think a lot of people would assume that in order to get all of those neat features that rails has we would need a dynamic language and give up some of our compile type safety.

^ Here we have a first class type, an enum, to describe all of the routes and their data that we want to recognize.

^ We have a `root` route for just going to domain _slash_

^ Then an episodes route, for getting all of the episodes on the site, that takes an optional value that describes how to sort the episodes.

^ And a route for watching a particular episodes. this route needs a param, which can be either a string or an integer, and an optional "ref" that is taken from the query string, which can be used to track referrals.

^ These are some very complicated routes! They take optional values, non-optional values, user-defined types, enums, etc...

^ So, how do we take a `URLRequest`, pick out all the pieces of it, and map it to this type?

---

# Routing: `(URLRequest) -> A?`
## Demo

```swift
let router = [
  Routes.iso.root
    <¢> get <% end,

  Routes.iso.episodes
    <¢> get %> lit("episodes") %> queryParam("order", opt(.order))
    <% end,

  Routes.iso.episode
    <¢> get %> lit("episodes") %> param(.intOrString)
    <%> queryParam("ref", opt(.string))
    <% end
  ]
  .reduce(.empty, <|>)
```

---

# Routing: `(URLRequest) -> A?`

```swift
switch router.match(request) {
case .some(.root):
  // Homepage
case .some(.episodes(order)):
  // Episodes page
case .some(.episode(param, ref)):
  // Episode page
case .none:
  // 404
}
```

^ Then to use the router you just attempting matching the request, and then switch on the optional route to pick apart the pieces.

---

# Routing: `(URLRequest) -> A?`
## Linking URL’s for free

```swift
link(to: .episodes(order: .some(.asc)))
// => "/episodes?order=asc"

link(to: .episode(param: .left("intro-to-functions"), ref: "twitter"))
// => "/episodes/intro-to-functions?ref=twitter"

link(to: .episode(param: .right(42), ref: nil))
// => "/episodes/42"
```

^ If i want to link to an episode I can do it like so. 

---

# Routing: `(URLRequest) -> A?`
## Template URL’s for free

```swift
template(to: .root)
// => "/"

template(to: .episodes(order: nil))
// => "/episodes?order=:optional_order"

link(to: .episode(param: .left(""), ref: nil))
// => "/episodes/:string_or_int?ref=optional_string"
```

^ there is no code generation for this! it is entirely due to the types and the way they compose!

---
[.build-lists: true]

* Namespaces
  * e.g. `/v1/`
* Resources
 * e.g.
 `(GET | POST | DELETE) /episodes/:id`
* Link helpers
  * e.g. `link(to: route)`
* Responsive Route
  * e.g.
  `/episodes/1.json`, `/episodes/1.xml`, etc...
* And more...

^ todo: the idea of applicative parsing subsumes _all_ ideas you have previously encountered when it comes to routing. EVERYTHING


---

# [fit] `(URLRequest) -> URLResponse`

**Components**

* ✓ Middleware
* ✓ Routing
* Data fetching
* View rendering

^ And that's routing!

---

# Data fetching

^ We aren't going to have much time to talk about this unfortunately. this is the layer where all of your side effects are going to happen. everything up to this point has been pure. it's where you will take that first class value that the router produced and then do database requests, network requests etc to gather all of the data that your view needs to do its job.

---

# Data fetching

```swift
(Conn<I, A>) -> IO<Conn<J, B>>
```

---

# Data fetching

```swift
writeStatus(200)
  >-> writeHeader("Set-Cookie", "foo=bar")
  >-> writeHeader("Content-Type", "text/html")
  >-> closeHeaders
  >-> send(Data("<html>Hello world!</html>".utf8))
  >-> end
```

---

# [fit] `(URLRequest) -> URLResponse`

**Components**

* ✓ Middleware
* ✓ Routing
* ✓ Data fetching
* View rendering

---

# View rendering

^ And finally we come to view rendering, perhaps the funnest part!

---

TODO:

^ very satisfying to write a test that simply constructs a request, feeds it into the system, and snapshot asserts on the response that came out.

mention OSS repos again

---

What else needs to be done?

Swift.js / webasm
