import SwiftUI

struct CountdownDemo: View {
  @State var countdown = 10
  @State var isConfettiVisible = false

  var body: some View {
    ZStack {
      Text("\(self.countdown)")
        .font(.system(size: 200).bold())
      if self.isConfettiVisible {
        ForEach(1...100, id: \.self) { _ in
          ConfettiView()
            .offset(x: .random(in: -20...20), y: .random(in: -20...20))
        }
      }
    }
    .task {
      while true {
        if self.countdown == 0 {
          self.isConfettiVisible = true
          break
        }
        try? await Task.sleep(for: .seconds(1))
        self.countdown -= 1
      }
    }
  }
}

struct ContentDemo_Previews: PreviewProvider {
  static var previews: some View {
    CountdownDemo()
  }
}
