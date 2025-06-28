import SwiftUI

struct PlanetaryExplorerView: View {
    @State private var selectedPlanet: Planet?
    @State private var gptResponse: String = ""
    @StateObject private var gptService = GPTService.shared
    @State private var userQuestion: String = ""
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cosmic background
                LinearGradient(
                    colors: [Color(hex: "#4B0082"), Color.black, Color(hex: "#800080")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("🌌 Planetary Explorer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text("Swipe through planets and tap to explore")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // 3D Stack of Planet Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(Planet.planets) { planet in
                                PlanetCard(planet: planet) {
                                    selectedPlanet = planet
                                    showingDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(item: $selectedPlanet) { planet in
            PlanetDetailView(planet: planet)
        }
    }
}

struct PlanetCard: View {
    let planet: Planet
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Planet Emoji
            Text(planet.emoji)
                .font(.system(size: 80))
                .scaleEffect(isPressed ? 0.95 : 1.0)
            
            // Planet Name
            Text(planet.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Basic Info
            Text(planet.basicInfo)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // Stats
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Distance:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(planet.distanceFromSun)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Diameter:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(planet.diameter)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
            
            Text("Tap to explore")
                .font(.caption2)
                .foregroundColor(Color(hex: "#FF4500"))
                .padding(.top, 5)
        }
        .frame(width: 200, height: 280)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: planet.color).opacity(0.3), Color.black.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: planet.color), lineWidth: 1)
                )
        )
        .shadow(color: Color(hex: planet.color).opacity(0.3), radius: 10)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(
            minimumDuration: 0,
            perform: {},
            onPressingChanged: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            }
        )
    }
}

struct PlanetDetailView: View {
    let planet: Planet
    @State private var userQuestion: String = ""
    @State private var gptResponse: String = ""
    @StateObject private var gptService = GPTService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cosmic background
                LinearGradient(
                    colors: [Color(hex: "#4B0082"), Color.black, Color(hex: planet.color)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Planet Header
                        VStack(spacing: 10) {
                            Text(planet.emoji)
                                .font(.system(size: 100))
                            
                            Text(planet.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(planet.basicInfo)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        
                        // Planet Stats
                        VStack(spacing: 15) {
                            StatRow(title: "Distance from Sun", value: planet.distanceFromSun)
                            StatRow(title: "Diameter", value: planet.diameter)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.3))
                        )
                        .padding(.horizontal)
                        
                        // AI Question Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Ask AI about \(planet.name)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("What would you like to know about \(planet.name)?", text: $userQuestion)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            hideKeyboard()
                                        }
                                    }
                                }
                            
                            Button(action: {
                                askAI()
                            }) {
                                HStack {
                                    if gptService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(gptService.isLoading ? "Asking AI..." : "Ask AI")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#FF4500"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(userQuestion.isEmpty || gptService.isLoading)
                            
                            if !gptResponse.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("AI Response:")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "#FF4500"))
                                    
                                    Text(gptResponse)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.black.opacity(0.3))
                                        )
                                }
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
    
    private func askAI() {
        let prompt = "Tell me about \(planet.name): \(userQuestion)"
        gptService.askGPT(prompt: prompt) { response in
            gptResponse = response
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    PlanetaryExplorerView()
} 