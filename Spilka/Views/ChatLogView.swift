//
//  Created by Evhen Gruzinov on 06.10.2023.
//

import SwiftUI

struct ChatLogView: View {
    @Environment(\.colorScheme) var colorScheme
    var screenSize = UIScreen.main.bounds.size
    @StateObject var viewModel = ViewModel()
    @ObservedObject var chatsListViewModel: ChatsListScreenView.ViewModel

    @State var chatId: String
    @FocusState var isTextfieldFocused: Bool

    var body: some View {
        VStack {
            ScrollViewReader { reader in
                ScrollView {
                    if let chat = chatsListViewModel.chatsDictionary[chatId] {
                        ForEach(chat.messagesSorted) { message in
                            if message.fromID == viewModel.accountUID {
                                HStack {
                                    Spacer()
                                    Text(message.uncryptedText ?? "<Encrypted>")
                                        .padding()
                                        .foregroundStyle(.white)
                                        .background(Color.accentColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .frame(width: screenSize.width * 0.95, alignment: .trailing)
                                .padding(.horizontal)
                                .id(message.id)
                            } else {
                                HStack {
                                    Text(message.uncryptedText ?? "<Encrypted>")
                                        .padding()
                                        .foregroundStyle(colorScheme == .light ? .black : .white)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    Spacer()
                                }
                                .frame(width: screenSize.width * 0.95, alignment: .trailing)
                                .padding(.horizontal)
                                .id(message.id)
                            }
                        }
                    }
                }
                .background(colorScheme == .light ? .white : .black)
                .padding(.bottom, 8)
                .onAppear {
                    reader.scrollTo(chatsListViewModel.chatsDictionary[chatId]?.messagesSorted.last?.id ?? "",
                                    anchor: .bottom)
                }
                .onChange(of: viewModel.goToId) { _, _ in
                    withAnimation {
                        reader.scrollTo(viewModel.goToId, anchor: .bottom)
                    }
                }
            }
            VStack {
                HStack {
                    HStack {
                        TextField(text: $viewModel.newMessageText, axis: .vertical) {
                            Text("New message")
                        }
                        .lineLimit(5)
                        .padding(.trailing, 32)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(colorScheme == .dark ? .black : .white)
                            .padding(-10)
                    }
                    Spacer()
                    VStack {
                        Button {
                            viewModel.handleSendMessage()
                        } label: {
                            Circle()
                                .fill(viewModel.newMessageText.count > 0 ?
                                    Color.accentColor : Color.gray)
                                .frame(width: 24, height: 24)
                                .overlay {
                                    Image(systemName: "arrow.up")
                                        .foregroundStyle(.white)
                                        .fontWeight(.black)
                                        .font(.footnote)
                                }
                                .padding(.leading, 15)
                        }
                        .disabled(viewModel.newMessageText.count == 0)
                    }
                }
                .frame(width: screenSize.width * 0.90)
                Text("")
                    .opacity(0)
                    .font(.system(size: 5))
            }
            .padding(.top, 20)
            .padding(.bottom, isTextfieldFocused ? 32 : 10)
            .frame(width: screenSize.width)
            .ignoresSafeArea()
            .background(.ultraThickMaterial)
        }
//        .overlay(alignment: .bottom) {
//
//        }

        .onAppear {
            viewModel.chat = chatsListViewModel.chatsDictionary[chatId]
            viewModel.chatId = chatId
            viewModel.accountUID = chatsListViewModel.accountUID
        }
    }
}

#Preview {
    ChatLogView(chatsListViewModel: ChatsListScreenView.ViewModel(), chatId: TestData.testChat.id!)
}
