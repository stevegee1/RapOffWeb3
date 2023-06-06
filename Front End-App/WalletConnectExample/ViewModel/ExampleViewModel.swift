//
//  ExampleViewModel.swift
//  WalletConnectExample
//
//  Created by Lev Baklanov on 12.06.2022.
//

    import Foundation
    import WalletConnectSwift
    import SwiftUI
    import web3swift
    import Web3Core
    import BigInt
    import UInt256
    protocol TransactionSigner {
        func signTransaction(transaction: CodableTransaction, completion: @escaping (Result<Data, Error>) -> Void)
    }


    class ExampleViewModel: ObservableObject {
        
        let deepLinkDelay = 0.5
        @Published
          var isLoading: Bool = true
        @Published
        var session: Session?
        @Published
        var currentWallet: Wallet?
        @Published
        var isConnecting: Bool = false
        @Published
        var isReconnecting: Bool = false
        @Published
        var walletConnect: WalletConnect?
        var pendingDeepLink: String?
        
        var walletAccount: String? {
            return session?.walletInfo!.accounts[0].lowercased()
        }
        
        var walletName: String {
            if let name = session?.walletInfo?.peerMeta.name {
                return name
            }
            return currentWallet?.name ?? ""
        }
        
        //Checking that connected to Polygon chain
        var isWrongChain: Bool {
            if let chainId = session?.walletInfo?.chainId, chainId != 5001 {
                return true
            }
            return false
        }
        
        func openWallet() {
            if let wallet = currentWallet {
                if let url = URL(string: wallet.formLinkForOpen()),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
       
       
        

        func initWalletConnect() {
            print("init wallet connect: \(walletConnect == nil)")
            
            if walletConnect == nil {
                isLoading = true

                walletConnect = WalletConnect(delegate: self)
                if walletConnect!.haveOldSession() {
                    withAnimation {
                        isConnecting = true
                    }
                    walletConnect!.reconnectIfNeeded()
                }else {
                    isLoading = false
                }
            }
        }
        
        
        func connect(wallet: Wallet) {
            guard let walletConnect = walletConnect else { return }
            let connectionUrl = walletConnect.connect()
            pendingDeepLink = wallet.formWcDeepLink(connectionUrl: connectionUrl)
            currentWallet = wallet
        }
        
        func disconnect() {
            guard let session = session, let walletConnect = walletConnect else { return }
            try? walletConnect.client?.disconnect(from: session)
            withAnimation {
                self.session = nil
            }
            UserDefaults.standard.removeObject(forKey: WalletConnect.sessionKey)
        }
        
        func triggerPendingDeepLink() {
            guard let deepLink = pendingDeepLink else { return }
            pendingDeepLink = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + deepLinkDelay) {
                if let url = URL(string: deepLink), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Open app in App Store or do something else
                }
            }
        }
        
        func sendTx(to: String) {
            guard let session = session,
                  let client = walletConnect?.client,
                  let from = walletAccount else {
                print("nil client or session")
                return
            }
            let tx = Client.Transaction(
                from: from,
                to: to,
                data: "",
                gas: nil,
                gasPrice: nil,
                value: "0x1",
                nonce: nil,
                type: nil,
                accessList: nil,
                chainId: nil,
                maxPriorityFeePerGas: nil,
                maxFeePerGas: nil)
            do {
                try client.eth_sendTransaction(url: session.url,
                                               transaction: tx) { [weak self] response in
                    self?.handleResponse(response)
                }
                DispatchQueue.main.async {
                    self.openWallet()
                }
            } catch {
                print("error sending tx: \(error)")
            }
        }
        
        private func handleResponse(_ response: Response) {
            DispatchQueue.main.async {
                if let error = response.error {
                    print("got error sending tx: \(error)")
                    return
                }
                do {
                    let result = try response.result(as: String.self)
                    print("got response result: \(result)")
                } catch {
                    print("Unexpected response type error: \(error)")
                }
            }
        }
    }

    extension ExampleViewModel: WalletConnectDelegate {
        func failedToConnect() {
            DispatchQueue.main.async { [unowned self] in
                withAnimation {
                    isConnecting = false
                    isReconnecting = false
                }
            }
        }

        func didConnect() {
            DispatchQueue.main.async { [unowned self] in
                withAnimation {
                    isConnecting = false
                    isReconnecting = false
                    session = walletConnect?.session
                    if currentWallet == nil {
                        currentWallet = Wallets.bySession(session: session)
                    }
                    // Load initial web3 info here
                }
            }
        }
        
        func didSubscribe(url: WCURL) {
            triggerPendingDeepLink()
        }
        
        func didUpdate(session: Session) {
            var accountChanged = false
            if let curSession = self.session,
               let curInfo = curSession.walletInfo,
               let info = session.walletInfo,
               let curAddress = curInfo.accounts.first,
               let address = info.accounts.first,
               curAddress != address || curInfo.chainId != info.chainId {
                accountChanged = true
                do {
                    let sessionData = try JSONEncoder().encode(session)
                    UserDefaults.standard.set(sessionData, forKey: WalletConnect.sessionKey)
                } catch {
                    print("Error saving session in update: \(error)")
                }
            }
            DispatchQueue.main.async { [unowned self] in
                withAnimation {
                    self.session = session
                }
                if accountChanged {
                    // Handle address change
                }
            }
        }

        func didDisconnect(isReconnecting: Bool) {
            if !isReconnecting {
                DispatchQueue.main.async { [unowned self] in
                    withAnimation {
                        isConnecting = false
                        session = nil
                    }
                }
            }
            DispatchQueue.main.async { [unowned self] in
                withAnimation {
                    self.isReconnecting = isReconnecting
                }
            }
        }
    }
extension ExampleViewModel {
    func sendEther(to address: String, value: String) {
        guard let session = session,
              let client = walletConnect?.client,
              let from = walletAccount else {
            print("nil client or session")
            return
        }
        
        let transaction = Client.Transaction(
            from: from,
            to: address,
            data: "0x",
            gas: "0x3183d",
            gasPrice: "0x1dfd14000",
            value: value,
            nonce: "0x0000000000000000",
            type: "0x1",
            accessList: nil,
            chainId: "0x1",
            maxPriorityFeePerGas: nil,
            maxFeePerGas: "0xe4e1c0" )
        
        do {
            try client.eth_sendTransaction(url: session.url,
                                           transaction: transaction) { [weak self] response in
                self?.handleResponse(response)
            }
            DispatchQueue.main.async {
                self.openWallet()
            }
        } catch {
            print("Error sending transaction: \(error)")
        }
    }
}

extension ExampleViewModel {
    func decodeResponse(data: Data) throws -> BigInt {
            struct Response: Decodable {
                let value: BigUInt
            }
            
            let decoder = JSONDecoder()
            
            let response = try decoder.decode([Response].self, from: data)
            
            guard let value = response.first?.value else {
                throw MyError.decodingError
            }
            
            return BigInt(value)
        }
    
//    func writeContractMethod(contractAddress: String, methodName: String, fromAddress: String) async throws {
//        // Create a web3 instance
//        guard let url = URL(string: "https://rpc.testnet.mantle.xyz/") else { return }
//        let privateKey = "0x5e2f1327a7bd0e106c9bb265dbe362aef5144f1e5525deb07f729deae7e63b1d"
//
//        let web3 = try await Web3.new(url, network: .Custom(networkID: 5001))
//        // Use the 'web3' instance here
//        let address = EthereumAddress(contractAddress)
//        if let fileURL = Bundle.main.url(forResource: "MyContractABI", withExtension: "json") {
//            do {
//                let jsonData = try Data(contentsOf: fileURL)
////                let parameters = [_pool_id, depositAmt]
//
//                // Convert JSON data to a string
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    let contract = web3.contract(jsonString, at: address , abiVersion: 2)!
//                    let writeOp = contract.createWriteOperation(methodName, parameters: ["test"])!
//
//                    // Set the sender address
//                    writeOp.transaction.from = EthereumAddress(fromAddress)
//                    writeOp.transaction.chainID = 5001
//                    writeOp.transaction.gasLimit = BigUInt(67105813441)
//                    writeOp.transaction.gasPrice = BigUInt(168387)
//                    do {
//                        let write = try await writeOp.writeToChain(password: privateKey)
//                        print("Write response:", write) // Add this line to print the response
//                    } catch let error as Web3Error {
//                        print("Web3 error:", error.localizedDescription)
//                    } catch {
//                        print("Other error:", error.localizedDescription)
//                    }
//                }
//            } catch {
//                print("Error reading JSON file:", error.localizedDescription)
//            }
//        } else {
//            print("JSON file not found.")
//        }
//    }

    
    
    func deployContract(bytecode: Data, abiString: String, parameters: [Any], fromAddress: String) async throws -> Any {
        // Create a web3 instance
        guard let url = URL(string: "https://rpc.testnet.mantle.xyz/") else { return MyError.decodingError }

        let web3 = try await Web3.new(url, network: .Custom(networkID: 5001))
            // Use the 'web3' instance here
        // Create a contract instance using the provided ABI string
        guard let contract = web3.contract(abiString, at: nil, abiVersion: 2) else {
            throw MyError.invalidContract
        }

        // Prepare the deploy operation
        guard let deployOp = contract.prepareDeploy(bytecode: bytecode, constructor: contract.contract.constructor, parameters: parameters) else {
            throw MyError.deployOperationFailed
        }

        // Set the "from" address and gas limit for the deploy operation
        deployOp.transaction.from = EthereumAddress(fromAddress)
        deployOp.transaction.gasLimit = BigUInt(3000000)
        
        // Send the deploy transaction and wait for the result
        let result = try await deployOp.writeToChain(password: "0x5e2f1327a7bd0e106c9bb265dbe362aef5144f1e5525deb07f729deae7e63b1d")

        return result
    }

  

   
        
    //extension ExampleViewModel {
    //    func readContractMethod(contractAddress: String, methodName: String, fromAddress: String) async throws -> Any {
    //        // Create a web3 instance
    //        let web3 = Web3.InfuraMainnetWeb3()
    //
    //        // Create a contract instance using the ERC20 ABI and contract address
    //        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress)!
    //
    //        // Create a read operation for the contract method
    //        let readOp = contract.createReadOperation(methodName)!
    //
    //        // Set the "from" address for the read operation
    //        readOp.transaction.from = EthereumAddress(fromAddress)
    //
    //        // Call the contract method and wait for the response
    //        let response = try await readOp.callContractMethod()
    //
    //        return response
    //    }
    //}
    
    
    
    
    
    
    //
    //
    //extension ExampleViewModel {
    //    func writeTransactionAndCallMethod(abiString: String, bytecode: Data, parameters: [Any], from address: String) {
    //        guard let client = walletConnect?.client else {
    //            print("nil client")
    //            return
    //        }
    //
    //        let contract = client.contract(abiString, at: nil, abiVersion: 2)
    //        let deployOp = contract?.prepareDeploy(bytecode: bytecode, constructor: contract!.contract.constructor, parameters: parameters)
    //        deployOp?.transaction.from = EthereumAddress(address)
    //        deployOp?.transaction.gasLimitPolicy = .manual(3000000)
    //
    //        do {
    //            let result = try deployOp?.writeToChain(password: "web3swift")
    //            // Handle the result of the deployment and method call
    //            print("Deployment result: \(result)")
    //        } catch {
    //            print("Error deploying contract and calling method: \(error)")
    //        }
    //    }
    //}
    //extension ExampleViewModel {
    //    func feeHistory(blockCount: UInt, block: BlockNumber, percentiles: [Double]) async throws -> Web3.Oracle.FeeHistory {
    //        guard let provider = web3.provider else {
    //            throw MyError.missingProvider
    //        }
    //
    //        let requestCall: APIRequest = .feeHistory(blockCount, block, percentiles)
    //        let response: APIResponse<Web3.Oracle.FeeHistory> = try await APIRequest.sendRequest(with: provider, for: requestCall)
    //        return response.result
    //    }
    //}
}
