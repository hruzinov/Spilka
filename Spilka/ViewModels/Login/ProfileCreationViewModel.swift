//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import SwiftUI
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
        @Published var uuid: String?
        @Published var profileName: String = ""
        @Published var profileDescription: String?
        @Published var profileUsername: String = ""
        @Published var isGoToSaveKeyView: Bool = false
        @Published var isGoToSigninSelector = false
        @Published var isGoToMainView: Bool = false
        @Published var isRegisterButtonDisabled: Bool = true
        @Published var isWaitingServer: Bool = false

        func handleGoToSaveKeys() {
            guard let privateKey = cryptoKeys.privateKey else { return }

            guard let privateBase64String = try? privateKey.base64String() else {
                return
            }

            let keychain = KeychainSwift()
            keychain.synchronizable = true
            keychain.set(privateBase64String, forKey: "userPrivateKey")

            isGoToSaveKeyView.toggle()
        }

        func handleRegisterButton() {
            let keychain = KeychainSwift()
            keychain.synchronizable = true
            uid = keychain.get("accountUID")
            guard let uid = uid, let publicKey = cryptoKeys.publicKey,
                let publicBase64String = try? publicKey.base64String() else { return }
            if let checkPhoneNumber = phoneNumber {
                phoneNumber = checkPhoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            }

            userAccount = UserAccount(
                uuid: UUID().uuidString,
                name: profileName,
                countryCode: countryCode,
                phoneNumber: phoneNumber,
                profileImageID: nil, // TODO: Change when implement avatars
                username: profileUsername,
                description: profileDescription,
                publicKey: publicBase64String
            )

            let dbase = Firestore.firestore()
            do {
                try dbase.collection("accounts").document(uid).setData(from: userAccount)
                let accountRef = dbase.collection("accounts").document(uid)

                accountRef.getDocument { user, error in
                    if let error {
                        print(error)
                    } else if let user, user.exists {
                        self.isGoToMainView.toggle()
                    }
                }
            } catch let error {
                print("ERROR with creating: \(error)")
            }
        }

        var privateKeyFile: CryptoKeyFile? {
            guard let data = try? self.cryptoKeys.privateKey!.data() else { return nil }
            return CryptoKeyFile(data: data)
        }
    }
}
