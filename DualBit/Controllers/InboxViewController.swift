//
//  InboxViewController.swift
//  DualBit
//
//  Created by Georgi Popov on 11.02.24.
//  Copyright © 2024 Angela Yu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    var friends: [Friend] = []
    private var db = Firestore.firestore()
    @IBOutlet weak var addButton: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    var lessonsBrain = LessonsBrain()
    var isAdmin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the user is an admin and add the admin tab if necessary
        checkIfUserIsAdmin { isAdmin in
            DispatchQueue.main.async {
                if isAdmin {
                    // User is an admin
                    self.addAdminTab()
                } else {
                    // User is not an admin
                    print("User is not an admin.")
                }
            }
            self.loadFriends()
        }
        
        let userId = Auth.auth().currentUser?.uid
        tabBar.delegate = self
        navigationItem.hidesBackButton = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LessonCell")

        // Load the lessons
        lessonsBrain.loadLessons { [weak self] result in
            switch result {
            case .success(let loadedLessons):
                DispatchQueue.main.async {
                    self?.lessonsBrain.lessons = loadedLessons
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error loading lessons: \(error)")
            }
        }
    }
    
    // MARK: - UITabBarDelegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }

        switch selectedIndex {
        case 0:
            // Present or navigate to the first view controller
            navigateToViewController(withIdentifier: "LessonViewController")
        case 1:
            // Present or navigate to the second view controller
            navigateToViewController(withIdentifier: "Inbox")

        case 2:
            navigateToViewController(withIdentifier: "ProfileViewController")

        case 3:
            navigateToViewController(withIdentifier: "Admin")

        default:
            break
            
        }
    }
    
    // MARK: - Helper Methods
    
    func navigateToViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        // Present or push the view controller
        // For example, if you're using a navigation controller:
        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath)
        let friend = friends[indexPath.row]
        let emailPrefix = friend.email.split(separator: "@").first.map(String.init) ?? ""
        cell.textLabel?.text = "\(emailPrefix) - Streak: \(friend.currentStreak) days🔥"
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 25)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendUID = friends[indexPath.row].uid
        performSegue(withIdentifier: "GoToChat", sender: friendUID)
    }

    
    func loadFriends() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }

        let userDocRef = db.collection("users").document(currentUserUID)
        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let document = document, document.exists, let friendsArray = document.data()?["friends"] as? [String] {
                self.friends.removeAll()

                let dispatchGroup = DispatchGroup()

                for friendUID in friendsArray {
                    dispatchGroup.enter()
                    
                    let friendDocRef = self.db.collection("users").document(friendUID)
                    friendDocRef.getDocument { (friendDoc, error) in
                        if let friendDoc = friendDoc, friendDoc.exists, let friendEmail = friendDoc.data()?["email"] as? String {
                            
                            // Now fetch the current streak for this friend
                            let userStreakRef = friendDocRef.collection("streak").document("current")
                            userStreakRef.getDocument { (streakDoc, streakError) in
                                var currentStreak = 0 // Default to 0
                                
                                if let streakDoc = streakDoc, streakDoc.exists, let streak = streakDoc.data()?["currentStreak"] as? Int {
                                    currentStreak = streak
                                } else {
                                    print("Could not fetch streak for user \(friendUID): \(streakError?.localizedDescription ?? "Unknown error")")
                                }
                                
                                // Now that we have all information, append the friend
                                let friend = Friend(email: friendEmail, uid: friendUID, currentStreak: currentStreak)
                                self.friends.append(friend)
                                
                                dispatchGroup.leave()
                            }
                        } else {
                            print("Could not fetch document for user \(friendUID): \(error?.localizedDescription ?? "Unknown error")")
                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.tableView.reloadData()
                }
            } else {
                print("Document does not exist or there was an error: \(String(describing: error))")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToChat" {
            if let chatVC = segue.destination as? ChatViewController,
               let friendUID = sender as? String {
                chatVC.friendUID = friendUID
            }
        }
    }


    private func addAdminTab() {
        let adminItem = UITabBarItem(title: "Add", image: UIImage(systemName: "plus"), tag: 1)
        if let items = tabBar.items {
            tabBar.items = items + [adminItem]
        } else {
            tabBar.items = [adminItem]
        }
    }
}

// Function to check if the current user is an admin
//func checkIfUserIsAdmin(completion: @escaping (Bool) -> Void) {
//    // Make sure there is a logged-in user
//    guard let userId = Auth.auth().currentUser?.uid else {
//        print("No user is logged in.")
//        completion(false) // No user is logged in, so cannot be admin
//        return
//    }
//
//    let userDocRef = Firestore.firestore().collection("users").document(userId)
//    userDocRef.getDocument { (document, error) in
//        if let document = document, document.exists {
//            // Check if 'isAdmin' field exists and is set to true
//            let isAdmin = document.data()?["isAdmin"] as? Bool ?? false
//            completion(isAdmin) // Return true or false based on the isAdmin field
//        } else {
//            print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
//            completion(false) // Document doesn't exist or there was an error, so cannot be admin
//        }
//    }
    
//}
