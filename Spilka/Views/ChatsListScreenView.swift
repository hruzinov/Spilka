//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import SwiftUI

struct ChatsListScreenView: View {
    @StateObject var viewModel = ViewModel(test: true)
    var screenSize = UIScreen.main.bounds.size

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.chats) { chat in
                    HStack(spacing: 0) {
                        if let profileImage = chat.user?.profileImageSmall {
                            Image(uiImage: profileImage)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .mask {
                                    Circle()
                                }
                        } else {
                            Circle()
                                .fill(.gray)
                                .frame(width: 50, height: 50)
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
                                        .onAppear {
                                            print(chat)
                                        }
                                }
                                Spacer()
                                if let dateTime = chat.messages.last?.dateTime {
                                    Text(dateTime.stringRel())
                                        .foregroundStyle(.gray)
                                }
                            }
                            HStack(spacing: 0) {
                                Text(chat.messages.last?.text ?? "")
                                    .lineLimit(2, reservesSpace: true)
                                    .foregroundStyle(.gray)
                                Spacer()
                                if chat.messages.last?.isUnread ?? false {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 25, height: 25)
                                        .padding(0)
                                        .overlay {
                                            Text("1") // TODO: Inplement real unread messages counter
                                                .foregroundStyle(.white)
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetListStyle())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO:
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
