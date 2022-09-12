import SwiftUI

enum DrillDownThenSheetThenPopover {
  class Model: ObservableObject {
    @Published var child: ChildModel?
    init(child: ChildModel? = nil) {
      self.child = child
    }
  }

  class ChildModel: ObservableObject, Hashable {
    @Published var sheet: SheetModel?
    init(sheet: SheetModel? = nil) {
      self.sheet = sheet
    }
    func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(self))
    }
    static func == (lhs: ChildModel, rhs: ChildModel) -> Bool {
      lhs === rhs
    }
  }

  class SheetModel: Identifiable, ObservableObject {
    @Published var popoverValue: Int?
    init(popoverValue: Int? = nil) {
      self.popoverValue = popoverValue
    }
    var id: ObjectIdentifier {
      ObjectIdentifier(self)
    }
  }

  struct ContentView: View {
    @ObservedObject var model: Model

    var body: some View {
      NavigationLink(
        "Go to child feature",
        isActive: Binding(
          get: { self.model.child != nil },
          set: { isActive in
            self.model.child = isActive ? ChildModel() : nil
          }
        )
      ) {
        if let child = self.model.child {
          ChildView(child: child)
        }
      }
    }
  }

  struct ChildView: View {
    @ObservedObject var child: ChildModel

    var body: some View {
      Button("Show sheet") {
        self.child.sheet = SheetModel()
      }
      .sheet(item: self.$child.sheet) { sheetModel in
        SheetView(model: sheetModel)
      }
    }
  }

  struct SheetView: View {
    @ObservedObject var model: SheetModel

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
