//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import SwiftUI

struct WelcomeScreenView: View {
    var screenSize = UIScreen.main.bounds.size
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Spacer()

                Text("Welcome to Spilka")
                    .font(.title)
                    .fontWeight(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: screenSize.width * 0.80)

                Spacer()

                Image(.startScreen)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenSize.width)
                    .mask {
                        Circle()
                            .padding(5)
                    }

                Spacer()

                Text("A fast and secure space to communicate with your colleagues and friends")
                    .multilineTextAlignment(.center)
                    .frame(width: screenSize.width * 0.80)
                    .font(.title3)

                Spacer()

                NavigationLink {
                    SignInScreenView()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .light ? .black : .white)
                        .frame(width: screenSize.width * 0.80, height: 45)
                        .overlay {
                            Text("Continue")
                                .foregroundStyle(colorScheme == .dark ? .black : .white)
                                .font(.title3)
                        }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    WelcomeScreenView()
}
