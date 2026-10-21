import Foundation

struct UserSettings: Codable {
    var darkMode: Bool = false
    var notificationsEnabled: Bool = true
    var stepGoal: Int = 8000
    var taskGoal: Int = 5
}
