import FirebaseFirestore

struct DailyStatsRepository {
    private let db = Firestore.firestore()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var todayKey: String { Self.dateFormatter.string(from: Date()) }

    func fetchToday(uid: String) async throws -> DailyStats {
        let doc = db.collection("users").document(uid).collection("dailyStats").document(todayKey)
        if let existing = try? await doc.getDocument(as: DailyStats.self) {
            return existing
        }
        return DailyStats()
    }

    func updateToday(uid: String, stats: DailyStats) async throws {
        let data = try Firestore.Encoder().encode(stats)
        try await db.collection("users").document(uid).collection("dailyStats").document(todayKey).setData(data, merge: true)
    }
}
