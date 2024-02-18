import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    /// Action method triggered when the login button is pressed.
    ///
    /// - Parameter sender: The button that triggered the action.
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error{
                    self!.errorLabel.text = e.localizedDescription
                    self!.errorLabel.textColor = .red
                }
                else{
                    self?.performSegue(withIdentifier: Constants.loginSegue, sender: self)
                }
            }
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Reset Password", message: "Enter your email to reset your password.", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        
        let sendAction = UIAlertAction(title: "Send", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first, let email = textField.text else { return }
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let e = error {
                    // Handle errors here, possibly by showing an alert to the user
                    print(e.localizedDescription)
                } else {
                    // Successfully sent password reset email
                    // Notify the user, possibly by showing an alert
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
