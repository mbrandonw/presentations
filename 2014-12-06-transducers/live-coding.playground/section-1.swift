import Foundation

extension Int {
  func square () -> Int {
    return self * self
  }
  func incr () -> Int {
    return self + 1
  }
}



3.square().incr()
let xs = Array(1...100)

map(xs, Int.square)

func square (x: Int) -> Int {
  return x * x
}
func incr (x: Int) -> Int {
  return x + 1
}

map(xs, square)

infix operator |> {associativity left}
func |> <A, B> (x: A, f: A -> B) -> B {
  return f(x)
}


func |> <A, B, C> (f: A -> B, g: B -> C) -> (A -> C) {
  return { a in
    return g(f(a))
  }
}

3 |> square |> incr
3 |> (square |> incr)


//map(<#source: C#>, <#transform: (C.Generator.Element) -> T##(C.Generator.Element) -> T#>)

func map <A, B> (f: A -> B) -> [A] -> [B] {
  return { xs in
    return map(xs, f)
  }
}

xs |> map(square) |> map(incr)
xs |> map(square |> incr)

//filter(<#source: S#>, <#includeElement: (S.Generator.Element) -> Bool##(S.Generator.Element) -> Bool#>)

func filter <A> (p: A -> Bool) -> [A] -> [A] {
  return { xs in
    return filter(xs, p)
  }
}

func isPrime (p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}

xs |> map(square |> incr) |> filter(isPrime)


func map_from_reduce <A, B> (f: A -> B) -> [A] -> [B] {
  return { xs in
    return reduce(xs, []) { accum, x in
      return accum + [f(x)]
    }
  }
}

func filter_from_reduce <A> (p: A -> Bool) -> [A] -> [A] {
  return { xs in
    return reduce(xs, []) { accum, x in
      return p(x) ? accum + [x] : accum
    }
  }
}

func take_from_reduce <A> (n: Int) -> [A] -> [A] {
  return { xs in
    return reduce(xs, []) { accum, x in
      return accum.count < n ? accum + [x] : accum
    }
  }
}

func flatten_from_reduce <A> (xss: [[A]]) -> [A] {
  return reduce(xss, []) { accum, xs in
    return accum + xs
  }
}




func squaringTransducer <C> (reducer: (C, Int) -> C) -> ((C, Int) -> C) {
  return { accum, x in
    return reducer(accum, x * x)
  }
}

reduce(xs, 0, +)
reduce(xs, 0, squaringTransducer(+))

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
func append <A> (xs: [A], x: A) -> [A] {
  return xs + [x]
}

let masterReducer = append |> filtering(isPrime) |> mapping(incr) |> mapping(square)
reduce(xs, [], masterReducer)
reduce(xs, 0, (+) |> filtering(isPrime) |> mapping(incr) |> mapping(square))























"done"













