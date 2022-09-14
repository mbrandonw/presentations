import SwiftUI

enum Playground {
  struct ContentView: View {
    @State private var customPreferenceKey: String = ""

    var body: some View {
      let _ = print(type(of: Text("").navigationDestination(for: Int.self) { _ in EmptyView() }))

      NavigationStack {
        VStack {
          NavigationLink(value: 42) { Text("Hi") }
            .frame(width: 200, height: 200)
            .preference(key: CustomPreferenceKey.self, value: "New value! 🤓")
        }

        List {
        }
        .navigationDestination(for: Int.self) { int in
          Text("\(int)")
        }
        .onPreferenceChange(CustomPreferenceKey.self) { value in
          customPreferenceKey = value
          print(#line, customPreferenceKey) // Prints: "New value! 🤓"
        }
      }
      .onPreferenceChange(CustomPreferenceKey.self) { value in
        customPreferenceKey = value
        print(#line, customPreferenceKey) // Prints: "New value! 🤓"
      }
    }
  }
}


struct CustomPreferenceKey: PreferenceKey {
  static var defaultValue: String = ""

  static func reduce(value: inout String, nextValue: () -> String) {
    print(#line, "reduce", value, ",", nextValue())
    value = nextValue()
  }
}
