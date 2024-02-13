//
//  AddQuestionsViewController.swift
//  DualBit
//
//  Created by Georgi Popov on 27.01.24.
//

import UIKit
import Firebase

/// A view controller for adding questions to a lesson.
class AddQuestionsViewController: UIViewController, UITabBarDelegate{
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet var answerTextFields: [UITextField]!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet var correctAnswerButtons: [UIButton]!
    var lessonID: String?
    
    override func viewDidLoad() {
        tabBar.delegate = self
        super.viewDidLoad()
    }
    
    /// Action method called when a correct answer button is tapped.
    /// - Parameter sender: The button that was tapped.
    @IBAction func correctAnswerButtonTapped(_ sender: UIButton) {
        // Deselect all buttons
        correctAnswerButtons.forEach { $0.isSelected = false }
        
        // Select the tapped button
        sender.isSelected = true
    }
    
    /// Action method called when the add question button is tapped.
    /// - Parameter sender: The button that was tapped.
    @IBAction func addQuestionButtonTapped(_ sender: UIButton) {
        guard let questionText = questionTextField.text, !questionText.isEmpty,
              let lessonID = lessonID else {
            print("Question and lesson ID are required.")
            return
        }
        
        let answers = answerTextFields.compactMap { $0.text }
        
        // You need to determine the index of the correct answer here.
        // For example, this could be from a selected state of a button or other UI element.
        // This is placeholder logic; you need to replace it with your actual logic to find the correct answer.
        let correctAnswerIndex = determineCorrectAnswerIndex()  // Implement this method based on your UI.
        
        Task {
            if let index = correctAnswerIndex, index >= 0, index < answers.count {
                let correctAnswer = answers[index]

                // Await the async function and get the document reference
                if let questionRef = await addQuestion(forLesson: lessonID, questionText: questionText, answers: answers, correctAnswer: correctAnswer) {
                    print("Added question with reference: \(questionRef.path)")
                    // The questionRef can be used here if needed
                } else {
                    print("Failed to add question.")
                }
            } else {
                print("Error: Correct answer index is out of bounds or not set")
            }

            clearInputs()
        }
    }
    
    /// Determines the index of the correct answer based on the UI state.
    /// - Returns: The index of the correct answer, or `nil` if not found.
    private func determineCorrectAnswerIndex() -> Int? {
        return correctAnswerButtons.firstIndex(where: { $0.isSelected })
    }
    
    /// Adds a question to the Firestore database for a specific lesson.
    /// - Parameters:
    ///   - lessonID: The ID of the lesson.
    ///   - questionText: The text of the question.
    ///   - answers: The possible answers for the question.
    ///   - correctAnswer: The correct answer for the question.
    /// - Returns: The document reference of the added question, or `nil` if an error occurred.
    func addQuestion(forLesson lessonID: String, questionText: String, answers: [String], correctAnswer: String) async -> DocumentReference? {
        let db = Firestore.firestore()
        
        // Instead of replacing spaces with empty string, you might want to use lessonID directly
        // or any other unique identifier for the lesson to ensure uniqueness.
        let collectionName = "questions_\(lessonID)"
        
        do {
            let documentRef = try await db.collection(collectionName).addDocument(data: [
                "questionText": questionText,
                "answers": answers,
                "correctAnswer": correctAnswer
            ])
            print("Question added successfully to collection: \(collectionName)")
            return documentRef
        } catch let error {
            print("Error adding question: \(error)")
            return nil
        }
    }
    
    /// Updates a lesson with a question reference.
    /// - Parameters:
    ///   - lessonID: The ID of the lesson.
    ///   - questionRef: The document reference of the question.
    func updateLessonWithQuestionRef(lessonID: String, questionRef: DocumentReference) async {
        let db = Firestore.firestore()
        let lessonRef = db.collection("lessons").document(lessonID)
        
        // Update the lesson document with the single question reference
        do {
            try await lessonRef.updateData([
                "questions": questionRef
            ])
            print("Lesson updated successfully with question reference")
        } catch let error {
            print("Error updating lesson with question ref: \(error)")
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }
        
        switch selectedIndex {
        case 0:
            // Present or navigate to the first view controller
            navigateToViewController(withIdentifier: "LessonViewController")
        case 1:
            // Present or navigate to the second view controller
            navigateToViewController(withIdentifier: "ProfileViewController")
            // Add more cases as needed
        default:
            break
        }
    }
    
    /// Navigates to a view controller with the specified identifier.
    /// - Parameter identifier: The identifier of the view controller.
    func navigateToViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        // Present or push the view controller
        // For example, if you're using a navigation controller:
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// Clears the input fields and resets the correct answer selection.
    private func clearInputs() {
        questionTextField.text = ""
        for textField in answerTextFields {
            textField.text = ""
        }
        // Reset correct answer selection as well...
    }
}
