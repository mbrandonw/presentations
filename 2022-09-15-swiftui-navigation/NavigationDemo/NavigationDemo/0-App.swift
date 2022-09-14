import SwiftUI

@main
struct NavigationDemoApp: App {
  var body: some Scene {
    WindowGroup {
      // 1️⃣
      SheetThenPopoverViewDemo.ContentView(
        model: .init()
      )

      // 2️⃣
//      NavigationView {
//        EmptyView()
//        DrillDownThenSheetThenPopoverDemo.ContentView(
//          model: .init()
//        )
//      }
//      .navigationViewStyle(.stack)

      // 3️⃣
//      NavigationView {
//        EmptyView()
//        NestedDrillDownDemo.ContentView(
//          model: .init()
//        )
//      }
//      .navigationViewStyle(.stack)

      // 4️⃣
//      NavigationStackDemo.ContentView(
//        model: .init()
//      )
    }
  }
}
