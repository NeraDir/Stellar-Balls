import SwiftUI

struct StarChartView: View {
    @State private var selectedConstellation: Constellation?
    @State private var searchText = ""
    
    private var filteredConstellations: [Constellation] {
        if searchText.isEmpty {
            return Constellation.constellations
        } else {
            return Constellation.constellations.filter { constellation in
                constellation.name.localizedCaseInsensitiveContains(searchText) ||
                constellation.season.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#4B0082"), Color.black, Color(hex: "#800080")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("🌌 Star Chart")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text("Discover constellations and their stories")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("Search constellations...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        hideKeyboard()
                                    }
                                }
                            }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredConstellations) { constellation in
                                ConstellationCard(constellation: constellation) {
                                    selectedConstellation = constellation
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(item: $selectedConstellation) { constellation in
            ConstellationDetailView(constellation: constellation)
        }
    }
}

struct ConstellationCard: View {
    let constellation: Constellation
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(constellation.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Best seen in \(constellation.season)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#FF4500"))
                }
                
                Spacer()
                
                Text("⭐")
                    .font(.title)
            }
            
            Text(constellation.mythology)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Brightest Star")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Text(constellation.brightestStar)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button("Learn More") {
                    onTap()
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: "#FF4500"))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct ConstellationDetailView: View {
    let constellation: Constellation
    @State private var aiStory = ""
    @StateObject private var gptService = GPTService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#4B0082"), Color.black, Color(hex: "#800080")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 15) {
                            Text("⭐")
                                .font(.system(size: 80))
                            
                            Text(constellation.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("The \(constellation.name) Constellation")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#FF4500"))
                        }
                        .padding()
                        
                        // Constellation info
                        VStack(spacing: 15) {
                            InfoRowStars(title: "Mythology", value: constellation.mythology)
                            InfoRowStars(title: "Brightest Star", value: constellation.brightestStar)
                            InfoRowStars(title: "Best Season", value: constellation.season)
                            InfoRowStars(title: "Coordinates", value: constellation.coordinates)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.3))
                        )
                        .padding(.horizontal)
                        
                        // AI story section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🤖 AI Constellation Story")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            if aiStory.isEmpty {
                                Button("Get AI Story") {
                                    getConstellationStory()
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#FF4500"))
                                )
                                .disabled(gptService.isLoading)
                                
                                if gptService.isLoading {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#FF4500")))
                                        Text("AI is creating a story...")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding()
                                }
                            } else {
                                Text(aiStory)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.4))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(hex: "#FF4500"), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.2))
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FF4500"))
                }
            }
        }
    }
    
    private func getConstellationStory() {
        let prompt = "Tell an engaging story about the \(constellation.name) constellation, including its mythology: \(constellation.mythology). Make it educational and captivating."
        
        gptService.askGPT(prompt: prompt) { response in
            aiStory = response
        }
    }
}

struct InfoRowStars: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StarChartView()
} 