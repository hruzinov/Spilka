//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import SwiftyRSA
import SwiftUI

extension ChatsListScreenView {
    class ViewModel: ObservableObject {
        var chatsDictionary: [String: Chat] = [:]
        @Published var accountUID: String
        @Published var userAccount: UserAccount?
        @Published var loadingStatus: LoadingStatus = .online
        var chatsSorted: [Chat] {
            if chatsDictionary.count >= 2 {
                return chatsDictionary.values.sorted {
                    var firstChatDate: Date
                    var secondChatDate: Date

                    if let firstChatLastMessage = $0.messagesSorted.last {
                        firstChatDate = firstChatLastMessage.dateTime
                    } else {
                        firstChatDate = Date.zero()
                    }
                    if let secondChatLastMessage = $1.messagesSorted.last {
                        secondChatDate = secondChatLastMessage.dateTime
                    } else {
                        secondChatDate = Date.zero()
                    }

                    return firstChatDate > secondChatDate
                }
            } else {
                return Array(chatsDictionary.values)
            }
        }

        init() {
            if let uid = UserDefaults.standard.string(forKey: "accountUID") {
                accountUID = uid
            } else {
                ErrorLog.save("Can't get accountUID from keychain")
                fatalError("Can't get accountUID from keychain")
            }

            UserAccount.getData(with: accountUID) { userAccount in
                self.userAccount = userAccount
            }
            getAllChats(accountUID)
        }

        func getAllChats(_ uid: String) {
            let dbase = Firestore.firestore()
            let dispatchGroupChats = DispatchGroup()
            loadingStatus = .loading

            let keychain = KeychainSwift()
            keychain.synchronizable = true
            guard let privateKeyData = keychain.getData("userPrivateKey_\(accountUID)"),
                  let privateKey = try? PrivateKey(data: privateKeyData) else {
                return
            }

            let privateChatsRef = dbase.collection("accounts/\(uid)/private_chats/")

            privateChatsRef.getDocuments(source: .cache) { privateChatsSnapshot, error in
                guard let privateChatsSnapshot else { ErrorLog.save(error); return }
                guard privateChatsSnapshot.documents.count > 0 else { self.loadingStatus = .online; return }

                dispatchGroupChats.enter()
                privateChatsSnapshot.documents.forEach { chatDocument in
                    self.getChatFromSnapshot(chatDocument, from: .cache, pvtKey: privateKey) {
                        dispatchGroupChats.leave()
                    }
                }
                dispatchGroupChats.notify(queue: .main) {
                    self.loadingStatus = .online
                }
            }

            privateChatsRef.addSnapshotListener { chatsChangeSnapshot, error in
                guard let chatsChangeSnapshot else { ErrorLog.save(error); return }
                guard chatsChangeSnapshot.documentChanges.count > 0 else { return }
                chatsChangeSnapshot.documentChanges.forEach { dif in
                    if dif.type == .added {
                        self.getChatFromSnapshot(dif.document, pvtKey: privateKey) {}
                    }
                }
            }
        }

        func getChatFromSnapshot(_ chatDocument: QueryDocumentSnapshot, from: FirestoreSource = .default,
                                 pvtKey: PrivateKey, completion: @escaping () -> Void) {
            do {
                var chat = try chatDocument.data(as: Chat.self)
                guard let userUID = chat.id else { return }

                UserAccount.getData(with: userUID, from: from) { userAccount in
                    guard let userAccount else { return }
                    chat.user = userAccount

                    userAccount.getProfileImageSmall { image in
                        chat.user?.profileImageSmall = image
                        self.chatsDictionary[userUID] = chat
                        self.objectWillChange.send()

                        let privateChatMessagesRef = chatDocument.reference.collection("messages")

                        if from == .cache {
                            privateChatMessagesRef.getDocuments(source: .cache) { messagesSnapshot, error in
                                guard let messagesSnapshot else { ErrorLog.save(error); return }

                                messagesSnapshot.documents.forEach { messageDocument in
                                    self.addMessage(messageDocument: messageDocument, chatId: userUID, pvtKey: pvtKey)
                                }

                                completion()
                            }
                        }
                        privateChatMessagesRef.addSnapshotListener { messagesSnapshot, error in
                            guard let messagesSnapshot else { ErrorLog.save(error); return }
                            messagesSnapshot.documentChanges.forEach { dif in
                                if dif.type == .added {
                                    self.addMessage(messageDocument: dif.document, chatId: userUID, pvtKey: pvtKey)
                                }
                            }
                        }
                    }
                }
            } catch { ErrorLog.save(error) }
        }

        func addMessage(messageDocument: QueryDocumentSnapshot, chatId: String, pvtKey: PrivateKey) {
            guard var message = try? messageDocument.data(as: Message.self),
                  let messageId = message.id else { return }

            if let encrypted = try? EncryptedMessage(base64Encoded: message.text),
               let clear = try? encrypted.decrypted(with: pvtKey, padding: .PKCS1) {
                message.uncryptedText = try? clear.string(encoding: .utf8)
            }

            self.chatsDictionary[chatId]?.messagesDictionary[messageId] = message
            self.objectWillChange.send()
        }

        enum LoadingStatus: String {
            case loading = ""
            case online = "Chats"
            case updating = "Updating..."
        }
    }
}
