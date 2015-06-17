import Foundation


struct Pair <A, B> {
  let fst: A
  let snd: B
}

let value: Pair<Int, String> = Pair<Int, String>(fst: 3, snd: "foo")
value.fst
value.snd


enum Optional <T> {
  case None
  case Some(T)
}

let three = Optional.Some(3)
let nothing = Optional<Int>.None


func f <A> (x: A) -> A {
  return x
}

func f <A, B> (x: A, y: B) -> A {
  return x
}

func f <A, B> (x: A, g: A -> B) -> B {
  return g(x)
}

func f <A, B, C> (g: A -> B, h: B -> C) -> A -> C {
  return { a in
    return h(g(a))
  }
}

enum Or <A, B> {
  case Left(A)
  case Right(B)
}

let z: Or<Int, String> = Or.Right("hi")

func f <A, B> (x: A) -> Or<A, B> {
  return Or.Left(x)
}

func f <A, B, C> (x: Or<A, B>, g: A -> C, h: B -> C) -> C {
  switch x {
  case let .Left(a):
    return g(a)
  case let .Right(b):
    return h(b)
  }
}

// Impossible
//func f <A, B> (x: A) -> B {
//  ???
//}

// Impossible
//func f <A, B, C> (g: A -> C, h: B -> C) -> C {
//  ???
//}

enum False {
}

struct Not <A> {
  let not: A -> False
  init (_ not: A -> False) {
    self.not = not
  }
}

struct And <A, B> {
  let Left: A
  let Right: B
  init (_ Left: A, _ Right: B) {
    self.Left = Left
    self.Right = Right
  }
}

func deMorgan <A, B> (f: Not<Or<A, B>>) -> And<Not<A>, Not<B>> {

  return And(
    Not { a in f.not(.Left(a)) },
    Not { b in f.not(.Right(b)) }
  )
}

func deMorgan <A, B> (f: And<Not<A>, Not<B>>) -> Not<Or<A, B>> {

  return Not { a_or_b in
    switch a_or_b {
    case let .Left(a):
      return f.Left.not(a)
    case let .Right(b):
      return f.Right.not(b)
    }
  }
}



"success"

