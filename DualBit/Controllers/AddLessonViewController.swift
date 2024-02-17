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
import Photos

/// A view controller for adding a lesson.
class AddLessonViewController: UIViewController, UITabBarDelegate{
    
    /// Text field for entering the lesson name.
    @IBOutlet weak var lessonNameTextField: UITextField!
    
    /// Tab bar for navigation.
    @IBOutlet weak var tabBar: UITabBar!
    
    /// Button action for adding a lesson.
    @IBAction func addLessonButtonTapped(_ sender: UIButton) {
        guard let lessonName = lessonNameTextField.text, !lessonName.isEmpty else {
            print("Lesson name is required.")
            return
        }
        
        addLesson(named: lessonName)
    }
    
    /// The ID of the lesson.
    var lessonID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
    }
    
    /// Uploads a video to Firebase Storage.
    ///
    /// - Parameters:
    ///   - videoURL: The URL of the video to upload.
    ///   - lessonID: The ID of the lesson.
    func uploadVideoToFirebaseStorage(_ videoURL: URL, lessonID: String) {
        let storageRef = Storage.storage().reference()
        let videoID = UUID().uuidString
        let videosRef = storageRef.child("videos/\(videoID).mp4")

        // Attempt to load video data into memory
        do {
            let videoData = try Data(contentsOf: videoURL)
            
            print("Starting video upload for videoID: \(videoID)")

            // Upload video data
            let uploadTask = videosRef.putData(videoData, metadata: nil) { metadata, error in
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
                            // Pass the lessonID as the sender here
                            self?.performSegue(withIdentifier: "AddQuestionsVC", sender: lessonID)
                        }
                    }
                }
            }

            // Optionally, you can observe the upload progress
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                print("Upload is \(percentComplete)% complete")
            }

        } catch {
            print("Error loading video data: \(error.localizedDescription)")
        }
    }

    
    /// Updates the lesson with the video reference.
    ///
    /// - Parameters:
    ///   - lessonID: The ID of the lesson.
    ///   - videoRef: The reference to the video.
    ///   - completion: The completion handler to be called after updating the lesson.
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
    
    /// Handles the selection of a tab bar item.
    ///
    /// - Parameters:
    ///   - tabBar: The tab bar.
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
    /// - Parameter identifier: The identifier of the view controller.
    func navigateToViewController(withIdentifier identifier: String) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            // Present or push the view controller
            // For example, if you're using a navigation controller:
            navigationController?.pushViewController(viewController, animated: true)
        }
    
    /// Adds a lesson with the specified name.
    ///
    /// - Parameter lessonName: The name of the lesson.
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
                    print("Lesson added successfully. \(newLessonRef.documentID) Now you can upload a video.")
                    DispatchQueue.main.async {
                        
                        // Use the documentID from the newLessonRef since we're setting data on it directly
                        self?.lessonID = newLessonRef.documentID
                    }
                }
            }
        }

    
    /// Prepares for the segue to the 'Add Questions' view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddQuestionsVC",
           let destinationVC = segue.destination as? AddQuestionsViewController,
           let lessonID = sender as? String {
            destinationVC.lessonID = lessonID
        }
    }


}

extension AddLessonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Handles the tap on the upload video button.
    ///
    /// - Parameter sender: The upload video button.
    @IBAction func uploadVideoButtonTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.mediaTypes = [kUTTypeMovie as String]
                picker.delegate = self
                present(picker, animated: true)
    }
    
    /// Shows the image picker for selecting a video.
    func showImagePicker() {
        // Code for showing the image picker
    }
    
    /// Handles the access denied to the photo library.
    func handleAccessDenied() {
        // Code for handling the access denied to the photo library
    }
    
    /// Handles the selection of a video from the image picker.
    ///
    /// - Parameters:
    ///   - picker: The image picker controller.
    ///   - info: The information about the selected video.
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
    
    /// Handles the cancellation of the image picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
