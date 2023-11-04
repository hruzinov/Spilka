//
//  Created by Evhen Gruzinov on 19.09.2023.
//

import SwiftUI

struct EnterVerificationCodeView: View {
    @Environment(\.colorScheme) var colorScheme
    var screenSize = UIScreen.main.bounds.size
    @ObservedObject var signInViewModel: SignInScreenView.ViewModel
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("Enter verification code")
                    .font(.title2)
                    .padding(.bottom, 15)
                Text("If you have already received a code in the past few minutes, enter this code")
                    .frame(maxWidth: screenSize.width * 0.8)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                TextField("", text: $signInViewModel.verificationCode)
                    .bold()
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .frame(width: screenSize.width * 0.5, height: 50)
                    .background(.thinMaterial,
                                in: RoundedRectangle(cornerRadius: 10))
                    .onChange(of: signInViewModel.verificationCode) {
                        signInViewModel.verificationCodeChanged()
                    }
                    .onSubmit {
                        guard !signInViewModel.isCodeContinueButtonDisabled &&
                            !signInViewModel.isWaitingServer else { return }
                        textFieldFocused = false
                        signInViewModel.handleCodeContinueButton()
                    }
                    .focused($textFieldFocused)
                    .onAppear {
                        textFieldFocused = true
                    }

                Button {
                    textFieldFocused = false
                    signInViewModel.handleCodeContinueButton()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(signInViewModel.isCodeContinueButtonDisabled ? .gray :
                            (colorScheme == .dark ? .white : .black))
                        .frame(width: signInViewModel.isWaitingServer
                            ? 45 : screenSize.width * 0.5, height: 45)
                        .overlay {
                            if signInViewModel.isWaitingServer {
                                ProgressView()
                                    .tint(colorScheme == .light ? .white : .black)
                            } else {
                                Text("Continue")
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                                    .font(.title3)
                            }
                        }
                        .padding(.top, 10)
                }
                .disabled(
                    signInViewModel.isCodeContinueButtonDisabled ||
                        signInViewModel.isWaitingServer
                )

                Button {
                    signInViewModel.sendSMSCode { _, _ in
                    }
                } label: {
                    Text(signInViewModel.smsCodeTimeOut > 0 ?
                        "You can request new verification code after \(signInViewModel.smsCodeTimeOut) seconds" :
                        "Resend verification code")
                        .foregroundStyle(signInViewModel.smsCodeTimeOut > 0 ? .gray : .accentColor)
                        .padding(.vertical, 10)
                }
                .disabled(signInViewModel.smsCodeTimeOut > 0)
                .onReceive(signInViewModel.timer) { _ in
                    if signInViewModel.smsCodeTimeOut > 0 {
                        signInViewModel.smsCodeTimeOut -= 1
                    }
                }

                Text(signInViewModel.codeMessagePrompt)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .frame(maxWidth: screenSize.width * 0.9)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 217 / 255, green: 4 / 255, blue: 41 / 255))
                            .padding(-5)
                    }
                    .opacity(signInViewModel.isShowingCodeMessagePrompt ? 1 : 0)
            }
            .navigationBarBackButtonHidden(true)
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
            .navigationTitle(signInViewModel.countryCode.flag + " " +
                signInViewModel.countryCode.dialCode + " " +
                signInViewModel.phoneNumber)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $signInViewModel.isGoToCreateProfile) {
                ProfileCreationView(signInViewModel: signInViewModel)
            }
            .navigationDestination(isPresented: $signInViewModel.isGoToSigninSelector) {
                SignInScreenView(viewModel: signInViewModel)
            }
            .navigationDestination(isPresented: $signInViewModel.isGoToImportPrivateKey) {
                ImportKeyView(signInViewModel: signInViewModel)
            }
            .navigationDestination(isPresented: $signInViewModel.isGoToMainView) {
                MainView(skipCheck: true)
            }
        }
    }
}

#Preview {
    EnterVerificationCodeView(signInViewModel: SignInScreenView.ViewModel())
}
