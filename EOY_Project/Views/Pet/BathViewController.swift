//
//  BathViewController.swift
//  EOY_Project
//
//  Created by Saraya Patel on 11/11/26.
//

import UIKit
import CoreMotion
import FirebaseAuth

class BathViewController: UIViewController {

    @IBOutlet weak var soapImageView: UIImageView!
    @IBOutlet weak var bathInstructionLabel: UILabel!
    @IBOutlet weak var cleanlinessProgressView: UIProgressView!
    @IBOutlet weak var cleanlinessPercentageLabel: UILabel!
    @IBOutlet weak var firstSoapView: UIButton!
    @IBOutlet weak var secondSoapView: UIButton!
    @IBOutlet weak var getSoapButton: UIButton!
    @IBOutlet weak var buyMoreButton: UIButton!
    
    private let petRepository = PetRepository()
    private let dailyStatsRepository = DailyStatsRepository()
    private var currentPet: Pet?
    
    private let motionManager = CMMotionManager()

    private let requiredShakingTime: TimeInterval = 10
    private var accumulatedShakingTime: TimeInterval = 0
    private var lastMotionTimestamp: TimeInterval?
    private var lastAccelerationMagnitude: Double?
    private var bathCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cleanlinessProgressView.progress = 0
        cleanlinessPercentageLabel.text = "--%"
        bathInstructionLabel.text = "Loading your pet..."

        Task {
            await loadPet()
            startDetectingShakes()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        motionManager.stopAccelerometerUpdates()
    }
    
    private func loadPet() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            bathInstructionLabel.text = "Please sign in to bathe your pet."
            return
        }

        do {
            let pet = try await petRepository.fetchPet(uid: uid)
            currentPet = pet

            cleanlinessProgressView.progress = Float(pet.cleanliness) / 100
            cleanlinessPercentageLabel.text = "\(pet.cleanliness)%"

            bathInstructionLabel.text = "Shake your phone to begin bath time"

            updateSoapInventory()
        } catch {
            bathInstructionLabel.text = "Unable to load your pet."
            print("Failed to load pet: \(error)")
        }
    }
    
    private func updateSoapInventory() {
        guard let pet = currentPet else {
            return
        }

        firstSoapView.backgroundColor = pet.soapCount >= 1
            ? UIColor.systemTeal.withAlphaComponent(0.15)
            : UIColor.white

        secondSoapView.backgroundColor = pet.soapCount >= 2
            ? UIColor.systemTeal.withAlphaComponent(0.15)
            : UIColor.white
    }
    
    private func startDetectingShakes() {
        guard let pet = currentPet else {
            return
        }

        guard pet.soapCount > 0 else {
            bathInstructionLabel.text = "You need soap to bathe your pet."
            return
        }

        guard motionManager.isAccelerometerAvailable else {
            bathInstructionLabel.text = "Motion tracking is unavailable."
            return
        }

        motionManager.accelerometerUpdateInterval = 0.1

        motionManager.startAccelerometerUpdates(
            to: OperationQueue.main
        ) { [weak self] data, error in
            guard let self = self, let data = data else {
                return
            }

            if self.bathCompleted {
                return
            }

            self.processMotion(data.acceleration, timestamp: data.timestamp)
        }
    }
    
    private func processMotion(
        _ acceleration: CMAcceleration,
        timestamp: TimeInterval
    ) {
        let magnitude = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )

        defer {
            lastAccelerationMagnitude = magnitude
            lastMotionTimestamp = timestamp
        }

        guard let previousMagnitude = lastAccelerationMagnitude,
              let previousTimestamp = lastMotionTimestamp else {
            return
        }

        let accelerationChange = abs(magnitude - previousMagnitude)
        let elapsed = timestamp - previousTimestamp

        guard elapsed > 0 && elapsed <= 0.25 else {
            return
        }

        if accelerationChange > 0.35 {
            accumulatedShakingTime += elapsed
        }

        let seconds = min(Int(accumulatedShakingTime), 10)

        bathInstructionLabel.text = "Bathing... \(seconds) / 10 seconds"

        if accumulatedShakingTime >= requiredShakingTime {
            completeBath()
        }
    }
    
    private func completeBath() {
        guard !bathCompleted else {
            return
        }

        bathCompleted = true
        motionManager.stopAccelerometerUpdates()

        bathInstructionLabel.text = "Finishing bath..."

        Task {
            guard let uid = Auth.auth().currentUser?.uid else {
                bathInstructionLabel.text = "Please sign in to save your bath."
                return
            }

            do {
                let updatedPet = try await petRepository.completeBath(uid: uid)

                currentPet?.soapCount = updatedPet.soapCount
                currentPet?.cleanliness = updatedPet.cleanliness

                cleanlinessProgressView.setProgress(
                    Float(updatedPet.cleanliness) / 100,
                    animated: true
                )

                cleanlinessPercentageLabel.text = "\(updatedPet.cleanliness)%"

                updateSoapInventory()

                bathInstructionLabel.text = "Bath complete! Your pet is clean!"

                await markCareRingClosed(uid: uid)

            } catch {
                bathInstructionLabel.text = "Unable to complete bath."
                showAlert(
                    title: "Bath Failed",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }

    private func markCareRingClosed(uid: String) async {
        var todayStats = (try? await dailyStatsRepository.fetchToday(uid: uid)) ?? DailyStats()
        guard !todayStats.ringsClosed.care else { return }
        todayStats.ringsClosed.care = true
        await dailyStatsRepository.closeRingsAndAwardBonus(uid: uid, stats: &todayStats)
    }
}
