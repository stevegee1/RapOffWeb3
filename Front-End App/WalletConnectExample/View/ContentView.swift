//
//  ContentView.swift
//  WalletConnectExample
//
//  Created by Lev Baklanov on 12.06.2022.
//

       


import SwiftUI
import web3swift
import Web3Core
import BigInt

var connection = false

//struct ContentView: View {
//    @State private var selectedTab: Tab = .house
//
//    let titleColor = UIColor(red: 220, green: 0, blue: 20, alpha: 1.0)
//
//
//    init() {
//
//        UITabBar.appearance().isHidden = true
//    }
//    var body: some View {
//        ZStack {
//            VStack {
//                VStack{
//                    TabView(selection: $selectedTab){
//                        if(selectedTab == .house){
//
////                            HomePage()
//
//                        }else if(selectedTab == .person){
////                            PersonView()
//
//                        }else if(selectedTab == .chart){
//                            Text("Settings")
//
//                        }
//
//
//
//                    }
//
//
//                }
//                Spacer()
//
//                CustomTabBar(selectedTab: $selectedTab)
//            }
//        }
//
//    }
//}
struct HomePage: View {
    var viewModel: ExampleViewModel

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("RapOff")
                        .foregroundColor(Color.red)
                        .font(.custom("Molend-Regular", size: 36))
                        .padding(.trailing)
                        .frame(width: 236.843, height: 72.842)
                        .shadow(color: .black, radius: 3)
                    Spacer()
                }

                ZStack {
                    Color(.secondarySystemBackground)

                    ScrollView(.vertical) {
                        VStack {
                            Image("TopPic")
                                .resizable()
                                .frame(height: 300.0)

                            Spacer()
                            RapperPost(viewModel: viewModel)
                            RapperPost(viewModel: viewModel)
                            RapperPost(viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}


struct RapperPost: View {
    @Environment(\.managedObjectContext) private var viewContext

    
    var viewModel: ExampleViewModel

    @State private var showBetSheet = false
    @State private var selectedRapper = "J-king" // Selected rapper

    @State private var showWatchView = false
    @State private var betAmount = ""
    @State private var rapperIndex : BigInt = 0
    @State private var betContract = 0


    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image("rapper1")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .cornerRadius(100)
                        .aspectRatio(contentMode: .fill)
                        .padding(.horizontal)
                    Text("J-king")
                }

                VStack {
                    Spacer().padding(.top)
                    Text("Fliptop")
                        .font(.system(size: 20, weight: .heavy))
                    Text("12 Aug 2023")
                    Text("1:30pm")
                    Spacer()

                    NavigationLink(destination: WatchView(viewModel: viewModel)    .environment(\.managedObjectContext, viewContext)
, isActive: $showWatchView) {
                        Text("Watch")
                            .frame(width: 100.0, height: 50.0)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                    .isDetailLink(false)
                }

                VStack {
                    Image("rapper2")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .cornerRadius(100)
                        .aspectRatio(contentMode: .fill)
                        .padding(.horizontal)
                    Text("Apoc")
                }
            }

            HStack {
                Spacer()
                Label("2.5", systemImage: "")
                    .padding(.trailing, 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: 70, height: 40)
                    )
                Spacer()

                Button("BET NOW") {
                    showBetSheet = true
                    
                }
                .frame(width: 120.0, height: 50.0)
                .foregroundColor(Color.white)
                .background(Color.black)
                .cornerRadius(6)

                Spacer()
                Label("3.5", systemImage: "")
                    .padding(.trailing, 2.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: 70, height: 40)
                    )
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(7)
        .sheet(isPresented: $showBetSheet) {
                    betSheet
                }
    }
    
    private var betSheet: some View {
        
            VStack {
                Text("Place Your Bet")
                    .font(.title)
                    .padding()
                    .foregroundColor(.black)
                
                Picker(selection: $selectedRapper, label: Text("Select a rapper")) {
                    Text("J-king").tag("J-king")
                    Text("Apoc").tag("Apoc")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)

                TextField("Enter bet amount", text: $betAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(.black) // Set the text color to black
                    .background(Color.white) // Add a white background
                    .cornerRadius(10) // Add rounded corners
                    .padding(.horizontal, 20) // Adjust horizontal padding
                
                HStack {
                    Spacer()

                    Button(action: {
                        if let amount = Double(betAmount) {
                            // Perform the bet confirmation action
                            betContract = Int(amount)
                            print("Bet amount: \(amount)")
                                   if selectedRapper == "Apoc" {
                                       rapperIndex = 1
                                   }else if(selectedRapper == "J-king") {
                                       rapperIndex = 0
                                   }
                        }
                        showBetSheet = false
                        Task { do {
                           
//                            let result = try await viewModel.readContractMethod(contractAddress: "0x3c78C640d9f94434b7aeBa329B300Bcf7deaca0b", methodName: "owner", fromAddress: "\(viewModel.walletAccount!)"
//)
//                            print(result)
                            
//                            let secondr = try await viewModel.writeContractMethod(contractAddress: "0x3c78C640d9f94434b7aeBa329B300Bcf7deaca0b", methodName: "setRapper", fromAddress: "\(viewModel.walletAccount!)")
//                            print(secondr)
//                            let signer = ExampleViewModel.UserAuthenticationSigningProvider(walletConnect: viewModel.walletConnect!)

//                            print(amount)
//                            print(rapperIndex)
//                            print("here is my bet amount : \(betContract) and my index \(rapperIndex)")
//                            print($betAmount)
                            let thirdr = try await viewModel.writeContractMethod2(contractAddress: K.contractAddress, methodName: "betOnRapper",value: betContract, fromAddress: "\(viewModel.walletAccount!)",params: [BigUInt(rapperIndex),BigUInt(betContract)])
                            print(thirdr)

                                                                                 
//

////
//           let value = "0.0"
//                            let walletAddress = EthereumAddress(viewModel.walletAccount!)
//
//        let contractAddress = EthereumAddress("0x9B233976FBFA8040210f2EeB71402F978cEB5C6b")
//
//                            let web3 = try await Web3.InfuraGoerliWeb3()
//                            let abiVersion = 2
//                            let contractMethod = "requesting"
//                            let parameters : [AnyObject] = [2]
//                            let extraData : Data = Data()
//                            let contract = web3.contract(contractAddress, at: contractAddress, abiVersion: abiVersion)
//
//                            let amount = Web3.Utils.parseToBigUInt(value, units: .ether)
//
//                            let options =
//                            let tx = contract.method(contractMethod,parameters:parameters,extraData : extraData)
//
//                            viewModel.sendEther(to: "0x61DE09B291D1A6d2a2eBbFb0DF0f94bb707cB43F", value: "5")
//                            print(result)
                            
                            // Handle the result here
                        } catch {
                            // Handle the error here
                            print(error)
                        }}
                        betAmount = "" // Reset the betAmount to clear the text
                        
                    }) {
                        Text("Confirm")
                            .frame(width: 100, height: 40)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black)
                            )
                    }
                    .padding()
                    .background(Color.white) // Add a white background
                    .cornerRadius(20) // Add rounded corners

                    Button(action: {
                        showBetSheet = false
                    }) {
                        Text("Cancel")
                            .frame(width: 100, height: 40)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black)
                            )
                    }
                    .padding()
                    .background(Color.white) // Add a white background
                    .cornerRadius(20) // Add rounded corners

                    Spacer()
                }
                .padding(.top, 20) // Add top padding
            }
            .padding()
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
            ) // Add a white background with rounded corners
            .padding(.horizontal, 40) // Adjust horizontal padding
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.black]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }

    




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(viewModel: ExampleViewModel())
    }
}
