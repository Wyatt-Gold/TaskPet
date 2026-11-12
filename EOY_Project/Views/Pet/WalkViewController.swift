//
//  WalkViewController.swift
//  EOY_Project
//
//  Created by Saraya Patel on 11/10/26.
//

import UIKit
import CoreMotion
import FirebaseAuth

class WalkViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepsCardView: UIView!
    @IBOutlet weak var circularProgressView: CircularProgressView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var remainingStepsLabel: UILabel!
    @IBOutlet weak var happinessCardView: UIView!
    @IBOutlet weak var activeTimeCardView: UIView!
    @IBOutlet weak var distanceCardView: UIView!
    @IBOutlet weak var happinessEarnedLabel: UILabel!
    @IBOutlet weak var happinessProgressView: UIProgressView!
    @IBOutlet weak var happinessDescriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var pedometerStatusLabel: UILabel!
    
    private let pedometer = CMPedometer()
    private let petRepository = PetRepository()
    private let dailyStatsRepository = DailyStatsRepository()
    private var isSaving = false
    private var pendingSteps: Int?
    private var activeSeconds: TimeInterval = 0
    private var previousStepCount: Int?
    private var previousStepTimestamp: Date?
    private var stepGoal = 8000
    private var petName = "Biscuit"
    private let maximumHappiness = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePedometerStatus(isAvailable: false)
        
        happinessCardView.layer.cornerRadius = 18
        happinessCardView.layer.masksToBounds = true

        distanceCardView.layer.cornerRadius = 16
        distanceCardView.layer.masksToBounds = true

        activeTimeCardView.layer.cornerRadius = 16
        activeTimeCardView.layer.masksToBounds = true
        
        displayWalkingData(steps: 0, distance: 0, activeTime: 0)
        
        happinessEarnedLabel.text = "+0"
        happinessDescriptionLabel.text = "0 of 25 possible from walking"
        happinessProgressView.progress = 0

        Task {
            await loadData()
            startTrackingSteps()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pedometer.stopUpdates()
        previousStepCount = nil
        previousStepTimestamp = nil
    }
    
    private func loadData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let pet = try await petRepository.fetchPet(uid: uid)
            petName = pet.name
            titleLabel.text = "Walk \(petName)"
        } catch {
            print("Failed to load pet: \(error)")
        }

        do {
            let stats = try await dailyStatsRepository.fetchToday(uid: uid)
            stepGoal = max(stats.stepGoal, 1)
            happinessEarnedLabel.text = "+\(stats.walkHappinessEarned)"

            happinessDescriptionLabel.text =
                "\(stats.walkHappinessEarned) of \(maximumHappiness) possible from walking"

            happinessProgressView.progress =
                Float(stats.walkHappinessEarned) / Float(maximumHappiness)
        } catch {
            print("Failed to load daily stats: \(error)")
        }

        goalLabel.text = "of \(stepGoal.formatted()) steps"
    }
    
    private func startTrackingSteps() {
        guard CMPedometer.isStepCountingAvailable() else {
            updatePedometerStatus(isAvailable: false)
            showAlert(
                title: "Pedometer Unavailable",
                message: "Step tracking is not supported on this device."
            )
            return
        }
        updatePedometerStatus(isAvailable: false)

        let startOfDay = Calendar.current.startOfDay(for: Date())

        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.updatePedometerStatus(isAvailable: false)

                    self.showAlert(
                        title: "Step Tracking Error",
                        message: error.localizedDescription
                    )
                }
                return
            }

            guard let data = data else { return }

            let steps = data.numberOfSteps.intValue
            let distance = data.distance?.doubleValue ?? 0
            let activeTime = 0

            DispatchQueue.main.async {
                self.updatePedometerStatus(isAvailable: true)
                self.displayWalkingData(
                    steps: steps,
                    distance: distance,
                    activeTime: activeTime
                )
                self.updateActiveTime(steps: steps)
                self.saveWalkingProgress(steps: steps)
            }
        }
    }
    
    private func displayWalkingData(steps: Int, distance: Double, activeTime: Int) {
        stepsLabel.text = steps.formatted()
        goalLabel.text = "of \(stepGoal.formatted()) steps"

        let remainingSteps = max(stepGoal - steps, 0)
        remainingStepsLabel.text = "\(remainingSteps.formatted()) steps to go"

        let progress = CGFloat(steps) / CGFloat(stepGoal)
        circularProgressView.progress = min(progress, 1)

        let miles = distance / 1609.344
        distanceLabel.text = String(format: "%.1f mi", miles)
        timeLabel.text = "\(activeTime) min"
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
    
    private func saveWalkingProgress(steps: Int) {
        pendingSteps = max(pendingSteps ?? 0, steps)

        guard !isSaving else {
            return
        }

        isSaving = true

        Task {
            while let stepsToSave = pendingSteps {
                pendingSteps = nil

                guard let uid = Auth.auth().currentUser?.uid else {
                    break
                }

                do {
                    let stats = try await dailyStatsRepository.saveWalkingProgress(
                        uid: uid,
                        steps: stepsToSave
                    )

                    happinessEarnedLabel.text = "+\(stats.walkHappinessEarned)"
                    happinessDescriptionLabel.text =
                        "\(stats.walkHappinessEarned) of \(maximumHappiness) possible from walking"

                    happinessProgressView.progress =
                        Float(stats.walkHappinessEarned) / Float(maximumHappiness)

                    if stats.steps >= stats.stepGoal {
                        await markWalkRingClosed(uid: uid)
                    }

                } catch {
                    print("Failed to save walking progress: \(error)")
                }
            }

            isSaving = false
        }
    }

    private func markWalkRingClosed(uid: String) async {
        var todayStats = (try? await dailyStatsRepository.fetchToday(uid: uid)) ?? DailyStats()
        guard !todayStats.ringsClosed.walk else { return }
        todayStats.ringsClosed.walk = true
        await dailyStatsRepository.closeRingsAndAwardBonus(uid: uid, stats: &todayStats)
    }
    
    private func updateActiveTime(steps: Int) {
        let now = Date()

        if let previousSteps = previousStepCount,
           let previousTimestamp = previousStepTimestamp {
            let elapsed = now.timeIntervalSince(previousTimestamp)
            if steps > previousSteps && elapsed > 0 && elapsed <= 60 {
                activeSeconds += elapsed
            }
        }

        previousStepCount = steps
        previousStepTimestamp = now

        let minutes = Int(activeSeconds / 60)
        timeLabel.text = "\(minutes) min"
    }
    
    private func updatePedometerStatus(isAvailable: Bool) {
        guard let statusLabel = pedometerStatusLabel else {
            print("ERROR: pedometerStatusLabel is nil")
            return
        }

        if isAvailable {
            statusLabel.text = "Pedometer on"
            statusLabel.textColor = UIColor.systemTeal
        } else {
            statusLabel.text = "Pedometer off"
            statusLabel.textColor = UIColor.systemRed
        }
    }
}
