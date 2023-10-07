//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

extension ProfileCreationView {
    @MainActor class ViewModel: ObservableObject {
        @Published var cryptoKeys: CryptoKeys?
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

        init() {
            DispatchQueue.global().async {
                let cryptoKeys = CryptoKeys()
                DispatchQueue.main.async {
                    self.cryptoKeys = cryptoKeys
                }
            }
        }

        func handleGoToSaveKeys() {
            isGoToSaveKeyView.toggle()
        }

        func handleRegisterButton() {
            guard let cryptoKeys, let privateKey = cryptoKeys.privateKey else { return }
            guard let privateKeyData = try? privateKey.externalRepresentation() else {
                return
            }

            let keychain = KeychainSwift()
            keychain.synchronizable = true
            keychain.set(privateKeyData, forKey: "userPrivateKey")
            uid = keychain.get("accountUID")

            guard let uid = uid, let publicKeyRepresentation = cryptoKeys.publicKeyRepresentation else { return }
            if let checkPhoneNumber = phoneNumber {
                phoneNumber = checkPhoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            }

            userAccount = UserAccount(
                uuid: uid,
                name: profileName,
                countryCode: countryCode,
                phoneNumber: phoneNumber,
                profileImageID: nil,
                username: profileUsername,
                description: profileDescription,
                publicKey: publicKeyRepresentation.toHexString()
            )

            let dbase = Firestore.firestore()
            do {
                try dbase.collection("accounts").document(uid).setData(from: userAccount)
                let accountRef = dbase.collection("accounts").document(uid)

                accountRef.getDocument { user, error in
                    if let error {
                        ErrorLog.save(error)
                    } else if let user, user.exists {
                        self.isGoToMainView.toggle()
                    }
                }
            } catch let error {
                ErrorLog.save("ERROR with creating: \(error)")
            }
        }

        var privateKeyFile: CryptoKeyFile? {
            guard let data = try? self.cryptoKeys?.privateKey!.externalRepresentation() else { return nil }
            return CryptoKeyFile(data: data)
        }
    }
}
