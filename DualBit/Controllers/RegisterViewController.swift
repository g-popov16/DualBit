

import UIKit
import Firebase
import GoogleSignIn

class RegisterViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text
        {
            Auth.auth().createUser(withEmail: email, password: password ) { authResult, error in
                if let e = error{
                    self.errorLabel.text = e.localizedDescription
                }
                else{
                    self.addUserToFirestore(email: email)
                    self.performSegue(withIdentifier: Constants.registerSegue, sender: self)
                }
            }
            
        }
        
        
    }
    func addUserToFirestore(email: String) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Initialize completedLessons as an empty array
        let user = [
            "email": email,
            "uid": uid,
            "completedLessons": []
        ] as [String : Any]
        
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
