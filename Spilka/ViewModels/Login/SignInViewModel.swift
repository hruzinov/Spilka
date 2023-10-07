//
//  Created by Evhen Gruzinov on 18.09.2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore
import CryptoSwift
import CryptoKit
import AuthenticationServices

extension SignInScreenView {
    @MainActor class ViewModel: ObservableObject {
        @Published var countryCode: CountryCode = CountryCode.get("UA")
        @Published var phoneNumber: String = ""
        @Published var verificationCode: String = ""
        @Published var verificationID: String = ""
        @Published var userAccount: UserAccount?

        @Published var searchCountry: String = ""
        @Published var phoneMessagePrompt: String = ""
        @Published var codeMessagePrompt: String = ""
        @Published var fileImportMessagePrompt: String = ""
        @Published var isPhoneContinueButtonDisabled = true
        @Published var isCodeContinueButtonDisabled = true
        @Published var isShowingFileImportMessagePrompt = false

        @Published var isGoToVerification = false
        @Published var isGoToCreateProfile = false
        @Published var isGoToSigninSelector = false
        @Published var isGoToImportPrivateKey = false
        @Published var isGoToMainView = false
        @Published var isWaitingServer = false

        fileprivate var currentNonce: String?

        @Published var smsCodeTimeOut = 0
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        func handlePhoneContinueButton() {
            guard phoneNumber.count >= countryCode.limit else { return }
            isWaitingServer = true
            phoneMessagePrompt = ""
            codeMessagePrompt = ""

            sendSMSCode { success, id in
                if success, let id {
                    let keychain = KeychainSwift()
                    keychain.synchronizable = true
                    keychain.set(id, forKey: "authVerificationID")

                    self.verificationID = id
                    self.isGoToVerification.toggle()
                }
            }
        }

        func sendSMSCode(_ competition: @escaping(Bool, String?) -> Void ) {
            Auth.auth().languageCode = Locale.current.language.languageCode?.identifier ?? "en"

            let phone = countryCode.dialCode + phoneNumber

            PhoneAuthProvider.provider()
                .verifyPhoneNumber(phone, uiDelegate: nil) { [self] id, error in
                    if let error {
                        self.showPhoneMessagePrompt(error)
                        ErrorLog.save(error)
                        isWaitingServer = false
                        competition(false, nil)
                    } else if let id {
                        smsCodeTimeOut = 60
                        competition(true, id)
                    }
                    isWaitingServer = false
                }
        }

        func handleCodeContinueButton() {
            guard verificationCode.count == 6 else { return }
            isWaitingServer = true
            phoneMessagePrompt = ""
            codeMessagePrompt = ""

            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error {
                    self.showCodeMessagePrompt(error)
                    ErrorLog.save(error)
                    self.isWaitingServer = false
                    return
                }
                if let user = authResult?.user {
                    self.signInUser(user.uid)
                }
                self.isWaitingServer = false
            }
        }

        func handleSignInWithApple(_ response: SignInWithAppleToFirebaseResponse) {
            if response == .success {
                let keychain = KeychainSwift()
                keychain.synchronizable = true
                guard let userUID = keychain.get("accountUID") else {
                    ErrorLog.save("Some problems with geting userUID from keychain")
                    return
                }
                self.userAccount?.phoneNumber = nil
                self.userAccount?.countryCode = nil
                signInUser(userUID)
            } else if response == .error {
                ErrorLog.save("Maybe the user cancelled or there's no internet")
            }
        }

        func handleSignInWithGoogle() {
            self.isWaitingServer = true

            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
                guard error == nil else {
                    self.showGAuthMessagePrompt(error!)
                    ErrorLog.save(error!)
                    isWaitingServer = false
                    return
                }
                guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                    isWaitingServer = false
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error {
                        self.showCodeMessagePrompt(error)
                        ErrorLog.save(error)
                        self.isWaitingServer = false
                        return
                    }
                    if let user = authResult?.user {
                        self.userAccount?.phoneNumber = nil
                        self.userAccount?.countryCode = nil
                        self.signInUser(user.uid)
                    }
                    self.isWaitingServer = false
                }
            }
        }

        func signInUser(_ userUID: String) {
            let dbase = Firestore.firestore()
            let accountRef = dbase.collection("accounts").document(userUID)

            let keychain = KeychainSwift()
            keychain.synchronizable = true

            accountRef.getDocument { user, error in
                if let error {
                    self.showCodeMessagePrompt(error)
                    ErrorLog.save(error)
                } else if let user, user.exists, let userData = try? user.data(as: UserAccount.self) {
                    self.userAccount = userData
                    if let privateKeyData = keychain.getData("userPrivateKey") {
                        self.isWaitingServer = true
                        if CryptoKeys.checkValidity(privateKeyData: privateKeyData,
                                                    publicKeyData: Data(hex: userData.publicKey)) {
                            self.isGoToMainView.toggle()
                        } else {
                            self.isGoToImportPrivateKey.toggle()
                        }
                    } else {
                        self.isGoToImportPrivateKey.toggle()
                    }
                } else {
                    keychain.set(userUID, forKey: "accountUID")
                    self.isGoToCreateProfile.toggle()
                }
            }
        }

        func privateKeyFileSelected(_ result: Result<URL, Error>) {
            self.isWaitingServer = true
            self.isShowingFileImportMessagePrompt = false

            switch result {
            case .success(let fileURL):
                do {
                    guard let userAccount else {
                        self.isWaitingServer = false
                        return
                    }

                    let isAccessing = fileURL.startAccessingSecurityScopedResource()

                    let privateKeyData = try Data(contentsOf: fileURL)
                    let publicKeyData = Data(hex: userAccount.publicKey)

                    if CryptoKeys.checkValidity(privateKeyData: privateKeyData, publicKeyData: publicKeyData) {
                        self.isWaitingServer = false
                        self.isGoToMainView.toggle()
                    } else {
                        self.isWaitingServer = false
                        self.showFileImportMessagePrompt("File contains an outdated or invalid key")
                        ErrorLog.save("Key not handled security check")
                    }
                    if isAccessing {
                        fileURL.stopAccessingSecurityScopedResource()
                    }
                } catch {
                    self.showFileImportMessagePrompt("This is not a private key file. Choose another one")
                    self.isWaitingServer = false
                    ErrorLog.save(error)
                }

            case .failure(let error):
                self.isWaitingServer = false
                self.showFileImportMessagePrompt(error.localizedDescription)
            }
        }

        func showGAuthMessagePrompt(_ error: Error) {
            withAnimation {
                let errorCode = (error as NSError).code
                switch errorCode {
                case -5:
                    self.phoneMessagePrompt = ""

                default:
                    self.phoneMessagePrompt = error.localizedDescription
                }
            }
        }

        func showPhoneMessagePrompt(_ error: Error) {
            withAnimation {
                let errorKey = (error as NSError).userInfo["FIRAuthErrorUserInfoNameKey"] as? String
                switch errorKey {
                case "ERROR_INVALID_PHONE_NUMBER":
                    self.phoneMessagePrompt = "Invalid phone number, check and try again"

                default:
                    self.phoneMessagePrompt = error.localizedDescription
                }
            }
        }

        func showCodeMessagePrompt(_ error: Error) {
            withAnimation {
                let errorKey = (error as NSError).userInfo["FIRAuthErrorUserInfoNameKey"] as? String
                switch errorKey {
                case "ERROR_INVALID_VERIFICATION_CODE":
                    self.codeMessagePrompt =
                    "The verification code is incorrect or expired. Please check and try again"

                default:
                    self.codeMessagePrompt = error.localizedDescription
                }
            }
        }

        func showFileImportMessagePrompt(_ error: String) {
            withAnimation {
                self.isShowingFileImportMessagePrompt = true
                self.fileImportMessagePrompt = error
            }
        }
    }
}

// Helpers functions
extension SignInScreenView.ViewModel {
    var isShowingPhoneMessagePrompt: Bool {
        phoneMessagePrompt.count > 0
    }
    var isShowingCodeMessagePrompt: Bool {
        codeMessagePrompt.count > 0
    }

    var filteredRecords: [CountryCode] {
        if searchCountry.isEmpty {
            return CountryCode.allCases
        } else {
            return CountryCode.allCases.filter { $0.title.lowercased().contains(searchCountry.lowercased()) }
        }
    }

    func phoneNumberChanged() {
        applyPatternOnNumbers(&phoneNumber, countryCode: countryCode,
                              pattern: countryCode.pattern, replacementCharacter: "#")
        if phoneNumber.count >= countryCode.limit && phoneNumber.count <= 18 {
            isPhoneContinueButtonDisabled = false
        } else {
            isPhoneContinueButtonDisabled = true
        }
    }
    func verificationCodeChanged() {
        if verificationCode.count == 6 {
            isCodeContinueButtonDisabled = false
        } else {
            isCodeContinueButtonDisabled = true
        }
    }

    func applyPatternOnNumbers(_ num: inout String, countryCode: CountryCode,
                               pattern: String, replacementCharacter: Character) {
        var pureNumber = num
        if pureNumber.hasPrefix(countryCode.dialCode) {
            pureNumber = String(pureNumber.dropFirst(countryCode.dialCode.count))
        }
        pureNumber = pureNumber.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                num = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        num = pureNumber
    }
}
