import UIKit
import FirebaseAuth

class LoadingViewController: UIViewController {
    @IBOutlet weak var dogImageView: UIImageView!

    private let viewModel = AuthViewModel()
    private let userRepository = UserRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        dogImageView.layer.cornerRadius = dogImageView.bounds.width / 2
        dogImageView.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            let signedIn = viewModel.checkAuthState()
            if signedIn, let uid = Auth.auth().currentUser?.uid,
               let profile = try? await userRepository.fetchProfile(uid: uid) {
                view.window?.overrideUserInterfaceStyle = profile.settings.darkMode ? .dark : .light
            }
            let identifier = signedIn ? "Home" : "Login"
            let next = storyboard!.instantiateViewController(withIdentifier: identifier)
            view.window?.rootViewController = next
        }
    }
}
