# [fit] Server-Side Swift from Scratch

* Brandon Williams

* @mbrandonw

* mbw234@gmail.com

^ intro

^

^ And i wanna talk about some future directions of server-side swift that will make it state-of-the-art and ahead most other frameworks out there today.

---

# [fit] The layers of a web server framework

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

^ So, on the high level, it is not unreasonable to say that a web server framework is nothing but a function `(URLRequest) -> HTTPURLResponse`. In fact, thinking of it this way can be highly illuminating and expose a lot of beautiful compositions.

^ It's this level that I am most interested in and been doing a lot of work. My goal is to break up this function up into as many small, composable, understandable units as possible. Things like routing, data fetching, middleware, view rendering, etc... can be expressed as very simple pure functions. And when you operate on this level you are able to see some really beautiful compositions and code reuse that is hard to see otherwise.

---
[.build-lists: true]

# [fit] `(URLRequest) -> URLResponse`

**Components**

* Middleware
* Routing
* Data fetching
* View render

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

^ We want to produce something that is super testable. This part of the story is perhaps the most interesting and unexplored.

---

# Middleware

* Naive: `(URLRequest) -> HTTPURLResponse`
* Better: `(Conn<A>) -> Conn<B>`
* Great: `(Conn<I, A>) -> Conn<J, B>`

^ Naively we may try to define middleware as a function from request to response, however these functions don't compose, and so they are not a good candidate for an atomic unit we can build our server off of.
