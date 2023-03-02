import Contacts

public func foo() {
  let store = CNContactStore()
  store.requestAccess(for: .contacts) { success, error in
    print(success)
    print(error)
    print("!!!")
  }
}

import SwiftUI

struct Preview_Previews: PreviewProvider {
  static var previews: some View {
    Button {
      foo()
    } label: {
      Text("Tap")
    }
  }
}
