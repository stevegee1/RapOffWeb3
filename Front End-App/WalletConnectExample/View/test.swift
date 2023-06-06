//
//  test.swift
//  WalletConnectExample
//
//  Created by Ahmed Eslam on 23/05/2023.
//

import SwiftUI

struct test: View {
    @StateObject
     var viewModel = ExampleViewModel()
    var body: some View {
                MainContainer()
                    .environmentObject(viewModel)
                    .onAppear {
                        viewModel.initWalletConnect()}
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
