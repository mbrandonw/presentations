// Maybe implementation

import Foundation

enum Maybe <A> {
  case Just(A)
  case Nothing

  func description () -> String {
    switch self {
    case let .Just(value): return "{Just \(value)}"
    case .Nothing: return "{Nothing}"
    }
  }
}

let x = Maybe<Int>.Just(4)
x.description()
let y: Int? = 2

switch x {
case let .Just(x):
  "just"
  x * x
case .Nothing:
  "nothing"
}

x
