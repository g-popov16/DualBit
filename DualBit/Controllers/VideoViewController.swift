//
//  VideoViewController.swift
//  DualBit
//
//  Created by Georgi Popov on 14.01.24.
//

import UIKit
import Firebase
import AVFoundation
import AVKit

protocol VideoPlayerDelegate: AnyObject {
    func didEndPlayingVideo(lessonId: String)
}

class VideoViewController:
    UIViewController{
    var videoRef: String? // The video reference URL
    var lessonId: String?
    weak var delegate: VideoPlayerDelegate?
    var player: AVPlayer?
    
    @IBOutlet var videoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let videoRef = videoRef, let videoURL = URL(string: videoRef) {
            playVideo(from: videoURL)
        }
    }
    
    func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        print(lessonId)
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak self] _ in
                self?.performSegue(withIdentifier: "VideoToQuiz", sender: self?.lessonId)
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VideoToQuiz",
           let destinationVC = segue.destination as? ViewController,
           let lessonId = sender as? String {
            destinationVC.selectedLessonId = lessonId // Ensure this property is correctly used to initialize `quizBrain` or directly passed to it.
            
        }
        
    }
}
