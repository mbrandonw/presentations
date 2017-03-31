## Accessibility in iOS

---

## VoiceOver

^ apple's technology for screen reading

---

## VoiceOver
### Demo

---

```swift
extension NSObject {
  public var isAccessibilityElement: Bool
  public var accessibilityLabel: String?
  public var accessibilityHint: String?
  public var accessibilityValue: String?
  public var accessibilityTraits: UIAccessibilityTraits
  public var accessibilityFrame: CGRect
  public var accessibilityPath: UIBezierPath?
  public var accessibilityActivationPoint: CGPoint
  public var accessibilityLanguage: String?
  public var accessibilityElementsHidden: Bool
  public var accessibilityViewIsModal: Bool
  public var shouldGroupAccessibilityChildren: Bool
  public var accessibilityNavigationStyle: UIAccessibilityNavigationStyle
}
```

^ baseline of a11y API's

---

```swift
// UIAccessibilityContainer
extension NSObject {
  public func accessibilityElementCount() -> Int
  public func accessibilityElementAtIndex(index: Int) -> AnyObject?
  public func indexOfAccessibilityElement(element: AnyObject) -> Int
  public var accessibilityElements: [AnyObject]?
}
```

^ API's for describing your own containers of a11y elements

---

```swift
// UIAccessibilityFocus
extension NSObject {
  public func accessibilityElementDidBecomeFocused()
  public func accessibilityElementDidLoseFocus()
  public func accessibilityElementIsFocused() -> Bool
  public func accessibilityAssistiveTechnologyFocusedIdentifiers() -> Set<String>?
}
```

^ API's for being notified when focus changes on elements

---

```swift
// UIAccessibilityAction
extension NSObject {
  public func accessibilityActivate() -> Bool
  public func accessibilityIncrement()
  public func accessibilityDecrement()
  public func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool
  public func accessibilityPerformEscape() -> Bool
  public func accessibilityPerformMagicTap() -> Bool
  public var accessibilityCustomActions: [UIAccessibilityCustomAction]?
}
```

^ API's performing actions when an a11y element is invoked

---

```swift
// UIAccessibilityReadingContent
public protocol UIAccessibilityReadingContent {
  public func accessibilityLineNumberForPoint(point: CGPoint) -> Int
  public func accessibilityContentForLineNumber(lineNumber: Int) -> String?
  public func accessibilityFrameForLineNumber(lineNumber: Int) -> CGRect
  public func accessibilityPageContent() -> String?
}
```

^ API's for being notified when focus changes on elements

^ The designers of these API's would have you believe that it is easy to just plunk right down into a view or controller, set these attributes and away you go.

^ They provide no support for composability, reuse or testing.

^ They provide no guidance of how to use these API's at scale, and how not to hate your decisions one year from now when you come back to your view and see these random attributes littered about.

^ As a native squad we are commonly faced with problems like these. This leads me to something a colleague once told me...

---

> Code to the interface you wish you had, not the interface you were given. - Stephen Celis*

^ How do we decide what the interface is that we wish we had. We could certainly just sketch out some API's that look nice to us. The resulting API is gonna have the fingerprints of whoever wrote it. It will be a confluence of all the past languages they've worked in, and a grab-bag of little ideas that at one time they thought were interesting.

^ In looking for that answer I was naturally led to quote I remembered from my time in mathematics

---

> God made the integers, all else is the work of man. - Leopold Kronecker

^ Kronecker was a harsh critic of the type of mathematics happening in the late 1800's. At that time many amazing things were being proven, but many of the proofs were non-constructive. For example, they could prove that something exists without actually constructing the thing, and instead proving that if it did not exist there would be some logical fallacy one could derive.

^ Kronecker's philosophy for mathematics didn't really take hold, but in the last 50 years or so he has been proven right, in that all of type theory and theory of languages is completely based on the constructive/intuitionistic view of mathematics.

^ This quote is important in how we think about our work because it tells us to identify the most fundamental units to work with, and build from there.

---

## Functions

^ For us on the native squad, it's functions. If it's not a function, we're not interested in it. I've never met a function I didn't like.

^ You can talk about....

---

## Single Responsibility Principle

---

## Open-Closed Principle

---

## Liskov Substitution Principle

---

## Interface Separation

---

## Dependency Inversion

---

## S.O.L.I.D.

* **S**ingle Responsibility Principle
* **O**pen-Closed Principle
* **L**iskov Substitution Principle
* **I**nterface Separation
* **D**ependency Inversion

^ ...until you are blue in the face, but none of that is applicable when it comes to functions.

^ every pure function has a single responsibility: it takes some inputs and returns some outputs

^ every function is open-closed for if you want to extend a function you simply compose, and any one can use a function! no rules about that!

^ liskov? the world of subtyping in functions is far more beautiful than in objects

^ interface separation? there only one interface!

^ dependency inversion? this is the idea that you dont want disparate objects to become coupled in strange ways. just give the function what it wants and you'll get something back. no fuss!

---

## Functions

^ A function does one single thing, it fully specifies what it needs to get that thing done, it does it, and it returns the result. It's all testable, understandable, composable and beautiful.

^ We have completely architected our native apps around this one idea only.

^ And because we embrace this fundamental unit of computation so wholly, we are always as close to the metal as possible without interacting directly with the metal. We have no abstraction layers between us and the a11y API's that Apple gives us.

---

> Code to the interface you wish you had, not the interface you were given. - Stephen Celis*

---

## What does this look like in practice?

---

## 1) Static accessibility attributes

^ take for example some of the a11y attributes i showed earlier

^ let's only consider the static, i.e set-it-and-forget-it, attributes

^ these attributes aren't dissimilar to stylings

^ we use something called lenses for stylings

---

```swift
public func sortButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort) -> (B -> B) {

}

```

---

```swift
public func sortButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort) -> (B -> B) {

  let sortString = string(forSort: sort)

  return B.lens.titleText(forState: .Normal) %~ { _ in
    switch sort {
    case .EndingSoon: return Strings.discovery_sort_types_end_date()
    case .Magic:      return Strings.discovery_sort_types_magic()
    case .MostFunded: return Strings.discovery_sort_types_most_funded()
    case .Newest:     return Strings.discovery_sort_types_newest()
    case .Popular:    return Strings.discovery_sort_types_popularity()
    }
  }
}

```

---

```swift
public func sortButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort) -> (B -> B) {

  return B.lens.titleText(forState: .Normal) .~ string(forSort: sort)
}

private func string(forSort sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .EndingSoon: return Strings.discovery_sort_types_end_date()
  case .Magic:      return Strings.discovery_sort_types_magic()
  case .MostFunded: return Strings.discovery_sort_types_most_funded()
  case .Newest:     return Strings.discovery_sort_types_newest()
  case .Popular:    return Strings.discovery_sort_types_popularity()
  }
}
```

---

```swift
public func sortButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort) -> (B -> B) {

  return B.lens.titleText(forState: .Normal) .~ string(forSort: sort)
    <> B.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
    <> B.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
}

private func string(forSort sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .EndingSoon: return Strings.discovery_sort_types_end_date()
  case .Magic:      return Strings.discovery_sort_types_magic()
  case .MostFunded: return Strings.discovery_sort_types_most_funded()
  case .Newest:     return Strings.discovery_sort_types_newest()
  case .Popular:    return Strings.discovery_sort_types_popularity()
  }
}
```

---

```swift
public func sortButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort) -> (B -> B) {

  return B.lens.titleText(forState: .Normal) .~ string(forSort: sort)
    <> B.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
    <> B.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
    <> B.lens.titleLabel.font .~ .ksr_subhead()
    <> B.lens.contentEdgeInsets .~ .init(topBottom: 0.0, leftRight: 16.0)
}

private func string(forSort sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .EndingSoon: return Strings.discovery_sort_types_end_date()
  case .Magic:      return Strings.discovery_sort_types_magic()
  case .MostFunded: return Strings.discovery_sort_types_most_funded()
  case .Newest:     return Strings.discovery_sort_types_newest()
  case .Popular:    return Strings.discovery_sort_types_popularity()
  }
}
```

---

```swift
public func sortButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort) -> (B -> B) {

  let sortString = string(forSort: sort)

  return B.lens.titleText(forState: .Normal) .~ sortString
    <> B.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
    <> B.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
    <> B.lens.titleLabel.font .~ .ksr_subhead()
    <> B.lens.contentEdgeInsets .~ .init(topBottom: 0.0, leftRight: 16.0)
    <> B.lens.accessibilityLabel .~ "Sort by \(sortString)"
    <> B.lens.accessibilityHint .~ "Changes sort"
}

private func string(forSort sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .EndingSoon: return Strings.discovery_sort_types_end_date()
  case .Magic:      return Strings.discovery_sort_types_magic()
  case .MostFunded: return Strings.discovery_sort_types_most_funded()
  case .Newest:     return Strings.discovery_sort_types_newest()
  case .Popular:    return Strings.discovery_sort_types_popularity()
  }
}
```

---

```swift
self.popularSortButton
  |> sortButtonStyle(sort: .Popular)
```

---

```swift
// swiftlint:disable type_name
import Prelude
import UIKit

// UIAccessibility
public extension LensHolder where Object: KSObjectProtocol {
  public var isAccessibilityElement: Lens<Object, Bool> {
    return Lens(
      view: { $0.isAccessibilityElement },
      set: { $1.isAccessibilityElement = $0; return $1 }
    )
  }

  public var accessibilityElementsHidden: Lens<Object, Bool> {
    return Lens(
      view: { $0.accessibilityElementsHidden },
      set: { $1.accessibilityElementsHidden = $0; return $1 }
    )
  }

  public var accessibilityHint: Lens<Object, String?> {
    return Lens(
      view: { $0.accessibilityHint },
      set: { $1.accessibilityHint = $0; return $1 }
    )
  }

  public var accessibilityLabel: Lens<Object, String?> {
    return Lens(
      view: { $0.accessibilityLabel },
      set: { $1.accessibilityLabel = $0; return $1 }
    )
  }

  public var accessibilityTraits: Lens<Object, UIAccessibilityTraits> {
    return Lens(
      view: { $0.accessibilityTraits },
      set: { $1.accessibilityTraits = $0; return $1 }
    )
  }

  public var accessibilityValue: Lens<Object, String?> {
    return Lens(
      view: { $0.accessibilityValue },
      set: { $1.accessibilityValue = $0; return $1 }
    )
  }

  public var shouldGroupAccessibilityChildren: Lens<Object, Bool> {
    return Lens(
      view: { $0.shouldGroupAccessibilityChildren },
      set: { $1.shouldGroupAccessibilityChildren = $0; return $1 }
    )
  }

  public var accessibilityNavigationStyle: Lens<Object, UIAccessibilityNavigationStyle> {
    return Lens(
      view: { $0.accessibilityNavigationStyle },
      set: { $1.accessibilityNavigationStyle = $0; return $1 }
    )
  }
}

// UIAccessibilityContainer
public extension LensHolder where Object: NSObject {
  public var accessibilityElements: Lens<Object, [AnyObject]?> {
    return Lens(
      view: { $0.accessibilityElements },
      set: { $1.accessibilityElements = $0; return $1 }
    )
  }
}
```

---

> Code to the interface you wish you had, not the interface you were given. - Stephen Celis*

---

## 2) Dynamic accessibility attributes

---

```swift
// DiscoveryProjectCellViewModel.swift

public protocol DiscoveryProjectViewModelOutputs {
  var cellAccessibilityLabel: Signal<String, NoError> { get }
  var cellAccessibilityValue: Signal<String, NoError> { get }

  // ... other outputs ...
}
```

---

```swift
self.cellAccessibilityLabel = project.map { $0.name }
self.cellAccessibilityValue = project.map { $0.blurb }
```

---

```swift
// DiscoveryProjectCell.swift

override func bindViewModel() {
  self.viewModel.outputs.cellAccessibilityLabel
    .observeForUI()
    .observeNext { [weak self] in self?.accessibilityLabel = $0 }

  self.viewModel.outputs.cellAccessibilityValue
    .observeForUI()
    .observeNext { [weak self] in self?.accessibilityValue = $0 }
}
```

---

```swift
// DiscoveryProjectCell.swift

override func bindViewModel() {
  self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
  self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
}
```

^ this is completely testable!

---

```swift
import ReactiveCocoa
import Result
import UIKit

private enum Associations {
  private static var accessibilityElementsHidden = 0
  private static var accessibilityHint = 1
  private static var accessibilityLabel = 2
  private static var accessibilityValue = 3
  private static var isAccessibilityElement = 4
}

public extension Rac where Object: NSObject {
  public var accessibilityElementsHidden: Signal<Bool, NoError> {
    nonmutating set {
      let prop: MutableProperty<Bool> = lazyMutableProperty(
        object,
        key: &Associations.accessibilityElementsHidden,
        setter: { [weak object] in object?.accessibilityElementsHidden = $0 },
        getter: { [weak object] in object?.accessibilityElementsHidden ?? false })

      prop <~ newValue.observeForUI()
    }

    get {
      return .empty
    }
  }

  public var accessibilityHint: Signal<String, NoError> {
    nonmutating set {
      let prop: MutableProperty<String> = lazyMutableProperty(
        object,
        key: &Associations.accessibilityHint,
        setter: { [weak object] in object?.accessibilityHint = $0 },
        getter: { [weak object] in object?.accessibilityHint ?? "" })

      prop <~ newValue.observeForUI()
    }

    get {
      return .empty
    }
  }

  public var accessibilityLabel: Signal<String, NoError> {
    nonmutating set {
      let prop: MutableProperty<String> = lazyMutableProperty(
        object,
        key: &Associations.accessibilityLabel,
        setter: { [weak object] in object?.accessibilityLabel = $0 },
        getter: { [weak object] in object?.accessibilityLabel ?? "" })

      prop <~ newValue.observeForUI()
    }

    get {
      return .empty
    }
  }

  public var accessibilityValue: Signal<String, NoError> {
    nonmutating set {
      let prop: MutableProperty<String> = lazyMutableProperty(
        object,
        key: &Associations.accessibilityValue,
        setter: { [weak object] in object?.accessibilityValue = $0 },
        getter: { [weak object] in object?.accessibilityValue ?? "" })

      prop <~ newValue.observeForUI()
    }

    get {
      return .empty
    }
  }

  public var isAccessibilityElement: Signal<Bool, NoError> {
    nonmutating set {
      let prop: MutableProperty<Bool> = lazyMutableProperty(
        object,
        key: &Associations.isAccessibilityElement,
        setter: { [weak object] in object?.isAccessibilityElement = $0 },
        getter: { [weak object] in object?.isAccessibilityElement ?? false })

      prop <~ newValue.observeForUI()
    }

    get {
      return .empty
    }
  }
}
```

---

> Code to the interface you wish you had, not the interface you were given. - Stephen Celis*

---

## 3) Reactive Accessibility
### Demo

^ how do we use the ideas of reactive programming to control the flow of accessibility through an app.

^ FRP has excelled in wrangling in multiple sources of truth into one source of truth

^ when i first introduced FRP to eng 1.5 yrs ago i used the example of scrolling a page to change the background color. there was a subtle bug in which changing the screen size caused the color to not update. this simply pointed out that the truth we were seeking was not only in the scroll position but also the screen size, and so all we had to do was merge those two truths.

^ a11y support is simply a new thing to derive from truth

^ sometimes it simply points to the fact that we haven't fully capture what the truth of the application is

---
