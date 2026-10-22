import UIKit
protocol AddTask{
    func addTask(newTask: TaskItem)
}
class HomeViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,AddTask {
    
    //private let viewModel = AuthViewModel()
    @IBOutlet weak var tableview:UITableView!
    let textCellIdentifier = "TaskCell"
    var taskList: [TaskItem]=[]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let task = taskList[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = nil
        return cell
    }
    func tableView(_ tableView:UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func addTask(newTask: TaskItem) {
        taskList.append(newTask)
        tableview.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTaskSegue"{
            if let destVC = segue.destination as? AddTaskViewController{
                destVC.delegate = self
            }
        }
    }
    //@IBAction func signOutTapped(_ sender: UIButton) {
        //try? viewModel.signOut()
        //let login = storyboard!.instantiateViewController(withIdentifier: "Login")
        //view.window?.rootViewController = login
    //}
}
