import UIKit
import EventKit
import FirebaseAuth

class ConnectCalendarViewController: UIViewController {
    private let userRepository = UserRepository()
    private let eventStore = EKEventStore()

    @IBAction func continueTapped(_ sender: UIButton) {
        Task {
            let granted = (try? await eventStore.requestFullAccessToEvents()) ?? false
            if granted, let uid = Auth.auth().currentUser?.uid {
                var connections = (try? await userRepository.fetchProfile(uid: uid))?.connections ?? Connections()
                connections.calendarConnected = true
                connections.calendarProvider = "apple"
                try? await userRepository.updateConnections(uid: uid, connections: connections)
            }
            let next = storyboard!.instantiateViewController(withIdentifier: "Home")
            view.window?.rootViewController = next
        }
    }
}
