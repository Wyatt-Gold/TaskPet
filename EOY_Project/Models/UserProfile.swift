import FirebaseFirestore

struct UserProfile: Codable {
    @DocumentID var id: String?
    var displayName: String
    var email: String
    var photoURL: String?
    @ServerTimestamp var createdAt: Timestamp?
    var settings: UserSettings
    var connections: Connections
}
