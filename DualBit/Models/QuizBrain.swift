

import Foundation
import Firebase



class QuizBrain {
    private var db = Firestore.firestore()
    private var questions: [Question] = []
    private var currentQuestionIndex: Int = 0
    private var score: Int = 0
    private var lessonId: String?

    // Load questions from Firestore
//    func loadQuestions() async {
//        do {
//            // Clear existing questions
//            self.questions.removeAll()
//            
//            guard let lessonId = lessonId else {
//                            print("No lesson ID provided")
//                            return
//                        }
//            
//            // Fetch all questions documents from the questions collection
//            let questionsSnapshot = try await db.collection("lessons").document(lessonId).collection("questions").getDocuments()
//            
//            // Iterate through each document and create a Question object
//            for document in questionsSnapshot.documents {
//                if let questionText = document.data()["questionText"] as? String,
//                   let answers = document.data()["answers"] as? [String],
//                   let correctAnswer = document.data()["correctAnswer"] as? String {
//                    let question = Question(q: questionText, a: answers, correctAnswer: correctAnswer)
//                    self.questions.append(question)
//                }
//            }
//            
//            // After fetching is complete, you can update the UI or call a method that does
//        } catch {
//            print("Error fetching questions: \(error)")
//        }
//    }
    func completeLesson(lessonId: String, userId: String) {
        // Reference to the user's document
        let userDocRef = db.collection("users").document(userId)
        
        // Atomically add a new lesson ID to the "completedLessons" array field
        userDocRef.updateData([
            "completedLessons": FieldValue.arrayUnion([lessonId])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func isQuizFinished() -> Bool {
            return currentQuestionIndex >= questions.count - 1
            
       }

       // Check if the user has passed the quiz
       func didUserPassQuiz() -> Bool {
           let passThreshold = 0.7 // 70%
           let totalQuestions = questions.count
           let requiredCorrectAnswers = Int(ceil(Double(totalQuestions) * passThreshold))
           return score >= requiredCorrectAnswers
       }


    @MainActor
    func loadQuestions() async {
        do {
            // Clear existing questions
            self.questions.removeAll()

            // Ensure we have a lessonId to work with
            guard let lessonId = lessonId else {
                print("No lesson ID provided")
                return
            }
            
            // The collection name should be constructed using the lessonId
            let formattedCollectionName = "questions_\(lessonId)"

            // Fetch all questions documents from the specific lesson's question collection
            let questionsSnapshot = try await db.collection(formattedCollectionName).getDocuments()
            
            // Iterate through each document and create a Question object
            for document in questionsSnapshot.documents {
                if let questionText = document.data()["questionText"] as? String,
                   let answers = document.data()["answers"] as? [String],
                   let correctAnswer = document.data()["correctAnswer"] as? String {
                    let question = Question(q: questionText, a: answers, correctAnswer: correctAnswer)
                    self.questions.append(question)
                }
            }

            if self.questions.isEmpty {
                print("No questions were loaded from the database for lesson: \(lessonId)")
            } else {
                print("Questions loaded successfully for lesson: \(lessonId)")
            }

        } catch {
            print("Error fetching questions: \(error)")
        }
    }





    
    func areQuestionsLoaded() -> Bool {
            return !questions.isEmpty
        }

// No completion handler needed. The function will resume here after await finishes.
    


        // Async function to fetch question data from Firestore
    private func fetchQuestionData() async throws -> Question? {
        let lessonRef = db.collection("lessons").document("Lesson 1")
        let documentSnapshot = try await lessonRef.getDocument()

        // No need to use guard let for documentSnapshot because it's not optional
        guard documentSnapshot.exists else {
            throw NSError(domain: "QuizBrainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Lesson document does not exist"])
        }

        guard let questionReference = documentSnapshot.data()?["questions"] as? DocumentReference else {
            throw NSError(domain: "QuizBrainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Lesson document does not contain a questions reference"])
        }

        // Dereference the question document
        let questionSnapshot = try await questionReference.getDocument()
        guard let questionData = questionSnapshot.data(),
              let questionText = questionData["questionText"] as? String,
              let answers = questionData["answers"] as? [String],
              let correctAnswer = questionData["correctAnswer"] as? String else {
            throw NSError(domain: "QuizBrainError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Question data is incomplete or missing"])
        }

        return Question(q: questionText, a: answers, correctAnswer: correctAnswer)
    }




    

    // Check if the user's answer is correct
    func checkAnswer(_ userAnswer: String) -> Bool {
            if userAnswer == questions[currentQuestionIndex].correctAnswer {
                score += 1
                return true
            } else {
                return false
            }
        }

        func getScore() -> Int {
            return score
        }

    // Get the current question's text
    func getQuestionText() -> String {
        guard !questions.isEmpty && currentQuestionIndex < questions.count else {
            return "No question available"
        }
        return questions[currentQuestionIndex].text
    }

    func getAnswers() -> [String] {
        guard !questions.isEmpty && currentQuestionIndex < questions.count else {
            return []
        }
        return questions[currentQuestionIndex].answer
    }

    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
        } else {
            // Quiz finished, handle accordingly without resetting here
            print("Quiz finished. currentQuestionIndex: \(currentQuestionIndex)")
        }
    }

    func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
    }
    
    
    
    func getProgress() -> Float{
        return Float(currentQuestionIndex + 1) / Float(questions.count)
    }
    
    init(lessonId: String?) {
            self.lessonId = lessonId
        }
}

