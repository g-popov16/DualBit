import UIKit
import Firebase
import FirebaseAuth

class LessonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    @IBOutlet weak var addButton: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    var lessonsBrain = LessonsBrain()
    var isAdmin: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }

        switch selectedIndex {
        case 0:
            // Present or navigate to the first view controller
            navigateToViewController(withIdentifier: "LessonViewController")
        case 1:
            // Present or navigate to the second view controller
            navigateToViewController(withIdentifier: "ProfileViewController")
        case 2:
            navigateToViewController(withIdentifier: "Admin")
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

    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonsBrain.lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath)
        let lesson = lessonsBrain.lessons[indexPath.row]
//        if lesson.completed{
//            cell.textLabel?.text = "✅\(lesson.name)"
//        }
        
        cell.textLabel?.text = "📚\(lesson.name)"
        
        
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 25)
    
        
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLessonId = lessonsBrain.lessons[indexPath.row].id
            // Make sure selectedLessonId is not nil and is a valid ID
        let quizBrain = QuizBrain(lessonId: selectedLessonId)
            // Proceed to load questions with quizBrain instance

                // Load questions asynchronously
                Task {
                    await quizBrain.loadQuestions()
                    
                    // Check if questions are loaded and update UI accordingly
                    if quizBrain.areQuestionsLoaded() == true {
                        // Perform segue or update UI to display questions
                        performSegue(withIdentifier: "LessonToVideo", sender: nil)
                    } else {
                        // Handle error or show a message to the user
                        print("Failed to load questions")
                    }
                }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LessonToVideo",
           let destinationVC = segue.destination as? VideoViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            let selectedLesson = lessonsBrain.lessons[indexPath.row]
            destinationVC.videoRef = selectedLesson.videoRef
//            destinationVC.quizBrain = QuizBrain(lessonId: selectedLesson.id)
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
func checkIfUserIsAdmin(completion: @escaping (Bool) -> Void) {
    // Make sure there is a logged-in user
    guard let userId = Auth.auth().currentUser?.uid else {
        print("No user is logged in.")
        completion(false) // No user is logged in, so cannot be admin
        return
    }

    let userDocRef = Firestore.firestore().collection("users").document(userId)
    userDocRef.getDocument { (document, error) in
        if let document = document, document.exists {
            // Check if 'isAdmin' field exists and is set to true
            let isAdmin = document.data()?["isAdmin"] as? Bool ?? false
            completion(isAdmin) // Return true or false based on the isAdmin field
        } else {
            print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            completion(false) // Document doesn't exist or there was an error, so cannot be admin
        }
    }
    
}



