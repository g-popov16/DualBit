//
//  AddQuestionsViewController.swift
//  DualBit
//
//  Created by Georgi Popov on 27.01.24.
//

import UIKit
import Firebase

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
    
    @IBAction func correctAnswerButtonTapped(_ sender: UIButton) {
        // Deselect all buttons
        correctAnswerButtons.forEach { $0.isSelected = false }
        
        // Select the tapped button
        sender.isSelected = true
    }

    
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

        // This function should contain the logic to determine the index of the correct answer based on your UI.
    private func determineCorrectAnswerIndex() -> Int? {
        return correctAnswerButtons.firstIndex(where: { $0.isSelected })
    }
    
    
    
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




                     
        
        private func clearInputs() {
            questionTextField.text = ""
            for textField in answerTextFields {
                textField.text = ""
            }
            // Reset correct answer selection as well...
        }
}
