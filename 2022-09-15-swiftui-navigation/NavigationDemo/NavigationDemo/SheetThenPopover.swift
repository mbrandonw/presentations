import SwiftUI

private class Model: ObservableObject {
  @Published var child: ChildModel?
  init(child: ChildModel? = nil) {
    self.child = child
  }
}

private class ChildModel: Identifiable, ObservableObject {
  @Published var popoverIsPresented: Bool
  init(popoverIsPresented: Bool = false) {
    self.popoverIsPresented = popoverIsPresented
  }
  var id: ObjectIdentifier {
    ObjectIdentifier(self)
  }
}

struct SheetThenPopoverView: View {
  @StateObject private var model = Model(
    child: ChildModel(
      popoverIsPresented: true
    )
  )

  var body: some View {
    Button("Show sheet") {
      self.model.child = ChildModel()
    }
    .sheet(item: self.$model.child) { childModel in
      ChildView(model: childModel)
    }
  }
}

private struct ChildView: View {
  @ObservedObject var model: ChildModel

  var body: some View {
    Button("Show popover") {
      self.model.popoverIsPresented = true
    }
    .popover(isPresented: self.$model.popoverIsPresented) {
      Text("Hello from popover!")
        .frame(width: 200, height: 300)
    }
  }
}
