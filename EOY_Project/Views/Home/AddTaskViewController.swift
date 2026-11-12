//
//  AddTaskViewController.swift
//  EOY_Project
//
//  Created by Nunna, Gayatri Sriv on 10/21/26.
//

import UIKit
import FirebaseFirestore

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var notesField: UITextField!
    var delegate: AddTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dueDatePicker.minimumDate = Date()
    }
    
    @IBAction func saveButtonPress(_ sender: Any) {
        let titletxt = titleField.text ?? ""
        if titletxt.isEmpty{
            makePopup(popupTitle: "Missing Title", popupMessage:"Add Title to Task")
            return
        }
        let priorities = ["low","medium","high"]
        let selected = priorityControl.selectedSegmentIndex
        let priority = priorities[selected]
        let chosenDate = Timestamp(date:dueDatePicker.date)
        let notes = notesField.text
        let points : Int
        switch priority{
        case "high":
            points = 30
        case "medium":
            points = 20
        default:
            points = 10
        }
        let task = TaskItem(title: titletxt,notes:notes,dueDate: chosenDate,priority: priority,completed: false,completedAt: nil,pointsAwarded: points,source: "manual")
        delegate?.addTask(newTask: task)
        dismiss(animated: true,completion: nil)
    }
    
    func makePopup(popupTitle:String,popupMessage:String){
        let controller = UIAlertController(title: popupTitle, message: popupMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        controller.addAction(okAction)
        present(controller,animated: true)
    }

}
