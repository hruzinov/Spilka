//
//  Created by Evhen Gruzinov on 21.09.2023.
//

import SwiftUI
import FirebaseFirestore

extension MainView {
    class ViewModel: ObservableObject {
        @Published var isLoaded: Bool = false
        @Published var isLoggedIn: Bool?

        func startingUp(needCheck: Bool) {
            let accountUID = UserDefaults().string(forKey: "accountUID")
            if let accountUID, needCheck {
                let db = Firestore.firestore()
                let accountRef = db.collection("accounts").document(accountUID)

                accountRef.getDocument { user, error in
                    if let error {
                        print(error)
                    } else if let user, user.exists {
                        self.isLoggedIn = true
                    } else {
                        self.isLoggedIn = false
                    }
                }
            } else {
                isLoggedIn = false
            }
            isLoaded.toggle()
        }
    }
}
