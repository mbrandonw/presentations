import Contacts
import SwiftUI

struct ContactsDemo: View {
  @State var users: [String] = []

  var body: some View {
    List {
      ForEach(self.users, id: \.self) { user in
        Text("\(user)")
      }
    }
    .navigationTitle(Text("Contacts"))
    .onAppear {
      let store = CNContactStore()
      store.requestAccess(for: .contacts) { success, error in
        guard success else { return }
        do {
          let contacts = try store.unifiedContacts(
            matching: NSPredicate(block: { _, _ in true }),
            keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor]
          )
          self.users = contacts.map(\.givenName)
        } catch {}
      }
    }
  }
}

struct ContactsDemo_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ContactsDemo()
    }
    NavigationStack {
      ContactsCore(users: ["Blob", "Blob Jr", "Blob Sr"])
    }
  }
}

struct ContactsCore: View {
  let users: [String]
  var body: some View {
    List {
      ForEach(self.users, id: \.self) { user in
        Text("\(user)")
      }
    }
  }
}
