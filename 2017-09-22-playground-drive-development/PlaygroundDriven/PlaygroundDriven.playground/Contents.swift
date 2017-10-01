import Boundaries
import BoundariesTestSupport
let largeNumber = 18_408_989 - 2



























import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

enum Hidden {
  struct State {
    var count: Int
    var isPrimeLabelText: String
    var isPrimeLabelColor: UIColor
  }
  enum Action {
    case decr
    case incr
    case `init`(Int)
    case isPrimeResult(String)
  }
  struct Result: Decodable {
    let queryresult: QueryResult

    struct QueryResult: Decodable {
      let pods: [Pod]

      struct Pod: Decodable {
        let subpods: [Subpod]

        struct Subpod: Decodable {
          let plaintext: String
        }
      }
    }
  }
  enum Effect: EffectProtocol {
    typealias A = Action
    case isPrime(Int)
  }
  static func execute(effect: Effect) -> Action? {
    switch effect {
    case let .isPrime(n):
      return isPrime(n)
    }
  }
  static func testExecute(effect: Effect) -> Action? {
    switch effect {
    case let .isPrime(n):
      return [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71].contains(n)
        ? .isPrimeResult("\(n) is a prime number")
        : .isPrimeResult("\(n) is not a prime number")
    }
  }
  static func isPrime(_ n: Int) -> Action? {
    let semaphore = DispatchSemaphore(value: 0)
    var action: Action?

    let url = URL(string: "https://api.wolframalpha.com/v2/query?input=is%20\(n)%20prime%3F&appid=6H69Q3-828TKQJ4EP&output=json")!
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in
      defer { semaphore.signal() }
      guard let result = data
        .flatMap({ try? JSONDecoder().decode(Result.self, from: $0) })?
        .queryresult
        else { return }

      action = .isPrimeResult(result.pods[1].subpods[0].plaintext)
      }
      .resume()

    semaphore.wait()

    return action
  }


  static let appReducer = Reducer<State, Action, Effect> { action, state in
    var nextState = state
    let effect: Cmd<Effect>

    switch action {
    case .decr:
      nextState.isPrimeLabelText = "Loading..."
      nextState.count -= 1
      effect = .parallel([.execute(.isPrime(nextState.count))])

    case .incr:
      nextState.isPrimeLabelText = "Loading..."
      nextState.count += 1
      effect = .parallel([.execute(.isPrime(nextState.count))])

    case let .init(n):
      nextState.isPrimeLabelText = "Loading..."
      nextState.count = n
      effect = .parallel([.execute(.isPrime(nextState.count))])

    case let .isPrimeResult(string):
      let isPrime = string.contains("is a prime")
      nextState.isPrimeLabelText = string + (isPrime ? "!" : "")
      nextState.isPrimeLabelColor = isPrime ? .white : UIColor(white: 1.0, alpha: 0.5)
      effect = .noop
    }

    return (nextState, effect)
  }

  static let liveStore = Store(
    reducer: Hidden.appReducer,
    initialState: Hidden.State(
      count: 1,
      isPrimeLabelText: "1 is not a prime number",
      isPrimeLabelColor: UIColor(white: 1.0, alpha: 0.5)
    ),
    execute: Hidden.execute(effect:)
  )

  static let testStore = TestStore(
    reducer: Hidden.appReducer,
    initialState: Hidden.State(
      count: 1,
      isPrimeLabelText: "1 is not a prime number",
      isPrimeLabelColor: UIColor(white: 1.0, alpha: 0.5)
    ),
    execute: Hidden.testExecute(effect:)
  )
}
let store = Hidden.liveStore
let startingCount = largeNumber

import AppFramework

PlaygroundPage.current.liveView = playgroundController(
  for: AppFramework.Controller(),
  device: Device.phone4_7inch,
  orientation: .portrait,
  traits: UITraitCollection.init(traitsFrom: [
    UITraitCollection.init(preferredContentSizeCategory: UIContentSizeCategory.extraExtraExtraLarge),
    UITraitCollection.init(layoutDirection: .rightToLeft)
    ])
)











