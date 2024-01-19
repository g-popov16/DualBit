import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "DualBit" // Replace with your app name or Constants.appName if you have that constant set up
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { [weak self] timer in
                self?.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
        // Call the fetch function after a delay that's long enough for your title animation to finish
        
        }
    }

    


