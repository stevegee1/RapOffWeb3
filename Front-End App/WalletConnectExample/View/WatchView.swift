import SwiftUI
import Web3Core
import BigInt
import CryptoSwift
import WebKit
import CoreData

struct WatchView: View {
    @State private var isLoaded = false // Loading state
    @State private var jKingVotes = 0 // Vote counter for J-king
    @State private var apocVotes = 0 // Vote counter for Apoc
    @State private var didVote = false // Flag to track if the user has voted
    @State private var showAlert = false

    @ObservedObject var viewModel: ExampleViewModel
    private func winnerMessage() -> String {
        if jKingVotes > apocVotes {
            return "The winner is: J-King"
        } else if apocVotes > jKingVotes {
            return "The winner is: Apoc"
        } else {
            return "It's a tie!"
        }
    }

    // Core Data context
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: 0) {
            if isLoaded {
                YouTubeView(videoId: "VoraDyCUBvY")
                    .frame(height: 200)
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 200)
                    .overlay(ProgressView()) // Show a loading indicator
            }

            Spacer() // Pushes the content below the YouTubeView

            ScrollView(.vertical) {
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
                                .font(.headline)
                            Text("Votes: \(jKingVotes)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        VStack {
                            Spacer()
                            Text("VS")
                                .font(.system(size: 40, weight: .heavy))
                                .foregroundColor(.red)
                            Spacer()
                        }

                        VStack {
                            Image("rapper2")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .cornerRadius(100)
                                .aspectRatio(contentMode: .fill)
                                .padding(.horizontal)
                            Text("Apoc")
                                .font(.headline)
                            Text("Votes: \(apocVotes)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 501.0, height: 200.0)

                    HStack(spacing: 20) {
                        VStack {
                            Button(action: {
                                voteForJKing()
                                Task{
                                    let thirdr = try await viewModel.writeContractMethod2(contractAddress: K.contractAddress, methodName: "voteNow",value: 3, fromAddress: "\(viewModel.walletAccount!)",params: [EthereumAddress("0xfdc6ba87c3B645dcF14fa34b1C215Ed725c9AC1E") , "J-King"])
                                    print(thirdr)
                                }
                                
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(jKingButtonColor())
                                        .frame(width: 120, height: 40)

                                    Text("Vote")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.trailing, 5.0)
                            .shadow(color: didVote ? .clear : .yellow, radius: 4, x: 0, y: 2)
                            .disabled(didVote)

                            Spacer()
                        }

                        VStack {
                            Button(action: {
                                voteForApoc()
                                Task{
                                    let thirdr = try await viewModel.writeContractMethod2(contractAddress: K.contractAddress, methodName: "voteNow",value: 3, fromAddress: "\(viewModel.walletAccount!)",params: [(EthereumAddress("0x7693ae16a9A363BDb07D44aDFe3bE0803c949239"),"Apoc")])
                                    print(thirdr)
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(apocButtonColor())
                                        .frame(width: 120, height: 40)

                                    Text("Vote")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.leading, 50.0)
                            .shadow(color: didVote ? .clear : .yellow, radius: 4, x: 0, y: 2)
                            .disabled(didVote)

                            Spacer()
                        }
                    }

                    if didVote {
                        Text("Your vote was placed successfully")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .padding(.top, 20)
                    }

                    Button(action: {
//                        deleteAllVotes()
//
                        Task{
                            let thirdr = try await viewModel.writeContractMethod2(contractAddress: K.contractAddress, methodName: "callWinner",value: nil, fromAddress: "\(viewModel.walletAccount!)", params: [])
                            showAlert = true // Set the flag to true to show the alert

                            print(thirdr)
                        }
                        
                        
                    }) {
                        Text("Show Winner")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                           title: Text("Winner"),
                           message: Text(winnerMessage()),
                           dismissButton: .default(Text("OK"))
                       )
                    
                }
                
            }
        }
        .onAppear {
            // Check if the address has voted before
            fetchVoteCounts()

                       // Check if the address has voted before
                       if hasVoted(for: viewModel.walletAccount ?? "") {
                           didVote = true
                       }

                       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           isLoaded = true // Simulate a delay and mark as loaded
                       }
        }
    }

    private func voteForJKing() {
        guard !didVote else { return } // Skip if the user has already voted
        jKingVotes += 1
        didVote = true
        saveVote(for: viewModel.walletAccount ?? "", jKingVoteCount: 1, apocVoteCount: 0)
    }

    private func voteForApoc() {
        guard !didVote else { return } // Skip if the user has already voted
        apocVotes += 1
        didVote = true
        saveVote(for: viewModel.walletAccount ?? "", jKingVoteCount: 0, apocVoteCount: 1)
    }

    private func jKingButtonColor() -> Color {
        didVote ? .gray : .yellow
    }

    private func apocButtonColor() -> Color {
        didVote ? .gray : .yellow
    }

    private func hasVoted(for address: String) -> Bool {
        // Fetch the Vote entity with the given address
        let fetchRequest: NSFetchRequest<Vote> = Vote.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "address == %@", address)
        do {
            let results = try viewContext.fetch(fetchRequest)
            didVote = !results.isEmpty // Update the didVote flag
            return didVote
        } catch {
            print("Error fetching votes: \(error.localizedDescription)")
            return false
        }
    }
    private func saveVote(for address: String, jKingVoteCount: Int, apocVoteCount: Int) {
        // Fetch the existing Vote entity with the given address or create a new one
        let fetchRequest: NSFetchRequest<Vote> = Vote.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "address == %@", address)

        if let existingVote = try? viewContext.fetch(fetchRequest).first {
            // Update the existing vote counts
            existingVote.jKingVotes += Int32(jKingVoteCount) // Increment J-King votes
            existingVote.apocVotes += Int32(apocVoteCount) // Increment Apoc votes
        } else {
            // Create a new Vote entity and set the vote counts
            let newVote = Vote(context: viewContext)
            newVote.address = address
            newVote.jKingVotes = Int32(jKingVoteCount)
            newVote.apocVotes = Int32(apocVoteCount)
        }

        do {
            try viewContext.save()
            fetchVoteCounts() // Fetch updated vote counts after saving
        } catch {
            print("Error saving vote: \(error.localizedDescription)")
        }
    }
    private func deleteAllVotes() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vote")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(batchDeleteRequest)
            jKingVotes = 0
            apocVotes = 0
            didVote = false
            deleteAllAddresses()
        } catch {
            print("Error deleting votes: \(error.localizedDescription)")
        }
    }
    private func deleteAllAddresses() {
        let fetchRequest: NSFetchRequest<Vote> = Vote.fetchRequest()
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            
            for vote in results {
                vote.address = nil
            }
            
            try viewContext.save()
        } catch {
            print("Error deleting addresses: \(error.localizedDescription)")
        }
    }
    private func fetchVoteCounts() {
        let fetchRequest: NSFetchRequest<Vote> = Vote.fetchRequest()

        do {
            let results = try viewContext.fetch(fetchRequest)
            var totalJKingVotes = 0
            var totalApocVotes = 0

            for vote in results {
                totalJKingVotes += Int(vote.jKingVotes)
                totalApocVotes += Int(vote.apocVotes)
            }

            DispatchQueue.main.async { // Update the vote counts on the main queue
                jKingVotes = totalJKingVotes
                apocVotes = totalApocVotes
            }
        } catch {
            print("Error fetching vote counts: \(error.localizedDescription)")
        }
    }

}

struct YouTubeView: UIViewRepresentable {
    let videoId: String
    func makeUIView(context: Context) ->  WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let demoURL = URL(string: "https://www.youtube.com/embed/\(videoId)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: demoURL))
    }
}
