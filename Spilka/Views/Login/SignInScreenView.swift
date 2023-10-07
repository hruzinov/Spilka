//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct SignInScreenView: View {
    var screenSize = UIScreen.main.bounds.size
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = ViewModel()

    @State var isPresentedSelectorSheet = false
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("Your phone number")
                    .font(.title)
                    .padding(.bottom, 25)
                Text("Confirm country code and enter phone number. Or use one of existing account")
                    .frame(maxWidth: screenSize.width * 0.8)
                    .padding(.bottom, 15)
                    .multilineTextAlignment(.center)

                HStack {
                    Button {
                        isPresentedSelectorSheet.toggle()
                    } label: {
                        Text("\(viewModel.countryCode.flag) \(viewModel.countryCode.dialCode)")
                            .bold()
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .padding(10)
                            .frame(width: screenSize.width * 0.25, height: 50)
                            .background(.thinMaterial,
                                        in: RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer()
                    TextField("", text: $viewModel.phoneNumber)
                        .bold()
                        .font(.title3)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .frame(width: screenSize.width * 0.625, height: 50)
                        .background(.thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 10))
                        .onChange(of: viewModel.phoneNumber) {
                            viewModel.phoneNumberChanged()
                        }
                        .focused($textFieldFocused)
//                        .onAppear {
//                            textFieldFocused = true
//                        }
                        .submitLabel(.next)
                        .onSubmit {
                            guard !viewModel.isPhoneContinueButtonDisabled &&
                                    !viewModel.isWaitingServer else { return }

                            textFieldFocused = false
                            viewModel.handlePhoneContinueButton()
                        }
                }
                .frame(width: screenSize.width * 0.9)
                .padding(.bottom, 10)

                Button {
                    textFieldFocused = false
                    viewModel.handlePhoneContinueButton()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.isPhoneContinueButtonDisabled ? .gray :
                                (colorScheme == .dark ? .white  : .black))
                        .frame(width: viewModel.isWaitingServer
                               ? 45 : screenSize.width * 0.90, height: 45)
                        .overlay {
                            if viewModel.isWaitingServer {
                                ProgressView()
                                    .tint(colorScheme == .light ? .white  : .black)
                            } else {
                                Text("Continue")
                                    .foregroundStyle(colorScheme == .light ? .white  : .black)
                                    .font(.title3)
                            }
                        }
                }
                .disabled(
                    viewModel.isPhoneContinueButtonDisabled || viewModel.isWaitingServer
                )

                Text(viewModel.phoneMessagePrompt)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .frame(maxWidth: screenSize.width * 0.9)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 217/255, green: 4/255, blue: 41/255))
                    }
                    .opacity(viewModel.isShowingPhoneMessagePrompt ? 1 : 0)

                Divider()
                    .background(.gray)
                    .padding(.vertical, 30)
                    .frame(width: screenSize.width * 0.90, height: 45)
                    .overlay {
                        Text("OR")
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 15)
                            .background( Rectangle().fill(
                                colorScheme == .light ? .white  : .black)
                            )
                    }

                SignInWithAppleToFirebase(isWaitingServer: $viewModel.isWaitingServer, { response in
                    viewModel.handleSignInWithApple(response)
                })
                .frame(width: screenSize.width * 0.90, height: 45)
                .overlay {
                    if viewModel.isWaitingServer {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                    }
                }

                GoogleSignInButton(scheme: .dark, style: .wide, state: .normal) {
                    viewModel.handleSignInWithGoogle()
                }
                .frame(width: screenSize.width * 0.90, height: 45)
                .overlay {
                    if viewModel.isWaitingServer {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                    }
                }
            }
            .sheet(isPresented: $isPresentedSelectorSheet) {
                NavigationStack {
                    List {
                        ForEach(viewModel.filteredRecords, id: \.id) { country in
                            Button {
                                viewModel.countryCode = country
                                isPresentedSelectorSheet.toggle()
                            } label: {
                                HStack {
                                    Text(country.flag)
                                    Text(country.title)
                                        .font(.headline)
                                    Spacer()
                                    Text(country.dialCode)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $viewModel.searchCountry, isPresented: .constant(true), prompt: "Your country")
                }
                .presentationDetents([.medium, .large])
            }
            .presentationDetents([.medium, .large])
            .navigationDestination(isPresented: $viewModel.isGoToVerification) {
                EnterVerificationCodeView(signInViewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.isGoToCreateProfile) {
                ProfileCreationView(signInViewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.isGoToImportPrivateKey) {
                ImportKeyView(signInViewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.isGoToMainView) {
                MainView(skipCheck: true)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SignInScreenView()
}
