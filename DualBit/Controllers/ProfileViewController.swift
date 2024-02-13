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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        if let email = Auth.auth().currentUser?.email {
            nameLabel.text = "Hello \(email)!"
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
