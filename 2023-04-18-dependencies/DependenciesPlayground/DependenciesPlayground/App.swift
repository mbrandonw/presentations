import SwiftUI

@main
struct DependenciesPlaygroundApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        List {
          NavigationLink("Countdown demo") {
            CountdownView()
          }
          NavigationLink("Location demo") {
            LocationDemo(model: LocationDemoModel())
          }
          NavigationLink("Contacts demo") {
            ContactsDemo()
          }
        }
        .navigationTitle("Demos")
      }
    }
  }
}
