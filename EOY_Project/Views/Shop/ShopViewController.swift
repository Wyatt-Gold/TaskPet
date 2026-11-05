//
//  ShopViewController.swift
//  EOY_Project
//
//  Created by Taylor Johnson on 10/20/26.
//

import UIKit
import FirebaseAuth

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

    private let petRepository = PetRepository()
    private var pet = Pet()

    var foodCount: Int { pet.foodCount }
    var waterCount: Int { pet.waterCount }
    var soapCount: Int { pet.soapCount }

    var points: Int { pet.points }

    override func viewDidLoad() {
        super.viewDidLoad()

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

        refreshLabels()
        Task { await loadPet() }
    }

    private func loadPet() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let fetched = try? await petRepository.fetchPet(uid: uid) else { return }
        pet = fetched
        refreshLabels()
    }

    private func refreshLabels() {
        pointsLabel.text = "\(points) points"
        foodOwnLabel.text = "Currently own: \(foodCount)"
        waterOwnLabel.text = "Currently own: \(waterCount)"
        soapOwnLabel.text = "Currently own: \(soapCount)"
    }

    private func persistPet() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let pet = self.pet
        Task { try? await petRepository.updatePet(uid: uid, pet: pet) }
    }
    
    @IBAction func foodBuyButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Buy Food?",
            message: "Spend 50 points to get one food portion?",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
            if (self.points >= 50) {
                self.pet.points -= 50
                self.pet.foodCount += 1
                self.refreshLabels()
                self.persistPet()
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
                self.pet.points -= 25
                self.pet.waterCount += 1
                self.refreshLabels()
                self.persistPet()
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
                self.pet.points -= 25
                self.pet.soapCount += 1
                self.refreshLabels()
                self.persistPet()
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
