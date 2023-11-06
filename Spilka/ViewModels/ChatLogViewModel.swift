//
//  Created by Evhen Gruzinov on 07.10.2023.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftyRSA
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
                let pubKey = try PublicKey(data: pubKey)
                let clearText = try ClearMessage(string: messageText, using: .utf8)
                let encryptedText = try clearText.encrypted(with: pubKey, padding: .PKCS1)

                let messageOut = Message(fromID: accountUID, toID: chatId,
                                         text: encryptedText.base64String, isUnread: true, dateTime: Date.now)
                sendMessage(fromID: accountUID, toID: chatId, message: messageOut) { success, _  in
                    if success {
                        do {
                            guard let accountPublicKeyString =
                                    UserDefaults.standard.string(forKey: "userPublicKey_\(self.accountUID)") else {
                                return
                            }
                            let accountPublicKey = try PublicKey(base64Encoded: accountPublicKeyString)

                            var messageIn = messageOut
                            messageIn.text =
                                try clearText.encrypted(with: accountPublicKey, padding: .PKCS1).base64String
                            self.sendMessage(fromID: chatId, toID: self.accountUID, message: messageIn) { _, mid in
                                if let mid {
                                    self.goToId = mid
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
