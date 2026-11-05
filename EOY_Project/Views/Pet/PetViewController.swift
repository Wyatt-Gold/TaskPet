//
//  PetViewController.swift
//  EOY_Project
//
//  Created by Saraya Patel on 10/21/26.
//

import UIKit
import FirebaseAuth

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
    
    var happiness: Float = 0.80
    var energy: Float = 0.60
    var cleanliness: Float = 0.40

    private let petRepository = PetRepository()
    private let dailyStatsRepository = DailyStatsRepository()
    private var petName = "Biscuit"

    override func viewDidLoad() {
        super.viewDidLoad()
        petCardView.layer.cornerRadius = 18
        petCardView.layer.masksToBounds = true

        petImageView.layer.cornerRadius = 55
        petImageView.layer.masksToBounds = true

        walkButton.layer.cornerRadius = 14
        bathButton.layer.cornerRadius = 14

        applyStats()
        Task { await loadPet() }
    }

    private func loadPet() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let pet = try? await petRepository.fetchPet(uid: uid) else { return }
        petName = pet.name
        happiness = Float(pet.happiness) / 100
        energy = Float(pet.energy) / 100
        cleanliness = Float(pet.cleanliness) / 100
        petImageView.image = UIImage(systemName: pet.type == "cat" ? "cat.fill" : "dog.fill")
        applyStats()
    }

    private func applyStats() {
        petNameLabel.text = petName
        petStatusLabel.text = "Feeling Amazing"
        petDescriptionLabel.text = "\(petName) is thriving. Keep it up!"

        happinessProgressView.progress = happiness
        energyProgressView.progress = energy
        cleanlinessProgressView.progress = cleanliness

        happinessLabel.text = "\(Int(happiness * 100))%"
        energyLabel.text = "\(Int(energy * 100))%"
        cleanlinessLabel.text = "\(Int(cleanliness * 100))%"
    }

    @IBAction func walkButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Walk \(petName)?",
            message: "Take \(petName) for a walk to increase happiness! Step tracking will be available in a future update.",
            preferredStyle: .alert
        )

        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.markRingDone(walk: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }

    @IBAction func bathButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Give \(petName) a Bath?",
            message: "Keep \(petName) clean! Shake-to-bathe functionality will be available in a future update.",
            preferredStyle: .alert
        )

        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.markRingDone(care: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(yesAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }

    private func markRingDone(walk: Bool = false, care: Bool = false) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            var stats = (try? await dailyStatsRepository.fetchToday(uid: uid)) ?? DailyStats()
            if walk { stats.ringsClosed.walk = true }
            if care { stats.ringsClosed.care = true }
            try? await dailyStatsRepository.updateToday(uid: uid, stats: stats)
        }
    }
}
