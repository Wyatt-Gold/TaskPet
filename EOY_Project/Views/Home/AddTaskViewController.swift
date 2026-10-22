//
//  AddTaskViewController.swift
//  EOY_Project
//
//  Created by Nunna, Gayatri Sriv on 10/21/26.
//

import UIKit

class AddTaskViewController: UIViewController {
    @IBOutlet weak var titleField: UITextField!
    var delegate: AddTask?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonPress(_ sender: Any) {
        let titletxt = titleField.text ?? ""
        if titletxt.isEmpty{
            makePopup(popupTitle: "Missing Title", popupMessage:"Add Title to Task")
            return
        }
        let task = TaskItem(title: titletxt, priority:"")
        delegate?.addTask(newTask: task)
        dismiss(animated: true,completion: nil)
    }
    func makePopup(popupTitle:String,popupMessage:String){
        let controller = UIAlertController(title: popupTitle, message: popupMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        controller.addAction(okAction)
        present(controller,animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
