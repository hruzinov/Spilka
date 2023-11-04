//
//  Created by Evhen Gruzinov on 03.10.2023.
//

import SwiftUI

struct ImportKeyView: View {
    var screenSize = UIScreen.main.bounds.size
    @Environment(\.colorScheme) var colorScheme
    @StateObject var privateKeysImportViewModel = PrivateKeysImportViewModel()
    @ObservedObject var signInViewModel: SignInScreenView.ViewModel

    @State private var isShowingImporter = false

    var body: some View {
        VStack {
            Text("Your private key is required to continue")
                .multilineTextAlignment(.center)
                .font(.headline)
            Text("Confirm the key transfer request on another device, enter your password or import the key file.")
                .multilineTextAlignment(.center)

            SecureField("Your password", text: $privateKeysImportViewModel.keyPassword)
                .padding(10)
                .background(.thinMaterial,
                            in: RoundedRectangle(cornerRadius: 10))
                .submitLabel(.done)
                .onSubmit {
                    privateKeysImportViewModel
                        .handlePrivateKeyPassword(userAccount: signInViewModel.userAccount)
                }

            Button {
                privateKeysImportViewModel
                    .handlePrivateKeyPassword(userAccount: signInViewModel.userAccount)
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? .white : .black)
                    .frame(width: signInViewModel.isWaitingServer ? 45 :
                        screenSize.width * 0.85, height: 45)
                    .overlay {
                        if privateKeysImportViewModel.isWaitingServer {
                            ProgressView()
                                .tint(colorScheme == .light ? .white : .black)
                        } else {
                            Text("Continue")
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                                .font(.title3)
                        }
                    }
                    .padding(.bottom, 24)
            }
            .disabled(privateKeysImportViewModel.isWaitingServer)

            Text(LocalizedStringKey(privateKeysImportViewModel.keyImportMessagePrompt))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: screenSize.width * 0.9)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 217 / 255, green: 4 / 255, blue: 41 / 255))
                }
                .opacity(privateKeysImportViewModel
                    .isShowingKeyImportMessagePrompt ? 1 : 0)

            Text("You can also import a key file using the button below.")
                .padding(.top, 24)

            Button {
                isShowingImporter.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if privateKeysImportViewModel.isWaitingServer {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            HStack {
                                Text("Import key file")
                                Image(systemName: "square.and.arrow.down")
                            }
                        }
                    }
                    .frame(maxHeight: 50)
            }
            .disabled(privateKeysImportViewModel.isWaitingServer)
            .fileImporter(isPresented: $isShowingImporter,
                          allowedContentTypes: [.data]) { result in
                privateKeysImportViewModel
                    .privateKeyFileSelected(result, userAccount: signInViewModel.userAccount)
            }

            // Disabled to better times
//            Text("If you have lost or don't have your key, or want to start over, click the button below")
//                .multilineTextAlignment(.center)
//            Button {
//
//            } label: {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(.ultraThinMaterial)
//                    .overlay {
            ////                        Text("Reset private key")
//                        Text("NOT WORKING")
//                            .foregroundStyle(.red)
//                    }
//                    .frame(maxHeight: 50)
//            }
//            .disabled(true)
        }
        .frame(width: screenSize.width * 0.85)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    signInViewModel.isGoToSigninSelector.toggle()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
        }
        .multilineTextAlignment(.center)
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $privateKeysImportViewModel.isGoToMainView) {
            MainView(skipCheck: true)
        }
        .navigationDestination(isPresented: $signInViewModel.isGoToSigninSelector) {
            SignInScreenView(viewModel: signInViewModel)
        }
    }
}

#Preview {
    ImportKeyView(signInViewModel: SignInScreenView.ViewModel())
}
