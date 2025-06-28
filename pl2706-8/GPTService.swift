import Foundation

class GPTService: ObservableObject {
    static let shared = GPTService()
    private let apiKey = "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"
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published var isLoading = false
    
    func askGPT(prompt: String, completion: @escaping (String) -> Void) {
        guard !apiKey.isEmpty else {
            completion("AI unavailable - no API key")
            return
        }
        
        isLoading = true
        
        guard let url = URL(string: baseURL) else {
            completion("AI unavailable - invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are an astronomy expert assistant. Provide educational and engaging responses about space, planets, and astronomy. Keep responses concise but informative."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 300,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion("AI unavailable - request error")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    completion("AI unavailable - \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    completion("AI unavailable - no data")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        completion("AI unavailable - invalid response")
                    }
                } catch {
                    completion("AI unavailable - parsing error")
                }
            }
        }.resume()
    }
} 