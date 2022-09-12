import SwiftUI

@main
struct NavigationDemoApp: App {
  var body: some Scene {
    WindowGroup {
      SheetThenPopoverView.ParentView(
        model: SheetThenPopoverView.Model(
          child: .init(popoverValue: 42)
        )
      )
      
//      ScreenC()
    }
  }
}
