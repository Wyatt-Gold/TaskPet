//
//  FeedViewController.swift
//  EOY_Project
//
//  Created by taylor johnson on 11/10/26.
//

import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {
    
    @IBOutlet weak var foodCountLabel: UILabel!
    @IBOutlet weak var waterCountLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var waterImage: UIImageView!
    @IBOutlet weak var foodView: UIView!
    @IBOutlet weak var waterView: UIView!
    
    private let petRepository = PetRepository()
    private var pet = Pet()

    var foodCount: Int { pet.foodCount }
    var waterCount: Int { pet.waterCount }

    override func viewDidLoad() {
        super.viewDidLoad()

        foodView.layer.cornerRadius = 10
        foodView.layer.masksToBounds = true
        waterView.layer.cornerRadius = 10
        waterView.layer.masksToBounds = true
        
        foodImage.layer.cornerRadius = 15
        foodImage.layer.masksToBounds = true
        waterImage.layer.cornerRadius = 15
        waterImage.layer.masksToBounds = true
        
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
        foodCountLabel.text = "Currently own: \(foodCount)"
        waterCountLabel.text = "Currently own: \(waterCount)"
    }
    
    private func persistPet() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let pet = self.pet
        Task { try? await petRepository.updatePet(uid: uid, pet: pet) }
    }
    
    @IBAction func foodButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Feed your pet?",
            message: "This will increase your pets energy!",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
            if (self.foodCount > 0) {
                self.pet.foodCount -= 1
                self.refreshLabels()
                self.persistPet()
            } else {
                self.makePopup(popupTitle: "Not enough food!", popupMessage: "Visit the store to get more.")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    @IBAction func waterButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Give your pet water?",
            message: "This will increase your pets energy!",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
            if (self.waterCount > 0) {
                self.pet.waterCount -= 1
                self.refreshLabels()
                self.persistPet()
            } else {
                self.makePopup(popupTitle: "Not enough water!", popupMessage: "Visit the store to get more.")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    func makePopup(popupTitle:String, popupMessage:String) {
        let controller = UIAlertController(
            title: popupTitle,
            message: popupMessage,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        controller.addAction(okAction)
        
        present(controller, animated: true)
    }

}
