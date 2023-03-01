import FirebaseAnalytics
import FirebaseAuth
import FirebaseCore
import SwiftUI
import FirebaseDatabase

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      Button {
        let firebaseAuth = Auth.auth()
        Analytics.logEvent(AnalyticsEventShare, parameters: nil)

        let ref = Database.database().reference()
        // Listen for new messages in the Firebase database
        let _refHandle = ref.child("messages").observe(.childAdded, with: {  (snapshot) -> Void in
          //        guard let strongSelf = self else { return }
          //        strongSelf.messages.append(snapshot)
          //        strongSelf.clientTable.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
        })

      } label: {
        Text("?!?!?!")
      }
    }
    .padding()
    .onAppear {
      let firebaseAuth = Auth.auth()
      Analytics.logEvent(AnalyticsEventShare, parameters: nil)

      let ref = Database.database().reference()
      // Listen for new messages in the Firebase database
      let _refHandle = ref.child("messages").observe(.childAdded, with: {  (snapshot) -> Void in
//        guard let strongSelf = self else { return }
//        strongSelf.messages.append(snapshot)
//        strongSelf.clientTable.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
      })

    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
