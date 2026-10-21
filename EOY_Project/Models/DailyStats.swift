import FirebaseFirestore

struct DailyStats: Codable {
    @DocumentID var id: String? // "yyyy-MM-dd"
    var steps: Int = 0
    var stepGoal: Int
    var tasksCompleted: Int = 0
    var taskGoal: Int
    var careDone: Bool = false
    var ringsClosed: Rings = Rings()
    var bonusPointsEarned: Int = 0

    struct Rings: Codable {
        var walk: Bool = false
        var tasks: Bool = false
        var care: Bool = false
    }
}
