import SwiftUI

enum NestedDrillDownDemo {
  class Model: ObservableObject {
    @Published var child: Model?
    init(child: Model? = nil) {
      self.child = child
    }
  }

  struct ContentView: View {
    @ObservedObject var model: Model

    var body: some View {
      // TODO: why can't i move NavigationView in here?
      NavigationLink(
        "Go to child feature",
        isActive: Binding(
          get: { self.model.child != nil },
          set: { isActive in
            self.model.child = isActive ? Model() : nil
          }
        )
      ) {
        if let child = self.model.child {
          ContentView(model: child)
        }
      }
    }
  }
}
