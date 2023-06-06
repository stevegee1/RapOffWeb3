//
//  PersonView.swift
//  HackathonFinal
//
//  Created by Ahmed Eslam on 16/05/2023.
//

import SwiftUI

struct PersonView: View {
    @ObservedObject var viewModel: ExampleViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    if let walletAddress = viewModel.walletAccount {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .frame(width: 90, height: 90)
                                        .opacity(0.8)
                                )
                        }
                        .padding(.top, 50)

                        Text("Your Wallet Address")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text(walletAddress)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .padding(.horizontal, 30)
                            .multilineTextAlignment(.center)
                        
                        MainContainer()
                            .environmentObject(viewModel)
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                        Text("Please Connect a MetaMask Wallet")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                    }

                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}


struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView(viewModel: ExampleViewModel())
    }
}
