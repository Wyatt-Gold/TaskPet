import UIKit
import FirebaseAuth
protocol AddTask{
    func addTask(newTask: TaskItem)
}
class HomeViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,AddTask {

    //private let viewModel = AuthViewModel()
    @IBOutlet weak var tableview:UITableView!
    let textCellIdentifier = "TaskCell"
    var taskList: [TaskItem]=[]
    private let taskRepository = TaskRepository()
    private let dailyStatsRepository = DailyStatsRepository()
    private let userRepository = UserRepository()
    private var taskGoal = 5
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        Task {
            await loadTaskGoal()
            await loadTasks()
        }
    }

    private func loadTaskGoal() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let profile = try? await userRepository.fetchProfile(uid: uid) else { return }
        taskGoal = profile.settings.taskGoal
    }

    private func loadTasks() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let tasks = try? await taskRepository.fetchTasks(uid: uid) {
            taskList = tasks
            tableview.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let task = taskList[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = nil
        cell.accessoryType = task.completed ? .checkmark : .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        taskList[indexPath.row].completed.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let task = taskList[indexPath.row]
        let completedCount = taskList.filter { $0.completed }.count
        let goal = taskGoal
        Task {
            try? await taskRepository.updateTask(uid: uid, task: task)
            var stats = (try? await dailyStatsRepository.fetchToday(uid: uid)) ?? DailyStats()
            stats.tasksCompleted = completedCount
            stats.taskGoal = goal
            stats.ringsClosed.tasks = completedCount >= goal
            try? await dailyStatsRepository.updateToday(uid: uid, stats: stats)
        }
    }
    func tableView(_ tableView:UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let task = taskList[indexPath.row]
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let uid = Auth.auth().currentUser?.uid, let taskId = task.id {
                Task { try? await taskRepository.deleteTask(uid: uid, taskId: taskId) }
            }
        }
    }

    func addTask(newTask: TaskItem) {
        guard let uid = Auth.auth().currentUser?.uid else {
            taskList.append(newTask)
            tableview.reloadData()
            return
        }
        Task {
            try? await taskRepository.addTask(uid: uid, task: newTask)
            await loadTasks()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTaskSegue"{
            if let destVC = segue.destination as? AddTaskViewController{
                destVC.delegate = self
            }
        }
    }
    @IBAction func signOutTapped(_ sender: UIButton) {
        try? AuthViewModel().signOut()
        let login = storyboard!.instantiateViewController(withIdentifier: "Login")
        view.window?.rootViewController = login
    }
}
