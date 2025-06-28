import SwiftUI

struct MissionControlView: View {
    @State private var missions: [Mission] = []
    @State private var showingAddMission = false
    @State private var newMissionTitle = ""
    @State private var newMissionDescription = ""
    @State private var newMissionTarget = ""
    @AppStorage("missions_data") private var missionsData: Data = Data()
    @StateObject private var gptService = GPTService.shared
    
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
                    Text("🚀 Mission Control")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text("Plan and track your space missions")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Mission stats
                    HStack {
                        StatCard(title: "Total", value: "\(missions.count)", color: Color(hex: "#FF4500"))
                        StatCard(title: "Active", value: "\(missions.filter { !$0.isCompleted }.count)", color: .blue)
                        StatCard(title: "Complete", value: "\(missions.filter { $0.isCompleted }.count)", color: .green)
                    }
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 15) {
                        Button("Add Mission") {
                            showingAddMission = true
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "#FF4500"))
                        )
                        
                        Button("AI Suggestion") {
                            getAISuggestion()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#FF4500"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "#FF4500"), lineWidth: 2)
                        )
                        .disabled(gptService.isLoading)
                    }
                    
                    // Missions list
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(missions) { mission in
                                MissionCard(mission: mission) { updatedMission in
                                    updateMission(updatedMission)
                                } onDelete: {
                                    deleteMission(mission)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingAddMission) {
            AddMissionView { title, description, target in
                addMission(title: title, description: description, target: target)
            }
        }
        .onAppear {
            loadMissions()
        }
    }
    
    private func loadMissions() {
        if let decoded = try? JSONDecoder().decode([Mission].self, from: missionsData) {
            missions = decoded
        } else {
            missions = Mission.defaultMissions
            saveMissions()
        }
    }
    
    private func saveMissions() {
        if let encoded = try? JSONEncoder().encode(missions) {
            missionsData = encoded
        }
    }
    
    private func addMission(title: String, description: String, target: String) {
        let newMission = Mission(title: title, description: description, target: target)
        missions.append(newMission)
        saveMissions()
    }
    
    private func updateMission(_ updatedMission: Mission) {
        if let index = missions.firstIndex(where: { $0.id == updatedMission.id }) {
            missions[index] = updatedMission
            saveMissions()
        }
    }
    
    private func deleteMission(_ mission: Mission) {
        missions.removeAll { $0.id == mission.id }
        saveMissions()
    }
    
    private func getAISuggestion() {
        let prompt = "Suggest an interesting and realistic space exploration mission. Include a catchy title, detailed description, and target (planet, moon, or celestial object). Make it educational and inspiring."
        
        gptService.askGPT(prompt: prompt) { response in
            // Parse the AI response and create a new mission
            let lines = response.components(separatedBy: "\n").filter { !$0.isEmpty }
            let title = lines.first?.replacingOccurrences(of: "Title:", with: "").trimmingCharacters(in: .whitespacesAndNewlines) ?? "AI Suggested Mission"
            let description = response
            let target = "Unknown"
            
            addMission(title: title, description: description, target: target)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct MissionCard: View {
    let mission: Mission
    let onUpdate: (Mission) -> Void
    let onDelete: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(mission.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("Target: \(mission.target)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#FF4500"))
                }
                
                Spacer()
                
                Button(action: {
                    var updatedMission = mission
                    updatedMission.isCompleted.toggle()
                    onUpdate(updatedMission)
                }) {
                    Image(systemName: mission.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(mission.isCompleted ? .green : .white.opacity(0.6))
                        .font(.title2)
                }
            }
            
            Text(mission.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
            
            HStack {
                Text("Created: \(formatDate(mission.dateCreated))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button("View") {
                        showingDetail = true
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#FF4500").opacity(0.8))
                    )
                    
                    Button("Delete") {
                        onDelete()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.red, lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(mission.isCompleted ? Color.green.opacity(0.1) : Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(mission.isCompleted ? .green : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingDetail) {
            MissionDetailView(mission: mission)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AddMissionView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var target = ""
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, String, String) -> Void
    
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
                    Text("🚀 New Mission")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    VStack(spacing: 15) {
                        TextField("Mission Title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Target (Planet, Moon, etc.)", text: $target)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Mission Description", text: $description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                        }
                    }
                    
                    Button("Create Mission") {
                        onAdd(title, description, target)
                        dismiss()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "#FF4500"))
                    )
                    .disabled(title.isEmpty || description.isEmpty || target.isEmpty)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FF4500"))
                }
            }
        }
    }
}

struct MissionDetailView: View {
    let mission: Mission
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
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(mission.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Target: \(mission.target)")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#FF4500"))
                            
                            HStack {
                                Text(mission.isCompleted ? "✅ Completed" : "🔄 In Progress")
                                    .font(.subheadline)
                                    .foregroundColor(mission.isCompleted ? .green : .yellow)
                                
                                Spacer()
                                
                                Text("Created: \(formatDateDetail(mission.dateCreated))")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Mission Description")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(mission.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.3))
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
    
    private func formatDateDetail(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    MissionControlView()
} 