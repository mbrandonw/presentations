import Foundation





























struct Pair <A, B> {
  let fst: A
  let snd: B
}
































enum Optional <T> {
  case None
  case Some(T)
}



































enum Or <A, B> {
  case Left(A)
  case Right(B)
}































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

//func deMorgan <A, B> (f: Not<Or<A, B>>) -> And<Not<A>, Not<B>> {
//  ???
//}

//func deMorgan <A, B> (f: And<Not<A>, Not<B>>) -> Not<Or<A, B>> {
//  ???
//}



"success"

