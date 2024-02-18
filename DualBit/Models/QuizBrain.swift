/**
 A class representing a Quiz Brain.

 The QuizBrain class is responsible for managing the quiz logic, including loading questions from Firestore, checking answers, keeping track of the score, and advancing to the next question.

 Usage:
 1. Create an instance of QuizBrain with a lesson ID.
 2. Call the `loadQuestions()` method to fetch questions from Firestore.
 3. Use the `getQuestionText()` method to get the current question's text.
 4. Use the `getAnswers()` method to get the available answers for the current question.
 5. Call the `checkAnswer(_:)` method to check if the user's answer is correct.
 6. Use the `getScore()` method to get the current score.
 7. Call the `nextQuestion()` method to advance to the next question.
 8. Use the `getProgress()` method to get the progress of the quiz.
 9. Call the `resetQuiz()` method to reset the quiz.

 - Note: Before using the QuizBrain class, make sure to set the `lessonId` property to the desired lesson ID.

 - Important: The QuizBrain class requires a valid Firestore configuration and internet connection to fetch questions from Firestore.
 */


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
        ]) { [self] error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                recordQuizCompletion(userId: Auth.auth().currentUser!.uid)
            }
        }
    }
    
    func recordQuizCompletion(userId: String) {
        let userStreakRef = db.collection("users").document(userId).collection("streak").document("current")

        // Use server timestamp to ensure consistency
        let today = Timestamp(date: Date())

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userStreakDocument: DocumentSnapshot
            do {
                try userStreakDocument = transaction.getDocument(userStreakRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let lastQuizDate = userStreakDocument.data()?["lastQuizDate"] as? Timestamp else {
                // If the document does not exist or lastQuizDate is not set, initialize
                transaction.setData(["currentStreak": 1, "lastQuizDate": today, "longestStreak": 1], forDocument: userStreakRef)
                return nil
            }

            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: lastQuizDate.dateValue())
            let date2 = calendar.startOfDay(for: Date())

            let components = calendar.dateComponents([.day], from: date1, to: date2)
            let currentStreak = userStreakDocument.data()?["currentStreak"] as? Int ?? 0
            let longestStreak = userStreakDocument.data()?["longestStreak"] as? Int ?? 0

            if components.day == 1 { // Consecutive day
                transaction.updateData(["currentStreak": currentStreak + 1, "lastQuizDate": today, "longestStreak": max(longestStreak, currentStreak + 1)], forDocument: userStreakRef)
            } else if components.day! > 1 { // Not consecutive, reset streak
                transaction.updateData(["currentStreak": 1, "lastQuizDate": today], forDocument: userStreakRef)
            }
            // If components.day == 0, do nothing (already completed quiz today)

            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
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

