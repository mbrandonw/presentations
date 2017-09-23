/*:
 # Composable Reducers & Effects Systems
 * Brandon Williams
 * mbw234@gmail.com
 * @mbrandonw
 */

/*:
 Today I want to explore effects systems, that is, how can we treat effects as data and provide a runtime for executing them. I've talked about side effects quite a bit, and we've heard a ton about it at this conference over the years. All of the talks discuss important ideas in how one can control side effects, but today I want to show a very concrete effects system with runtime. This was largely driven by Elm, which has a runtime for executing standard effects, but also a lot of this may seem more recognizable if you have ever looked at Redux.

 So, in order to talk about a particular effects system I need to use a setup similar to Elm/Redux, which is where you describe your application by 3 things: state, action and updater/reducer. Elm will take over from there and provide the runtime to execute effects and update DOM. On the other hand, Redux provides a `Store` concept to provide the runtime.

 I will talk about how to build this system from scratch, how to get a lot of composability out of it, and then finally how to get an understandable effects system in place.
 */
