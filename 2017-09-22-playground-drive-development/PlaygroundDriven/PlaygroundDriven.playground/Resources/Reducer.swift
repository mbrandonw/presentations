import Dispatch
import Foundation

public enum Effect<A> {
  case _execute(Any, (@escaping (A) -> ()) -> ())
  case batch([Effect<A>])
  case dispatch(A)
  case sequence([Effect<A>])

  public static func execute(
    fingerprint: Any = "\(#file):\(#line):\(#function)",
    _ callback: @escaping (@escaping (A) -> ()) -> ())
    -> Effect {

      return ._execute(fingerprint, callback)
  }

  public static var noop: Effect { return .batch([]) }

  public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    switch self {
    case let ._execute(fingerprint, effect):
      return ._execute(fingerprint, { dispatch in
        effect { a in
          dispatch(f(a))
        }
      })
      
    case let .batch(effects):
      return .batch(effects.map { $0.map(f) })

    case let .dispatch(action):
      return .dispatch(f(action))

    case let .sequence(effects):
      return .sequence(effects.map { $0.map(f) })
    }
  }
}

public struct Reducer<S, A> {
  public let reduce: (A, S) -> (S, Effect<A>)

  public init(_ reduce: @escaping (A, S) -> (S, Effect<A>)) {
    self.reduce = reduce
  }
}

public final class Store<S, A> {
  let reducer: Reducer<S, A>

  var subscribers: [(S) -> Void] = []
  var currentState: S {
    didSet {
      subscribers.forEach { $0(self.currentState) }
    }
  }

  public init(reducer: Reducer<S, A>, initialState: S) {
    self.reducer = reducer
    self.currentState = initialState
  }

  public func interpret(_ effect: Effect<A>) {
    switch effect {
    case let ._execute(_, f):
      f(self.dispatch)
    case let .batch(effects):
      // TODO: execute actions in order
      effects.forEach { e in
        DispatchQueue.global(qos: .userInitiated).async {
          self.interpret(e)
        }
      }
    case let .dispatch(action):
      self.dispatch(action)
    case let .sequence(effects):
      effects.forEach(self.interpret)
    }
  }

  public func dispatch(_ action: A) {
    let (newState, effect) = self.reducer.reduce(action, self.currentState)
    self.currentState = newState
    self.interpret(effect)
  }
  
  public func subscribe(_ subscriber: @escaping (S) -> Void) {
    self.subscribers.append(subscriber)
  }
}
