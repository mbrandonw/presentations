import XCTest



extension Array {
  func anySatisfy(_ p: (Element) -> Bool) -> Bool {
    for x in self {
      if p(x) { return true }
    }
    return false
  }
}




enum Bit {
  case zero
  case one

  var toInt: Int {
    switch self {
    case .zero: return 0
    case .one:  return 1
    }
  }
}

struct Cantor {
  let atIndex: (UInt) -> Bit

  subscript(index: UInt) -> Bit {
    return self.atIndex(index)
  }
}

func allSatisfy(_ p: (Bool) -> Bool) -> Bool {
  return !anySatisfy { !p($0) }
}
func anySatisfy(_ p: (Bool) -> Bool) -> Bool {
  return find { b in p(b) }.map(p) ?? false
  //  return p(true) || p(false)
}
func find(_ p: (Bool) -> Bool) -> Bool? {
  return [true, false].first(where: p)
}

func allSatisfy<A: CaseIterable>(_ p: (A) -> Bool) -> Bool {
  return !anySatisfy { !p($0) }
}
func anySatisfy<A: CaseIterable>(_ p: (A) -> Bool) -> Bool {
  return find { b in p(b) }.map(p) ?? false
  //  return A.allCases.reduce(false, { $0 || p($1) })
}
func find<A: CaseIterable>(_ p: (A) -> Bool) -> A? {
  return A.allCases.first(where: p)
}

["2", "1"]
  .first(where: { $0 == "1" })

// Given a predicate on `Cantor`, returns a boolean that determines if all values return `true`.
func allSatisfy(_ p: @escaping (Cantor) -> Bool) -> Bool {
  return !anySatisfy({ a in !p(a) })
}

// Given a predicate on `Cantor`, returns a boolean that determines if any value return `true`.
func anySatisfy(_ p: @escaping (Cantor) -> Bool) -> Bool {
  return p(Cantor { n in find({ a in p(a) })[n] })
}

func find(_ p: @escaping (Cantor) -> Bool) -> Cantor {
  return anySatisfy({ a in p(.zero + a) })
    ? .zero + find({ a in p(.zero + a )})
    : .one + find({ a in p(.one + a )})
}

func search(_ p: @escaping (Cantor) -> Bool) -> Cantor? {
  return anySatisfy({ a in p(a) })
    ? .some(find({ a in p(a) }))
    : nil
}

func + (
  bit: @escaping @autoclosure () -> Bit,
  cantor: @escaping @autoclosure () -> Cantor
  ) -> Cantor {

  return Cantor { n in
    n == 0
      ? bit()
      : cantor()[n - 1]
  }
}

func == <A: Equatable>(
  lhs: @escaping (Cantor) -> A,
  rhs: @escaping (Cantor) -> A
  ) -> Bool {

  return allSatisfy({ a in lhs(a) == rhs(a) })
}
func != <A: Equatable>(
  lhs: @escaping (Cantor) -> A,
  rhs: @escaping (Cantor) -> A
  ) -> Bool {

  return !(lhs == rhs)
}


let f: (Cantor) -> Int = { c in
  1
}
let g: (Cantor) -> Int = { c in
  2
}
let h: (Cantor) -> Int = { c in
  c.atIndex(0) == .one ? 1 : 1
}

func PGAssert(_ bool: Bool) -> String {
  return bool ? "✅" : "💔"
}


//PGAssert(f != g)
//PGAssert(f != h)
//PGAssert(f == f)
//PGAssert(g == g)
//PGAssert(h == h)

1
2

let p: (Cantor) -> Bool = { _ in false }
let tmp = find(p)

tmp.atIndex(1)

p(tmp)

//tmp.atIndex(2)
//tmp.atIndex(3)
//tmp.atIndex(4)
//tmp.atIndex(5)

