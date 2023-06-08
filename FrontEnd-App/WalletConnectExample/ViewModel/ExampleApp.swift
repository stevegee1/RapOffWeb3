import SwiftUI

@main
struct WalletConnectExampleApp: App {
    @StateObject var viewModel = ExampleViewModel()

    var body: some Scene {
        WindowGroup {
            if viewModel.walletAccount != nil {
                TabbedView()
                    .environmentObject(viewModel)
            } else {
                ConnectView(viewModel: viewModel)
            }
        }
    }
}

struct TabbedView: View {
    @EnvironmentObject var viewModel: ExampleViewModel
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case profile
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            switch selectedTab {
            case .home:
                HomePage(viewModel: viewModel)
            case .profile:
                NavigationView {
                    PersonView(viewModel: viewModel)
                        .navigationBarHidden(true)
                }
            }

            ZStack {
                Color(red: 0.5, green: 0, blue: 0)
                    .ignoresSafeArea(edges: .bottom)
                    .frame(height: 48) // Adjust the height as desired
                    .shadow(color: .black, radius: 2, x: 0, y: -2)

                HStack(spacing: 70) { // Adjust the spacing as desired
                    tabItem(tab: .home, systemName: "house")
                        .opacity(selectedTab == .home ? 1 : 0.5) // Change opacity
                    tabItem(tab: .profile, systemName: "person")
                        .opacity(selectedTab == .profile ? 1 : 0.5) // Change opacity
                }
                .padding(.horizontal, 16)
                .foregroundColor(.white)
            }
        }
    }

    private func tabItem(tab: Tab, systemName: String) -> some View {
        Button(action: {
            selectedTab = tab // Remove withAnimation block
        }) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 60, height: 48) // Adjust the height as desired
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(selectedTab == tab ? 0.1 : 0)) // Change opacity
                        .frame(height: 4)
                        .padding(.top, 44) // Adjust the top padding as desired
                )
                .foregroundColor(selectedTab == tab ? .white : .gray) // Adjust the color of selected and unselected items
        }
    }
}
