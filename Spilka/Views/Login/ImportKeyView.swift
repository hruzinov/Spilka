//
//  Created by Evhen Gruzinov on 03.10.2023.
//

import SwiftUI

struct ImportKeyView: View {
    var screenSize = UIScreen.main.bounds.size
    @ObservedObject var signInViewModel: SignInScreenView.ViewModel

    @State private var isShowingImporter = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Your private key is required to continue")
                .multilineTextAlignment(.center)
                .font(.headline)
            Text("Confirm the key transfer request on another device or import the key file.")
                .multilineTextAlignment(.center)

            Button {
                isShowingImporter.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if signInViewModel.isWaitingServer {
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
            .disabled(signInViewModel.isWaitingServer)
            .fileImporter(isPresented: $isShowingImporter,
                          allowedContentTypes: [.data]) { result in
                signInViewModel.privateKeyFileSelected(result)
            }

            Text(LocalizedStringKey(signInViewModel.fileImportMessagePrompt))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: screenSize.width * 0.9)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 217/255, green: 4/255, blue: 41/255))
                }
                .opacity(signInViewModel.isShowingFileImportMessagePrompt ? 1 : 0)

            Text("If you have lost or don't have your key, or want to start over, click the button below")
                .multilineTextAlignment(.center)
            Button {

            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay {
//                        Text("Reset private key")
                        Text("NOT WORKING")
                            .foregroundStyle(.red)
                    }
                    .frame(maxHeight: 50)
            }
            .disabled(true)

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
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $signInViewModel.isGoToMainView) {
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
