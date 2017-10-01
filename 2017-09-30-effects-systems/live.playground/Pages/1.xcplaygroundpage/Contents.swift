/*:
 # Composable Reducers & Effects Systems
 * Brandon Williams
 * mbw234@gmail.com
 * @mbrandonw
 */

// typealias Reducer<S, A> = (S, A) -> S
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

extension Reducer: Monoid {
  static var empty: Reducer<S, A> {
    return Reducer { s, _ in s }
  }

  // (S, A) -> S
  // (A, S) -> S
  // (A) -> (S) -> S
  // (A) -> Endo(S)

  static func <>(lhs: Reducer<S, A>, rhs: Reducer<S, A>) -> Reducer<S, A> {
    return Reducer { s, a in
      let newState = lhs.reduce(s, a)
      return rhs.reduce(newState, a)
    }
  }
}

class Store<S, A> {
  private let reducer: Reducer<S, A>
  private var subscribers: [(S) -> Void] = []
  private var currentState: S {
    didSet {
      self.subscribers.forEach { $0(self.currentState) }
    }
  }

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


struct EpisodesState {
  var episodes: [Episode] = []
  var watchedEpisodes: [Episode] = []
}

struct AccountState {
  var loggedInUser: User? = nil
  var settings: Settings = .init()
  var watchedEpisodes: [Episode] = []
}

struct Settings {
  var notificationsOn: Bool = false
}

enum EpisodesAction {
  case tappedEpisode(Episode)
}

enum AccountAction {
  case login(User)
  case tappedEpisode(Episode)
  case tappedLogout
  case tappedNotification(on: Bool)
}


struct AppState {
  var episodesState: EpisodesState = .init()
  var accountState: AccountState = .init()
}

enum AppAction {
  case accountAction(AccountAction)
  case episodesAction(EpisodesAction)
}

let accountReducer = Reducer<AccountState, AccountAction> { state, action in

  switch action {

  case let .login(user):
    return AccountState.init(loggedInUser: user, settings: state.settings, watchedEpisodes: state.watchedEpisodes)

  case let .tappedEpisode(episode):
    return AccountState.init(loggedInUser: state.loggedInUser, settings: state.settings, watchedEpisodes: state.watchedEpisodes + [episode])

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

print("✅")



































