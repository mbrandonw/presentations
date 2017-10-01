/*:
 # Composable Reducers & Effects Systems
 * Brandon Williams
 * mbw234@gmail.com
 * @mbrandonw
 */

/*:
 Today we are going to talk about composable reducers, and maybe if there is enough time, effects systems.

 Interestingly, I gave a somewhat related talk at the very first Functional Swift Conference back in 2014. The topic was transducers, which are transformations of reducres, i.e. functions that take a reducer and return a reducer. Such functions have some nice properties too and help you effeciency process lists of values without traversing many times, but what we are talking about today is a lil different.

 A reducer is just a function that you can feed into array's `reduce`, but also is a key component to how Elm and Redux work, which are systems for managing state in an application. Turns out this form of function has all types of fun ways to compose, and knowing them helps build a really robust framework for making an application. There isn't a lot of literature on these compositions, so I think a lot of this will be new to y'all, even if you've written a lot of Elm/Redux before.

 At a high level, Elm/Redux describes an application using 3 main pieces: state, action and reducer (Elm uses message and update instead of action and reducer). The state value holds 100% of all the state in your application, and action enumerates 100% of the user actions that can happen, and the reducer takes a state and action and produces the next state of the application.

 After that basic definition Elm and Redux diverge a bit. Elm further handles the effects part of the story by having the reducer not only return the new state, but also returning a value that describes any side effects that should be performed by the runtime, and how to get the results of those effects fed back into the system. Redux doesn't provide any guidance on that subject and instead encourages you to use a library for dealing with side effects.

 Redux's runtime is also handled by something called a `Store`. it's what holds the current state of the system, and then allows subscribing to the store for state changes, and then it allows you to dispatch actions to the store to update the current state.

 We're now going to build some of this from scratch.
 */
