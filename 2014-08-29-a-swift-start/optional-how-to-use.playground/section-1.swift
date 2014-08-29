// How to use Optionals?

import Foundation

let colorsByName: [String: Int] = [
  "black": 0x0,
  "red": 0xff0000,
  "blue": 0x0000ff,
]

let redColor = colorsByName["red"]

if let redColor = redColor {
  redColor / 2
} else {
  redColor == nil
}

redColor
