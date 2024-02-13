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
        // Code for uploading video to Firebase Storage
    }
    
    /// Updates the lesson with the video reference.
    ///
    /// - Parameters:
    ///   - lessonID: The ID of the lesson.
    ///   - videoRef: The reference to the video.
    ///   - completion: The completion handler to be called after updating the lesson.
    func updateLessonWithVideoRef(lessonID: String, videoRef: String, completion: @escaping () -> Void) {
        // Code for updating the lesson with the video reference
    }
    
    /// Handles the selection of a tab bar item.
    ///
    /// - Parameters:
    ///   - tabBar: The tab bar.
    ///   - item: The selected tab bar item.
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Code for handling the selection of a tab bar item
    }
    
    /// Navigates to a view controller with the specified identifier.
    ///
    /// - Parameter identifier: The identifier of the view controller.
    func navigateToViewController(withIdentifier identifier: String) {
        // Code for navigating to a view controller
    }
    
    /// Adds a lesson with the specified name.
    ///
    /// - Parameter lessonName: The name of the lesson.
    func addLesson(named lessonName: String) {
        // Code for adding a lesson
    }
    
    /// Prepares for the segue to the 'Add Questions' view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Code for preparing for the segue
    }
}

extension AddLessonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Handles the tap on the upload video button.
    ///
    /// - Parameter sender: The upload video button.
    @IBAction func uploadVideoButtonTapped(_ sender: UIButton) {
        // Code for handling the tap on the upload video button
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
        // Code for handling the selection of a video from the image picker
    }
    
    /// Handles the cancellation of the image picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Code for handling the cancellation of the image picker
    }
}
