//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

extension ChatsListScreenView {
    class ViewModel: ObservableObject {
        @Published var chats: [Chat] = []
        @Published var accountUID: String
        @Published var navbarStatus: NavbarStatus = .online

        init(test: Bool = false) {
            var uid: String?
            if test {
                self.accountUID = "testUserAccount"
                uid = "testUserAccount"
            } else {
                let keychain = KeychainSwift()
                keychain.synchronizable = true

                if let uid = keychain.get("accountUID") {
                    self.accountUID = uid
                } else {
                    fatalError("Can't get accountUID from keychain")
                }
            }

            guard let uid else {
                fatalError("Can't read accountUID")
            }
            getAllChats(uid)
        }

        func getAllChats(_ uid: String) {
            let dbase = Firestore.firestore()
            let dispatchGroup = DispatchGroup()
            self.navbarStatus = .updating

            let chatsRef = dbase.collection("accounts/\(uid)/chats/")
            chatsRef.getDocuments { chatsSnapshot, error in
                guard let chatsSnapshot else { print(error ?? "Some error in chatsRef.getDocuments"); return }
                chatsSnapshot.documents.forEach { chatDocument in
                    do {
                        var chat = try chatDocument.data(as: Chat.self)

                        dispatchGroup.enter()
                        switch chat.type {
                        case .dialog:
                            guard let userUUID = chat.id else { return }
                            UserAccount.getData(withUUID: userUUID) { userAccount in
                                guard let userAccount else { return }
                                chat.user = userAccount

                                chatsRef.document(chatDocument.documentID).collection("messages")
                                    .getDocuments { messagesSnapshot, error in
                                        guard let messagesSnapshot else {
                                            print(error ?? "Some error in messages.getDocuments"); return
                                        }
                                        messagesSnapshot.documents.forEach { messageDocument in
                                            do {
                                                let message = try messageDocument.data(as: Message.self)
                                                chat.messages.append(message)
                                            } catch { print(error) }
                                        }
                                        dispatchGroup.leave()
                                    }
                            }
                        case .group:
                            // TODO:
                            print("")
                        }
                        dispatchGroup.notify(queue: .main) {
                            withAnimation {
                                if let user = chat.user {
                                    user.getProfileImageSmall { image in
                                        chat.user?.profileImageSmall = image
                                        self.chats.append(chat); self.navbarStatus = .online
                                    }
                                } else {
                                    self.chats.append(chat); self.navbarStatus = .online
                                }
                            }
                        }
                    } catch { print(error) }
                }
            }
        }

        enum NavbarStatus: String {
            case online = "Chats"
            case updating = "Updating..."
        }
    }
}
