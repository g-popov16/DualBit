import Foundation

/// Represents a question in a quiz.
struct Question {
    /// The text of the question.
    let text: String
    
    /// The possible answers for the question.
    let answer: [String]
    
    /// The correct answer for the question.
    let correctAnswer: String
    
    /// Initializes a new instance of the `Question` struct.
    /// - Parameters:
    ///   - q: The text of the question.
    ///   - a: The possible answers for the question.
    ///   - correctAnswer: The correct answer for the question.
    init(q: String, a: [String], correctAnswer: String){
        text = q
        answer = a
        self.correctAnswer = correctAnswer
    }
}
