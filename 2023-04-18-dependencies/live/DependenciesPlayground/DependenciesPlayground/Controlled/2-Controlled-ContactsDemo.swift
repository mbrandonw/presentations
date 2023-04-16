import Contacts
import SwiftUI

struct ControlledContactsDemo: View {
  @State var users: [Contact] = []
  let contactsClient: any ContactsClient

  init(contacts: any ContactsClient = LiveContactsClient()) {
    self.contactsClient = contacts
  }

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

struct ControlledContactsDemo_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ControlledContactsDemo(
        contacts: MockContactsClient(
          contacts: (1...100).flatMap { _ in
            [
              Contact(givenName: "Blob"),
              Contact(givenName: "Blob Jr."),
              Contact(givenName: "Blob Sr."),
              Contact(givenName: "Blob Esq."),
            ]
          }
        )
      )
    }
  }
}

protocol ContactsClient {
  func requestAccess() async -> Bool
  func unifiedContacts() async throws -> [Contact]
}

struct LiveContactsClient: ContactsClient {
  let store = CNContactStore()

  func requestAccess() async -> Bool {
    await withUnsafeContinuation { continuation in
      self.store.requestAccess(for: .contacts) { success, error in
        continuation.resume(returning: success)
      }
    }
  }

  func unifiedContacts() async throws -> [Contact] {
    try self.store.unifiedContacts(
      matching: NSPredicate(value: true),
      keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor]
    )
    .map(Contact.init(contact:))
  }
}

struct Contact: Identifiable {
  let id: String
  let givenName: String
  init(givenName: String) {
    self.id = UUID().uuidString
    self.givenName = givenName
  }
  init(contact: CNContact) {
    self.id = contact.identifier
    self.givenName = contact.givenName
  }
}

struct MockContactsClient: ContactsClient {
  let contacts: [Contact]

  func requestAccess() async -> Bool {
    true
  }

  func unifiedContacts() async throws -> [Contact] {
    self.contacts
  }
}
