//
//  streakBrain.swift
//  DualBit
//
//  Created by Georgi Popov on 18.02.24.
//  Copyright © 2024 DualBit. All rights reserved.
//

import Foundation
import Foundation
import FirebaseFirestore
import FirebaseAuth

class StreakBrain {
    private var db = Firestore.firestore()
    
    /// Checks if 24 hours have passed since the last quiz without activity and resets the streak if so.
    func checkStreak() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        
        let userStreakRef = db.collection("users").document(userId).collection("streak").document("current")
        
        userStreakRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let lastQuizDate = (data?["lastQuizDate"] as? Timestamp)?.dateValue() ?? Date()
                let now = Date()
                
                let elapsedTime = now.timeIntervalSince(lastQuizDate)
                let hours = elapsedTime / 3600 // Convert seconds to hours
                
                if hours >= 24 {
                    // At least 24 hours have passed, so reset the streak
                    userStreakRef.updateData([
                        "currentStreak": 0, // Reset streak to 0
                        "lastQuizDate": Timestamp(date: now) // Update lastQuizDate to now
                    ]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Streak reset successfully")
                        }
                    }
                } else {
                    print("No need to reset the streak. Hours since last quiz: \(hours)")
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
