//
//  Created by Evhen Gruzinov on 18.09.2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
// import GoogleSignIn
// import GoogleSignInSwift

extension SignInScreenView {
    @MainActor class ViewModel: ObservableObject {
        @Published var countryCode: CountryCode = CountryCode.get("UA")
        @Published var phoneNumber: String = ""
        @Published var verificationCode: String = ""
        @Published var verificationID: String = ""

        @Published var searchCountry: String = ""
        @Published var phoneMessagePrompt: String = ""
        @Published var codeMessagePrompt: String = ""
        @Published var isPhoneContinueButtonDisabled = true
        @Published var isCodeContinueButtonDisabled = true
        @Published var isGoToVerification = false
        @Published var isGoToCreateProfile = false
        @Published var isWaitingServer = false
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

        func handlePhoneContinueButton() {
            guard phoneNumber.count >= countryCode.limit else { return }
            isWaitingServer = true

            Auth.auth().languageCode = Locale.current.language.languageCode?.identifier ?? "en"

            let phone = countryCode.dialCode + phoneNumber
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(phone, uiDelegate: nil) { [self] id, error in
                    if let error {
                        self.showPhoneMessagePrompt(error)
                        print(error)
                        isWaitingServer = false
                        return
                    } else if let id {
                        UserDefaults.standard.set(id, forKey: "authVerificationID")
                        verificationID = id
                        isGoToVerification.toggle()
                    }
                    isWaitingServer = false
                }
        }

        func handleCodeContinueButton() {
            guard verificationCode.count == 6 else { return }
            isWaitingServer = true

            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error {
                    self.showCodeMessagePrompt(error)
                    print(error)
                    self.isWaitingServer = false
                    return
                }
                if let userUID = authResult?.user.uid {
                    let dbase = Firestore.firestore()
                    let accountRef = dbase.collection("accounts").document(userUID)

                    accountRef.getDocument { user, error in
                        if let error {
                            self.showCodeMessagePrompt(error)
                            print(error)
                        } else if let user, user.exists {
                            print("User Exist") // TODO: Sign in when user exist
                        } else {
                            UserDefaults.standard.set(userUID, forKey: "accountUID")
                            self.isGoToCreateProfile.toggle()
                        }
                    }
                }
                self.isWaitingServer = false
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
}
