//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import SwiftUI

struct ChatsListScreenView: View {
    @StateObject var viewModel = ViewModel()
    var screenSize = UIScreen.main.bounds.size

    var body: some View {
        NavigationStack {
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
                                            .font(.footnote)
                                    }
                                }
                                HStack(spacing: 0) {
                                    Text(chat.messagesSorted.last?.text ?? "")
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Writing message to new user
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .navigationTitle(LocalizedStringKey(stringLiteral: viewModel.navbarStatus.rawValue))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatsListScreenView()
}
