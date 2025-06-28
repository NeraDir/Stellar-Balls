import SwiftUI

struct CosmicTriviaView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingResult = false
    @State private var score = 0
    @State private var showingHint = false
    @State private var hintText = ""
    @StateObject private var gptService = GPTService.shared
    @AppStorage("trivia_high_score") private var highScore = 0
    @AppStorage("trivia_total_questions") private var totalQuestions = 0
    @AppStorage("trivia_correct_answers") private var correctAnswers = 0
    
    private var currentQuestion: TriviaQuestion {
        TriviaQuestion.questions[currentQuestionIndex]
    }
    
    private var isGameComplete: Bool {
        currentQuestionIndex >= TriviaQuestion.questions.count
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Cosmic background
                    LinearGradient(
                        colors: [Color(hex: "#4B0082"), Color.black, Color(hex: "#800080")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: geometry.size.height < 600 ? 12 : 20) {
                            // Header
                            VStack(spacing: geometry.size.height < 600 ? 5 : 10) {
                                Text("🌌 Cosmic Trivia")
                                    .font(geometry.size.height < 600 ? .title2 : .largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.8)
                                
                                Text("Test your astronomy knowledge")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.top, geometry.size.height < 600 ? 8 : 16)
                            
                            // Score and Progress
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Score: \(score)")
                                        .font(geometry.size.height < 600 ? .subheadline : .headline)
                                        .foregroundColor(Color(hex: "#FF4500"))
                                    
                                    Text("High Score: \(highScore)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                if !isGameComplete {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Question \(currentQuestionIndex + 1) of \(TriviaQuestion.questions.count)")
                                            .font(geometry.size.height < 600 ? .caption : .subheadline)
                                            .foregroundColor(.white)
                                            .minimumScaleFactor(0.8)
                                        
                                        ProgressView(value: Double(currentQuestionIndex), total: Double(TriviaQuestion.questions.count))
                                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#FF4500")))
                                            .frame(width: geometry.size.width < 375 ? 80 : 120)
                                    }
                                }
                            }
                            .padding(.horizontal)
                    
                            if isGameComplete {
                                // Game Complete View
                                GameCompleteView(
                                    score: score,
                                    total: TriviaQuestion.questions.count,
                                    isNewHighScore: score > highScore,
                                    screenHeight: geometry.size.height
                                ) {
                                    restartGame()
                                }
                            } else if showingResult {
                                // Result View
                                ResultView(
                                    question: currentQuestion,
                                    selectedAnswer: selectedAnswer ?? 0,
                                    screenHeight: geometry.size.height,
                                    onNext: nextQuestion
                                )
                            } else {
                                // Question View
                                QuestionCard(
                                    question: currentQuestion,
                                    selectedAnswer: $selectedAnswer,
                                    screenHeight: geometry.size.height,
                                    screenWidth: geometry.size.width,
                                    onAnswer: submitAnswer,
                                    onHint: getHint
                                )
                            }
                            
                            // Add bottom padding for small screens
                            if geometry.size.height < 600 {
                                Spacer(minLength: 20)
                            }
                        }
                        .padding(.bottom, geometry.size.height < 600 ? 10 : 20)
                    }
                    
                    // Hint overlay
                    if showingHint {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showingHint = false
                            }
                        
                        HintView(
                            hintText: hintText,
                            screenWidth: geometry.size.width,
                            screenHeight: geometry.size.height
                        ) {
                            showingHint = false
                        }
                    }
                }
            }
        }
    }
    
    private func submitAnswer() {
        guard let selected = selectedAnswer else { return }
        
        totalQuestions += 1
        
        if selected == currentQuestion.correctAnswer {
            score += 1
            correctAnswers += 1
        }
        
        showingResult = true
    }
    
    private func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        showingResult = false
        
        if isGameComplete {
            if score > highScore {
                highScore = score
            }
        }
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        showingResult = false
        score = 0
    }
    
    private func getHint() {
        let prompt = "Provide a helpful hint for this astronomy trivia question without giving away the answer directly: \(currentQuestion.question)"
        
        gptService.askGPT(prompt: prompt) { response in
            hintText = response
            showingHint = true
        }
    }
}

struct QuestionCard: View {
    let question: TriviaQuestion
    @Binding var selectedAnswer: Int?
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    let onAnswer: () -> Void
    let onHint: () -> Void
    
    private var isSmallScreen: Bool {
        screenHeight < 600
    }
    
    var body: some View {
        VStack(spacing: isSmallScreen ? 15 : 25) {
            // Question
            VStack(spacing: isSmallScreen ? 8 : 15) {
                Text(question.question)
                    .font(isSmallScreen ? .headline : .title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
                    .padding(isSmallScreen ? 12 : 16)
                
                // Hint button
                Button(action: onHint) {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb")
                        Text("Get AI Hint")
                    }
                    .font(isSmallScreen ? .caption2 : .caption)
                    .foregroundColor(Color(hex: "#FF4500"))
                    .padding(.horizontal, isSmallScreen ? 8 : 12)
                    .padding(.vertical, isSmallScreen ? 4 : 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "#FF4500"), lineWidth: 1)
                    )
                }
            }
            .padding(isSmallScreen ? 8 : 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
            )
            .padding(.horizontal)
            
            // Answer options
            VStack(spacing: isSmallScreen ? 8 : 15) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        selectedAnswer = index
                    }) {
                        HStack {
                            Text(option)
                                .font(isSmallScreen ? .subheadline : .body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.9)
                            
                            Spacer()
                            
                            if selectedAnswer == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "#FF4500"))
                                    .font(isSmallScreen ? .subheadline : .body)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(isSmallScreen ? .subheadline : .body)
                            }
                        }
                        .padding(isSmallScreen ? 10 : 14)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(selectedAnswer == index ? Color(hex: "#FF4500").opacity(0.2) : Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(selectedAnswer == index ? Color(hex: "#FF4500") : Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            // Submit button
            Button(action: onAnswer) {
                Text("Submit Answer")
                    .font(isSmallScreen ? .subheadline : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(isSmallScreen ? 12 : 16)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedAnswer != nil ? Color(hex: "#FF4500") : Color.gray.opacity(0.5))
                    )
            }
            .disabled(selectedAnswer == nil)
            .padding(.horizontal)
        }
    }
}

struct ResultView: View {
    let question: TriviaQuestion
    let selectedAnswer: Int
    let screenHeight: CGFloat
    let onNext: () -> Void
    
    private var isCorrect: Bool {
        selectedAnswer == question.correctAnswer
    }
    
    private var isSmallScreen: Bool {
        screenHeight < 600
    }
    
    var body: some View {
        VStack(spacing: isSmallScreen ? 15 : 25) {
            // Result indicator
            VStack(spacing: isSmallScreen ? 10 : 15) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: isSmallScreen ? 40 : 60))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(isSmallScreen ? .title2 : .title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !isCorrect {
                    Text("The correct answer was:")
                        .font(isSmallScreen ? .caption : .subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(question.options[question.correctAnswer])
                        .font(isSmallScreen ? .subheadline : .headline)
                        .foregroundColor(Color(hex: "#FF4500"))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .padding(isSmallScreen ? 8 : 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.3))
                        )
                }
            }
            
            // Explanation
            VStack(alignment: .leading, spacing: isSmallScreen ? 5 : 10) {
                Text("Explanation:")
                    .font(isSmallScreen ? .subheadline : .headline)
                    .foregroundColor(.white)
                
                Text(question.explanation)
                    .font(isSmallScreen ? .subheadline : .body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(nil)
                    .minimumScaleFactor(0.9)
                    .padding(isSmallScreen ? 10 : 14)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.3))
                    )
            }
            .padding(.horizontal)
            
            // Next button
            Button(action: onNext) {
                Text("Next Question")
                    .font(isSmallScreen ? .subheadline : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(isSmallScreen ? 12 : 16)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "#FF4500"))
                    )
            }
            .padding(.horizontal)
        }
    }
}

struct GameCompleteView: View {
    let score: Int
    let total: Int
    let isNewHighScore: Bool
    let screenHeight: CGFloat
    let onRestart: () -> Void
    
    private var percentage: Double {
        Double(score) / Double(total) * 100
    }
    
    private var performanceMessage: String {
        switch percentage {
        case 90...100: return "Stellar performance! 🌟"
        case 70..<90: return "Great job! 🚀"
        case 50..<70: return "Good effort! 🌙"
        default: return "Keep learning! 📚"
        }
    }
    
    private var isSmallScreen: Bool {
        screenHeight < 600
    }
    
    var body: some View {
        VStack(spacing: isSmallScreen ? 15 : 25) {
            Text("🎉 Quiz Complete!")
                .font(isSmallScreen ? .title2 : .largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)
            
            if isNewHighScore {
                Text("🏆 New High Score!")
                    .font(isSmallScreen ? .headline : .title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#FF4500"))
                    .padding(isSmallScreen ? 8 : 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "#FF4500").opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "#FF4500"), lineWidth: 2)
                            )
                    )
            }
            
            VStack(spacing: isSmallScreen ? 8 : 15) {
                Text("Final Score")
                    .font(isSmallScreen ? .subheadline : .headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(score) / \(total)")
                    .font(.system(size: isSmallScreen ? 36 : 48, weight: .bold))
                    .foregroundColor(Color(hex: "#FF4500"))
                
                Text(String(format: "%.0f%%", percentage))
                    .font(isSmallScreen ? .headline : .title2)
                    .foregroundColor(.white)
                
                Text(performanceMessage)
                    .font(isSmallScreen ? .caption : .subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(isSmallScreen ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
            )
            .padding(.horizontal)
            
            Button(action: onRestart) {
                Text("Play Again")
                    .font(isSmallScreen ? .subheadline : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(isSmallScreen ? 12 : 16)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "#FF4500"))
                    )
            }
            .padding(.horizontal)
        }
    }
}

struct HintView: View {
    let hintText: String
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let onDismiss: () -> Void
    
    private var isSmallScreen: Bool {
        screenHeight < 600 || screenWidth < 375
    }
    
    var body: some View {
        VStack(spacing: isSmallScreen ? 12 : 20) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "#FF4500"))
                    .font(isSmallScreen ? .subheadline : .headline)
                Text("AI Hint")
                    .font(isSmallScreen ? .subheadline : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .font(isSmallScreen ? .headline : .title2)
                }
            }
            
            ScrollView {
                Text(hintText)
                    .font(isSmallScreen ? .subheadline : .body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            .frame(maxHeight: isSmallScreen ? 120 : 200)
            
            Button("Got it!", action: onDismiss)
                .font(isSmallScreen ? .subheadline : .headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(isSmallScreen ? 10 : 14)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: "#FF4500"))
                )
        }
        .padding(isSmallScreen ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#FF4500"), lineWidth: 2)
                )
        )
        .padding(isSmallScreen ? 12 : 20)
        .frame(maxWidth: isSmallScreen ? screenWidth * 0.9 : .infinity)
    }
}

#Preview {
    CosmicTriviaView()
} 