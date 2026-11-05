import FirebaseFirestore

struct TaskRepository {
    private let db = Firestore.firestore()

    func fetchTasks(uid: String) async throws -> [TaskItem] {
        let snapshot = try await db.collection("users").document(uid).collection("tasks").getDocuments()
        return try snapshot.documents.map { try $0.data(as: TaskItem.self) }
    }

    func addTask(uid: String, task: TaskItem) async throws {
        _ = try db.collection("users").document(uid).collection("tasks").addDocument(from: task)
    }

    func updateTask(uid: String, task: TaskItem) async throws {
        guard let id = task.id else { return }
        try db.collection("users").document(uid).collection("tasks").document(id).setData(from: task, merge: true)
    }

    func deleteTask(uid: String, taskId: String) async throws {
        try await db.collection("users").document(uid).collection("tasks").document(taskId).delete()
    }
}
