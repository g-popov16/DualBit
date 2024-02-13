import UIKit
import Firebase
import GoogleSignIn

/// A view controller responsible for user registration.
class RegisterViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    /// Action method triggered when the register button is pressed.
    ///
    /// - Parameter sender: The button that triggered the action.
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password ) { authResult, error in
                if let e = error {
                    self.errorLabel.text = e.localizedDescription
                } else {
                    self.addUserToFirestore(email: email)
                    self.performSegue(withIdentifier: Constants.registerSegue, sender: self)
                }
            }
        }
    }
    
    /// Adds the user to Firestore database.
    ///
    /// - Parameter email: The email of the user.
    func addUserToFirestore(email: String) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Initialize completedLessons as an empty array, friends as an empty array, and streak as 0
        let user = [
            "email": email,
            "uid": uid,
            "completedLessons": [],
            "friends": [], // Empty array to hold friends' user IDs
            "streak": 0 // Integer to track consecutive days of app usage or lesson completion
        ] as [String: Any]

        db.collection("users").document(uid).setData(user) { error in
            if let error = error {
                self.errorLabel.text = "Error saving user data to Firestore: \(error.localizedDescription)"
            } else {
                // User data added to Firestore, perform segue to the next screen
                self.performSegue(withIdentifier: Constants.registerSegue, sender: self)
            }
        }
    }

    override func viewDidLoad() {
    }
}
