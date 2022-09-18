import SwiftUI

@main
struct NavigationDemoApp: App {
  var body: some Scene {
    WindowGroup {
      // 1️⃣
//      SheetThenPopoverViewDemo.ContentView(
//        model: .init(sheet: .init(popoverValue: 42))
//      )

      // 2️⃣
//      NavigationView {
//        EmptyView()
//        DrillDownThenSheetThenPopoverDemo.ContentView(
//          model: .init(child: .init(sheet: .init(popoverValue: 42)))
//        )
//      }
//      .navigationViewStyle(.stack)

      // 3️⃣
//      NavigationView {
//        EmptyView()
//        NestedDrillDownDemo.ContentView(
//          model: .init(child: .init(child: .init(child: .init(child: .init()))))
//        )
//      }
//      .navigationViewStyle(.stack)

      // 4️⃣
      NavigationStackDemo.ContentView(
        model: .init()
      )
    }
  }
}
