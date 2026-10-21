//
//  PetViewController.swift
//  EOY_Project
//
//  Created by Saraya Patel on 10/21/26.
//

import UIKit

class PetViewController: UIViewController {

    @IBOutlet weak var petCardView: UIView!
    @IBOutlet weak var petImageView: UIImageView!
    
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petStatusLabel: UILabel!
    @IBOutlet weak var petDescriptionLabel: UILabel!
    
    @IBOutlet weak var happinessProgressView: UIProgressView!
    @IBOutlet weak var energyProgressView: UIProgressView!
    @IBOutlet weak var cleanlinessProgressView: UIProgressView!
    
    @IBOutlet weak var happinessLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var cleanlinessLabel: UILabel!
    
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var bathButton: UIButton!
    
    var happiness: Float = 0.96
    var energy: Float = 0.90
    var cleanliness: Float = 0.94
    
    override func viewDidLoad() {
        super.viewDidLoad()
        petCardView.layer.cornerRadius = 18
        petCardView.layer.masksToBounds = true

        petImageView.layer.cornerRadius = 55
        petImageView.layer.masksToBounds = true

        petNameLabel.text = "Biscuit"
        petStatusLabel.text = "Feeling Amazing"
        petDescriptionLabel.text = "Biscuit is thriving. Keep it up!"

        // Progress Bars
        happinessProgressView.progress = happiness
        energyProgressView.progress = energy
        cleanlinessProgressView.progress = cleanliness

        happinessLabel.text = "\(Int(happiness * 100))%"
        energyLabel.text = "\(Int(energy * 100))%"
        cleanlinessLabel.text = "\(Int(cleanliness * 100))%"

        walkButton.layer.cornerRadius = 14
        bathButton.layer.cornerRadius = 14
    }
    
    @IBAction func walkButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Walk Biscuit?",
            message: "Take Biscuit for a walk to increase happiness! Step tracking will be available in a future update.",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .default)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    @IBAction func bathButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Give Biscuit a Bath?",
            message: "Keep Biscuit clean! Shake-to-bathe functionality will be available in a future update.",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .default)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
}
