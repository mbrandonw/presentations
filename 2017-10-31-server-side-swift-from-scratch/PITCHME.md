```swift
infix operator >>>
func >>> <A, B, C>(_ f: @escaping (A) -> B,
                   _ g: @escaping (B) -> C)
                   -> (A) -> C {
  return { g(f($0))}
}

let incr: (Int) -> Int = { $0 + 1 }
let square: (Int) -> Int = { $0 * $0 }

(incr >>> square >>> incr >>> String.init)(2) // => "10"
```

---

# [fit] Server-Side Swift from Scratch

* Brandon Williams

* @mbrandonw

* mbw234@gmail.com

^ Some of y'all may know me for having worked at Kickstarter, open sourcing our apps and doing a bunch of strange functional programming stuff. But, in my 5.5 years at Kickstarter I did a lot of backend work. I believe I was one of the top 5 contributors to the code base before leaving.

^ And today i wanna talk about some future directions of server-side swift that will make it state-of-the-art and ahead most other frameworks out there today.

^ The backend at kickstarter was rails, and that informed a lot of what I thought a web framework was supposed to be like. I think there's a lot of really cool things about rails, some things I even steal directly from them, but I think swift's type system gives us an opportunity to rethink a lot of things, and we can get a much better server side framework in the long run.

^ the stuff i'm going to show you today i find very exciting, and in fact is some of the coolest stuff I've worked on in awhile. there is a lot to cover, so i'm going to have to skip some details and go pretty quickly, but the best part is everything i'm talking about today is open sourced.

---

![](images/pf-square@6x.png)

^ the reason i got into this stuff is because i'm working on a new project with my colleague stephen celis, called point-free. we're creating a video series on swift and functional programming, and we wanted to build the site in server-side swift, so of course we would build a lot of stuff from scratch.

---

![](images/pf-square@6x.png)

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
}

func closeHeaders<A>(conn: Conn<HeadersOpen, A>)
  -> Conn<BodyOpen, A> {
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
}

func end<A>(conn: Conn<HeadersOpen, A>)
  -> Conn<ResponseEnded, Data?> {
}
```

^ Finally we need to write data to the response. we can do that be sending chunks of data to be appended to the response, and then when we are done we can end the whole lifecycle.

^ and then here's the beautiful thing. since middleware is just a function, you already know how to compose these. it's just function composition!

---

```swift
infix operator >>>
func >>> <A, B, C>(_ f: @escaping (A) -> B,
                   _ g: @escaping (B) -> C)
                   -> (A) -> C {
  return { g(f($0))}
}
```

^ let's define this arrow operator to aid in composing functions

^ it takes a function from `A` to `B` and a function `B` to `C` and outputs a function `A` to `C`.

---

```swift
infix operator >>>
func >>> <A, B, C>(_ f: @escaping (A) -> B,
                   _ g: @escaping (B) -> C)
                   -> (A) -> C {
  return { g(f($0))}
}

let incr: (Int) -> Int = { $0 + 1 }
let square: (Int) -> Int = { $0 * $0 }

(incr >>> square >>> incr >>> String.init)(2) // => "10"
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

---

# [fit] `(URLRequest) -> URLResponse`

**Components**

* ✓ Middleware
* Routing
* Data fetching
* View rendering

^ So, going back to our list of components that get us from a request to a response, we've just finished talking about middleware. Phew! there is even more that could be said, but we'll have to stop there.

---

# Routing

^ Next up is routing! There is a wonderful story to tell here, but it's going to have to be brief.

^ The goal of routing is to transform the nebulous `URLRequest` into a first class value. This value can then be used in the next step of the serve lifecycle by making database requests to get full values.

^ Routing is a notoriously tricky problem to solve, and there are a ton of approaches. we are most interested in leveraging as much of the swift type system as possible to give us really nice features.

---

# Routing

### Type-safety

---

# Routing
## Demo

```swift
enum Routes {
  // e.g. /
  case root

  // e.g. /episodes?order=asc
  case episodes(order: Order?)

  // e.g. /episodes/intro-to-functions?ref=twitter
  case episode(episodeParam: Either<String, Int>, ref: String?)
}

enum Order {
  case asc
  case desc
}
```

---

# Routing
## Demo

```swift
let router =
  Routes.iso.root
    <¢> end,

  Routes.iso.episodes
    <¢> lit("episodes") %> queryParam("order", opt(.order))
    <% end,

  Routes.iso.episode
    <¢> lit("episodes") %> param(.stringOrInt)
    <%> queryParam("ref", opt(.string))
    <% end
  ]
  .reduce(.empty, <|>)
```

---

# [fit] `(URLRequest) -> URLResponse`

**Components**

* ✓ Middleware
* ✓ Routing
* Data fetching
* View rendering

---

# Data fetching

^ We aren't going to have much time to talk about this unfortunately. this is the layer where all of your side effects are going to happen. everything up to this point has been pure. it's where you will take that first class value that the router produced and then do database requests, network requests etc to gather all of the data that your view needs to do its job.

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
