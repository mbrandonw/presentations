/*:
 # Seemingly Impossible Swift Programs
 */
/*:
 # 1.) Completely possible programs
 */

[1, 2, 3]
  .allSatisfy { $0 >= 2 }
[1, 2, 3]
  .allSatisfy { $0 >= 1 }

extension Array {
  func anySatisfy(_ p: (Element) -> Bool) -> Bool {
    return !self.allSatisfy { !p($0) }
  }
}

// !(a || b) == !a && !b

[1, 2, 3]
  .anySatisfy { $0 >= 4 }
[1, 2, 3]
  .anySatisfy { $0 >= 1 }

/*:
 # 2.) Approaching impossible programs
 */

extension Bool {
  static func allSatisfy(_ p: (Bool) -> Bool) -> Bool {
    return p(true) && p(false)
  }
}

Bool
  .allSatisfy { $0 == true }
Bool
  .allSatisfy { $0 == true || $0 == false }

extension CaseIterable {
  static func allSatisfy(_ p: (Self) -> Bool) -> Bool {
    return self.allCases.allSatisfy(p)
  }
}

enum Direction: CaseIterable {
  case up, down, left, right
}

Direction
  .allSatisfy { $0 == .up }

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

Direction
  .allSatisfy { $0.rotatedLeft.rotatedRight == $0 }

/*:
 # 3.) Impossible programs
 */

extension Int {
  static func allSatisfy(_ p: (Int) -> Bool) -> Bool {
    fatalError()
  }
}

//Int
//  .allSatisfy { $0 >= 0 }
//Int
//  .allSatisfy { $0 % 2 == 0 || $0 % 2 == 1 }

extension String {
  static func allSatisfy(_ p: (String) -> Bool) -> Bool {
    fatalError()
  }
}

//String
//  .allSatisfy { $0 == "cat" }
//String
//  .allSatisfy { $0.count >= 0 }

//func == (f: (Int) -> Int, g: (Int) -> Int) -> Bool {
//  return Int.allSatisfy { f($0) == g($0) }
//}

/*:
 # 4.) Seeimingly impossible programs
 */

enum Bit {
  case one
  case zero
}

struct BitSequence {
  let atIndex: (UInt) -> Bit
}

let xs = BitSequence { _ in .one }
let ys = BitSequence { $0 < 1000 ? .zero : .one }

ys.atIndex(0)
ys.atIndex(2000)

func + (head: Bit, tail: @escaping @autoclosure () -> BitSequence) -> BitSequence {
  return BitSequence { idx in
    idx == 0 ? head : tail().atIndex(idx - 1)
  }
}

.one + ys

/*:
 # 5.) Achieving the seemingly impossible
 */

extension BitSequence {
  static func allSatisfy(_ p: @escaping (BitSequence) -> Bool) -> Bool {
    return !self.anySatisfy { !p($0) }
  }
}

extension BitSequence {
  static func anySatisfy(_ p: @escaping (BitSequence) -> Bool) -> Bool {
    let found = BitSequence { idx in self.find(p).atIndex(idx)}
    return p(found)
  }
}

extension BitSequence {
  static func find(_ p: @escaping (BitSequence) -> Bool) -> BitSequence {
    if self.anySatisfy({ s in p(.zero + s) }) {
      return .zero + self.find({ s in p(.zero + s) })
    } else {
      return .one + self.find({ s in p(.one + s) })
    }
  }
}

let someSequence = BitSequence.find { s in
  s.atIndex(0) == .one
    && s.atIndex(2) == .one
    && s.atIndex(4) == .one
    && s.atIndex(6) == .one
    && s.atIndex(8) == .one
}

someSequence.atIndex(0)
someSequence.atIndex(1)
someSequence.atIndex(2)
someSequence.atIndex(3)
someSequence.atIndex(4)
someSequence.atIndex(5)
someSequence.atIndex(6)
someSequence.atIndex(7)
someSequence.atIndex(8)
someSequence.atIndex(9)
someSequence.atIndex(10)
someSequence.atIndex(11)

BitSequence
  .allSatisfy { s in s.atIndex(0) == .zero }
BitSequence
  .allSatisfy { s in s.atIndex(0) == .zero || s.atIndex(1) == .one }
BitSequence
  .allSatisfy { s in s.atIndex(0) == .zero || s.atIndex(0) == .one }

BitSequence
  .anySatisfy { s in s.atIndex(4) == s.atIndex(8) }

func == <A: Equatable> (lhs: @escaping (BitSequence) -> A, rhs: @escaping (BitSequence) -> A) -> Bool {
  return BitSequence.allSatisfy { s in lhs(s) == rhs(s) }
}

let const1: (BitSequence) -> Int = { _ in 1 }
let const2: (BitSequence) -> Int = { _ in 2 }

const1 == const1
const2 == const2
const1 == const2

extension Bit {
  var toUInt: UInt {
    switch self {
    case .one:  return 1
    case .zero: return 0
    }
  }
}

let f: (BitSequence) -> UInt = { s in
  s.atIndex(1).toUInt * s.atIndex(2).toUInt
}

let g: (BitSequence) -> UInt = { s in
  s.atIndex(1).toUInt + s.atIndex(2).toUInt
}

f == f
g == g
f == g

let h: (BitSequence) -> UInt = { s in
  switch (s.atIndex(1), s.atIndex(2)) {
  case (.zero, _), (_, .zero):
    return 0
  case (.one, let other), (let other, .one):
    return other.toUInt
  }
}

h == f
h == g

let k: (BitSequence) -> UInt = { s in
  ((s.atIndex(1).toUInt + s.atIndex(2).toUInt + 908) % 6) / 4
}

k == f
k == g
k == h

/*:
 # 6.) Topology
 */

/*:
 # References


 ## Infinite sets that admit fast exhaustive search
 Martín Escardó

 http://www.cs.bham.ac.uk/~mhe/papers/exhaustive.pdf

 ---

 ## Synthetic topology of data types and classical spaces
 Martín Escardó

 http://www.cs.bham.ac.uk/~mhe/papers/entcs87.pdf

 ---

 ## Seemingly Impossible Functional Programs
 Martín Escardó

 http://math.andrej.com/2007/09/28/seemingly-impossible-functional-programs/

 ---
 ## The topology of Seemingly impossible functional programs (Slides)
 Martín Escardó
 
 https://www.cs.bham.ac.uk/~mhe/.talks/popl2012/escardo-popl2012.pdf
 */
