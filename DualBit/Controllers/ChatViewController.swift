

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    var lessonsBrain = LessonsBrain()

    let db = Firestore.firestore()
    
    var messages: [Message] = [
        
    ]
    
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
    
    func loadMessages(){
        
        
        db.collection(Constants.FStore.collectionName).order(by: Constants.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error{
            print(e)
        }else{
            
            if let snapshotDocuments = querySnapshot?.documents{
                for i in snapshotDocuments{
                    let data = i.data()
                    if let sender = data[Constants.FStore.senderField] as? String, let messageBody = data[Constants.FStore.bodyField] as? String{
                        let newMessage = Message(sender: sender, body: messageBody )
                        self.messages.append(newMessage)
                        
                        
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let message = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            db.collection(Constants.FStore.collectionName).addDocument(data: [Constants.FStore.senderField: messageSender, Constants.FStore.bodyField: message, Constants.FStore.dateField: Date().timeIntervalSince1970], completion: {(error) in if let e = error{
                print(e)} else{
                    print("Success")
                    DispatchQueue.main.async{
                        self.messageTextfield.text = ""

                    }
                }
            }
            )
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
            // Get the selected lesson
            let selectedLesson = lessonsBrain.lessons[indexPath.item]
            print("Cell tapped")
            // Perform the segue and pass the selected lesson's identifier
            performSegue(withIdentifier: "GoToQuiz", sender: selectedLesson.id) // Assuming your lesson has an 'id' property
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToQuiz" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedLessonId = sender as? String // Cast the sender to a String
        }
    }
        }
    

    


extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.isOpaque = false
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        
        if message.sender == Auth.auth().currentUser?.email{
            cell.youImageView.isHidden = true
            cell.rightImageView.isHidden = false
        
            cell.label.textColor = UIColor(named: Constants.BrandColors.purple)
        }
        else{
            cell.youImageView.isHidden = false
            cell.rightImageView.isHidden = true
        }
        
        if let textLabel = cell.textLabel {
                textLabel.font = UIFont.boldSystemFont(ofSize: textLabel.font.pointSize)
            
            textLabel.font = UIFont.italicSystemFont(ofSize: textLabel.font.pointSize)
            
            }

        return cell
    }
    
    
}


