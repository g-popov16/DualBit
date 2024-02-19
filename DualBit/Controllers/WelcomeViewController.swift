import UIKit
import Firebase



/// The view controller responsible for displaying the welcome screen of the DualBit app.
class WelcomeViewController: UIViewController {
    
    /// The Firestore database instance used for data storage and retrieval.
    let db = Firestore.firestore()
    
    /// The label that displays the title of the app.
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "DualBit"
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { [weak self] timer in
                self?.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
        
        
    }
}
