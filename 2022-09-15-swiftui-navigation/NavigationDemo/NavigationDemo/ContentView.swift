import SwiftUI

enum Route: Hashable, Codable {
  case a(id: Int)
  case b
  case c(showModal: Bool = false)
}

// /a/12/b/13/c/14?modal=true

struct ContentView: View {
  @State var path: [Route] = []
//  @State var path = NavigationPath(
//    [
//      Route.a(id: 20),
//      Route.b,
//      Route.c(showModal: true),
//    ]
//  )

  var body: some View {
    NavigationStack(path: self.$path) {
      NavigationLink("Go to screen A", value: Route.a(id: 10))
        .navigationDestination(for: Route.self) { route in
          switch route {
          case let .a(id: count):
            ScreenA(count: count)
          case .b:
            ScreenB()
          case let .c(showModal: showModal):
            ScreenC(showModal: showModal)
          }
        }
//        .sheet(item: <#T##Binding<Identifiable?>#>, content: <#T##(Identifiable) -> View#>)
        .onChange(of: self.path) { path in
          do {
            let data = try JSONEncoder().encode(
              path//.codable
            )
            try data.write(
              to: URL(filePath: NSTemporaryDirectory())
                .appendingPathComponent("path", conformingTo: .data)
            )
          } catch {
            print("!!!!")
          }
        }
        .onAppear {
          do {
            let data = try Data(
              contentsOf: URL(filePath: NSTemporaryDirectory())
                .appendingPathComponent("path", conformingTo: .data)
            )
            self.path = try
            //NavigationPath(
              JSONDecoder().decode([Route].self, from: data)
//            )
          } catch {
            print(error)
            print("!!!")
          }
        }
    }
  }
}

class ScreenAModel: ObservableObject {
  @Published var count = 0
  init(count: Int = 0) {
    self.count = count
  }
}
struct ScreenA: View {
  @StateObject var model = ScreenAModel()
  init(count: Int) {
    //self.model.count = count // Doesn't work
    self._model = .init(wrappedValue: .init(count: count))
  }
  var body: some View {
    Text("Screen A")
//    VStack {
//      HStack {
//        Button("-") { self.model.count -= 1 }
//        Text("\(self.model.count)")
//        Button("+") { self.model.count += 1 }
//      }
//    }
//    NavigationLink("Go to screen B", value: Route.b)
  }
}

class ScreenBModel: ObservableObject {}
struct ScreenB: View {
  @StateObject var model = ScreenBModel()
  var body: some View {
    NavigationLink("Go to screen C", value: Route.c())
  }
}

class ScreenCModel: ObservableObject {
  @Published var showModal = false
  init(showModal: Bool = false) {
    self.showModal = showModal
  }
}
struct ScreenC: View {
  @StateObject var model = ScreenCModel()
  init(showModal: Bool = false) {
    self._model = .init(wrappedValue: .init(showModal: showModal))
  }
  var body: some View {
    VStack {
      Text("Hello!")
      Button("Show popover") { self.model.showModal.toggle() }
    }
      .popover(isPresented: self.$model.showModal) {
        Text("Hello from popover!")
          .frame(width: 200, height: 300)
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
