import FirebaseFirestore

struct UserRepository {
    private let db = Firestore.firestore()

    // Atomic: writes the user doc and the default pet doc together so sign-up
    // never leaves a half-created user if one write fails.
    func createUserWithPet(uid: String, displayName: String, email: String) async throws {
        let userRef = db.collection("users").document(uid)
        let petRef = userRef.collection("pet").document("current")

        let profile = UserProfile(
            displayName: displayName,
            email: email,
            settings: UserSettings(),
            connections: Connections()
        )

        let batch = db.batch()
        try batch.setData(from: profile, forDocument: userRef, merge: true)
        try batch.setData(from: Pet(), forDocument: petRef, merge: true)
        try await batch.commit()
    }

    func fetchProfile(uid: String) async throws -> UserProfile {
        try await db.collection("users").document(uid).getDocument(as: UserProfile.self)
    }

    func updateSettings(uid: String, settings: UserSettings) async throws {
        let data = try Firestore.Encoder().encode(settings)
        try await db.collection("users").document(uid).setData(["settings": data], merge: true)
    }

    func updateConnections(uid: String, connections: Connections) async throws {
        let data = try Firestore.Encoder().encode(connections)
        try await db.collection("users").document(uid).setData(["connections": data], merge: true)
    }
}
