import Foundation

enum Maybe <A> {
  case Just(A)
  case Nothing

  func description () -> String {
    switch self {
    case let .Just(value):
      return "{Just \(value)}"
    case .Nothing:
      return "{Nothing}"
    }
  }
}

func squareRoot (x: Float) -> Maybe<Float> {
  if x >= 0 { return .Just(sqrtf(x)) }
  return .Nothing
}

func invert (x: Float) -> Maybe<Float> {
  if x != 0.0 { return .Just(1.0 / x) }
  return .Nothing
}

infix operator >>= {associativity left}
func >>= <A, B> (x: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B> {
  switch x {
  case let .Just(x): return f(x)
  case .Nothing:     return .Nothing
  }
}

let x = squareRoot(2.0)
  >>= { .Just($0 - 1.0) }
  >>= { invert($0) }
  >>= { squareRoot($0) }
x.description()

let y = Maybe<Float>.Just(1.0)
  >>= { .Just($0 - 1.0) }
  >>= { invert($0) }
  >>= { squareRoot($0) }
y.description()
