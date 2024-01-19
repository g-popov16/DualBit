

import UIKit
import FirebaseFirestore
import FirebaseAuth

let db = Firestore.firestore()
let questionRef = db.collection("questions").document("question1")



class ViewController: UIViewController {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var True: UIButton!
    @IBOutlet weak var falseButton: UIButton!
    
    @IBOutlet weak var snake: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    var selectedLessonId: String?
    
    var quizBrain: QuizBrain!
    
    
    override func viewDidLoad() {
        True.titleLabel?.numberOfLines = 1 // Ensure the title is only one line
        True.titleLabel?.adjustsFontSizeToFitWidth = true // Enable font size adjustment
        True.titleLabel?.lineBreakMode = .byClipping // Clip the text that goes beyond the button's bounds
        True.titleLabel?.baselineAdjustment = .alignCenters // Keep the text centered vertically
        True.titleLabel?.minimumScaleFactor = 0.2 // The text will now scale down to 50% of its original size if needed    True.titleLabel?.numberOfLines = 1 // Ensure the title is only one line
        trueButton.titleLabel?.adjustsFontSizeToFitWidth = true // Enable font size adjustment
        trueButton.titleLabel?.lineBreakMode = .byClipping // Clip the text that goes beyond the button's bounds
        trueButton.titleLabel?.baselineAdjustment = .alignCenters // Keep the text centered vertically
        trueButton.titleLabel?.minimumScaleFactor = 0.2 // The text will now scale down to 50% of its original size if needed    True.titleLabel?.numberOfLines = 1 // Ensure the title is only one line
        falseButton.titleLabel?.adjustsFontSizeToFitWidth = true // Enable font size adjustment
        falseButton.titleLabel?.lineBreakMode = .byClipping // Clip the text that goes beyond the button's bounds
        falseButton.titleLabel?.baselineAdjustment = .alignCenters // Keep the text centered vertically
        falseButton.titleLabel?.minimumScaleFactor = 0.2 // The text will now scale down to 50% of its original size if needed
        super.viewDidLoad()
        snake.image = UIImage(named: "SnakeHappy")
        quizBrain = QuizBrain(lessonId: selectedLessonId)
        
        Task {
            await loadQuestions()
            updateUI() // This is already on the main thread because of @MainActor
        }
    }
    
    func loadQuestions() async {
        await quizBrain.loadQuestions()
        // Call updateUI on the main thread after questions have been loaded
        DispatchQueue.main.async {
            self.updateUI()
        }
    }




    @IBAction func answerButtonPressed(_ sender: UIButton) {
        
        
        
        let userAnswer = sender.currentTitle!
        let isCorrect = quizBrain.checkAnswer(userAnswer)
        
        sender.backgroundColor = isCorrect ? UIColor.green : UIColor.red
        snake.image = isCorrect ? UIImage(named: "SnakeHappy") : UIImage(named: "SnakeAngry")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.quizBrain.isQuizFinished() {
                if self.quizBrain.didUserPassQuiz() {
                        // The user has completed and passed the quiz
                        if let userId = Auth.auth().currentUser?.uid, let lessonId = self.selectedLessonId {
                            self.quizBrain.completeLesson(lessonId: lessonId, userId: userId)
                        }
                    } else {
                        self.quizBrain.nextQuestion()

                    }
                } else {
                    // The quiz is not yet finished, go to the next question
                    self.quizBrain.nextQuestion()
                    // Update UI accordingly
                }
                self.updateUI()
            }
        
       
        
        
        
        
        
    }
    
    @objc func updateUI() {
        // Assuming you have a method in QuizBrain to get the current question text
        
        questionLabel.text = quizBrain.getQuestionText()
        // Fetch answers for the current question
        let answers = quizBrain.getAnswers()

        // Ensure there are enough answers to update the buttons
        guard answers.count >= 3 else {
            print("Not enough answers fetched")
            trueButton.setTitle("N/A", for: .normal)
            falseButton.setTitle("N/A", for: .normal)
            True.setTitle("N/A", for: .normal) // Assuming you have a third button
            return
        }

        trueButton.setTitle(answers[0], for: .normal)
        falseButton.setTitle(answers[1], for: .normal)
        True.setTitle(answers[2], for: .normal) // Update this as per your button's actual name
    



//        quizBrain.fetchCorrectAnswer { [weak self] correctAnswer in
//            DispatchQueue.main.async {
//                // Here you can update a label or other UI element with the correct answer
//                self?.correctAnswerLabel.text = correctAnswer
//            }
//        }

        trueButton.backgroundColor = UIColor.clear
        
        
        True.backgroundColor = UIColor.clear
        falseButton.backgroundColor = UIColor.clear
        scoreLabel.text = "Score: \(quizBrain.getScore())/10"
        progressBar.setProgress(quizBrain.getProgress(), animated: true)
    }


    
    @IBOutlet weak var bar: UIProgressView!
    


}
