/*:
 # Composable Reducers & Effects Systems
 * Brandon Williams
 * mbw234@gmail.com
 * @mbrandonw
 */

/*:
 We start with a reducer, which takes a state and an action and produce another state.
 */

struct Reducer<S, A> {
  let reduce: (S, A) -> S
}

precedencegroup MonoidAppend {
  associativity: left
}
infix operator <>
protocol Monoid {
  static var empty: Self { get }
  static func <> (lhs: Self, rhs: Self) -> Self
}

/*:
 A fun thing we can do is realize that `(S, A) -> S` can be written as `(A) -> Endo(S)`, and we have previously seen that `Endo(S)` is a monoid, and we know that functions into monoids are monoids, and therefore Reducers naturally form a monoid. here we've just spelled it out more explicitly.
 */

extension Reducer: Monoid {
  static var empty: Reducer {
    return Reducer { s, _ in s }
  }

  static func <> (lhs: Reducer, rhs: Reducer) -> Reducer {
    // (S, A) -> S
    // (A, S) -> S
    // (A) -> (S) -> S
    // (A) -> Endo(S)
    return Reducer { state, action in
      let state1 = lhs.reduce(state, action)
      let state2 = rhs.reduce(state1, action)
      return state2
    }
  }
}

/*:
 Next thing we need is a runtime thing to allow our view to dispatch action, run the reducer, save the current state, and send it out to subscribers.
 */

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
    self.currentState = self.reducer.reduce(self.currentState, action)
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
  case tappedEpisode(Episode)
  case tappedLogout
  case tappedNotification(on: Bool)
}

enum EpisodesAction {
  case tappedEpisode(Episode)
}

let accountReducer = Reducer<AccountState, AccountAction> { state, action in
  switch action {
    
  case let .tappedEpisode(episode):
    return AccountState(
      loggedInUser: state.loggedInUser,
      settings: state.settings,
      watchedEpisodes: state.watchedEpisodes + [episode]
    )

  case .tappedLogout:
    return AccountState(
      loggedInUser: nil,
      settings: state.settings,
      watchedEpisodes: []
    )

  case let .tappedNotification(on):
    return AccountState(
      loggedInUser: state.loggedInUser,
      settings: Settings(notificationsOn: on),
      watchedEpisodes: state.watchedEpisodes
    )
  }
}

/*:
 Ok this reducer is got way too much in it. first of all, the state is fully private inside the store, so there's not reason to create a new state and return it. we might as well be handled an `inout` state and just mutate right in the reducer.
 */

print("✅")
