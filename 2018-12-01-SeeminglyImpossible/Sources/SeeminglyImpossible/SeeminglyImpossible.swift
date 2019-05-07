

extension Array {
  func anySatisfy(_ p: (Element) -> Bool) -> Bool {
    return !self.allSatisfy { !p($0) }
  }
}

extension Bool {
  static func allSatisfy(_ p: (Bool) -> Bool) -> Bool {
    return p(true) && p(false)
  }
}


extension CaseIterable {
  static func allSatisfy(_ p: (Self) -> Bool) -> Bool {
    return Self.allCases.allSatisfy(p)
  }
}

enum Direction: CaseIterable {
  case up, down, left, right
}
extension Direction {
  var rotatedLeft: Direction {
    switch self {
    case .up:    return .left
    case .left:  return .down
    case .down:  return .right
    case .right: return .up
    }
  }

  var rotatedRight: Direction {
    switch self {
    case .up:    return .right
    case .left:  return .up
    case .down:  return .left
    case .right: return .down
    }
  }
}


extension Int {
  static func allSatisfy(_ p: (Int) -> Bool) -> Bool {
    fatalError()
  }
}


extension String {
  static func allSatisfy(_ p: (String) -> Bool) -> Bool {
    fatalError()
  }
}


func == (lhs: (Int) -> Int, rhs: (Int) -> Int) -> Bool {
  return Int.allSatisfy { lhs($0) == rhs($0) }
}


enum Bit {
  case one
  case zero
}

struct BitSequence {
  let atIndex: (UInt) -> Bit
}


let xs = BitSequence { _ in .one }
let ys = BitSequence { $0 < 1_000 ? .zero : .one }
let zs = BitSequence { $0 % 2 == 0 ? .zero : .one }


extension BitSequence {
  var head: Bit {
    return self.atIndex(0)
  }

  var tail: BitSequence {
    return BitSequence { self.atIndex($0 + 1)}
  }
}

func + (lhs: Bit, rhs: BitSequence) -> BitSequence {
  return BitSequence { $0 == 0 ? lhs : rhs.atIndex($0 - 1) }
}
extension BitSequence {
  static func allSatisfy(_ p: @escaping (BitSequence) -> Bool) -> Bool {
    return !BitSequence.anySatisfy { !p($0) }
  }
}

extension BitSequence {
  static func anySatisfy(_ p: @escaping (BitSequence) -> Bool) -> Bool {
    return p(BitSequence.find(p))
  }
}























extension BitSequence {
  static func find(_ p: @escaping (BitSequence) -> Bool) -> BitSequence {
    if BitSequence.anySatisfy({ s in p(.zero + s) }) {
      return .zero + find({ s in p(.zero + s) })
    } else {
      return .one + find({ s in p(.one + s) })
    }
  }
}











