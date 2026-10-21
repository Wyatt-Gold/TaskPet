//
//  ShopViewController.swift
//  EOY_Project
//
//  Created by Taylor Johnson on 10/20/26.
//

import UIKit

class ShopViewController: UIViewController {

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var foodView: UIView!
    @IBOutlet weak var waterView: UIView!
    @IBOutlet weak var soapView: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var waterImage: UIImageView!
    @IBOutlet weak var soapImage: UIImageView!
    
    @IBOutlet weak var foodOwnLabel: UILabel!
    @IBOutlet weak var waterOwnLabel: UILabel!
    @IBOutlet weak var soapOwnLabel: UILabel!
    
    var foodCount: Int = 0
    var waterCount: Int = 0
    var soapCount: Int = 0
    
    var points: Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pointsLabel.text = "\(points) points"
        pointsLabel.layer.cornerRadius = 25
        pointsLabel.layer.masksToBounds = true
        
        foodView.layer.cornerRadius = 10
        foodView.layer.masksToBounds = true
        waterView.layer.cornerRadius = 10
        waterView.layer.masksToBounds = true
        soapView.layer.cornerRadius = 10
        soapView.layer.masksToBounds = true
        
        foodImage.layer.cornerRadius = 15
        foodImage.layer.masksToBounds = true
        waterImage.layer.cornerRadius = 15
        waterImage.layer.masksToBounds = true
        soapImage.layer.cornerRadius = 15
        soapImage.layer.masksToBounds = true
    }
    
    @IBAction func foodBuyButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Buy Food?",
            message: "Spend 50 points to get one food portion?",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
            if (self.points >= 50) {
                self.points -= 50
                self.foodCount += 1
                self.foodOwnLabel.text = "Currently own: \(self.foodCount)"
                self.pointsLabel.text = "\(self.points) points"
            } else {
                self.makePopup()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        
        
        
        present(controller, animated: true)
    }
    
    @IBAction func waterBuyButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Buy Water?",
            message: "Spend 25 points to get one water?",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
            if (self.points >= 25) {
                self.points -= 25
                self.waterCount += 1
                self.waterOwnLabel.text = "Currently own: \(self.waterCount)"
                self.pointsLabel.text = "\(self.points) points"
            } else {
                self.makePopup()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    @IBAction func soapBuyButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Buy Soap?",
            message: "Spend 25 points to get a soap bar?",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
            if (self.points >= 25) {
                self.points -= 25
                self.soapCount += 1
                self.soapOwnLabel.text = "Currently own: \(self.soapCount)"
                self.pointsLabel.text = "\(self.points) points"
            } else {
                self.makePopup()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    func makePopup() {
        let controller = UIAlertController(
            title: "Not enough points.",
            message: "Go do some tasks!",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        controller.addAction(okAction)
        
        present(controller, animated: true)
    }
    
}
