import UIKit
import FirebaseAuth

class RingsViewController: UIViewController {
    @IBOutlet weak var walkStatusImageView: UIImageView!
    @IBOutlet weak var tasksStatusImageView: UIImageView!
    @IBOutlet weak var careStatusImageView: UIImageView!

    private let dailyStatsRepository = DailyStatsRepository()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await loadRings() }
    }

    private func loadRings() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let stats = try? await dailyStatsRepository.fetchToday(uid: uid) else { return }
        walkStatusImageView.image = icon(for: stats.ringsClosed.walk)
        tasksStatusImageView.image = icon(for: stats.ringsClosed.tasks)
        careStatusImageView.image = icon(for: stats.ringsClosed.care)
    }

    private func icon(for done: Bool) -> UIImage? {
        UIImage(systemName: done ? "checkmark.circle.fill" : "circle")
    }
}
