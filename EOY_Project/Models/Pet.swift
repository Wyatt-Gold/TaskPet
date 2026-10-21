import FirebaseFirestore

struct Pet: Codable {
    @DocumentID var id: String?
    var type: String = "dog"
    var name: String = "Biscuit"
    var happiness: Int = 80
    var energy: Int = 60
    var cleanliness: Int = 40
    var points: Int = 0
    @ServerTimestamp var lastUpdated: Timestamp?
}
