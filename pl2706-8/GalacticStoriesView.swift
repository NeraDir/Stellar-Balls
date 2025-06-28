import SwiftUI

struct GalacticStoriesView: View {
    @State private var stories = Story.stories
    @State private var selectedStory: Story?
    @State private var searchText = ""
    @AppStorage("favorite_stories") private var favoriteStoriesData: Data = Data()
    
    private var filteredStories: [Story] {
        if searchText.isEmpty {
            return stories
        } else {
            return stories.filter { story in
                story.title.localizedCaseInsensitiveContains(searchText) ||
                story.category.localizedCaseInsensitiveContains(searchText) ||
                story.preview.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
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
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("🌠 Galactic Stories")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Cosmic tales from across the universe")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("Search stories...", text: $searchText)
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
                    .padding(.bottom)
                    
                    // Stories list
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredStories) { story in
                                StoryCard(story: story) {
                                    selectedStory = story
                                } onToggleFavorite: {
                                    toggleFavorite(story: story)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(item: $selectedStory) { story in
            StoryDetailView(story: story)
        }
        .onAppear {
            loadFavorites()
        }
    }
    
    private func toggleFavorite(story: Story) {
        if let index = stories.firstIndex(where: { $0.id == story.id }) {
            stories[index].isFavorite.toggle()
            saveFavorites()
        }
    }
    
    private func saveFavorites() {
        let favoriteIds = stories.filter { $0.isFavorite }.map { $0.id }
        if let encoded = try? JSONEncoder().encode(favoriteIds) {
            favoriteStoriesData = encoded
        }
    }
    
    private func loadFavorites() {
        if let decoded = try? JSONDecoder().decode([UUID].self, from: favoriteStoriesData) {
            for index in stories.indices {
                stories[index].isFavorite = decoded.contains(stories[index].id)
            }
        }
    }
}

struct StoryCard: View {
    let story: Story
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and favorite button
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(story.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(story.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#FF4500").opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "#FF4500"), lineWidth: 1)
                                )
                        )
                        .foregroundColor(Color(hex: "#FF4500"))
                }
                
                Spacer()
                
                Button(action: onToggleFavorite) {
                    Image(systemName: story.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(story.isFavorite ? .red : .white.opacity(0.6))
                        .font(.title2)
                }
            }
            
            // Preview text
            Text(story.preview)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
            
            // Read button
            HStack {
                Spacer()
                Button("Read Story") {
                    onTap()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
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

struct StoryDetailView: View {
    let story: Story
    @State private var gptSummary = ""
    @StateObject private var gptService = GPTService.shared
    @Environment(\.dismiss) private var dismiss
    
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 10) {
                            Text(story.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(story.category)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#FF4500").opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "#FF4500"), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(Color(hex: "#FF4500"))
                        }
                        
                        // Story content
                        Text(story.content)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.black.opacity(0.3))
                            )
                        
                        // AI Summary section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🤖 AI Story Analysis")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            if gptSummary.isEmpty {
                                Button("Get AI Summary") {
                                    getSummary()
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
                                        Text("AI is analyzing the story...")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding()
                                }
                            } else {
                                Text(gptSummary)
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
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
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
    
    private func getSummary() {
        let prompt = "Analyze this space story and provide insights about its themes, scientific elements, and what makes it engaging: \(story.content)"
        
        gptService.askGPT(prompt: prompt) { response in
            gptSummary = response
        }
    }
}

#Preview {
    GalacticStoriesView()
} 