import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var dogImageView: UIImageView!

    private let viewModel = AuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        dogImageView.layer.cornerRadius = dogImageView.bounds.width / 2
        dogImageView.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let identifier = viewModel.checkAuthState() ? "Home" : "Login"
        let next = storyboard!.instantiateViewController(withIdentifier: identifier)
        view.window?.rootViewController = next
    }
}
