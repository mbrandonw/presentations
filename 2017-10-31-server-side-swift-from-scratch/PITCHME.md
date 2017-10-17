```swift
infix operator >>>
func >>> <A, B, C>(_ f: @escaping (A) -> B,
                   _ g: @escaping (B) -> C)
                   -> (A) -> C {
  return { g(f($0))}
}

let incr: (Int) -> Int = { $0 + 1 }
let square: (Int) -> Int = { $0 * $0 }

(incr >>> square >>> incr >>> String.init)(2) // => "10"
```

---
