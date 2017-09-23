/*:
 # Composable Reducers & Effects Systems
 * Brandon Williams
 * mbw234@gmail.com
 * @mbrandonw
 */

/*:
 Let's make our reducer operate on state via `inout`!

 Any function of the form `(A) -> A` can be equivalently rewritten as `(inout A) -> Void`. And more generally, if your function has more inputs and outputs, those stay fixed, i.e.:

 ```
 (A, B) -> (A, C) ~> (inout A, B) -> C
 ```
 */

precedencegroup MonoidAppend {
  associativity: left
}
infix operator <>
protocol Monoid {
  static var empty: Self { get }
  static func <> (lhs: Self, rhs: Self) -> Self
}

struct Reducer<S, A>: Monoid {
  let reduce: (inout S, A) -> Void

  static var empty: Reducer {
    return Reducer { s, _ in }
  }

  static func <> (lhs: Reducer, rhs: Reducer) -> Reducer {
    return Reducer { state, action in
      lhs.reduce(&state, action)
      rhs.reduce(&state, action)
    }
  }
}

class Store<S, A> {
  let reducer: Reducer<S, A>
  private var currentState: S {
    didSet {
      self.subscribers.forEach { $0(self.currentState) }
    }
  }
  var subscribers: [(S) -> Void] = []

  init(reducer: Reducer<S, A>, initialState: S) {
    self.reducer = reducer
    self.currentState = initialState
  }

  func dispatch(_ action: A) {
    self.reducer.reduce(&self.currentState, action)
  }

  func subscribe(_ subscriber: @escaping (S) -> Void) {
    self.subscribers.append(subscriber)
    subscriber(self.currentState)
  }
}

struct User {
  let id: Int
  let name: String
}

struct Episode {
  let id: Int
  let title: String
  let videoUrl: String
}

struct Settings {
  var notificationsOn: Bool = false
}

struct AppState {
  var episodesState: EpisodesState = .init()
  var accountState: AccountState = .init()
}

struct EpisodesState {
  var episodes: [Episode] = []
  var watchedEpisodes: [Episode] = []
}

struct AccountState {
  var loggedInUser: User? = nil
  var settings: Settings = .init()
  var watchedEpisodes: [Episode] = []
}

enum AppAction {
  case accountAction(AccountAction)
  case episodesAction(EpisodesAction)
}

enum AccountAction {
  case login(User)
  case tappedEpisode(Episode)
  case tappedLogout
  case tappedNotification(on: Bool)
}

enum EpisodesAction {
  case tappedEpisode(Episode)
}

let accountReducer = Reducer<AccountState, AccountAction> { state, action in
  switch action {
  case let .login(user):
    state.loggedInUser = user

  case let .tappedEpisode(episode):
    state.watchedEpisodes.append(episode)

  case .tappedLogout:
    state.loggedInUser = nil
    state.watchedEpisodes = []

  case let .tappedNotification(on):
    state.settings.notificationsOn = on
  }
}

let episodeReducer = Reducer<EpisodesState, EpisodesAction> { state, action in
  switch action {
  case let .tappedEpisode(episode):
    state.watchedEpisodes.append(episode)
  }
}

/*:
 Now let's try composing these reducers!
 */

//let appReducer = accountReducer <> episodeReducer

/*:
 Ok this doesn't work because each reducer understands only a subset of the state and actions in the entire app. We need some way to lift these reducers up to the world of global state and actions.

 Let's think out loud how that might work. say you have a reducer that operates on substate of some global state. how could we lift it to understand the global state? well using keypaths you can construct getters/setters for projecting into the substate:

 (GlobalState) -> SubState
 (GlobalState, SubState) -> GlobalState

 These shapes are also known as lenses!

 So when the global state comes in, we could first use the keypath to pluck out the substate and then we can hand that to our subreducer. Then the subreducers returns a new substate, which we then use the keypath to plug the substate back into the global state! Let's write this:
 */

extension Reducer {
  func lift<T>(state: WritableKeyPath<T, S>) -> Reducer<T, A> {
    return Reducer<T, A> { stateT, action in
      self.reduce(&stateT[keyPath: state], action)
    }
  }
}

//let appReducer =
//  accountReducer.lift(state: \AppState.accountState)
//    <> episodeReducer.lift(state: \AppState.episodesState)

/*:
 Still doesn't work! We gotta deal with subactions now!

 So how do we lift a subreducer that only understands a subset of actions? Let's think about it outloud to see how it might go. A global action comes in and you first try to pluck out your subaction from the global. if that fails, then you do nothing and let the action pass by. if you do successfully get a subaction, you then run your reducer with that subaction. what's the best way to do this?

 Well, we needed lenses/keypaths to deal with struct/state so naturally we must need to use prisms, the dual of lenses, to deal with enums/actions!

 Prisms are the dual to lenses in that they pick apart enums while lenses pick apart structs. So, what are the ways we can pick apart an enum? Well, for one, given an enum with a bunch of cases with associated values, you can have a function that tries to pluck out a value from a branch in the enum, so it would be a function `(A) -> B?`. and then on the other hand, if you had a value from a branch you could trivially embed that branch into the main enum with a function `(B) -> A`.

 Maybe someday Swift will give us first class support for this like they did with key paths.

 Let's define a first class type for this:
 */

struct Prism<A, B> {
  let preview: (A) -> B?
  let review: (B) -> A
}

/*:
 And now let's define a `lift` function
 */

extension Reducer {
  func lift<B>(action: Prism<B, A>) -> Reducer<S, B> {
    return Reducer<S, B> { state, actionB in
      guard let actionA = action.preview(actionB) else { return }
      self.reduce(&state, actionA)
    }
  }
}

/*:
 Weirdly we only used the `preview` functionality of the prism, not review. We'll use review soon...

 Let's define some prisms for our global action:
 */

extension AppAction {
  enum prism {
    static let accountAction = Prism<AppAction, AccountAction>(
      preview: {
        if case let .accountAction(action) = $0 { return action }
        return nil
    },
      review: AppAction.accountAction
    )
    static let episodesAction = Prism<AppAction, EpisodesAction>(
      preview: {
        if case let .episodesAction(action) = $0 { return action }
        return nil
    },
      review: AppAction.episodesAction
    )
  }
}

/*:
 Ok, now we can lift our reducers finally! First we will define a `lift` that lifts actions and state together
 */

extension Reducer {
  func lift<T, B>(state: WritableKeyPath<T, S>, action: Prism<B, A>) -> Reducer<T, B> {
    return self.lift(state: state).lift(action: action)
  }
}

let appReducer =
  accountReducer
    .lift(state: \AppState.accountState, action: AppAction.prism.accountAction)
    <> episodeReducer
      .lift(state: \AppState.episodesState, action: AppAction.prism.episodesAction)

/*:
 Ok! We can now finally create a store that uses this reducer and dispatch some commands to it!
 */

let ep1 = Episode(id: 1, title: "Ep 1", videoUrl: "ep1.mp4")
let ep2 = Episode(id: 2, title: "Ep 2", videoUrl: "ep2.mp4")
let ep3 = Episode(id: 3, title: "Ep 3", videoUrl: "ep3.mp4")

let store = Store(
  reducer: appReducer,
  initialState: .init(
    episodesState: EpisodesState(
      episodes: [ep1, ep2, ep3],
      watchedEpisodes: []
    ),
    accountState: AccountState(
      loggedInUser: nil,
      settings: Settings(notificationsOn: false),
      watchedEpisodes: []
    )
  )
)

store.subscribe {
  dump($0)
  print("-----------")
  print("-----------")
}

let user = User(id: 1, name: "Blob")

store.dispatch(.episodesAction(.tappedEpisode(ep1)))
store.dispatch(.episodesAction(.tappedEpisode(ep3)))
store.dispatch(.accountAction(.login(user)))
store.dispatch(.accountAction(.tappedNotification(on: true)))

/*:
 Ok, i'm starting to see something weird in the state. In the main screen we had watched two episodes, yet the array of watched episodes is empty. this is because our app state isn't correctly factored, it has an overlap of data in which both the account and episodes screens contains an array of watched episodes.

 We can move the `watchedEpisodes` out of each of those substates and into global state that way anyone can access the list of watched episodes. However, that will break our reducers. We'd want a way to pluck out multiple pieces from the global state that we can reducer on. This shows a shortcoming in keypaths that lenses don't have.

 We want to be able to write a function like so:

 ```
 func both<A, B, C>(
   _ lhs: WritableKeyPath<A, B>,
   _ rhs: WritableKeyPath<A, C>
   ) -> WritableKeyPath<A, (B, C)>
 ```

 This is not possible to write because key paths are not constructible by us, only the compiler. Lenses, however, do not have this problem! We can define:
 */

struct Lens<A, B> {
  let view: (A) -> B
  let set: (A, B) -> A
}

func both<A, B, C>(_ lhs: Lens<A, B>, _ rhs: Lens<A, C>) -> Lens<A, (B, C)> {
  return Lens<A, (B, C)>(
    view: { (lhs.view($0), rhs.view($0)) },
    set: { whole, parts in rhs.set(lhs.set(whole, parts.0), parts.1) }
  )
}

func lens<A, B>(_ keyPath: WritableKeyPath<A, B>) -> Lens<A, B> {
  return Lens<A, B>(
    view: { $0[keyPath: keyPath] },
    set: { whole, part in var result = whole; result[keyPath: keyPath] = part; return whole }
  )
}

/*:
 Worth saying that it is not possible to go the other way, (Lens<A, B>) -> WritableKeyPath<A, B> due to not being able to construct key paths.

 So now we get to leverage the fact that swift autogens a lens for us for every single field, and combine them in new ways:
 */

let episodesAndNotificationsLens: Lens<AppState, ([Episode], Bool)> =
  both(
    lens(\.episodesState.episodes),
    lens(\.accountState.settings.notificationsOn)
)

/*:
 Now we get to be super expressive in how we pick up the minimal amount of state our reducers need to do its job. Let's do that now!
 */



print("✅")

