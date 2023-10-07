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
            let keychain = KeychainSwift()
            keychain.synchronizable = true
            let accountUID = keychain.get("accountUID")

            if skipCheck {
                print("Check skipped")
                isLoggedIn = true
            } else if let accountUID {
                let dbase = Firestore.firestore()
                let accountRef = dbase.collection("accounts").document(accountUID)

                accountRef.getDocument { user, error in
                    if let error {
                        ErrorLog.save(error)
                    } else if let user, user.exists {
                        self.isLoggedIn = true
                    } else {
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
