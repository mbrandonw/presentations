
import Foundation


// # METHODS ARE NOT COMPOSABLE

// here are some samples:
/* 👍👍👍👍👍👍👍👍👍 */
extension Int {
  func square () -> Int {
    return self * self
  }
  func incr () -> Int {
    return self + 1
  }
}

// then we can do stuff like this
3.square().incr()

// but `square` and `incr` are intimately
// tied to instances of `Int` now. It's not
// easy to just consider just the simple
// `square: Int -> Int` function on its own.
// Best we can do is:
Int.square(3)() // <-- need to do that nasty invoke ()

// which means this isn't possible:
let xs = Array(1...100)
map(xs, Int.square) // ????

// what if instead we just had standalone functions
/* 👍👍👍👍👍👍👍👍👍 */
func square (x: Int) -> Int {
  return x * x
}
func incr (x: Int) -> Int {
  return x + 1
}

// now we can easily do
map(xs, square)


// # PROMOTING COMPOSITION

// swift gives us the tools to even promote 
// composition in ways that the language
// doesn't natively give us.

// here are some useful combinators

/* 👍👍👍👍👍👍👍👍👍 */
infix operator |> {associativity left}
func |> <A, B> (x: A, f: A -> B) -> B {
//  let b = B() //????
  return f(x)
}

3 |> square

/* 👍👍👍👍👍👍👍👍👍 */
func |> <A, B, C> (f: A -> B, g: B -> C) -> (A -> C) {
  return { a in
//    let c = C() //????
    return g(f(a))
  }
}

3 |> square |> incr
3 |> (square |> incr)
3.0 |> sqrt |> cos |> exp


// # CURRIED FUNCTIONS

// std lib map:
//map(<#source: C#>, <#transform: (C.Generator.Element) -> T##(C.Generator.Element) -> T#>) -> [T]

// this is not curried, and even the order of 
// params is wrong. this is way better
func map <A, B> (f: A -> B) -> ([A] -> [B]) {
  return { xs in
    return map(xs, f)
  }
}

map(square)(xs)
xs |> map(square)
xs |> map(square) |> map(incr)
xs |> map(square |> incr)

// the first one iterates over xs TWICE,
// and the second just once.
// this comes up a lot with FP, accidentally
// traversing structures more than once
// when not necessary, and along the way
// creating multiple copies of data.

// std lib filter
//filter(<#source: S#>, <#includeElement: (S.Generator.Element) -> Bool##(S.Generator.Element) -> Bool#>) -> [T]
func filter <A> (p: A -> Bool) -> ([A] -> [A]) {
  return { xs in
    return filter(xs, p)
  }
}

/* 👍👍👍👍👍👍👍👍👍 */
func isPrime (p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}

xs |> map(square |> incr) |> filter(isPrime)
// ^ iterating twice!





// =================================================
// =================================================
// =================================================
// =================================================
// =================================================

/* 👍👍👍👍👍👍👍👍👍 */
func map_from_reduce <A, B> (f: A -> B) -> [A] -> [B] {
  return { xs in
    return reduce(xs, [], { accum, x in
      return accum + [f(x)]
    })
  }
}
func filter_from_reduce <A> (p: A -> Bool) -> [A] -> [A] {
  return { xs in
    return reduce(xs, [], { accum, x in
      return p(x) ? accum + [x] : accum
    })
  }
}




// =================================================
// =================================================
// =================================================
// =================================================
// =================================================



/* 👍👍👍👍👍👍👍👍👍 */
func squaringTransducer <C> (reducer: (C, Int) -> C) -> ((C, Int) -> C) {
  return { accum, x in
    return reducer(accum, x * x)
  }
}

reduce(xs, 0, +)
reduce(xs, 0, squaringTransducer(+))





// =================================================
// =================================================
// =================================================
// =================================================
// =================================================




/* 👍👍👍👍👍👍👍👍👍 */
func mapping <A, B, C> (f: A -> B) -> (((C, B) -> C) -> ((C, A) -> C)) {
  return { reducer in
    return { accum, a in
      return reducer(accum, f(a))
    }
  }
}

func filtering <A, C> (p: A -> Bool) -> ((C, A) -> C) -> (C, A) -> C {
  return { reducer in
    return { accum, x in
      return p(x) ? reducer(accum, x) : accum
    }
  }
}


// =================================================
// =================================================
// =================================================
// =================================================
// =================================================


/* 👍👍👍👍👍👍👍👍👍 */
func append <A> (xs: [A], x: A) -> [A] {
  return xs + [x]
}

reduce(xs, [], append
  |> filtering(isPrime)
  |> mapping(incr)
  |> mapping(square)
)

reduce(xs, 0, (+)
  |> filtering(isPrime)
  |> mapping(incr)
  |> mapping(square)
)

























