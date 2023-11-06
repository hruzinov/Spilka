//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import CryptoSwift
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

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

        @Published var isSaveKeyToServer: Bool = true
        @Published var keyCryptoPassword: String = ""
        @Published var keyCryptoRePassword: String = ""
        @Published var keyCryptoPasswordShow: Bool = false
        @Published var keyCryptoRePasswordShow: Bool = false

        var isPasswordsMatch: Bool {
            guard keyCryptoPassword != "" && keyCryptoRePassword != "" else { return true }
            return keyCryptoPassword == keyCryptoRePassword
        }

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
            guard let cryptoKeys, let privateKey = cryptoKeys.privateKey, let publicKey = cryptoKeys.publicKey,
                  let privateKeyData = try? privateKey.data(), let publicKeyBase64 = try? publicKey.base64String(),
                  let uid = UserDefaults.standard.string(forKey: "accountUID")
            else {
                isWaitingServer = false
                return
            }

            let keychain = KeychainSwift()
            keychain.synchronizable = true
            keychain.set(privateKeyData, forKey: "userPrivateKey_\(uid)")
            UserDefaults.standard.set(publicKeyBase64, forKey: "userPublicKey_\(uid)")

            if isSaveKeyToServer {
                guard keyCryptoPassword == keyCryptoRePassword, keyCryptoPassword != "" else {
                    isWaitingServer = false; return
                }
                saveCryptoKeyToDatabase(uid: uid)
            }

            if let checkPhoneNumber = phoneNumber {
                phoneNumber = checkPhoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            }

            userAccount = UserAccount(
                name: profileName,
                countryCode: countryCode,
                phoneNumber: phoneNumber,
                profileImageID: nil,
                username: profileUsername,
                description: profileDescription,
                publicKey: publicKeyBase64
            )

            let dbase = Firestore.firestore()
            do {
                try dbase.collection("accounts").document(uid).setData(from: userAccount)

                let accountRef = dbase.collection("accounts").document(uid)
                accountRef.getDocument { user, error in
                    if let error {
                        self.isWaitingServer = false
                        ErrorLog.save(error)
                    } else if let user, user.exists {
                        self.isGoToMainView.toggle()
                    }
                }
            } catch {
                isWaitingServer = false
                ErrorLog.save("ERROR with creating: \(error)")
            }
        }

        func saveCryptoKeyToDatabase(uid: String) {
            guard let privateKey = cryptoKeys?.privateKey
            else { fatalError("Error with geting uid in saveKeyToDatabase()") }

            let password = keyCryptoPassword
            DispatchQueue.global(qos: .background).async {
                do {
                    let password = String(password.utf8).bytes
                    let salt = String(uid.utf8).bytes
                    let aesKey = try PKCS5.PBKDF2(
                        password: password,
                        salt: salt,
                        iterations: 4096,
                        keyLength: 32,
                        variant: .sha3(.sha256)
                    ).calculate()
                    let initVector = AES.randomIV(AES.blockSize)

                    let aes = try AES(key: aesKey, blockMode: CBC(iv: initVector), padding: .pkcs7)

                    let encryptedKey = try aes.encrypt(privateKey.data().bytes)
                    let encryptedKeyHex = encryptedKey.toHexString()

                    let serverKeyData = ServerKeyData(keyHex: encryptedKeyHex, initVector: initVector.toHexString())

                    try Firestore.firestore().collection("keyholder").document(uid).setData(from: serverKeyData)
                } catch {
                    ErrorLog.save(error)
                    return
                }
            }
        }

        var privateKeyFile: CryptoKeyFile? {
            guard let data = try? cryptoKeys?.privateKey!.data() else { return nil }
            return CryptoKeyFile(data: data)
        }
    }
}
