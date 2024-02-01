//
//  AddLessonViewController.swift
//  DualBit
//
//  Created by Georgi Popov on 27.01.24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import MobileCoreServices

class AddLessonViewController: UIViewController, UITabBarDelegate{
    @IBOutlet weak var lessonNameTextField: UITextField!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBAction func addLessonButtonTapped(_ sender: UIButton) {
        guard let lessonName = lessonNameTextField.text, !lessonName.isEmpty else {
            print("Lesson name is required.")
            return
        }
        
        addLesson(named: lessonName)
    }
    var lessonID: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        
    }
    
    func uploadVideoToFirebaseStorage(_ videoURL: URL, lessonID: String) {
        let storageRef = Storage.storage().reference()
        let videoID = UUID().uuidString
        let videosRef = storageRef.child("videos/\(videoID).mp4")
        
        print("Starting video upload for videoID: \(videoID)")
        
        videosRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Error during video upload: \(error.localizedDescription)")
                return
            }
            
            guard metadata != nil else {
                print("Metadata is nil after video upload.")
                return
            }
            
            print("Video uploaded, fetching download URL for videoID: \(videoID)")
            
            videosRef.downloadURL { [weak self] (url, error) in
                if let error = error {
                    print("Download URL not found: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url else {
                    print("Download URL is nil.")
                    return
                }
                
                print("Video uploaded successfully, download URL: \(downloadURL)")
                self?.updateLessonWithVideoRef(lessonID: lessonID, videoRef: downloadURL.absoluteString) {
                    // After successfully updating the lesson, perform the segue
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: "AddQuestionsVC", sender: nil)
                    }
                }
            }
        }
    }

    
    
    func updateLessonWithVideoRef(lessonID: String, videoRef: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let lessonRef = db.collection("lessons").document(lessonID)
        
        lessonRef.updateData([
            "videoRef": videoRef
        ]) { error in
            if let error = error {
                print("Error updating lesson with video ref: \(error)")
            } else {
                print("Lesson updated successfully with video reference.")
                completion() // Call the completion handler here
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
    
    func addLesson(named lessonName: String) {
        let db = Firestore.firestore()
        // Create a new document reference first
        let newLessonRef = db.collection("lessons").document()

        // Use this reference to add the document with data
        newLessonRef.setData([
            "lessonName": lessonName,
            "completed": false,
            "videoRef": ""
        ]) { [weak self] error in
            if let error = error {
                print("Error adding lesson: \(error)")
            } else {
                print("Lesson added successfully. Now you can upload a video.")
                DispatchQueue.main.async {
                    
                    // Use the documentID from the newLessonRef since we're setting data on it directly
                    self?.lessonID = newLessonRef.documentID
                }
            }
        }
    }





        
        // Prepare for the segue to the 'Add Questions' view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddQuestionsVC",
           let destinationVC = segue.destination as? AddQuestionsViewController,
           let lessonID = sender as? String {
            destinationVC.lessonID = lessonID
        }
    }

}

extension AddLessonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func uploadVideoButtonTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let videoURL = info[.mediaURL] as? URL else {
            print("Error: No video selected")
            return
        }
        
        // Here, ensure lessonID is available before calling
        if let lessonID = self.lessonID {
            uploadVideoToFirebaseStorage(videoURL, lessonID: lessonID)
        } else {
            print("Error: lessonID is nil. Ensure lesson is added before uploading video.")
        }
    }


    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
