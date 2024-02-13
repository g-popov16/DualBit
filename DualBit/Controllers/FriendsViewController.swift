import UIKit
import FirebaseAuth
import FirebaseFirestore

/// A view controller that displays a list of friends and allows searching for new friends.
class FriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    let db = Firestore.firestore()
    var users: [[String: Any]] = [] // Array of dictionaries to store user data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        searchBar.autocapitalizationType = .none
    }
    
    /**
     This code is from the `FriendsViewController.swift` file and contains the implementation of a view controller that displays a list of friends. It includes methods for setting up the search bar and table view, searching for users by email, and handling table view data source and delegate methods. It also includes an action method for adding a friend and a helper method for creating a conversation between friends.
     */
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        // Register the UITableViewCell class with the "UserCell" identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.backgroundColor = UIColor.clear
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let emailToSearch = searchBar.text else { return }
        searchUserByEmail(email: emailToSearch)
    }
    
    private func searchUserByEmail(email: String) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                self.users = querySnapshot.documents.map { $0.data() }
                self.tableView.reloadData()
            } else {
                print("No users found with that email.")
                self.users = []
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        if let email = users[indexPath.row]["email"] as? String {
            cell.textLabel?.text = email
        }
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.backgroundColor = UIColor.clear // In case the label has its own background
        return cell
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        // Ensure there's at least one user in the search results
        guard let userToAdd = users.first, let friendDocumentID = userToAdd["uid"] as? String else {
                print("No user selected or user data incomplete.")
                return
            }
            
            addFriend(friendDocumentID: friendDocumentID) { [weak self] success in
                guard let strongSelf = self else { return }
                
                if success {
                    print("Both users successfully added to each other's friends list.")
                    // Call createConversationForFriends only once here after both friend additions are successful
                    strongSelf.createConversationForFriends(user1UID: Auth.auth().currentUser?.uid ?? "", user2UID: friendDocumentID)
                } else {
                    print("Failed to add users to each other's friends list.")
                }
            }
    }
    
    private func addFriend(friendDocumentID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No current user logged in")
            completion(false)
            return
        }

        // Prepare to update both users simultaneously, tracking completion with a DispatchGroup
        let dispatchGroup = DispatchGroup()
        var updateSuccess = true

        // Update current user's friend list
        dispatchGroup.enter()
        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayUnion([friendDocumentID])
        ]) { error in
            if let error = error {
                print("Error updating currentUser's document: \(error)")
                updateSuccess = false
            }
            dispatchGroup.leave()
        }

        // Update friend user's friend list
        dispatchGroup.enter()
        db.collection("users").document(friendDocumentID).updateData([
            "friends": FieldValue.arrayUnion([currentUserID])
        ]) { error in
            if let error = error {
                print("Error updating friendUser's document: \(error)")
                updateSuccess = false
            }
            dispatchGroup.leave()
        }

        // Once both updates are complete, call the completion handler
        dispatchGroup.notify(queue: .main) {
            completion(updateSuccess)
        }
    }
    
    func createConversationForFriends(user1UID: String, user2UID: String) {
        // Generate conversation ID using the sorted UIDs joined by an underscore
        let conversationID = [user1UID, user2UID].sorted().joined(separator: "_")

        db.collection("conversations").document(conversationID).getDocument { [weak self] (document, error) in
            guard let strongSelf = self else { return }

            if let error = error {
                print("Error checking for existing conversation: \(error)")
                return
            }

            if let document = document, document.exists {
                // If the conversation already exists, do nothing
                print("Conversation already exists with ID: \(conversationID).")
            } else {
                // No existing conversation, create a new one
                let ref = strongSelf.db.collection("conversations").document(conversationID)
                ref.setData([
                    "participants": [user1UID, user2UID].sorted()
                ]) { error in
                    if let e = error {
                        print("There was an issue creating a conversation in Firestore: \(e)")
                    } else {
                        print("New conversation created with ID: \(conversationID).")

                        // Add an initial message to the 'messages' subcollection to implicitly create it
                        ref.collection("messages").addDocument(data: [
                            "sender": "system", // Or use a relevant sender ID for system messages
                            "body": "Conversation started.",
                            "dateField": FieldValue.serverTimestamp()
                        ]) { err in
                            if let err = err {
                                print("Error adding initial message: \(err)")
                            } else {
                                print("Initial message added to conversation.")
                            }
                        }
                    }
                }
            }
        }
    }

    

    


    func addConversationToUser(userID: String, conversationID: String) {
        let userDocRef = db.collection("users").document(userID)
        
        userDocRef.updateData([
            "conversations": FieldValue.arrayUnion([conversationID])
        ]) { error in
            if let e = error {
                print("Error updating user with conversationID: \(e)")
            } else {
                print("User \(userID) updated with new conversationID \(conversationID)")
            }
        }
    }
}
