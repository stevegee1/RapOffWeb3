////
////  Encrypt.swift
////  RapOff
////
////  Created by Ahmed Eslam on 03/06/2023.
////
//
//import Foundation
//import web3swift
//import Web3Core
//
//struct KeystoreManager {
//    static func createEncryptedKeystore(privateKey: String, password: String) throws -> EthereumKeystoreV3? {
//        // Create a keystore manager from the private key
//        guard let keystore = EthereumKeystoreV3(privateKey) else {
//            print("Failed to create keystore.")
//            return nil
//        }
//
//        // Set the keystore's password
//        let keyData = try JSONEncoder().encode(keystore.keystoreParams)
//        let encryptedKeyData = try BIP39Generator.encryptKey(keyData, password: password)
//        let encryptedKeystore = try EthereumKeystoreV3(encryptedKeyJSON: encryptedKeyData)
//
//        return encryptedKeystore
//    }
//}
