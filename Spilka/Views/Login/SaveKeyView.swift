//
//  Created by Evhen Gruzinov on 02.10.2023.
//

import SwiftUI

struct SaveKeyView: View {
    var screenSize = UIScreen.main.bounds.size
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var profileCreationViewModel: ProfileCreationView.ViewModel
//    @State private var isShowingExporter = false

    var body: some View {
        VStack(spacing: 20) {
            Text("All messages sent to Spilka are encrypted to ensure the security of your communications.")
                .font(.headline)
            Text("The decryption key is stored only in the device's memory and is never transmitted to the server.")

            if profileCreationViewModel.cryptoKeys == nil {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        HStack(spacing: 15) {
                            Text("Generating keys...")
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .frame(maxHeight: 50)
                    .padding(.vertical, 24)
            } else {
                ShareLink(
                    item: profileCreationViewModel.privateKeyFile!, preview: SharePreview("Private Key",
                            image: Image(systemName: "key.radiowaves.forward")
                                .renderingMode(.original))) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.ultraThinMaterial)
                                        .overlay {
                                            HStack {
                                                Text("Export key file")
                                                Image(systemName: "square.and.arrow.down.on.square")
                                            }
                                        }
                                        .frame(maxHeight: 50)
                                        .padding(.vertical, 24)
                                }
            }

            // swiftlint:disable:next line_length
            Text("It's **recommended** to save a backup file of this key in a safe place so you can restore access to your messages.")

            Button {
                profileCreationViewModel.handleRegisterButton()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(profileCreationViewModel.cryptoKeys == nil ? .gray :
                        colorScheme == .dark ? .white  : .black)
                    .frame(width: profileCreationViewModel.isWaitingServer ? 45 :
                            screenSize.width * 0.8, height: 45)
                    .overlay {
                        if profileCreationViewModel.isWaitingServer {
                            ProgressView()
                                .tint(colorScheme == .light ? .white  : .black)
                        } else {
                            Text("Register")
                                .foregroundStyle(colorScheme == .light ? .white  : .black)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 24)
            }
            .disabled(profileCreationViewModel.cryptoKeys == nil)

        }
        .frame(width: screenSize.width * 0.8)
        .multilineTextAlignment(.center)
        .navigationDestination(isPresented: $profileCreationViewModel.isGoToMainView) {
            MainView(skipCheck: true)
        }
    }
}

#Preview {
    SaveKeyView(profileCreationViewModel: ProfileCreationView.ViewModel.init())
}
