//
//  AdminViewController.swift
//  DualBit
//
//  Created by Georgi Popov on 27.01.24.
//

import UIKit
import Firebase
import FirebaseAuth

class AdminViewController: UIViewController, UITabBarDelegate{
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        
        tabBar.delegate = self
        super.viewDidLoad()
        if let email = Auth.auth().currentUser?.email{
            nameLabel.text = "Hello \(email), you are an admin!"
        }
        
    }
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
    
    func navigateToViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        // Present or push the view controller
        // For example, if you're using a navigation controller:
        navigationController?.pushViewController(viewController, animated: true)
    }
        
}
