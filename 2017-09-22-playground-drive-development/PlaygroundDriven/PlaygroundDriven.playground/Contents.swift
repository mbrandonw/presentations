import UIKit
import Boundaries
import BoundariesTestSupport
import Prelude
import Optics
import NonEmpty

let largeNumber = 18_408_989 - 3

public func playgroundController(
  for viewController: UIViewController,
  device: Device = .phone4_7inch,
  orientation: Orientation = .portrait,
  traits: UITraitCollection = .init())
  -> UIViewController
{
  return playgroundController(
    for: viewController,
    size: device.size(for: orientation),
    traits: .init(
      traitsFrom: [
        device.traits(for: orientation),
        traits
      ]
    )
  )
}

public func playgroundController(
  for child: UIViewController,
  size: CGSize,
  traits: UITraitCollection = .init())
  -> UIViewController
{
  let parent = UIViewController()
  parent.view.frame.size = size
  parent.preferredContentSize = parent.view.frame.size
  parent.addChildViewController(child)
  parent.setOverrideTraitCollection(traits, forChildViewController: child)
  parent.view.addSubview(child.view)

  child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  child.view.frame = parent.view.frame
  parent.view.backgroundColor = .white

  return parent
}

public enum Orientation {
  case portrait
  case landscape
}

public enum Device {
  case phone3_5inch
  case phone4inch
  case phone4_7inch
  case phone5_5inch
  case pad
  case pad12_9inch

  var portraitSize: CGSize {
    switch self {
    case .phone3_5inch:
      return .init(width: 320, height: 480)
    case .phone4inch:
      return .init(width: 320, height: 568)
    case .phone4_7inch:
      return .init(width: 375, height: 667)
    case .phone5_5inch:
      return .init(width: 414, height: 736)
    case .pad:
      return .init(width: 768, height: 1024)
    case .pad12_9inch:
      return .init(width: 1024, height: 1366)
    }
  }

  var landscapeSize: CGSize {
    let portraitSize = self.portraitSize
    return .init(width: portraitSize.height, height: portraitSize.width)
  }

  func size(for orientation: Orientation) -> CGSize {
    switch orientation {
    case .portrait:
      return self.portraitSize
    case .landscape:
      return self.landscapeSize
    }
  }

  func traits(for orientation: Orientation) -> UITraitCollection {
    switch (self, orientation) {
    case (.phone3_5inch, .portrait), (.phone4inch, .portrait), (.phone4_7inch, .portrait), (.phone5_5inch, .portrait):
      return .init(
        traitsFrom: [
          .init(horizontalSizeClass: .compact),
          .init(verticalSizeClass: .regular),
          .init(userInterfaceIdiom: .phone)
        ]
      )
    case (.phone3_5inch, .landscape), (.phone4inch, .landscape), (.phone4_7inch, .landscape):
      return .init(
        traitsFrom: [
          .init(horizontalSizeClass: .compact),
          .init(verticalSizeClass: .compact),
          .init(userInterfaceIdiom: .phone)
        ]
      )
    case (.phone5_5inch, .landscape):
      return .init(
        traitsFrom: [
          .init(horizontalSizeClass: .regular),
          .init(verticalSizeClass: .compact),
          .init(userInterfaceIdiom: .phone)
        ]
      )
    case (.pad, _), (.pad12_9inch, _):
      return .init(
        traitsFrom: [
          .init(horizontalSizeClass: .regular),
          .init(verticalSizeClass: .regular),
          .init(userInterfaceIdiom: .pad)
        ]
      )
    }
  }
}


import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


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

func execute(effect: Effect) -> Action? {
  switch effect {
  case let .isPrime(n):
    return isPrime(n)
  }
}

func testExecute(effect: Effect) -> Action? {
  switch effect {
  case let .isPrime(n):
    return [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71].contains(n)
      ? .isPrimeResult("\(n) is a prime number")
      : .isPrimeResult("\(n) is not a prime number")
  }
}

func isPrime(_ n: Int) -> Action? {
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

let appReducer = Reducer<State, Action, Effect> { action, state in
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

let liveStore = Store(
  reducer: appReducer,
  initialState: State(
    count: 1,
    isPrimeLabelText: "1 is not a prime number",
    isPrimeLabelColor: UIColor(white: 1.0, alpha: 0.5)
  ),
  execute: execute(effect:)
)

let testStore = TestStore(
  reducer: appReducer,
  initialState: State(
    count: 1,
    isPrimeLabelText: "1 is not a prime number",
    isPrimeLabelColor: UIColor(white: 1.0, alpha: 0.5)
  ),
  execute: testExecute(effect:)
)

let store = liveStore

import AppFramework

class Controller: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .init(red: 0.75, green: 0.15, blue: 0.16, alpha: 1)

    let imageView = UIImageView()
    imageView.image = UIImage(
      named: "frenchkit-logo",
      in: Bundle(identifier: "com.playground-drive.AppFramework"),
      compatibleWith: self.traitCollection
    )
    imageView.contentMode = .center

    let titleLabel = UILabel()
    titleLabel.text = "Playground Driven Development"
    titleLabel.textAlignment = .center
    titleLabel.textColor = .white
    titleLabel.numberOfLines = 2
    titleLabel.font = self.traitCollection.horizontalSizeClass == .compact
      ? .preferredFont(forTextStyle: .title3, compatibleWith: self.traitCollection)
      : .preferredFont(forTextStyle: .title1, compatibleWith: self.traitCollection)

    let incrButton = UIButton()
    incrButton.setTitle("+", for: .normal)
    incrButton.setTitleColor(.white, for: .normal)
    incrButton.addTarget(self, action: #selector(incrButtonTapped), for: .touchUpInside)
    incrButton.setContentHuggingPriority(.required, for: .horizontal)
    incrButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    let decrButton = UIButton()
    decrButton.setTitle("-", for: .normal)
    decrButton.setTitleColor(.white, for: .normal)
    decrButton.addTarget(self, action: #selector(decrButtonTapped), for: .touchUpInside)
    decrButton.setContentHuggingPriority(.required, for: .horizontal)
    decrButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    let countLabel = UILabel()
    countLabel.textAlignment = .center
    countLabel.textColor = .white
    countLabel.font = .preferredFont(forTextStyle: .body, compatibleWith: self.traitCollection)

    let isPrimeLabel = UILabel()
    isPrimeLabel.font = .preferredFont(forTextStyle: .body, compatibleWith: self.traitCollection)
    isPrimeLabel.textAlignment = .center
    isPrimeLabel.numberOfLines = 0

    let buttonsAndCountStackView = UIStackView()
    buttonsAndCountStackView.axis = .horizontal

    let whiteView = UIView()
    whiteView.backgroundColor = .white
    let blueView = UIView()
    blueView.backgroundColor = .init(red: 0.2, green: 0.3, blue: 0.58, alpha: 1)

    [
      decrButton,
      countLabel,
      incrButton
      ]
      .forEach(buttonsAndCountStackView.addArrangedSubview)


    let mainStackView = UIStackView()
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.layoutMargins = self.traitCollection.horizontalSizeClass == .compact
      ? .init(top: 64, left: 24, bottom: 64, right: 24)
      : .init(top: 128, left: 64, bottom: 128, right: 64)
    mainStackView.isLayoutMarginsRelativeArrangement = true
    mainStackView.spacing = 24

    [
      imageView,
      titleLabel,
      buttonsAndCountStackView,
      isPrimeLabel
      ]
      .forEach(mainStackView.addArrangedSubview)

    let rootStackView = UIStackView()
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    rootStackView.axis = .vertical

    [
      mainStackView,
      whiteView,
      blueView
      ]
      .forEach(rootStackView.addArrangedSubview)

    self.view.addSubview(rootStackView)

    NSLayoutConstraint.activate(
      [
        rootStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        rootStackView.topAnchor.constraint(equalTo: self.view.topAnchor),
        rootStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        rootStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

        whiteView.heightAnchor.constraint(equalTo: blueView.heightAnchor),
      ]
    )

    store.subscribe { state in
      state.isPrimeLabelText
      countLabel.text = String(state.count)
      isPrimeLabel.text = state.isPrimeLabelText
      isPrimeLabel.textColor = state.isPrimeLabelColor
    }

    store.dispatch(.init(largeNumber))
  }

  @objc func incrButtonTapped() {
    store.dispatch(.incr)
  }

  @objc func decrButtonTapped() {
    store.dispatch(.decr)
  }
}

PlaygroundPage.current.liveView = playgroundController(
  for: Controller(),
  device: .phone4_7inch,
  orientation: .portrait,
  traits: .init(preferredContentSizeCategory: .extraExtraExtraLarge)
)
