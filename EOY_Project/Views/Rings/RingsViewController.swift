import UIKit
import FirebaseAuth

class RingsViewController: UIViewController {
    @IBOutlet weak var walkRingView: CircularProgressView!
    @IBOutlet weak var tasksRingView: CircularProgressView!
    @IBOutlet weak var careRingView: CircularProgressView!

    @IBOutlet weak var walkPercentLabel: UILabel!
    @IBOutlet weak var tasksPercentLabel: UILabel!
    @IBOutlet weak var carePercentLabel: UILabel!

    @IBOutlet weak var walkDotView: UIView!
    @IBOutlet weak var tasksDotView: UIView!
    @IBOutlet weak var careDotView: UIView!

    private let dailyStatsRepository = DailyStatsRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        walkRingView.ringColor = Theme.Colors.primaryTeal
        tasksRingView.ringColor = .systemOrange
        careRingView.ringColor = .systemBlue
        [walkDotView, tasksDotView, careDotView].forEach { $0?.layer.cornerRadius = 7 }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await loadRings() }
    }

    private func loadRings() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let stats = try? await dailyStatsRepository.fetchToday(uid: uid) else { return }

        let walkProgress: Float = stats.stepGoal > 0 ? min(Float(stats.steps) / Float(stats.stepGoal), 1) : 0
        let tasksProgress: Float = stats.taskGoal > 0 ? min(Float(stats.tasksCompleted) / Float(stats.taskGoal), 1) : 0
        let careProgress: Float = stats.ringsClosed.care ? 1 : 0

        walkRingView.progress = CGFloat(walkProgress)
        tasksRingView.progress = CGFloat(tasksProgress)
        careRingView.progress = CGFloat(careProgress)

        walkPercentLabel.text = "\(Int(walkProgress * 100))%"
        tasksPercentLabel.text = "\(Int(tasksProgress * 100))%"
        carePercentLabel.text = "\(Int(careProgress * 100))%"
    }
}
