//
//  ContentView.swift
//  pl2706-8
//
//  Created by Александр on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlanetaryExplorerView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Planets")
                }
                .tag(0)
            
            CelestialDialoguesView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Dialogues")
                }
                .tag(1)
            
            CosmicTriviaView()
                .tabItem {
                    Image(systemName: "questionmark.circle")
                    Text("Trivia")
                }
                .tag(2)
            
            GalacticStoriesView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Stories")
                }
                .tag(3)
            
            InteractiveOrbitView()
                .tabItem {
                    Image(systemName: "circle.dotted")
                    Text("Orbits")
                }
                .tag(4)
            
            StarChartView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Stars")
                }
                .tag(5)
            
            MissionControlView()
                .tabItem {
                    Image(systemName: "flag")
                    Text("Missions")
                }
                .tag(6)
        }
        .accentColor(Color(hex: "#800080"))
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
