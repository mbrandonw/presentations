import Boundaries
//import BoundariesTestSupport

public enum Hidden {
  public struct State {
    var count: Int
    var isPrimeLabelText: String
    var isPrimeLabelColor: UIColor
  }
  public enum Action {
    case decr
    case incr
    case `init`(Int)
    case isPrimeResult(String)
  }
  public struct Result: Decodable {
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
  public enum Effect: EffectProtocol {
    public typealias A = Action
    case isPrime(Int)
  }
  public static func execute(effect: Effect) -> Action? {
    switch effect {
    case let .isPrime(n):
      return isPrime(n)
    }
  }
  public static func testExecute(effect: Effect) -> Action? {
    switch effect {
    case let .isPrime(n):
      return [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71].contains(n)
        ? .isPrimeResult("\(n) is a prime number")
        : .isPrimeResult("\(n) is not a prime number")
    }
  }
  public static func isPrime(_ n: Int) -> Action? {
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


  public static let appReducer = Reducer<State, Action, Effect> { action, state in
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

  public static let liveStore = Store(
    reducer: Hidden.appReducer,
    initialState: Hidden.State(
      count: 1,
      isPrimeLabelText: "1 is not a prime number",
      isPrimeLabelColor: UIColor(white: 1.0, alpha: 0.5)
    ),
    execute: Hidden.execute(effect:)
  )

//  static let testStore = TestStore(
//    reducer: Hidden.appReducer,
//    initialState: Hidden.State(
//      count: 1,
//      isPrimeLabelText: "1 is not a prime number",
//      isPrimeLabelColor: UIColor(white: 1.0, alpha: 0.5)
//    ),
//    execute: Hidden.testExecute(effect:)
//  )
}
public let store = Hidden.liveStore

public class Controller: UIViewController {

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .init(red: 0.75, green: 0.15, blue: 0.16, alpha: 1)

    let imageView = UIImageView()
    imageView.image = UIImage(
      named: "frenchkit-logo",
      in: Bundle(for: SomeClass.self),
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
    incrButton.layer.cornerRadius = 6
    incrButton.layer.borderColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.8).cgColor
    incrButton.layer.borderWidth = 1
    incrButton.layer.masksToBounds = true
    incrButton.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
    incrButton.backgroundColor = UIColor.init(white: 0.0, alpha: 0.1)

    let decrButton = UIButton()
    decrButton.setTitle("-", for: .normal)
    decrButton.setTitleColor(.white, for: .normal)
    decrButton.addTarget(self, action: #selector(decrButtonTapped), for: .touchUpInside)
    decrButton.setContentHuggingPriority(.required, for: .horizontal)
    decrButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    decrButton.layer.cornerRadius = 6
    decrButton.layer.borderColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.8).cgColor
    decrButton.layer.borderWidth = 1
    decrButton.layer.masksToBounds = true
    decrButton.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
    decrButton.backgroundColor = UIColor.init(white: 0.0, alpha: 0.1)

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
      countLabel.text = String(state.count)
      isPrimeLabel.text = state.isPrimeLabelText
      isPrimeLabel.textColor = state.isPrimeLabelColor
    }

    store.dispatch(.init(1))
  }
  @objc func incrButtonTapped() {
    store.dispatch(.incr)
  }
  @objc func decrButtonTapped() {
    store.dispatch(.decr)
  }
}

