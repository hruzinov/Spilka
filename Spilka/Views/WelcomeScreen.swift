//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import SwiftUI

struct WelcomeScreen: View {
    var screenSize = UIScreen.main.bounds.size

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Spacer()

                Text("Welcome to Spilka")
                    .font(.title)
                    .fontWeight(.black)

                Spacer()

                Image(.startScreen)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenSize.width)

                Spacer()

                Text("A fast and secure space to communicate with your colleagues and friends")
                    .multilineTextAlignment(.center)
                    .frame(width: screenSize.width * 0.80)
                    .font(.title3)

                Spacer()

                NavigationLink {
                    SignInScreen()
                } label: {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.black)
                        .frame(width: screenSize.width * 0.80, height: 45)
                        .overlay {
                            Text("Continue")
                                .foregroundStyle(.white)
                                .font(.title3)
                        }
                }
                Spacer()
//                NavigationLink {
//                    SignInScreen()
//                } label: {
//                    HStack {
//                        Text("I already have account")
//                        Image(systemName: "chevron.right")
//                            .font(.footnote)
//                    }
//                    .foregroundStyle(.black)
//                }
            }
        }
    }
}

#Preview {
    WelcomeScreen()
}
