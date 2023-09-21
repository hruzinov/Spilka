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

            Auth.auth().languageCode = "en" // TODO: Get language code from settings

            let phone = countryCode.dialCode + phoneNumber
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(phone, uiDelegate: nil) { [self] id, error in
                    if let error {
//                        self.showMessagePrompt(error.localizedDescription)
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
//                    self.showMessagePrompt(error.localizedDescription)
                    print(error)
                    self.isWaitingServer = false
                    return
                }
                if let userUID = authResult?.user.uid {
                    let db = Firestore.firestore()
                    let accountRef = db.collection("accounts").document(userUID)

                    accountRef.getDocument { user, error in
                        if let error {
//                            self.showMessagePrompt(error.localizedDescription)
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
