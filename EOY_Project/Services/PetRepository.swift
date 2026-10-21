import FirebaseFirestore

struct PetRepository {
    private let db = Firestore.firestore()

    func fetchPet(uid: String) async throws -> Pet {
        try await db.collection("users").document(uid).collection("pet").document("current").getDocument(as: Pet.self)
    }

    func updatePet(uid: String, pet: Pet) async throws {
        let data = try Firestore.Encoder().encode(pet)
        try await db.collection("users").document(uid).collection("pet").document("current").setData(data, merge: true)
    }
}
