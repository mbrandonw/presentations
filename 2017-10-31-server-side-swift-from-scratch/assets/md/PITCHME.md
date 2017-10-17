```swift
let router =
  Routes.iso.root
    <¢> end,

  Routes.iso.episodes
    <¢> lit("episodes") %> queryParam("order", opt(.order))
    <% end,

  Routes.iso.episode
    <¢> lit("episodes") %> param(.stringOrInt)
    <%> queryParam("ref", opt(.string))
    <% end
  ]
  .reduce(.empty, <|>)
```

@[1]
@[2]
@[3]
@[4]
