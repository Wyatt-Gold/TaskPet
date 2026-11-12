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
    var calendarEventID: String? // EKEvent.eventIdentifier, set only when source == "calendar"
    @ServerTimestamp var createdAt: Timestamp?
}
