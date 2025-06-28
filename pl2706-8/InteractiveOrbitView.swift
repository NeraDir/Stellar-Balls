import SwiftUI

struct InteractiveOrbitView: View {
    @State private var rotationAngle: Double = 0
    @State private var planetToShow: Planet?
    @State private var aiExplanation = ""
    @StateObject private var gptService = GPTService.shared
    @State private var animationSpeed: Double = 1.0
    @State private var isAnimating = true
    @State private var animationTimer: Timer?
    
    var body: some View {
        ZStack {
            // Cosmic background
            LinearGradient(
                colors: [Color(hex: "#4B0082"), Color.black, Color(hex: "#800080")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                                    // Header
                    VStack(spacing: 8) {
                        Text("🧭 Interactive Orbit")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Explore planetary orbits around the Sun")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 10)
                
                // Controls - Responsive layout
                VStack(spacing: 8) {
                    HStack {
                        Button(isAnimating ? "Pause" : "Play") {
                            isAnimating.toggle()
                            updateAnimation()
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#FF4500"))
                        )
                        
                        Spacer()
                        
                        Text("Speed: \(String(format: "%.1f", animationSpeed))x")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    // Slider on separate row for better mobile layout
                    Slider(value: $animationSpeed, in: 0.1...3.0, step: 0.1)
                        .accentColor(Color(hex: "#FF4500"))
                }
                .padding(.horizontal)
                
                // Solar System
                ZStack {
                    // Sun at center
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow, Color.orange, Color.red],
                                center: .center,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("☀️")
                                .font(.title)
                        )
                    
                    // Planet orbits
                    ForEach(Array(Planet.planets.enumerated()), id: \.offset) { index, planet in
                        let radius = Double(60 + index * 18)
                        let speed = 1.0 / (Double(index + 1) * 0.5) * animationSpeed
                        
                        ZStack {
                            // Orbit path
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                .frame(width: radius * 2, height: radius * 2)
                            
                            // Planet
                            PlanetOrbitView(
                                planet: planet,
                                radius: radius,
                                rotationAngle: rotationAngle * speed,
                                                                    onTap: {
                                        planetToShow = planet
                                    }
                            )
                        }
                    }
                }
                .frame(height: 280)
                .scaleEffect(0.7)
                
                // Info text
                Text("Tap any planet to learn about its orbit")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            // Small delay to ensure view is fully loaded before starting animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateAnimation()
            }
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
        .sheet(item: $planetToShow) { planet in
            OrbitInfoView(planet: planet)
        }
    }
    
    private func updateAnimation() {
        animationTimer?.invalidate()
        
        if isAnimating {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                rotationAngle += animationSpeed * 0.5
                if rotationAngle >= 360 {
                    rotationAngle -= 360
                }
            }
        }
    }
}

struct PlanetOrbitView: View {
    let planet: Planet
    let radius: Double
    let rotationAngle: Double
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let x = centerX + cos(rotationAngle * .pi / 180) * radius
            let y = centerY + sin(rotationAngle * .pi / 180) * radius
            
            Button(action: onTap) {
                Text(planet.emoji)
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(hex: planet.color).opacity(0.3))
                            .frame(width: 40, height: 40)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .position(x: x, y: y)
        }
    }
}

struct OrbitInfoView: View {
    let planet: Planet
    @State private var aiExplanation = ""
    @StateObject private var gptService = GPTService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#4B0082"), Color.black, Color(hex: planet.color)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Planet info
                        VStack(spacing: 15) {
                            Text(planet.emoji)
                                .font(.system(size: 80))
                            
                            Text(planet.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Distance from Sun: \(planet.distanceFromSun)")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#FF4500"))
                        }
                        .padding()
                        
                        // Orbit facts
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Orbital Facts")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 10) {
                                InfoRow(title: "Planet Diameter", value: planet.diameter)
                                InfoRow(title: "Distance from Sun", value: planet.distanceFromSun)
                                InfoRow(title: "Basic Info", value: planet.basicInfo)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.3))
                        )
                        .padding(.horizontal)
                        
                        // AI explanation section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🤖 AI Orbital Analysis")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            if aiExplanation.isEmpty {
                                Button("Get AI Explanation") {
                                    getOrbitalExplanation()
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
                                        Text("AI is analyzing orbital dynamics...")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding()
                                }
                            } else {
                                Text(aiExplanation)
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
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .foregroundColor(Color(hex: "#FF4500"))
                }
            }
        }
    }
    
    private func getOrbitalExplanation() {
        let prompt = "Explain the orbital dynamics and characteristics of \(planet.name), including why it orbits at its specific distance and any unique orbital features."
        
        gptService.askGPT(prompt: prompt) { response in
            aiExplanation = response
        }
    }
}

struct InfoRow: View {
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
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    InteractiveOrbitView()
} 