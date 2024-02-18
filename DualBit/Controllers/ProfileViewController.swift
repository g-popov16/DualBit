//
//  ProfileViewController.swift
//  DualBit
//
//  Created by Georgi Popov on 21.01.24.
//

import Foundation
import UIKit
import FirebaseAuth

/// A view controller that displays the user's profile information and allows navigation to other view controllers.
class ProfileViewController: UIViewController, UITabBarDelegate{
    @IBOutlet weak var GoToFriends: UIButton!
    
    @IBOutlet weak var streak: UILabel!
    /// Action method triggered when the logout button is pressed.
    ///
    /// - Parameter sender: The button that triggered the action.
    @IBAction func logOutPressed(_ sender: UIButton) {
    
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func updateEmailPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Update Email", message: "Enter your new email address.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "New Email"
            textField.keyboardType = .emailAddress
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self, weak alertController] _ in
            guard let newEmail = alertController?.textFields?.first?.text, !newEmail.isEmpty else { return }
            self?.updateUserEmail(to: newEmail) { error in
                if let error = error {
                    // Handle the error, perhaps by showing an alert to the user
                    print("Failed to update email: \(error.localizedDescription)")
                } else {
                    // Email update was successful
                    // Notify the user, perhaps by showing an alert
                    print("Email updated successfully.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func updateUserEmail(to newEmail: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in"]))
            return
        }
        
        // Sending a verification email to the new address
        user.sendEmailVerification(beforeUpdatingEmail: newEmail, completion: { error in
            if let error = error {
                // Handle any errors here, such as by showing an alert to the user
                completion(error)
            } else {
                // A verification email has been sent successfully
                // Inform the user to check their email and verify the new address
                completion(nil)
            }
        })
    }

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        if let email = Auth.auth().currentUser?.email {
            let emailPrefix = email.split(separator: "@").first.map(String.init) ?? ""
            nameLabel.text = "Hello \(emailPrefix)!"
            
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        
        let userStreakRef = db.collection("users").document(userId).collection("streak").document("current")
        
        
            
        userStreakRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let currentStreak = data?["currentStreak"] as? Int {
                    // Now that you have the currentStreak, update the UI on the main thread
                    DispatchQueue.main.async {
                        self.streak.text = "Current Streak: \(String(currentStreak)) days🔥🔥🔥"
                    }
                } else {
                    print("Current streak not found or is not an Int")
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
    }
    
    /// Delegate method called when a tab bar item is selected.
    ///
    /// - Parameters:
    ///   - tabBar: The tab bar that triggered the delegate call.
    ///   - item: The selected tab bar item.
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
    ///
    /// - Parameter identifier: The identifier of the view controller to navigate to.
    func navigateToViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        // Present or push the view controller
        // For example, if you're using a navigation controller:
        navigationController?.pushViewController(viewController, animated: true)
    }
}
