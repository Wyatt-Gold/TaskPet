import Foundation

// School/calendar connections only ever store a boolean + provider/domain here.
// Any future Canvas API token or password belongs in the Keychain, never Firestore.
struct Connections: Codable {
    var schoolConnected: Bool = false
    var schoolDomain: String?
    var calendarConnected: Bool = false
    var calendarProvider: String? // "apple" | "google" | "outlook"
}
