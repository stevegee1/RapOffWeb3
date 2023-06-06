import SwiftUI
import WebKit

struct WatchView: View {
    @State private var isLoaded = false // Loading state
    @State private var jKingVotes = 0 // Vote counter for J-king
    @State private var apocVotes = 0 // Vote counter for Apoc
    @State private var didVote = false // Flag to track if the user has voted

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
                }
                .padding()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoaded = true // Simulate a delay and mark as loaded
            }
        }
    }

    private func voteForJKing() {
        jKingVotes += 1
        didVote = true
    }
    
    private func voteForApoc() {
        apocVotes += 1
        didVote = true
    }

    private func jKingButtonColor() -> Color {
        didVote ? .gray : .yellow
    }
    
    private func apocButtonColor() -> Color {
        didVote ? .gray : .yellow
    }
}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView()
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
