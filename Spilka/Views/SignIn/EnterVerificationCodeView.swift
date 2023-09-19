//
//  Created by Evhen Gruzinov on 19.09.2023.
//

import SwiftUI

struct EnterVerificationCodeView: View {
    @Environment(\.colorScheme) var colorScheme
    var screenSize = UIScreen.main.bounds.size
    @ObservedObject var signInViewModel: SignInScreenView.ViewModel

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
                                in: RoundedRectangle(cornerRadius: 10)
                    )
                    .onChange(of: signInViewModel.verificationCode) {
                        signInViewModel.verificationCodeChanged()
                    }

                Button {
                    signInViewModel.handleCodeContinueButton()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(signInViewModel.isCodeContinueButtonDisabled ? .gray :
                                (colorScheme == .dark ? .white  : .black))
                        .frame(width: signInViewModel.isWaitingServer
                               ? 45 : screenSize.width * 0.5, height: 45)
                        .overlay {
                            if signInViewModel.isWaitingServer {
                                ProgressView()
                                    .tint(colorScheme == .light ? .white  : .black)
                            } else {
                                Text("Continue")
                                    .foregroundStyle(colorScheme == .light ? .white  : .black)
                                    .font(.title3)
                            }
                        }
                        .padding(.top, 10)
                }
                .disabled(
                    signInViewModel.isCodeContinueButtonDisabled ||
                    signInViewModel.isWaitingServer
                )
                .navigationDestination(isPresented: $signInViewModel.isGoToCreateProfile) {
                    ProfileCreationView()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    EnterVerificationCodeView(signInViewModel: SignInScreenView.ViewModel())
}
