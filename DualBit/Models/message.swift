import FirebaseFirestore
import Foundation
struct Message {
    let sender: String
    let body: String
    let dateField: Timestamp // Ensure this matches the Firestore field type

    init(sender: String, body: String, dateField: Timestamp) {
        self.sender = sender
        self.body = body
        self.dateField = dateField
    }
}
