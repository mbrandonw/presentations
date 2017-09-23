/*:
 # Composable Reducers & Effects Systems
 * Brandon Williams
 * mbw234@gmail.com
 * @mbrandonw
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

extension Reducer {
  func lift<T>(state: WritableKeyPath<T, S>) -> Reducer<T, A> {
    return Reducer<T, A> { stateT, action in
      self.reduce(&stateT[keyPath: state], action)
    }
  }
}

struct Prism<A, B> {
  let preview: (A) -> B?
  let review: (B) -> A
}

extension Reducer {
  func lift<B>(action: Prism<B, A>) -> Reducer<S, B> {
    return Reducer<S, B> { state, actionB in
      guard let actionA = action.preview(actionB) else { return }
      self.reduce(&state, actionA)
    }
  }
}

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

let episodesAndNotificationsLens: Lens<AppState, ([Episode], Bool)> =
  both(
    lens(\.episodesState.episodes),
    lens(\.accountState.settings.notificationsOn)
)

/*:
 Before we can move the watched episodes state out into the global state we need our reducers to understand lenses. let's make a `lift` specific to lenses
 */

extension Reducer {
  func lift<T>(state: Lens<T, S>)
}

print("✅")



/*:
 Future directions:

 - We need proper Swift support for prisms.
 */













