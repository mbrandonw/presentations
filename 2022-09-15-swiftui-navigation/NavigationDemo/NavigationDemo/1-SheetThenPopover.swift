import SwiftUI

enum SheetThenPopoverViewDemo {
  class Model: ObservableObject {
    @Published var sheet: SheetModel?
    init(sheet: SheetModel? = nil) {
      self.sheet = sheet
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
      Button("Show sheet") {
        self.model.sheet = SheetModel()
      }
      .sheet(item: self.$model.sheet) { sheetModel in
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
