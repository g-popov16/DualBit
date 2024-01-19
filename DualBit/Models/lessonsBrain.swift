import Firebase
class LessonsBrain {
    private var db = Firestore.firestore()
    var lessons: [Lesson] = []

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
