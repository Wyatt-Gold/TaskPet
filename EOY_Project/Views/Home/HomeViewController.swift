import UIKit
import FirebaseAuth
import FirebaseFirestore

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
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    private let petRepository = PetRepository()
    
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
            sortTasks()
            tableview.reloadData()
        }
    }
    
    private func sortTasks() {
        taskList.sort { first, second in
            if first.completed != second.completed {
                return !first.completed
            }
            guard let firstDate = first.dueDate?.dateValue() else { return false }
            guard let secondDate = second.dueDate?.dateValue() else { return true }
            return firstDate < secondDate
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let task = taskList[indexPath.row]
        cell.textLabel?.text = task.title

        var subtitleParts: [String] = []
        subtitleParts.append(task.priority.capitalized)

        if let dueDate = task.dueDate {
            let dateText = dateFormatter.string(from: dueDate.dateValue())
            subtitleParts.append(dateText)
        }

        subtitleParts.append("\(task.pointsAwarded) pts")
        cell.detailTextLabel?.text = subtitleParts.joined(separator: " • ")

        cell.accessoryType = task.completed ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let wasCompleted = taskList[indexPath.row].completed
        
        taskList[indexPath.row].completed.toggle()
        let task = taskList[indexPath.row]
        
        sortTasks()
        tableview.reloadData()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let completedCount = taskList.filter { $0.completed }.count
        let goal = taskGoal
        
        
        Task {
            do {
                        // Save the task
                        try await taskRepository.updateTask(uid: uid, task: task)

                        // Fetch the user's Pet
                        guard var pet = try? await petRepository.fetchPet(uid: uid) else {
                            return
                        }

                        // Award or remove points
                        if !wasCompleted && task.completed {
                            pet.points += task.pointsAwarded
                        } else if wasCompleted && !task.completed {
                            pet.points -= task.pointsAwarded
                        }

                        // Save the updated Pet
                        try await petRepository.updatePet(uid: uid, pet: pet)

                        // Update daily statistics
                        var stats = (try? await dailyStatsRepository.fetchToday(uid: uid)) ?? DailyStats()
                        stats.tasksCompleted = completedCount
                        stats.taskGoal = goal
                        stats.ringsClosed.tasks = completedCount >= goal

                        try await dailyStatsRepository.updateToday(uid: uid, stats: stats)

                    } catch {
                        print("Error updating task or pet: \(error)")
                    }
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
        taskList.append(newTask)
        sortTasks()
        tableview.reloadData()
        guard let uid = Auth.auth().currentUser?.uid else { return }
            Task {
                try? await taskRepository.addTask(uid: uid, task: newTask)
                await loadTasks()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTaskSegue" {
            if let destVC = segue.destination as? AddTaskViewController {
                destVC.delegate = self
            } else if let navVC = segue.destination as? UINavigationController,
                      let destVC = navVC.topViewController as? AddTaskViewController {
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
