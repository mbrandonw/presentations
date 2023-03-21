import SwiftUI

@main
struct DependenciesPlaygroundApp: App {
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

struct AppView: View {
  var body: some View {
    NavigationStack {
      List {
        Section {
          NavigationLink("Countdown demo") {
            CountdownDemo()
          }
          NavigationLink("Location demo") {
            LocationDemo(model: LocationDemoModel())
          }
          NavigationLink("Contacts demo") {
            ContactsDemo()
          }
          NavigationLink("Analytics demo") {
            AnalyticsDemo(model: AnalyticsDemoModel())
          }
        } header: {
          Text("Uncontrolled dependencies")
        }

        // Spacer
        ForEach(0...10, id: \.self) { _ in
          Section { } header: { Text("") }
        }

        Section {
          NavigationLink("Countdown demo") {
            ControlledCountdownDemo()
          }
          NavigationLink("Location demo") {
            ControlledLocationDemo(model: ControlledLocationDemoModel())
          }
          NavigationLink("Contacts demo") {
            ControlledContactsDemo()
          }
          NavigationLink("Analytics demo") {
            ControlledAnalyticsDemo(model: ControlledAnalyticsDemoModel())
          }
        } header: {
          Text("Controlled dependencies")
        }

        // Spacer
        ForEach(0...10, id: \.self) { _ in
          Section { } header: { Text("") }
        }

        Section {
          NavigationLink("Countdown demo") {
          }
          NavigationLink("Location & Analytics demo") {
          }
          NavigationLink("Contacts demo") {
          }
        } header: {
          Text("@Dependency")
        }

        // Spacer
        ForEach(0...3, id: \.self) { _ in
          Section { } header: { Text("") }
        }
      }
      .navigationTitle("Demos")
    }
  }
}

struct App_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}
