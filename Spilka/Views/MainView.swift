//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = ViewModel()
    @State var needCheck = true

    var body: some View {
        NavigationStack {
            if viewModel.isLoaded, let isLoggedIn = viewModel.isLoggedIn {
                if isLoggedIn {
                    Text("You're logged in")
                } else {
                    WelcomeScreenView()
                }
            } else {
                ProgressView("Loading...")
                    .task {
                        viewModel.startingUp(needCheck: needCheck)
                    }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    MainView()
}
