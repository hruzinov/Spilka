//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import Foundation
import SwiftyRSA
import FirebaseFirestore
import FirebaseFirestoreSwift

extension ProfileCreationView {
    @MainActor class ViewModel: ObservableObject {
        @Published var cryptoKeys = CryptoKeys()
        @Published var userAccount: UserAccount?

        @Published var countryCode: String?
        @Published var phoneNumber: String?
        @Published var uid: String?
        @Published var profileName: String = ""
        @Published var profileDescription: String?
        @Published var profileUsername: String = ""
        @Published var isGoToMainView: Bool = false
        @Published var isRegisterButtonDisabled: Bool = true
        @Published var isWaitingServer: Bool = false

        func handleRegisterButton() {
            uid = UserDefaults().string(forKey: "accountUID")
            guard let uid = uid else { return }
            if let checkPhoneNumber = phoneNumber {
                phoneNumber = checkPhoneNumber.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
            }
            userAccount = UserAccount(
                uid: uid,
                name: profileName,
                countryCode: countryCode,
                phoneNumber: phoneNumber,
                profileImageID: nil, // TODO: Change when implement avatars
                username: profileUsername,
                description: profileDescription,
                publicKey: try! cryptoKeys.publicKey.base64String()
            )

            guard let userPrivateKeyBase64String = try? cryptoKeys.privateKey.base64String() else {
                return
            }

            UserDefaults.standard.set(userPrivateKeyBase64String, forKey: "userPrivateKey") // TODO: A temporary option for storing a private key. Transfer to Keychain in the future

            let db = Firestore.firestore()
            do {
                try db.collection("accounts").document(uid).setData(from: userAccount)
                let accountRef = db.collection("accounts").document(uid)

                accountRef.getDocument { user, error in
                    if let error {
                        print(error)
//                        self.showMessagePrompt(error.localizedDescription)
                    } else if let user, user.exists {
                        self.isGoToMainView.toggle()
                    }
                }
            } catch let error {
                print("ERROR with creating: \(error)")
//                self.showMessagePrompt(error.localizedDescription)
            }
        }
    }
}
