//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import SwiftUI

struct SignInScreenView: View {
    var screenSize = UIScreen.main.bounds.size
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = ViewModel()

    @State var isPresentedSelectorSheet = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("Your phone number")
                    .font(.title)
                    .padding(.bottom, 25)
                Text("Confirm country code and enter phone number. Or use one of existing account")
                    .frame(maxWidth: screenSize.width * 0.8)
                    .padding(.bottom, 15)

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
                        .keyboardType(.numbersAndPunctuation)
                        .padding(10)
                        .frame(width: screenSize.width * 0.625, height: 50)
                        .background(.thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 10))
                        .onChange(of: viewModel.phoneNumber) {
                            viewModel.phoneNumberChanged()
                        }
                }
                .frame(width: screenSize.width * 0.9)
                .padding(.bottom, 10)

                Button {
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

//                GoogleSignInButton(action: handleSignInButton)
//
//                    .font(.title2)
//                GoogleSignInButton(scheme: .dark, style: .wide, state: .normal, action: handleSignInButton)
//                    .frame(width: screenSize.width * 0.80, height: 45)
                Button {
                    //                    SignUpScreen()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? .white : .black)
                        .frame(width: screenSize.width * 0.90, height: 45)
                        .overlay {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .font(.title)
                                Text("Continue with Apple")
                                    .font(.title3)
                            }
                            .foregroundStyle(colorScheme == .light ? .white : .black)
                        }
                }
            }
            .sheet(isPresented: $isPresentedSelectorSheet) {
                NavigationStack {
//                    Button(action: { isPresentedSelectorSheet.toggle() }, label: {
//                        Text("Cancel")
//                            .font(.title3)
//                            .padding(.vertical, 10)
//                    })
                    //                List(filteredRecords.wrap) { country in
                    //                    HStack {
                    //                        Text(country.flag)
                    //                        /
                    //                    }
                    //                }
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
                    .searchable(text: $viewModel.searchCountry, prompt: "Your country")
                }
                .presentationDetents([.medium, .large])
            }
            .presentationDetents([.medium, .large])
            .navigationDestination(isPresented: $viewModel.isGoToVerification) {
                EnterVerificationCodeView(signInViewModel: viewModel)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SignInScreenView()
}
