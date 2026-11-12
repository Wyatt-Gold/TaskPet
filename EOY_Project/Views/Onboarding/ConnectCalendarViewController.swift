import UIKit
import EventKit
import FirebaseAuth

class ConnectCalendarViewController: UIViewController {
    private let userRepository = UserRepository()
    private let eventStore = EKEventStore()

    @IBAction func continueTapped(_ sender: UIButton) {
        Task {
            let granted = (try? await eventStore.requestFullAccessToEvents()) ?? false
            if let uid = Auth.auth().currentUser?.uid {
                var connections = (try? await userRepository.fetchProfile(uid: uid))?.connections ?? Connections()
                connections.calendarConnected = granted
                connections.calendarProvider = granted ? "apple" : nil
                try? await userRepository.updateConnections(uid: uid, connections: connections)
            }
            if granted {
                goToHome()
            } else {
                presentDeniedAlert()
            }
        }
    }

    private func presentDeniedAlert() {
        let alert = UIAlertController(
            title: "Calendar Access Denied",
            message: "You can turn this on anytime in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.goToHome()
        })
        present(alert, animated: true)
    }

    private func goToHome() {
        let next = storyboard!.instantiateViewController(withIdentifier: "Home")
        view.window?.rootViewController = next
    }
}
