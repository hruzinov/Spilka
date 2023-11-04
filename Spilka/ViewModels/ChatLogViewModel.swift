//
//  Created by Evhen Gruzinov on 07.10.2023.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import CryptoSwift
import SwiftUI

extension ChatLogView {
    class ViewModel: ObservableObject {
        @Published var chatId: String?
        @Published var chat: Chat?
        @Published var accountUID: String = ""
        @Published var newMessageText = ""
        @Published var goToId: String = ""

        func handleSendMessage() {
            guard let chatId else { return }

            let messageText = newMessageText
            newMessageText = ""

            guard let pubKeyBase64 = chat?.user?.publicKey,
                let pubKey = Data(base64Encoded: pubKeyBase64) else { return }
            do {
                let bytedText = messageText.bytes
                let pubKey = try RSA(rawRepresentation: pubKey)
                let encryptedText = try pubKey.encrypt(bytedText)

                let messageOut = Message(fromID: accountUID, toID: chatId,
                                      text: encryptedText.toHexString(), isUnread: true, dateTime: Date.now)
                sendMessage(fromID: accountUID, toID: chatId, message: messageOut) { success, _  in
                    if success {
                        do {
                            let keychain = KeychainSwift()
                            keychain.synchronizable = true
                            guard let privateKeyData = keychain.getData("userPrivateKey_\(self.accountUID)"),
                                  let privateKey = try? RSA(rawRepresentation: privateKeyData) else {
                                return
                            }

                            var messageIn = messageOut
                            messageIn.text = try privateKey.encrypt(bytedText).toHexString()
                            self.sendMessage(fromID: chatId, toID: self.accountUID, message: messageIn) { _, messageId in
                                if let messageId {
                                    self.goToId = messageId
                                }
                            }
                        } catch {
                            ErrorLog.save(error)
                        }
                    }
                }

            } catch {
                ErrorLog.save(error)
            }
        }

        private func sendMessage(fromID: String, toID: String, message: Message,
                                 completion: @escaping (_ success: Bool, _ newMessageId: String?) -> Void) {
            let dbase = Firestore.firestore()
            do {
                let messageRef = dbase.collection("accounts/\(toID)/private_chats/\(fromID)/messages").document()
                try messageRef.setData(from: message) { error in
                        if let error {
                            ErrorLog.save(error)
                            completion(false, nil)
                        } else {
                            completion(true, messageRef.documentID)
                        }
                    }
            } catch {
                ErrorLog.save(error)
                completion(false, nil)
            }
        }
    }
}
