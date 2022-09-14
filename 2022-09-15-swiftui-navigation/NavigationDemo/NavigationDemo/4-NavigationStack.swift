import SwiftUI

enum NavigationStackDemo {
  enum Destination: Hashable {
    case screenA
    case screenB
    case screenC(destination: ScreenCDestination? = nil)
  }
  enum ScreenCDestination: Hashable {
    case sheet(popoverValue: Int? = nil)
  }

  class Model: ObservableObject {
    @Published var path: [Destination]
    init(path: [Destination] = []) {
      self.path = path
    }
  }

  struct ContentView: View {
    @ObservedObject var model: Model

    var body: some View {
      NavigationStack(path: self.$model.path) {
        List {
          NavigationLink(value: Destination.screenA) {
            Text("Screen A")
          }
          NavigationLink(value: Destination.screenB) {
            Text("Screen B")
          }
          NavigationLink(value: Destination.screenC()) {
            Text("Screen C")
          }
        }
        .navigationDestination(for: Destination.self) { destination in
          switch destination {
          case .screenA:
            ScreenA()
          case .screenB:
            ScreenB()
          case .screenC(destination: .none):
            ScreenC(model: .init())
          case .screenC(destination: .sheet(popoverValue: .none)):
            ScreenC(model: .init(sheet: .init()))
          case let .screenC(destination: .sheet(popoverValue: value)):
            ScreenC(model: .init(sheet: .init(popoverValue: value)))
          }
        }
        .navigationTitle("Root")
      }
      .onOpenURL { url in
        do {
          self.model.path = try Router().match(url: url)
        }
        catch {}
      }
    }
  }

  struct ScreenA: View {
    var body: some View {
      List {
        NavigationLink(value: Destination.screenA) {
          Text("Screen A")
        }
        NavigationLink(value: Destination.screenB) {
          Text("Screen B")
        }
        NavigationLink(value: Destination.screenC()) {
          Text("Screen C")
        }
      }
      .navigationTitle("Screen A")
    }
  }

  struct ScreenB: View {
    var body: some View {
      List {
        NavigationLink(value: Destination.screenA) {
          Text("Screen A")
        }
        NavigationLink(value: Destination.screenB) {
          Text("Screen B")
        }
        NavigationLink(value: Destination.screenC()) {
          Text("Screen C")
        }
      }
      .navigationTitle("Screen B")
    }
  }

  class ScreenCModel: ObservableObject {
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

  struct ScreenC: View {
    @ObservedObject var model: ScreenCModel

    var body: some View {
      List {
        NavigationLink(value: Destination.screenA) {
          Text("Screen A")
        }
        NavigationLink(value: Destination.screenB) {
          Text("Screen B")
        }
        NavigationLink(value: Destination.screenC()) {
          Text("Screen C")
        }

        Button("Sheet") {
          self.model.sheet = .init()
        }
        .sheet(item: self.$model.sheet) { sheetModel in
          SheetView(model: sheetModel)
        }
      }
      .buttonStyle(BorderlessButtonStyle())
      .navigationTitle("Screen C")
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

import URLRouting

extension NavigationStackDemo {
  struct Router: ParserPrinter {
    var body: some ParserPrinter<URLRequestData, [Destination]> {
      // screenA/screenB/screenA/screenB
      Many {
        ScreenRouter()
      }
    }
  }

  struct ScreenRouter: ParserPrinter {
    var body: some ParserPrinter<URLRequestData, Destination> {
      OneOf {
        // screenA
        Parse(.case(Destination.screenA)) {
          Path { "screenA" }
        }
        // screenB
        Parse(.case(Destination.screenB)) {
          Path { "screenB" }
        }
        // screenC/sheet-42
        Parse(.case(Destination.screenC(destination:))) {
          Path { "screenC" }
          Optionally { ScreenCRouter() }
        }
      }
    }
  }

  struct ScreenCRouter: ParserPrinter {
    var body: some ParserPrinter<URLRequestData, ScreenCDestination> {
      Parse(.case(ScreenCDestination.sheet(popoverValue:))) {
        Path {
          "sheet"
          Optionally { Int.parser() }
        }
      }
    }
  }
}
