//
//  ConnectView.swift
//  WalletConnectExample
//
//  Created by Ahmed Eslam on 25/05/2023.
//

import SwiftUI
struct ConnectView: View {
    @ObservedObject var viewModel: ExampleViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("Welcome to RapOff")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        // Background shadow
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.black.opacity(0.5))
                            .blur(radius: 10)
                            .offset(x: 0, y: 4)
                            .padding(.bottom, 16)
                    )
                
                if viewModel.session == nil && !viewModel.isReconnecting {
                    if viewModel.isConnecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .opacity(1)
                            .disabled(true)
                    } else {
                        MainContainer()
                            .environmentObject(viewModel)
                            .opacity(1)
                        
                            .onAppear {
                                viewModel.initWalletConnect()
                            }
                            .cornerRadius(9)
                            .shadow(color: .black, radius: 4, x: 0, y: 2)
//                        .shadow(color: .gray, radius: 15, x: 0, y: 2)
                    }
                }
                
                Spacer()
            }
        }
    }
}

//struct ConnectView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        ConnectView(viewModel: viewModel)
//    }
//}
