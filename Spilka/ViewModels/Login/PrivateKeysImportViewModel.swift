//
//  PrivateKeysViewModel.swift
//  Spilka
//
//  Created by Evhen Gruzinov on 08.10.2023.
//

import SwiftUI
import CryptoSwift
import FirebaseFirestore
import FirebaseFirestoreSwift

class PrivateKeysImportViewModel: ObservableObject {
    @Published var keyPassword: String = ""
    @Published var isWaitingServer: Bool = false
    @Published var isShowingKeyImportMessagePrompt: Bool = false
    @Published var isGoToMainView: Bool = false
    @Published var keyImportMessagePrompt: String = ""

    func handlePrivateKeyPassword(userAccount: UserAccount?) {
        guard let userAccount, let uid = userAccount.uuid else { return }

        self.isWaitingServer = true
        let password = self.keyPassword
        DispatchQueue.global(qos: .background).async {
            Firestore.firestore().collection("keyholder").document(uid).getDocument { documentSnapstot, error in
                guard let documentSnapstot, documentSnapstot.exists,
                      let serverKeyData = try? documentSnapstot.data(as: ServerKeyData.self) else {
                    DispatchQueue.main.async {
                        ErrorLog.save(error)
                        self.isWaitingServer = false
                        self.showPrivateKeyImportMessagePrompt(error?.localizedDescription ??
                                                         "Error with getting key information")
                    }
                    return
                }

                let password = String(password.utf8).bytes
                let salt = String(uid.utf8).bytes

                do {
                    let aesKey = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096,
                                                  keyLength: 32, variant: .sha3(.sha256)).calculate()
                    let initVector = Array(hex: serverKeyData.initVector)
                    let aes = try AES(key: aesKey, blockMode: CBC(iv: initVector), padding: .pkcs7)
                    let encryptedKeyData = Data(hex: serverKeyData.keyHex)
                    let decryptedKeyBytes = try aes.decrypt(encryptedKeyData.bytes)

                    let privateKeyData = Data(decryptedKeyBytes)
                    let publicKeyData = Data(hex: userAccount.publicKey)

                    if CryptoKeys.checkValidity(privateKeyData: privateKeyData, publicKeyData: publicKeyData) {
                        DispatchQueue.main.async {
                            self.isWaitingServer = false
                            self.isGoToMainView.toggle()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isWaitingServer = false
                            self.showPrivateKeyImportMessagePrompt("Password is incorrect or key is out of date")
                            ErrorLog.save("Key not handled security check")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        ErrorLog.save(error)
                        self.showPrivateKeyImportMessagePrompt(error.localizedDescription)
                        self.isWaitingServer = false
                    }
                    return
                }
            }
        }
    }

    func privateKeyFileSelected(_ result: Result<URL, Error>, userAccount: UserAccount?) {
        self.isWaitingServer = true
        self.isShowingKeyImportMessagePrompt = false

        switch result {
        case .success(let fileURL):
            do {
                guard let userAccount else { self.isWaitingServer = false; return }

                let isAccessing = fileURL.startAccessingSecurityScopedResource()

                let privateKeyData = try Data(contentsOf: fileURL)
                let publicKeyData = Data(hex: userAccount.publicKey)

                if CryptoKeys.checkValidity(privateKeyData: privateKeyData, publicKeyData: publicKeyData) {
                    self.isWaitingServer = false
                    self.isGoToMainView.toggle()
                } else {
                    self.isWaitingServer = false
                    self.showPrivateKeyImportMessagePrompt("File contains an outdated or invalid key")
                    ErrorLog.save("Key not handled security check")
                }
                if isAccessing {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            } catch {
                self.showPrivateKeyImportMessagePrompt("This is not a private key file. Choose another one")
                self.isWaitingServer = false
                ErrorLog.save(error)
            }

        case .failure(let error):
            self.isWaitingServer = false
            self.showPrivateKeyImportMessagePrompt(error.localizedDescription)
        }
    }

    func showPrivateKeyImportMessagePrompt(_ error: String) {
        withAnimation {
            self.isShowingKeyImportMessagePrompt = true
            self.keyImportMessagePrompt = error
        }
    }
}
