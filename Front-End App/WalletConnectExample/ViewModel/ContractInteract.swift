//import Foundation
import WalletConnectSwift
import SwiftUI
import web3swift
import Web3Core
import BigInt
import UInt256

extension ExampleViewModel {
    
    
    
    
    
    // Helper function to load JSON from a file
    func loadJSONFromFile(named filename: String) -> Data? {
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                print("Error loading JSON file: \(error)")
            }
        }
        return nil
    }
    enum MyError: Error {
        case invalidAddress
        case decodingError
        case invalidContract
        case deployOperationFailed
        case transactionCreationError
        case contractCreationError
        
    }
    func getValue(for userInput: Int) -> BigUInt {
        let value = BigUInt(userInput) * BigUInt(10).power(18)
        return value
    }
    func writeContractMethod2(contractAddress: String, methodName: String,value:Int?, fromAddress: String,params : [ Any]) async throws {
           // Create a web3 instance
           guard let url = URL(string: "https://rpc.testnet.mantle.xyz/") else { return }
        let privateKeyString = K.privateKey
           let privateKeyData = Data(hex: privateKeyString)

           let web3 = try await Web3.new(url, network: .Custom(networkID: 5001))

           // Use the 'web3' instance here
           let address = EthereumAddress(contractAddress)

           if let fileURL = Bundle.main.url(forResource: "MyContractABI", withExtension: "json") {
               do {
                   let jsonData = try Data(contentsOf: fileURL)

                   // Convert JSON data to a string
                   if let jsonString = String(data: jsonData, encoding: .utf8) {
                       let contract = web3.contract(jsonString, at: address)!
                       let writeOp = contract.createWriteOperation(methodName, parameters: params)!

                       // Set the sender address
                       guard let senderAddress = EthereumAddress(fromAddress) else {
                           print("Invalid sender address.")
                           return
                       }
                       writeOp.transaction.from = senderAddress

                       // Get the current nonce value
                       let nonce = try await web3.eth.getTransactionCount(for: senderAddress)
                       writeOp.transaction.nonce = nonce
//                       writeOp.transaction.value = 2

                       // Set the gas price
                       let gasPrice = try await web3.eth.gasPrice()
                       writeOp.transaction.gasPrice = gasPrice
                       if value != nil {
                           let value = getValue(for: value!)
                           print(value)
                           writeOp.transaction.value = BigUInt(value ?? 0)

                       }

                       
                       
                       // Set a higher gas limit
                       let gasLimit: BigUInt = 3000000 // Set a suitable gas limit
                       writeOp.transaction.gasLimit = gasLimit

                       // Sign the transaction
                       try writeOp.transaction.sign(privateKey: privateKeyData)

                       // Get the signed transaction data
                       guard let transactionData = writeOp.transaction.encode() else {
                           print("Error encoding the transaction.")
                           return
                       }

                       // Send the raw transaction
                       let transactionResult = try await web3.eth.send(raw: transactionData)
                       print("Transaction result:", transactionResult)
                   }
               } catch {
                   print("Error reading JSON file:", error.localizedDescription)
               }
           } else {
               print("JSON file not found.")
           }
       }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func readContractMethod(contractAddress: String, methodName: String, fromAddress: String) async throws -> Any {
        
        // Create a web3 instance
        guard let url = URL(string: "https://rpc.testnet.mantle.xyz/") else { return "" }
        
        let web3 = try await Web3.new(url, network: .Custom(networkID: 5001))
        // Use the 'web3' instance here
        let address = EthereumAddress(contractAddress)
        if let fileURL = Bundle.main.url(forResource: "MyContractABI", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: fileURL)
                
                // Convert JSON data to a string
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    //                    print(jsonString)
                    
                    let contract = web3.contract(jsonString, at: address)!
                    
                    let readOp = contract.createReadOperation(methodName,extraData: Data())!
                    
                    
                    
                    
                    //                    do {
                    //                        let call = try await writeOp?.callContractMethod()
                    //                        let returnAnswer = call?["0"] as! String
                    //                        return returnAnswer
                    //                    } catch {
                    //                        print("error")
                    //                    }
                    //
                    
                    readOp.transaction.chainID = 5001
                    // Set the "from" address for the read operation
                    //                    readOp.transaction.chainID = 5001
                    readOp.transaction.from = EthereumAddress(fromAddress)
                    // Call the contract method and wait for the response
                    //                    print(contract)
                    //                    print(readOp)
                    
                    
                    
                    
                    
                    do {
                        let call = try await readOp.callContractMethod()
                        let returnAnswer = call["0"] as! String
                        return returnAnswer
                    } catch {
                        print("error")
                    }
                    
                    
                    //                let response = try await readOp.callContractMethod()
                    
                    
                    //                print(response)
                    
                    return "response"
                    
                }
            } catch {
                print("Error reading JSON file:", error)
            }
        } else {
            print("JSON file not found.")
        }
        // Create a read operation for the contract method
        return ""
    }
    
    
}

