//
//  Testing view for adding and testing new features
//
//  Created by Evhen Gruzinov on 21.09.2023.
//

import SwiftUI
import FirebaseFirestore

struct TestingView: View {
    var body: some View {
        Text("This is TestingView")
            .onAppear {
                getAccountFromFB()
            }
    }

    func getAccountFromFB() {
        let db = Firestore.firestore()
        let accountRef = db.collection("accounts").document("testUserAccount")

        accountRef.getDocument { user, error in
            if let error {
                print(error)
            } else if let user, user.exists {
                print("User Exist")
            } else {
                print("User Not Exist")
            }
        }
    }
}

#Preview {
    TestingView()
}
