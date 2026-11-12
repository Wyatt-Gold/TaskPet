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
    
    func saveWalkingProgress(uid: String, steps: Int) async throws -> DailyStats {
        let today = todayKey

        let statsRef = db.collection("users")
            .document(uid)
            .collection("dailyStats")
            .document(today)

        let petRef = db.collection("users")
            .document(uid)
            .collection("pet")
            .document("current")

        return try await withCheckedThrowingContinuation { continuation in
            db.runTransaction({ transaction, errorPointer -> Any? in
                let statsSnapshot: DocumentSnapshot
                let petSnapshot: DocumentSnapshot

                do {
                    statsSnapshot = try transaction.getDocument(statsRef)
                    petSnapshot = try transaction.getDocument(petRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }

                guard petSnapshot.exists else {
                    errorPointer?.pointee = NSError(
                        domain: "TaskPet",
                        code: 404,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Pet not found."
                        ]
                    )
                    return nil
                }

                let statsData = statsSnapshot.data() ?? [:]
                let petData = petSnapshot.data() ?? [:]

                let previousSteps = statsData["steps"] as? Int ?? 0
                let previouslyRewarded = statsData["rewardedWalkSteps"] as? Int ?? 0
                let previousHappinessEarned =
                    statsData["walkHappinessEarned"] as? Int ?? 0

                let currentSteps = max(steps, previousSteps)
                let totalEarned = min(currentSteps / 320, 25)

                let newHappiness = max(
                    totalEarned - previousHappinessEarned,
                    0
                )

                let currentPetHappiness =
                    petData["happiness"] as? Int ?? 0

                let updatedPetHappiness = min(
                    currentPetHappiness + newHappiness,
                    100
                )

                transaction.setData([
                    "steps": currentSteps,
                    "rewardedWalkSteps": max(
                        previouslyRewarded,
                        currentSteps
                    ),
                    "walkHappinessEarned": max(
                        previousHappinessEarned,
                        totalEarned
                    )
                ], forDocument: statsRef, merge: true)

                if newHappiness > 0 {
                    transaction.updateData([
                        "happiness": updatedPetHappiness
                    ], forDocument: petRef)
                }

                return [
                    "steps": currentSteps,
                    "stepGoal": statsData["stepGoal"] as? Int ?? 8000,
                    "walkHappinessEarned": max(
                        previousHappinessEarned,
                        totalEarned
                    )
                ]
            }, completion: { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result = result as? [String: Int] else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "TaskPet",
                            code: 500,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    "Invalid walking progress result."
                            ]
                        )
                    )
                    return
                }

                var stats = DailyStats()
                stats.steps = result["steps"] ?? 0
                stats.stepGoal = result["stepGoal"] ?? 8000
                stats.walkHappinessEarned =
                    result["walkHappinessEarned"] ?? 0

                continuation.resume(returning: stats)
            })
        }
    }
}
