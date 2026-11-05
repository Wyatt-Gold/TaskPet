import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet weak var catButton: UIButton!
    @IBOutlet weak var darkModeSwitch: UISwitch!

    private let userRepository = UserRepository()
    private let petRepository = PetRepository()
    private var pet = Pet()
    private var settings = UserSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.style(input: usernameField)
        Theme.style(primaryButton: dogButton)
        Theme.style(primaryButton: catButton)
        Task { await loadData() }
    }

    private func loadData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let profile = try? await userRepository.fetchProfile(uid: uid) {
            usernameField.text = profile.displayName
            settings = profile.settings
            darkModeSwitch.isOn = settings.darkMode
        }
        if let fetched = try? await petRepository.fetchPet(uid: uid) {
            pet = fetched
            updateAvatar()
        }
    }

    private func updateAvatar() {
        let symbolName = pet.type == "cat" ? "cat.fill" : "dog.fill"
        avatarImageView.image = UIImage(systemName: symbolName)
        dogButton.isSelected = pet.type != "cat"
        catButton.isSelected = pet.type == "cat"
        dogButton.alpha = pet.type == "cat" ? 0.5 : 1.0
        catButton.alpha = pet.type == "cat" ? 1.0 : 0.5
    }

    @IBAction func saveUsernameTapped(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid,
              let name = usernameField.text, !name.isEmpty else { return }
        Task { try? await userRepository.updateProfile(uid: uid, displayName: name) }
    }

    @IBAction func dogTapped(_ sender: Any) {
        selectPetType("dog")
    }

    @IBAction func catTapped(_ sender: Any) {
        selectPetType("cat")
    }

    private func selectPetType(_ type: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        pet.type = type
        updateAvatar()
        let pet = self.pet
        Task { try? await petRepository.updatePet(uid: uid, pet: pet) }
    }

    @IBAction func darkModeToggled(_ sender: UISwitch) {
        view.window?.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
        guard let uid = Auth.auth().currentUser?.uid else { return }
        settings.darkMode = sender.isOn
        let settings = self.settings
        Task { try? await userRepository.updateSettings(uid: uid, settings: settings) }
    }
}
