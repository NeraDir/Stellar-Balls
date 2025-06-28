import SwiftUI

struct CelestialDialoguesView: View {
    @State private var messages: [ChatMessage] = []
    @State private var currentMessage: String = ""
    @StateObject private var gptService = GPTService.shared
    @AppStorage("celestial_messages") private var messagesData: Data = Data()
    
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
                        Text("🔭 Celestial Dialogues")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Chat with AI about the cosmos")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    // Quick prompts
                    if messages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(quickPrompts, id: \.self) { prompt in
                                    Button(prompt) {
                                        currentMessage = prompt
                                        sendMessage()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(hex: "#FF4500").opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color(hex: "#FF4500"), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(.white)
                                    .font(.caption)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                    
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if gptService.isLoading {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#FF4500")))
                                        Text("AI is thinking...")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding()
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _ in
                            if let lastMessage = messages.last {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input area
                    VStack(spacing: 10) {
                        HStack(spacing: 12) {
                            TextField("Ask about the cosmos...", text: $currentMessage, axis: .vertical)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 15)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.black.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            hideKeyboard()
                                        }
                                    }
                                }
                            
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: "#FF4500"))
                                    )
                            }
                            .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || gptService.isLoading)
                        }
                        .padding(.horizontal)
                        
                        // Clear chat button
                        if !messages.isEmpty {
                            Button("Clear Conversation") {
                                clearMessages()
                            }
                            .foregroundColor(Color(hex: "#FF4500"))
                            .padding(.bottom, 5)
                        }
                    }
                    .padding(.bottom)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .blur(radius: 10)
                    )
                }
            }
        }
        .onAppear {
            loadMessages()
        }
    }
    
    private let quickPrompts = [
        "What is the hottest planet?",
        "Tell me about black holes",
        "How do stars form?",
        "What are exoplanets?",
        "Explain the Big Bang theory"
    ]
    
    private func sendMessage() {
        let messageText = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: messageText, isUser: true)
        messages.append(userMessage)
        currentMessage = ""
        saveMessages()
        
        // Get AI response
        gptService.askGPT(prompt: messageText) { response in
            let aiMessage = ChatMessage(text: response, isUser: false)
            messages.append(aiMessage)
            saveMessages()
        }
    }
    
    private func clearMessages() {
        messages.removeAll()
        saveMessages()
    }
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            messagesData = encoded
        }
    }
    
    private func loadMessages() {
        if let decoded = try? JSONDecoder().decode([ChatMessage].self, from: messagesData) {
            messages = decoded
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text(message.text)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "#FF4500"))
                        )
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity * 0.8, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 10) {
                        Text("🤖")
                            .font(.title2)
                        
                        Text(message.text)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "#800080"), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.leading, 40)
                }
                .frame(maxWidth: .infinity * 0.8, alignment: .leading)
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    CelestialDialoguesView()
} 