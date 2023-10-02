//
//  Created by Evhen Gruzinov on 19.09.2023.
//

import SwiftUI

struct ProfileCreationView: View {
    var screenSize = UIScreen.main.bounds.size
    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel = ViewModel()
    @ObservedObject var signInViewModel: SignInScreenView.ViewModel
    @FocusState private var fullNameTextFieldFocused
    @FocusState private var usernameTextFieldFocused

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Circle()
                        .stroke(.black, lineWidth: 2)
                        .fill(.thickMaterial)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.title)
                        }
                }
                .mask {
                    Circle()
                }
                .frame(width: 100)

                VStack(spacing: 10) {
                    Text("Your info")
                        .font(.title)
                    Text("Enter your name. \n Optional: profile photo and username")
                        .frame(width: screenSize.width * 0.8)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 15)

                TextField("Full Name", text: $viewModel.profileName)
                    .keyboardType(.alphabet)
//                    .padding(.horizontal, 5)
                    .padding(10)
                    .background(.thinMaterial,
                                in: RoundedRectangle(cornerRadius: 10))
                    .frame(width: screenSize.width * 0.65)
                    .focused($fullNameTextFieldFocused)
                    .submitLabel(.next)
                    .onSubmit {
                        fullNameTextFieldFocused.toggle()
                        usernameTextFieldFocused.toggle()
                    }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Username ")
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 10)

                    TextField("Help people find you easier", text: $viewModel.profileUsername)
                        .keyboardType(.alphabet)
                        .padding(10)
                        .background(.thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 10))
                        .focused($usernameTextFieldFocused)
                        .submitLabel(.done)
//                        .onSubmit {
//                            usernameTextFieldFocused.toggle()
//                        }

                        .disabled(true) // TODO: Remove after implementing checking
                }
                .frame(width: screenSize.width * 0.65)
                .padding(.vertical, 15)

                Button {
                    fullNameTextFieldFocused = false
                    usernameTextFieldFocused = false
//                    viewModel.handleRegisterButton()
                    viewModel.handleGoToSaveKeys()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.profileName.count == 0 ? .gray :
                                (colorScheme == .dark ? .white  : .black))
                        .frame(width: viewModel.isWaitingServer
                               ? 45 : screenSize.width * 0.65, height: 45)
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
                    viewModel.profileName.count == 0 ||
                    viewModel.isWaitingServer
                )
            }
            .onAppear {
                fullNameTextFieldFocused.toggle()
                viewModel.countryCode = signInViewModel.countryCode.code
                viewModel.phoneNumber = signInViewModel.phoneNumber
            }
        }
        .navigationDestination(isPresented: $viewModel.isGoToSaveKeyView) {
            SaveKeyView(profileCreationViewModel: viewModel)
        }
    }
}

#Preview {
    ProfileCreationView(signInViewModel: SignInScreenView.ViewModel())
}
