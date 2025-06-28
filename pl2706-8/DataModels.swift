import Foundation

// MARK: - Planet Model
struct Planet: Identifiable, Codable {
    let id = UUID()
    let name: String
    let emoji: String
    let basicInfo: String
    let distanceFromSun: String
    let diameter: String
    let color: String
    
    static let planets = [
        Planet(name: "Mercury", emoji: "☿️", basicInfo: "The smallest planet and closest to the Sun", distanceFromSun: "36 million miles", diameter: "3,032 miles", color: "#8C7853"),
        Planet(name: "Venus", emoji: "♀️", basicInfo: "The hottest planet with thick atmosphere", distanceFromSun: "67 million miles", diameter: "7,521 miles", color: "#FFC649"),
        Planet(name: "Earth", emoji: "🌍", basicInfo: "Our blue planet, the only known planet with life", distanceFromSun: "93 million miles", diameter: "7,926 miles", color: "#6B93D6"),
        Planet(name: "Mars", emoji: "♂️", basicInfo: "The red planet with polar ice caps", distanceFromSun: "142 million miles", diameter: "4,220 miles", color: "#CD5C5C"),
        Planet(name: "Jupiter", emoji: "♃", basicInfo: "The largest planet with the Great Red Spot", distanceFromSun: "484 million miles", diameter: "88,695 miles", color: "#D8CA9D"),
        Planet(name: "Saturn", emoji: "♄", basicInfo: "Famous for its beautiful ring system", distanceFromSun: "886 million miles", diameter: "74,898 miles", color: "#FAD5A5"),
        Planet(name: "Uranus", emoji: "♅", basicInfo: "An ice giant that rotates on its side", distanceFromSun: "1.8 billion miles", diameter: "31,763 miles", color: "#4FD0E7"),
        Planet(name: "Neptune", emoji: "♆", basicInfo: "The windiest planet in our solar system", distanceFromSun: "2.8 billion miles", diameter: "30,775 miles", color: "#4B70DD")
    ]
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    
    init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
        self.timestamp = Date()
    }
}

// MARK: - Trivia Question Model
struct TriviaQuestion: Identifiable, Codable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    
    static let questions = [
        TriviaQuestion(question: "Which planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctAnswer: 1, explanation: "Mars appears red due to iron oxide on its surface"),
        TriviaQuestion(question: "What is the largest planet in our solar system?", options: ["Saturn", "Neptune", "Jupiter", "Uranus"], correctAnswer: 2, explanation: "Jupiter is the largest planet, with a mass greater than all other planets combined"),
        TriviaQuestion(question: "Which planet has the most moons?", options: ["Jupiter", "Saturn", "Neptune", "Uranus"], correctAnswer: 1, explanation: "Saturn has 146 confirmed moons, more than any other planet"),
        TriviaQuestion(question: "How long does it take light from the Sun to reach Earth?", options: ["8 minutes", "1 hour", "1 day", "1 second"], correctAnswer: 0, explanation: "Light travels at 186,000 miles per second and takes about 8 minutes to reach Earth"),
        TriviaQuestion(question: "Which planet is closest to the Sun?", options: ["Venus", "Mercury", "Earth", "Mars"], correctAnswer: 1, explanation: "Mercury is the innermost planet in our solar system")
    ]
}

// MARK: - Story Model
struct Story: Identifiable, Codable {
    let id = UUID()
    let title: String
    let preview: String
    let content: String
    let category: String
    var isFavorite: Bool = false
    
    static let stories = [
        Story(title: "The Mystery of the Asteroid Belt", preview: "A young astronomer discovers something unusual...", content: "Dr. Sarah Chen was studying routine asteroid observations when she noticed an anomaly. One asteroid seemed to be moving in an impossible orbit, defying the laws of physics as she knew them. As she investigated further, she realized this wasn't just any space rock—it was something that would change our understanding of the solar system forever.", category: "Mystery"),
        Story(title: "Jupiter's Storm", preview: "The Great Red Spot holds ancient secrets...", content: "Captain Rivera's spacecraft approached Jupiter's Great Red Spot, a storm larger than Earth itself that had been raging for centuries. As they descended into the swirling clouds, they discovered that the storm wasn't just a weather phenomenon—it was a gateway to understanding the planet's mysterious core and the secrets it had been hiding for billions of years.", category: "Adventure"),
        Story(title: "The Rings of Saturn", preview: "Ice particles tell a billion-year story...", content: "Professor Martinez had always been fascinated by Saturn's rings, but when the latest probe sent back data showing patterns that shouldn't exist, she knew she had stumbled upon something extraordinary. The rings weren't just ice and rock—they were a cosmic library, recording the history of our solar system in ways no one had ever imagined.", category: "Discovery"),
        Story(title: "Mars Colony One", preview: "The first human settlement faces unexpected challenges...", content: "Commander Liu looked out at the red Martian landscape from the observation deck of Colony One. They had successfully established humanity's first permanent settlement on another planet, but now they faced a new challenge: mysterious signals coming from beneath the Martian ice caps that suggested they might not be alone on the red planet.", category: "Science Fiction")
    ]
}

// MARK: - Mission Model
struct Mission: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var target: String
    var isCompleted: Bool = false
    let dateCreated: Date
    
    init(title: String, description: String, target: String) {
        self.title = title
        self.description = description
        self.target = target
        self.dateCreated = Date()
    }
    
    static let defaultMissions = [
        Mission(title: "Explore Europa's Oceans", description: "Study the subsurface ocean of Jupiter's moon Europa for signs of life", target: "Europa"),
        Mission(title: "Map Mars Ice Caps", description: "Create detailed maps of seasonal changes in Mars' polar ice caps", target: "Mars"),
        Mission(title: "Study Saturn's Rings", description: "Analyze the composition and age of Saturn's ring system", target: "Saturn"),
        Mission(title: "Observe Solar Flares", description: "Monitor and record solar activity and its effects on Earth", target: "Sun")
    ]
}

// MARK: - Constellation Model
struct Constellation: Identifiable, Codable {
    let id = UUID()
    let name: String
    let mythology: String
    let brightestStar: String
    let season: String
    let coordinates: String
    
    static let constellations = [
        Constellation(name: "Orion", mythology: "The great hunter in Greek mythology", brightestStar: "Rigel", season: "Winter", coordinates: "5h 30m, +0°"),
        Constellation(name: "Ursa Major", mythology: "The Great Bear, home to the Big Dipper", brightestStar: "Alioth", season: "Spring", coordinates: "11h 0m, +50°"),
        Constellation(name: "Cassiopeia", mythology: "The vain queen who boasted about her beauty", brightestStar: "Gamma Cassiopeiae", season: "Fall", coordinates: "1h 0m, +60°"),
        Constellation(name: "Leo", mythology: "The lion slain by Hercules", brightestStar: "Regulus", season: "Spring", coordinates: "10h 30m, +15°"),
        Constellation(name: "Cygnus", mythology: "The swan flying along the Milky Way", brightestStar: "Deneb", season: "Summer", coordinates: "20h 30m, +40°")
    ]
} 