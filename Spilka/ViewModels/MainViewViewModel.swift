//
//  Created by Evhen Gruzinov on 21.09.2023.
//

import SwiftUI
import FirebaseFirestore

extension MainView {
    class ViewModel: ObservableObject {
        @Published var isLoaded: Bool = false
        @Published var isLoggedIn: Bool?

        func startingUp(skipCheck: Bool) {
            let accountUID = UserDefaults().string(forKey: "accountUID")
            if skipCheck {
                print("Check skipped")
                isLoggedIn = true
            } else if let accountUID {
                let dbase = Firestore.firestore()
                let accountRef = dbase.collection("accounts").document(accountUID)

                accountRef.getDocument { user, error in
                    if let error {
                        print(error)
                    } else if let user, user.exists {
                        print("User exist")
                        self.isLoggedIn = true
                    } else {
                        print("User not exist")
                        self.isLoggedIn = false
                    }
                }
            } else {
                isLoggedIn = false
            }
            isLoaded = true
        }
    }
}
