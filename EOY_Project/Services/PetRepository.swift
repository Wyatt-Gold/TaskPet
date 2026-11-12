import FirebaseFirestore

struct PetRepository {
    private let db = Firestore.firestore()

    func fetchPet(uid: String) async throws -> Pet {
        let ref = db.collection("users").document(uid).collection("pet").document("current")
        do {
            return try await ref.getDocument(as: Pet.self)
        } catch is DecodingError {
            // Tolerate pet docs saved before a field (e.g. foodCount) existed on the
            // model: strict Codable decoding throws keyNotFound on any missing key,
            // which was silently breaking every screen that reads the pet (points,
            // rings, walk/bath/feed). Fall back to a manual, default-filled parse.
            // Network/permission errors still propagate normally below.
            let snapshot = try await ref.getDocument()
            let data = snapshot.data() ?? [:]
            return Pet(
                id: snapshot.documentID,
                type: data["type"] as? String ?? "dog",
                name: data["name"] as? String ?? "Biscuit",
                happiness: data["happiness"] as? Int ?? 80,
                energy: data["energy"] as? Int ?? 60,
                cleanliness: data["cleanliness"] as? Int ?? 40,
                points: data["points"] as? Int ?? 0,
                foodCount: data["foodCount"] as? Int ?? 0,
                waterCount: data["waterCount"] as? Int ?? 0,
                soapCount: data["soapCount"] as? Int ?? 0
            )
        }
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
