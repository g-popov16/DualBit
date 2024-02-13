import UIKit
import Firebase

/// View controller responsible for managing the chat functionality.
class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    var lessonsBrain = LessonsBrain()
    var friendName = ""
    let db = Firestore.firestore()
    var friendUID = ""
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        navigationItem.hidesBackButton = false
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        title = Constants.appName
        tableView.backgroundColor = UIColor.clear

        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
    }
    
    /// Generates a unique conversation ID based on the current user's UID and the friend's UID.
    /// - Parameter friendUID: The UID of the friend.
    /// - Returns: The conversation ID.
    func getConversationID(with friendUID: String) -> String {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            fatalError("Current user UID is nil.")
        }
        return [currentUserUID, friendUID].sorted().joined(separator: "_")
    }

    /// Loads the messages for the current conversation from Firestore.
    func loadMessages() {
        let conversationID = getConversationID(with: friendUID)

        db.collection("conversations").document(conversationID).collection("messages").order(by: "dateField").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let e = error {
                print("There was an issue retrieving data from Firestore: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    self.messages = snapshotDocuments.compactMap { doc -> Message? in
                        let data = doc.data()
                        if let sender = data["sender"] as? String,
                           let messageBody = data["body"] as? String,
                           let dateField = data["dateField"] as? Timestamp {
                            return Message(sender: sender, body: messageBody, dateField: dateField)
                        }
                        return nil
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        let lastRowIndex = self.messages.count - 1
                        if lastRowIndex >= 0 {
                            let indexPath = IndexPath(row: lastRowIndex, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                    }
                }
            }
        }
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        guard let messageBody = messageTextfield.text, !messageBody.isEmpty else {
            print("Message is empty.")
            return
        }
        
        let conversationID = getConversationID(with: friendUID)
        let messageData: [String: Any] = [
            "sender": Auth.auth().currentUser?.email ?? "",
            "body": messageBody,
            "dateField": Timestamp(date: Date())
        ]
        
        db.collection("conversations").document(conversationID).collection("messages").addDocument(data: messageData) { [weak self] error in
            if let e = error {
                print("There was a problem sending the message: \(e)")
            } else {
                DispatchQueue.main.async {
                    self?.messageTextfield.text = ""
                    print(conversationID)
                }
            }
        }
    }

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLesson = lessonsBrain.lessons[indexPath.item]
        print("Cell tapped")
        performSegue(withIdentifier: "GoToQuiz", sender: selectedLesson.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToQuiz" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedLessonId = sender as? String // Cast the sender to a String
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.isOpaque = false
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.youImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.label.textColor = UIColor(named: Constants.BrandColors.purple)
        } else{
            cell.youImageView.isHidden = false
            cell.rightImageView.isHidden = true
            // check if it's the initial message
            if message.sender == "system"{
                cell.rightImageView.image = UIImage(named: "Admin")
            }
            
        }
        
        if let textLabel = cell.textLabel {
            textLabel.font = UIFont.boldSystemFont(ofSize: textLabel.font.pointSize)
            textLabel.font = UIFont.italicSystemFont(ofSize: textLabel.font.pointSize)
        }

        return cell
    }
}
