// swiftlint:disable all
//
//  SignInWithAppleToFirebase.swift
//  LoginWithAppleFirebaseSwiftUI
//
//  Created by Joseph Hinkle on 12/15/19.
//  Copyright © 2019 Joseph Hinkle. All rights reserved.
//

import UIKit
import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

struct SignInWithApple: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
      switch colorScheme {
      case .light:
          return ASAuthorizationAppleIDButton(type: .default, style: .black)
      case .dark:
          return ASAuthorizationAppleIDButton(type: .default, style: .whiteOutline)
      @unknown default:
          return ASAuthorizationAppleIDButton(type: .default, style: .black)
      }
  }

  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
  }
}

enum SignInWithAppleToFirebaseResponse {
    case success
    case error
}

struct SignInWithAppleToFirebase: UIViewControllerRepresentable {
    @Binding var isWaitingServer: Bool
    @State var appleSignInDelegates: SignInWithAppleDelegates! = nil
    let onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> ())?
    @State var currentNonce: String?

    init(isWaitingServer: Binding<Bool>, _ onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> ())? = nil) {
        self.onLoginEvent = onLoginEvent
        self._isWaitingServer = isWaitingServer
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIHostingController(rootView: SignInWithApple().onTapGesture(perform: showAppleLogin))
        return vc as UIViewController
    }

    func updateUIViewController(_ uiView: UIViewController, context: Context) {
    }

    func showAppleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]
        request.nonce = sha256(nonce)

        performSignIn(using: [request])
    }

    private func performSignIn(using requests: [ASAuthorizationRequest]) {
        guard let currentNonce = self.currentNonce else {
            return
        }
        appleSignInDelegates = SignInWithAppleDelegates(window: nil, currentNonce: currentNonce, 
                                                        onLoginEvent: self.onLoginEvent, isWaitingServer: $isWaitingServer)

        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = appleSignInDelegates
        authorizationController.presentationContextProvider = appleSignInDelegates
        authorizationController.performRequests()
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if length == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

class SignInWithAppleDelegates: NSObject {
    private let onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> ())?
    private weak var window: UIWindow!
    private var currentNonce: String? // Unhashed nonce.
    @Binding var isWaitingServer: Bool

    init(window: UIWindow?, currentNonce: String, 
         onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> ())? = nil, isWaitingServer: Binding<Bool>) {
        self.window = window
        self.currentNonce = currentNonce
        self.onLoginEvent = onLoginEvent
        self._isWaitingServer = isWaitingServer
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    func firebaseLogin(credential: ASAuthorizationAppleIDCredential) {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = credential.identityToken else {
            ErrorLog.save("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            ErrorLog.save("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }

        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        self.isWaitingServer = true
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error {
                ErrorLog.save(error)
                self.onLoginEvent?(.error)
                return
            }
            if let user = authResult?.user {
                let userUID = user.uid

                let keychain = KeychainSwift()
                keychain.synchronizable = true
                keychain.set(userUID, forKey: "accountUID")

                self.onLoginEvent?(.success)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            self.firebaseLogin(credential: appleIdCredential)
            break
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.onLoginEvent?(.error)
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}
// swiftlint:enable all
