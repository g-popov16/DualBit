import Firebase

/// The brain of the Lessons feature, responsible for loading lessons from Firestore.
class LessonsBrain {
    private var db = Firestore.firestore()
    var lessons: [Lesson] = []

    /// Loads lessons from Firestore.
    /// - Parameter completion: A closure that is called when the loading is complete. It takes a `Result` object as its parameter, which contains either an array of `Lesson` objects or an error.
    func loadLessons(completion: @escaping (Result<[Lesson], Error>) -> Void) {
        db.collection("lessons").getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let loadedLessons = querySnapshot?.documents.compactMap { document -> Lesson? in
                let data = document.data()
                guard let name = data["lessonName"] as? String,
                      let completed = data["completed"] as? Bool,
                      let videoRef = data["videoRef"] as? String else {
                    return nil
                }
                // Ensure that the Lesson initializer accepts a videoRef argument
                return Lesson(id: document.documentID, name: name, completed: completed, videoRef: videoRef)
            } ?? []

            self.lessons = loadedLessons
            completion(.success(loadedLessons))
        }
    }
}
