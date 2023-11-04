//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import CryptoSwift
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
            loadingStatus = .updating

            let keychain = KeychainSwift()
            keychain.synchronizable = true
            guard let privateKeyData = keychain.getData("userPrivateKey_\(accountUID)"),
                  let privateKey = try? RSA(rawRepresentation: privateKeyData) else {
                return
            }

            let privateChatsRef = dbase.collection("accounts/\(uid)/private_chats/")
            privateChatsRef.getDocuments { privateChatsSnapshot, error in
                guard let privateChatsSnapshot else { ErrorLog.save(error); return }
                guard privateChatsSnapshot.documents.count > 0 else { self.loadingStatus = .online; return }

                privateChatsSnapshot.documents.forEach { chatDocument in
                    do {
                        var chat = try chatDocument.data(as: Chat.self)
                        guard let userUID = chat.id else { return }

                        dispatchGroupChats.enter()
                        UserAccount.getData(with: userUID) { userAccount in
                            guard let userAccount else { return }
                            chat.user = userAccount

                            userAccount.getProfileImageSmall { image in
                                chat.user?.profileImageSmall = image
                                self.chatsDictionary[userUID] = chat
                                self.objectWillChange.send()

                                let privateChatMessagesRef =
                                    privateChatsRef.document(chatDocument.documentID).collection("messages")

                                privateChatMessagesRef.getDocuments { messagesSnapshot, error in
                                    guard let messagesSnapshot else {
                                        ErrorLog.save(error); dispatchGroupChats.leave(); return
                                    }
                                    messagesSnapshot.documents.forEach { messageDocument in
                                        guard var message = try? messageDocument.data(as: Message.self),
                                              let decryptedData = try? privateKey.decrypt(Data(hex: message.text).bytes),
                                              let messageId = message.id else { return }
                                        message.uncryptedText = String(data: Data(decryptedData), encoding: .utf8)
                                        self.chatsDictionary[userUID]?.messagesDictionary[messageId] = message
                                        self.objectWillChange.send()
                                    }
                                    dispatchGroupChats.leave()
                                }
                                privateChatMessagesRef.addSnapshotListener { messagesSnapshot, error in
                                    guard let messagesSnapshot else { ErrorLog.save(error); return }
                                    messagesSnapshot.documentChanges.forEach { dif in
                                        if dif.type == .added {
                                            guard var message = try? dif.document.data(as: Message.self),
                                                  let decryptedData = try? privateKey.decrypt(Data(hex: message.text).bytes),
                                                  let messageId = message.id else { return }
                                            message.uncryptedText = String(data: Data(decryptedData), encoding: .utf8)
                                            self.chatsDictionary[userUID]?.messagesDictionary[messageId] = message
                                            self.objectWillChange.send()
                                        }
                                    }
                                }
                            }
                        }
                        dispatchGroupChats.notify(queue: .main) { self.loadingStatus = .online }
                    } catch { ErrorLog.save(error) }
                }
            }
        }

        enum LoadingStatus: String {
            case online = "Chats"
            case updating = "Updating..."
        }
    }
}
