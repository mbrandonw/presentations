import SwiftUI

enum DrillDownThenSheetThenPopover {
  class Model: ObservableObject {
    @Published var child: ChildModel?
    init(child: ChildModel? = nil) {
      self.child = child
    }
  }

  class ChildModel: Identifiable, ObservableObject {
    @Published var popoverValue: Int?
    init(popoverValue: Int? = nil) {
      self.popoverValue = popoverValue
    }
    var id: ObjectIdentifier {
      ObjectIdentifier(self)
    }
  }

  struct ParentView: View {
    @ObservedObject var model: Model

    var body: some View {
      Button("Show sheet") {
        self.model.child = ChildModel()
      }
      .sheet(item: self.$model.child) { childModel in
        ChildView(model: childModel)
      }
    }
  }

  struct ChildView: View {
    @ObservedObject var model: ChildModel

    var body: some View {
      Button("Show popover") {
        self.model.popoverValue = .random(in: 1...1_000)
      }
      .popover(item: self.$model.popoverValue) { value in
        PopoverView(count: value)
          .frame(width: 200, height: 300)
      }
    }
  }

  struct PopoverView: View {
    @State var count: Int
    var body: some View {
      HStack {
        Button("-") { self.count -= 1 }
        Text("\(self.count)")
        Button("+") { self.count += 1 }
      }
    }
  }
}
