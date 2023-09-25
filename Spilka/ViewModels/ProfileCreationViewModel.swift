//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import Foundation
import SwiftyRSA
import FirebaseFirestore
import FirebaseFirestoreSwift

extension ProfileCreationView {
    @MainActor class ViewModel: ObservableObject {
        @Published var cryptoKeys: CryptoKeys = CryptoKeys()
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
                phoneNumber = checkPhoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            }

            guard let publicKey = cryptoKeys.publicKey, let privateKey = cryptoKeys.privateKey,
                    let publicBase64String = try? publicKey.base64String() else { return }

            userAccount = UserAccount(
                uid: uid,
                name: profileName,
                countryCode: countryCode,
                phoneNumber: phoneNumber,
                profileImageID: nil, // TODO: Change when implement avatars
                username: profileUsername,
                description: profileDescription,
                publicKey: publicBase64String
            )

            guard let privateBase64String = try? privateKey.base64String() else {
                return
            }

            UserDefaults.standard.set(privateBase64String, forKey: "userPrivateKey")
            // TODO: A temporary option for storing a private key. Transfer to Keychain in the future

            let dbase = Firestore.firestore()
            do {
                try dbase.collection("accounts").document(uid).setData(from: userAccount)
                let accountRef = dbase.collection("accounts").document(uid)

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
