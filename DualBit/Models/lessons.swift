/// Represents a lesson in the DualBit app.
struct Lesson {
    /// The unique identifier of the lesson.
    var id: String
    
    /// The name of the lesson.
    var name: String
    
    /// Indicates whether the lesson has been completed or not.
    var completed: Bool
    
    /// The reference to the video associated with the lesson.
    var videoRef: String
    
    /// Initializes a new instance of the Lesson struct.
    /// - Parameters:
    ///   - id: The unique identifier of the lesson.
    ///   - name: The name of the lesson.
    ///   - completed: Indicates whether the lesson has been completed or not.
    ///   - videoRef: The reference to the video associated with the lesson.
    init(id: String, name: String, completed: Bool, videoRef: String) {
        self.id = id
        self.name = name
        self.completed = completed
        self.videoRef = videoRef
    }
}
