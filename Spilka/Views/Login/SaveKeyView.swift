//
//  Created by Evhen Gruzinov on 02.10.2023.
//

import SwiftUI

struct SaveKeyView: View {
    var screenSize = UIScreen.main.bounds.size
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var profileCreationViewModel: ProfileCreationView.ViewModel

    @FocusState private var isFieldFocus: FieldToFocus?

    var isRegisterButtonActive: Bool {
        guard profileCreationViewModel.cryptoKeys != nil,
                !profileCreationViewModel.isWaitingServer else { return false }
        if profileCreationViewModel.isSaveKeyToServer {
            if profileCreationViewModel.keyCryptoPassword != "",
               profileCreationViewModel.keyCryptoRePassword != "",
               profileCreationViewModel.keyCryptoPassword ==
                profileCreationViewModel.keyCryptoRePassword {
                return true
            } else { return false }
        } else {
            return true
        }
    }

    var body: some View {
        ScrollView {
            Text("All messages sent through Spilka are encrypted.")
                .font(.headline)
                .padding(.bottom, 24)

            Text("You can synchronize encryption key between devices for easier login.")
                .padding(.bottom, 16)
            Text("In this case, the key will be encrypted with a password and stored on the server.")
                .padding(.bottom, 24)

            Toggle(isOn: $profileCreationViewModel.isSaveKeyToServer, label: {
                Text("Synchronize the decryption key")
                    .bold()
            })
            .frame(width: screenSize.width * 0.8)

            if profileCreationViewModel.isSaveKeyToServer {
//                VStack {
                VStack {
                    Group {
                        if profileCreationViewModel.keyCryptoPasswordShow {
                            TextField("Enter password", text:
                                        $profileCreationViewModel.keyCryptoPassword)
                                .focused($isFieldFocus, equals: .passwordTextField)
                        } else {
                            SecureField("Enter password", text:
                                            $profileCreationViewModel.keyCryptoPassword)
                                .focused($isFieldFocus, equals: .passwordSecureField)
                        }
                    }
                    .frame(height: 22)
                    .padding(10)
                    .submitLabel(.next)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textContentType(.newPassword)
                    .onSubmit {
                        isFieldFocus = .rePasswordSecureField
                    }
                    .background(.thinMaterial,
                                in: RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment: .trailing) {
                        Button {
                            profileCreationViewModel.keyCryptoPasswordShow.toggle()
                        } label: {
                            Image(systemName: profileCreationViewModel.keyCryptoPasswordShow ?
                                  "eye.slash" : "eye.fill")
                            .foregroundStyle(Color.primary)
                            .padding()
                        }
                    }
                    .onChange(of: profileCreationViewModel.keyCryptoPasswordShow, { _, _ in
                        isFieldFocus = profileCreationViewModel.keyCryptoPasswordShow ?
                            .passwordTextField : .passwordSecureField
                    })

                    Group {
                        if profileCreationViewModel.keyCryptoRePasswordShow {
                            TextField("Re-enter password", text: $profileCreationViewModel.keyCryptoRePassword)
                                .focused($isFieldFocus, equals: .rePasswordTextField)
                        } else {
                            SecureField("Re-enter password", text: $profileCreationViewModel.keyCryptoRePassword)
                                .focused($isFieldFocus, equals: .rePasswordSecureField)
                        }
                    }
                    .frame(height: 22)
                    .padding(10)
                    .submitLabel(.next)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textContentType(.newPassword)
                    .onSubmit {
                        isFieldFocus = nil
                    }
                    .background(.thinMaterial,
                                in: RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment: .trailing) {
                        Button {
                            profileCreationViewModel.keyCryptoRePasswordShow.toggle()
                        } label: {
                            Image(systemName: profileCreationViewModel.keyCryptoRePasswordShow ?
                                  "eye.slash" : "eye.fill")
                            .foregroundStyle(Color.primary)
                            .padding()
                        }
                    }
                    .onChange(of: profileCreationViewModel.keyCryptoRePasswordShow, { _, _ in
                        isFieldFocus = profileCreationViewModel.keyCryptoRePasswordShow ?
                            .rePasswordTextField : .rePasswordSecureField
                    })

                    if !profileCreationViewModel.isPasswordsMatch {
                        Text("Check passwords as they do not match")
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .padding(.bottom, 16)
            }

            Text("Optionally, you can save a backup key in case you forget your password")
            Group {
                if profileCreationViewModel.cryptoKeys == nil {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            HStack(spacing: 15) {
                                Text("Generating keys, wait...")
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                        }
                } else {
                    ShareLink(
                        item: profileCreationViewModel.privateKeyFile!, preview: SharePreview("Private Key",
                                  image: Image(systemName: "key.radiowaves.forward")
                            .renderingMode(.template))) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay {
                                        HStack {
                                            Text("Export backup key file")
                                            Image(systemName: "square.and.arrow.down.on.square")
                                        }
                                    }
                            }
                }
            }
            .frame(width: screenSize.width * 0.8, height: 50)
            .padding(.bottom, 22)

            Button {
                profileCreationViewModel.isWaitingServer = true
                profileCreationViewModel.handleRegisterButton()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(!isRegisterButtonActive ? .gray :
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
            .disabled(!isRegisterButtonActive)

        }
        .frame(width: screenSize.width * 0.9)
        .multilineTextAlignment(.center)
        .navigationDestination(isPresented: $profileCreationViewModel.isGoToMainView) {
            MainView(skipCheck: true)
        }
    }

    enum FieldToFocus {
        case passwordSecureField, passwordTextField
        case rePasswordSecureField, rePasswordTextField
    }
}

#Preview {
    SaveKeyView(profileCreationViewModel: ProfileCreationView.ViewModel.init())
}
