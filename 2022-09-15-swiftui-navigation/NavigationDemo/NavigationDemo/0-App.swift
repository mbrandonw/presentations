import SwiftUI

@main
struct NavigationDemoApp: App {
  var body: some Scene {
    WindowGroup {
//      SheetThenPopoverView.ContentView(
//        model: SheetThenPopoverView.Model(
//          sheet: .init(popoverValue: 42)
//        )
//      )
//
//      NavigationView {
//        EmptyView()
//
//        DrillDownThenSheetThenPopover.ContentView(
//          model: .init(
//            child: .init(
//              sheet: .init(popoverValue: 42)
//            )
//          )
//        )
//        .navigationViewStyle(.stack)
//      }

      NavigationView {
        EmptyView()

        NestedDrillDown.ContentView(
          model: .init(
            child: .init(child: .init(child: .init(child: .init())))
          )
        )
        .navigationViewStyle(.stack)
      }

//      ScreenC()
    }
  }
}
