import FirebaseFirestore

struct TaskItem: Codable {
    @DocumentID var id: String?
    var title: String
    var notes: String?
    var dueDate: Timestamp?
    var priority: String // "low" | "medium" | "high"
    var completed: Bool = false
    var completedAt: Timestamp?
    var pointsAwarded: Int = 0
    var source: String = "manual" // "manual" | "canvas" | "calendar"
    @ServerTimestamp var createdAt: Timestamp?
}
