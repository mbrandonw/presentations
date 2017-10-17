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

<span class="code-presenting-annotation fragment current-only" data-code-focus="1"></span>
<span class="code-presenting-annotation fragment current-only" data-code-focus="2"></span>
<span class="code-presenting-annotation fragment current-only" data-code-focus="3"></span>
<span class="code-presenting-annotation fragment current-only" data-code-focus="4"></span>

---