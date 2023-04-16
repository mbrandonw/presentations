import Dependencies
import SwiftUI

struct DependencyCountdownDemo: View {
  @State var countdown = 10
  @State var isConfettiVisible = false
  @Dependency(\.continuousClock) var clock

  var body: some View {
    ZStack {
      if self.isConfettiVisible {
        ForEach(1...100, id: \.self) { _ in
          ConfettiView()
            .offset(x: .random(in: -20...20), y: .random(in: -20...20))
        }
      }
      Text("\(self.countdown)")
        .font(.system(size: 200).bold())
    }
    .task {
      while true {
        if self.countdown == 0 {
          self.isConfettiVisible = true
          break
        }
        try? await self.clock.sleep(for: .seconds(1))
        self.countdown -= 1
      }
    }
  }
}

struct DependencyContentDemo_Previews: PreviewProvider {
  static var previews: some View {
    DependencyCountdownDemo()
      .previewDisplayName("Continuous clock")

    withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      DependencyCountdownDemo()
    }
    .previewDisplayName("Immediate clock")
  }
}
