import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    /// Action method triggered when the login button is pressed.
    ///
    /// - Parameter sender: The button that triggered the action.
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error{
                    print(e)
                }
                else{
                    self?.performSegue(withIdentifier: Constants.loginSegue, sender: self)
                }
            }
        }
    }
    
}
