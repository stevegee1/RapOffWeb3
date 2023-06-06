//
//  MainContainer.swift
//  WalletConnectExample
//
//  Created by Lev Baklanov on 12.06.2022.



// //                    Button {
//                        viewModel.sendTx(to: "0x89e7d8Fe0140523EcfD1DDc4F511849429ecB1c2")
//                    } label: {
//                        HStack {
//                            Spacer()
//                            Text("Send tx")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                                .foregroundColor(Color.white)
//                            Spacer()
//                        }
//                        .padding(.vertical, 15)
//                        .background(Color.blue)
//                        .cornerRadius(32)
//                    }
//                    .padding(.horizontal, 30)
//                    .padding(.top, 30)
//                }

import SwiftUI

struct MainContainer: View {
    @EnvironmentObject var viewModel: ExampleViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.session == nil {
                Button(action: {
                    viewModel.connect(wallet: Wallets.Metamask)
                }, label: {
                    HStack {
                        Image("MetaMask_Fox")
                            .resizable()
                            .padding(.leading, 5.0)
                            .frame(width: 36, height: 35)
                        Text("Connect")
                        
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            
                            

                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .frame(width: 130, height: 50)
                    .background(Color(red: 0.208, green: 0.337, blue: 0.569))
                    .foregroundColor(.red)
                    .cornerRadius(9)
                                   })
                .padding(.trailing, 15)
            } else {
                if viewModel.isWrongChain {
                    Text("Connected to wrong chain. Please connect to Mantle")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, 30)
                } else {
                    Button(action: {
                        viewModel.disconnect()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Disconnect")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 15)
                        .frame(width: 120, height:50) // Decrease the button size
                        .background(Color.red)
                        .cornerRadius(3)
                        .shadow(color: .gray, radius: 5)
                    })
                    .padding(.trailing, 17)
                }
            }
        }
    }
}

struct MainContainer_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}



//Text("Connected")
//                    .font(.system(size: 17))
//                    .fontWeight(.bold)
//
//                Text("Address: \(viewModel.walletAccount ?? "")")
//                    .font(.system(size: 13))
//                    .fontWeight(.regular)
//                    .lineLimit(1)
//                    .truncationMode(.middle)
//                    .padding(.top, 10)
//                    .padding(.horizontal, 20)
