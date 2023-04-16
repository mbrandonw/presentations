import Contacts
import Dependencies
import SwiftUI

struct DependencyContactsDemo: View {
  @Dependency(\.contactsClient) var contactsClient
  @State var users: [Contact] = []

  var body: some View {
    List {
      ForEach(self.users) { user in
        Text("\(user.givenName)")
      }
    }
    .navigationTitle(Text("Contacts"))
    .task {
      do {
        if await self.contactsClient.requestAccess() {
          self.users = try await self.contactsClient.unifiedContacts()
        }
      } catch {}
    }
  }
}

struct DependencyContactsDemo_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      DependencyContactsDemo()
    }
  }
}

extension DependencyValues {
  var contactsClient: any ContactsClient {
    get { self[ContactsClientKey.self] }
    set { self[ContactsClientKey.self] = newValue }
  }
}

private enum ContactsClientKey: DependencyKey {
  static let liveValue: any ContactsClient = LiveContactsClient()
  static let previewValue: any ContactsClient = MockContactsClient(
    contacts: (1...200).flatMap { _ in
      [
        Contact(givenName: "Blob"),
        Contact(givenName: "Blob Jr."),
        Contact(givenName: "Blob Sr."),
        Contact(givenName: "Blob Esq."),
      ]
    }
  )
}
