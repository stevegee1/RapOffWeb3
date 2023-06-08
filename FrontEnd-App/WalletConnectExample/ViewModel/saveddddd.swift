////import Foundation
//import WalletConnectSwift
//import SwiftUI
//import web3swift
//import Web3Core
//import BigInt
//import UInt256
//
//extension ExampleViewModel {
//    class UserAuthenticationSigningProvider: TransactionSigner {
//        
//        private weak var walletConnect: WalletConnect?
//        
//        init(walletConnect: WalletConnect) {
//            self.walletConnect = walletConnect
//        }
//        
//        func signTransaction(transaction: CodableTransaction, completion: @escaping (Result<Data, Error>) -> Void) {
//            guard let walletConnect = walletConnect else {
//                let error = NSError(domain: "WalletConnect not initialized", code: 0, userInfo: nil)
//                completion(.failure(error))
//                return
//            }
//            
//            guard let session = walletConnect.session,
//                  let client = walletConnect.client,
//                  let _ = session.walletInfo?.accounts.first else {
//                let error = NSError(domain: "Invalid session or client", code: 0, userInfo: nil)
//                completion(.failure(error))
//                return
//            }
//            
//            do {
//                // Encode the transaction as Data
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .withoutEscapingSlashes
//                let encodedTransaction = try encoder.encode(transaction)
//                let hexString = encodedTransaction.reduce("") { $0 + String(format: "%02x", $1) }
//                // Send the raw transaction data using `eth_sendRawTransaction`
//                try client.eth_sendRawTransaction(url: session.url, data: hexString) { [weak self] response in
//                    self?.handleResponse(response, completion: completion)
//                    
//                    // Open wallet and reopen the app if signing is done
//                    DispatchQueue.main.async {
//                        self?.openWallet()
//                    }
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }
//
//              
//        
//        private func openWallet() {
//            guard let walletConnect = walletConnect,
//                  let session = walletConnect.session,
//                  let wallet = Wallets.bySession(session: session) else {
//                // Handle the case where the WalletConnect or session is not available
//                return
//            }
//            
//            let connectionUrl = walletConnect.connect()
//            let deepLink = wallet.formWcDeepLink(connectionUrl: connectionUrl)
//            
//            guard let url = URL(string: deepLink) else {
//                // Handle the case where the deep link URL is invalid
//                return
//            }
//            
//            DispatchQueue.main.async {
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url, options: [:]) { success in
//                        if success {
//                            // Handle the case where the wallet app was successfully opened
//                            print("Wallet app opened successfully.")
//                        } else {
//                            // Handle the case where opening the wallet app failed
//                            print("Failed to open the wallet app")
//                        }
//                    }
//                } else {
//                    // Handle the case where the wallet app is not installed
//                    print("Wallet app is not installed")
//                }
//            }
//        }
//        
//        private func handleResponse(_ response: Response, completion: @escaping (Result<Data, Error>) -> Void) {
//            if let error = response.error {
//                completion(.failure(error))
//                return
//            }
//            
//            do {
//                let result = try response.result(as: String.self)
//                guard let data = hexStringToData(result) else {
//                    let error = NSError(domain: "Invalid signed transaction data", code: 0, userInfo: nil)
//                    completion(.failure(error))
//                    return
//                }
//                completion(.success(data))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//        
//        private func hexStringToData(_ hexString: String) -> Data? {
//            var hex = hexString
//            var data = Data()
//            while !hex.isEmpty {
//                let index = hex.index(hex.startIndex, offsetBy: 2)
//                let byte = hex[..<index]
//                hex = String(hex[index...])
//                
//                if var number = UInt8(byte, radix: 16) {
//                    data.append(&number, count: 1)
//                } else {
//                    return nil
//                }
//            }
//            return data
//        }
//    }
//    
//    
//    
//    
//    
//    
//    // Helper function to load JSON from a file
//    func loadJSONFromFile(named filename: String) -> Data? {
//        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                return data
//            } catch {
//                print("Error loading JSON file: \(error)")
//            }
//        }
//        return nil
//    }
//    enum MyError: Error {
//        case invalidAddress
//        case decodingError
//        case invalidContract
//        case deployOperationFailed
//        case transactionCreationError
//        case contractCreationError
//        
//    }
//    func writeContractMethod2(contractAddress: String, methodName: String, fromAddress: String, signer: UserAuthenticationSigningProvider) async throws {
//        // Create a web3 instance
//        guard let url = URL(string: "https://rpc.testnet.mantle.xyz/") else {
//            print("Invalid URL.")
//            return
//        }
//        //        let privateKey = "0x5e2f1327a7bd0e106c9bb265dbe362aef5144f1e5525deb07f729deae7e63b1d"
//        //        let keystoreManager = KeystoreManager.managerForPrivateKey(privateKey)
//        
//        let web3 = try await Web3.new(url, network: .Custom(networkID: 5001))
//        
//        //        let web3 = try await Web3.new(url, network: .Custom(networkID: 5001))
//        
//        // Use the 'web3' instance here
//        let address = EthereumAddress(contractAddress)
//        
//        if let fileURL = Bundle.main.url(forResource: "MyContractABI", withExtension: "json") {
//            do {
//                let jsonData = try Data(contentsOf: fileURL)
//                
//                // Convert JSON data to a string
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    let contract = web3.contract(jsonString, at: address)!
//                    let writeOp = contract.createWriteOperation(methodName, parameters: ["test"])!
//                    
//                    // Set the sender address
//                    guard let senderAddress = EthereumAddress(fromAddress) else {
//                        print("Invalid sender address.")
//                        return
//                    }
//                    writeOp.transaction.from = senderAddress
//                    
//                    // Get the current nonce value
//                    let nonce = try await web3.eth.getTransactionCount(for: senderAddress)
//                    writeOp.transaction.nonce = nonce
//                    
//                    // Set the gas price
//                    let gasPrice = try await web3.eth.gasPrice()
//                    writeOp.transaction.gasPrice = gasPrice
//                    
//                    // Set a higher gas limit
//                    let gasLimit: BigUInt = 3000000 // Set a suitable gas limit
//                    writeOp.transaction.gasLimit = gasLimit
//                    
//                    // Sign the transaction using the signer object
//                    signer.signTransaction(transaction: writeOp.transaction) { result in
//                        switch result {
//                        case .success(let signedTransactionData):
//                            // Send the raw transaction
//                            Task {
//                                do {
//                                    let transactionResult = try await web3.eth.send(raw: signedTransactionData)
//                                    print("Transaction result:", transactionResult)
//                                } catch {
//                                    print("Error sending transaction:", error)
//                                }
//                            }
//                        case .failure(let error):
//                            print("Error signing transaction:", error)
//                        }
//                    }
//                }
//            } catch {
//                print("Error reading JSON file:", error.localizedDescription)
//            }
//        } else {
//            print("JSON file not found.")
//        }
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    func readContractMethod(contractAddress: String, methodName: String, fromAddress: String) async throws -> Any {
//        
//        // Create a web3 instance
//        guard let url = URL(string: "https://rpc.testnet.mantle.xyz/") else { return "" }
//        
//        let web3 = try await Web3.new(url, network: .Custom(networkID: 5001))
//        // Use the 'web3' instance here
//        let address = EthereumAddress(contractAddress)
//        if let fileURL = Bundle.main.url(forResource: "MyContractABI", withExtension: "json") {
//            do {
//                let jsonData = try Data(contentsOf: fileURL)
//                
//                // Convert JSON data to a string
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    //                    print(jsonString)
//                    
//                    let contract = web3.contract(jsonString, at: address)!
//                    
//                    let readOp = contract.createReadOperation(methodName,extraData: Data())!
//                    
//                    
//                    
//                    
//                    //                    do {
//                    //                        let call = try await writeOp?.callContractMethod()
//                    //                        let returnAnswer = call?["0"] as! String
//                    //                        return returnAnswer
//                    //                    } catch {
//                    //                        print("error")
//                    //                    }
//                    //
//                    
//                    readOp.transaction.chainID = 5001
//                    // Set the "from" address for the read operation
//                    //                    readOp.transaction.chainID = 5001
//                    readOp.transaction.from = EthereumAddress(fromAddress)
//                    // Call the contract method and wait for the response
//                    //                    print(contract)
//                    //                    print(readOp)
//                    
//                    
//                    
//                    
//                    
//                    do {
//                        let call = try await readOp.callContractMethod()
//                        let returnAnswer = call["0"] as! String
//                        return returnAnswer
//                    } catch {
//                        print("error")
//                    }
//                    
//                    
//                    //                let response = try await readOp.callContractMethod()
//                    
//                    
//                    //                print(response)
//                    
//                    return "response"
//                    
//                }
//            } catch {
//                print("Error reading JSON file:", error)
//            }
//        } else {
//            print("JSON file not found.")
//        }
//        // Create a read operation for the contract method
//        return ""
//    }
//    
//    
//}
//





//MARK: - second save


//
//class UserAuthenticationSigningProvider: TransactionSigner {
//    
//    private weak var walletConnect: WalletConnect?
//    
//    init(walletConnect: WalletConnect) {
//        self.walletConnect = walletConnect
//    }
//    
//    func signTransaction(transaction: CodableTransaction, completion: @escaping (Result<Data, Error>) -> Void) {
//        guard let walletConnect = walletConnect else {
//            let error = NSError(domain: "WalletConnect not initialized", code: 0, userInfo: nil)
//            completion(.failure(error))
//            return
//        }
//        
//        guard let session = walletConnect.session,
//              let client = walletConnect.client,
//              let _ = session.walletInfo?.accounts.first else {
//            let error = NSError(domain: "Invalid session or client", code: 0, userInfo: nil)
//            completion(.failure(error))
//            return
//        }
//        
//        do {
//            // Encode the transaction as Data
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .withoutEscapingSlashes
//            let encodedTransaction = try encoder.encode(transaction)
//            let hexString = encodedTransaction.reduce("") { $0 + String(format: "%02x", $1) }
//            // Send the raw transaction data using `eth_sendRawTransaction`
//            try client.eth_sendRawTransaction(url: session.url, data: hexString) { [weak self] response in
//                self?.handleResponse(response, completion: completion)
//                
//                // Open wallet and reopen the app if signing is done
//                DispatchQueue.main.async {
//                    self?.openWallet()
//                }
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//
//          
//    
//    private func openWallet() {
//        guard let walletConnect = walletConnect,
//              let session = walletConnect.session,
//              let wallet = Wallets.bySession(session: session) else {
//            // Handle the case where the WalletConnect or session is not available
//            return
//        }
//        
//        let connectionUrl = walletConnect.connect()
//        let deepLink = wallet.formWcDeepLink(connectionUrl: connectionUrl)
//        
//        guard let url = URL(string: deepLink) else {
//            // Handle the case where the deep link URL is invalid
//            return
//        }
//        
//        DispatchQueue.main.async {
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:]) { success in
//                    if success {
//                        // Handle the case where the wallet app was successfully opened
//                        print("Wallet app opened successfully.")
//                    } else {
//                        // Handle the case where opening the wallet app failed
//                        print("Failed to open the wallet app")
//                    }
//                }
//            } else {
//                // Handle the case where the wallet app is not installed
//                print("Wallet app is not installed")
//            }
//        }
//    }
//    
//    private func handleResponse(_ response: Response, completion: @escaping (Result<Data, Error>) -> Void) {
//        if let error = response.error {
//            completion(.failure(error))
//            return
//        }
//        
//        do {
//            let result = try response.result(as: String.self)
//            guard let data = hexStringToData(result) else {
//                let error = NSError(domain: "Invalid signed transaction data", code: 0, userInfo: nil)
//                completion(.failure(error))
//                return
//            }
//            completion(.success(data))
//        } catch {
//            completion(.failure(error))
//        }
//    }
//    
//    private func hexStringToData(_ hexString: String) -> Data? {
//        var hex = hexString
//        var data = Data()
//        while !hex.isEmpty {
//            let index = hex.index(hex.startIndex, offsetBy: 2)
//            let byte = hex[..<index]
//            hex = String(hex[index...])
//            
//            if var number = UInt8(byte, radix: 16) {
//                data.append(&number, count: 1)
//            } else {
//                return nil
//            }
//        }
//        return data
//    }
//}
//
//
