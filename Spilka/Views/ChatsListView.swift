//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import CryptoSwift
import SwiftUI

struct ChatsListScreenView: View {
    @StateObject var viewModel = ViewModel()
    var screenSize = UIScreen.main.bounds.size

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.chatsDictionary.count > 0 || viewModel.loadingStatus == .updating {
                    List {
                        ForEach(viewModel.chatsSorted) { chat in
                            if let chatId = chat.id {
                                HStack(spacing: 0) {
                                    if let profileImage = chat.user?.profileImageSmall {
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .frame(width: 55, height: 55)
                                            .mask {
                                                Circle()
                                            }
                                    } else {
                                        Circle()
                                            .fill(.gray)
                                            .frame(width: 55, height: 55)
                                            .overlay {
                                                if let user = chat.user, user.name.count > 0 {
                                                    Text(String(user.name.first!))
                                                }
                                            }
                                    }
                                    Spacer()
                                    VStack(spacing: 2) {
                                        HStack {
                                            if let user = chat.user {
                                                Text(user.name)
                                                    .bold()
                                                    .lineLimit(1)
                                            } else {
                                                Text("NaN")
                                                    .bold()
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            if let dateTime = chat.messagesSorted.last?.dateTime {
                                                Text(dateTime.stringRel())
                                                    .foregroundStyle(.gray)
                                                    .font(.subheadline)
                                            }
                                        }
                                        HStack(spacing: 0) {
                                            Text(chat.messagesSorted.last?.uncryptedText ?? "")
                                                .lineLimit(2, reservesSpace: true)
                                                .foregroundStyle(.gray)
                                            Spacer()
                                            if chat.unreadedCount > 0 {
                                                Circle()
                                                    .fill(Color.accentColor)
                                                    .frame(width: 25, height: 25)
                                                    .padding(0)
                                                    .overlay {
                                                        Text("\(chat.unreadedCount)")
                                                            .foregroundStyle(.white)
                                                    }
                                            }

                                            if let lastMessage = chat.messagesSorted.last,
                                               lastMessage.isUnread && lastMessage.fromID == viewModel.accountUID {
                                                // TODO: Mark sended messages as unread/read
                                            }
                                        }
                                    }
                                }
                                .background {
                                    NavigationLink("", destination:
                                        ChatLogView(chatsListViewModel: viewModel, chatId: chatId))
                                        .opacity(0)
                                }
                            }
                        }
                    }
                    .listStyle(InsetListStyle())
                } else if viewModel.loadingStatus == .loading {
                    ProgressView("Loading...")
                } else {
                    VStack(spacing: 0) {
                        Text("It's a bit empty here...")
                            .font(.title2)
                            .padding(16)
                        Text("Click the \(Image(systemName: "square.and.pencil")) above to start a new chat,")
                        Text("or try the search to find channels of interest")
                    }
                    .multilineTextAlignment(.center)
                }
            }
            .toolbar {
                if viewModel.loadingStatus != .loading {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            // Writing message to new user
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey(stringLiteral: viewModel.loadingStatus.rawValue))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatsListScreenView()
}
