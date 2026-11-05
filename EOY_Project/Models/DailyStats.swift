import FirebaseFirestore

struct DailyStats: Codable {
    @DocumentID var id: String? // "yyyy-MM-dd"
    var steps: Int = 0
    var stepGoal: Int = 8000
    var tasksCompleted: Int = 0
    var taskGoal: Int = 5
    var careDone: Bool = false
    var ringsClosed: Rings = Rings()
    var bonusPointsEarned: Int = 0

    struct Rings: Codable {
        var walk: Bool = false
        var tasks: Bool = false
        var care: Bool = false
    }
}
