//
//  Created by Evhen Gruzinov on 07.10.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

extension ChatLogView {
    class ViewModel: ObservableObject {
        @Published var chatId: String?
        @Published var accountUID: String = ""
        @Published var newMessageText = ""

        func handleSendMessage() {
            guard let chatId else { return }

            let messageText = newMessageText
            newMessageText = ""

            let message = Message(fromID: accountUID, toID: chatId,
                                  text: messageText, isUnread: true, dateTime: Date.now)

            sendMessage(fromID: accountUID, toID: chatId, message: message) { success in
                if success {
                    self.sendMessage(fromID: chatId, toID: self.accountUID, message: message) { _ in
                    }
                }
            }
        }

        private func sendMessage(fromID: String, toID: String,
                                 message: Message, completion: @escaping(_ success: Bool) -> Void) {
            let dbase = Firestore.firestore()
            do {
                try dbase.collection("accounts/\(toID)/private_chats/\(fromID)/messages")
                    .addDocument(from: message) { error in
                    if let error {
                        ErrorLog.save(error)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } catch {
                ErrorLog.save(error)
                completion(false)
            }
        }
    }
}
