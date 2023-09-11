//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import SwiftUI
//import FirebaseCore
//import FirebaseAuth
//import GoogleSignIn
//import GoogleSignInSwift

struct SignInScreen: View {
    var screenSize = UIScreen.main.bounds.size

    @State var countryCode: CountryCode = CountryCode.get("UA")
    @State var phoneNumber: String = ""
    @State var searchCountry: String = ""
    @State var isContinueButtonDisabled = true
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
                        Text("\(countryCode.flag) \(countryCode.dialCode)")
                            .bold()
                            .padding(10)
                            .frame(width: screenSize.width * 0.25, height: 50)
                            .background(.thinMaterial,
                                        in: RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer()
                    TextField("", text: $phoneNumber)
                        .bold()
                        .font(.title3)
                        .keyboardType(.numbersAndPunctuation)
                        .padding(10)
                        .frame(width: screenSize.width * 0.625, height: 50)
                        .background(.thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 10))
                        .onChange(of: phoneNumber) {
                            applyPatternOnNumbers(&phoneNumber, countryCode: countryCode,
                                                  pattern: countryCode.pattern, replacementCharacter: "#")
                            if phoneNumber.count >= countryCode.limit && phoneNumber.count <= 18 {
                                isContinueButtonDisabled = false
                            } else {
                                isContinueButtonDisabled = true
                            }
                        }
                }
                .frame(width: screenSize.width * 0.9)

                Button {
                    if phoneNumber.count == countryCode.limit {
                        handleContinueButton(number: phoneNumber, country: countryCode)
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isContinueButtonDisabled ? .gray : .black)
                        .frame(width: screenSize.width * 0.90, height: 45)
                        .overlay {
                            Text("Continue")
                                .foregroundStyle(.white)
                                .font(.title3)
                        }
                }
                .disabled(isContinueButtonDisabled)

                Divider()
                    .background(.gray)
                    .padding(.vertical, 30)
                    .frame(width: screenSize.width * 0.90, height: 45)
                    .overlay {
                        Text("OR")
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 15)
                            .background( Rectangle().fill(.white) )
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
                        .fill(.black)
                        .frame(width: screenSize.width * 0.90, height: 45)
                        .overlay {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .font(.title)
                                Text("Continue with Apple")
                                    .font(.title3)
                            }
                            .foregroundStyle(.white)
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
                        ForEach(filteredRecords, id: \.id) { country in
                            Button {
                                countryCode = country
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
                    .searchable(text: $searchCountry, prompt: "Your country")
                }
                .presentationDetents([.medium, .large])
            }
            .presentationDetents([.medium, .large])
        }
        .foregroundStyle(.black)
    }

    var filteredRecords: [CountryCode] {
        if searchCountry.isEmpty {
            return CountryCode.allCases
        } else {
            return CountryCode.allCases.filter { $0.title.lowercased().contains(searchCountry.lowercased()) }
        }
    }


    func handleContinueButton(number: String, country: CountryCode) {
        
    }

    func applyPatternOnNumbers(_ stringvar: inout String, countryCode: CountryCode, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar
        if pureNumber.hasPrefix(countryCode.dialCode) {
            pureNumber = String(pureNumber.dropFirst(countryCode.dialCode.count))
        }
        pureNumber = pureNumber.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        stringvar = pureNumber
    }
}

#Preview {
    SignInScreen()
}
