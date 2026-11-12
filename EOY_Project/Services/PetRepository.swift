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
    
    func completeBath(uid: String) async throws -> Pet {
        var pet = try await fetchPet(uid: uid)

        guard pet.soapCount > 0 else {
            throw NSError(
                domain: "PetRepository",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "You don't have enough soap"
                ]
            )
        }

        pet.soapCount -= 1
        pet.cleanliness = min(pet.cleanliness + 25, 100)

        try await updatePet(uid: uid, pet: pet)

        return pet
    }
}
