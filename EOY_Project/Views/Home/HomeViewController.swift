import UIKit

class HomeViewController: UIViewController {
    private let viewModel = AuthViewModel()

    @IBAction func signOutTapped(_ sender: UIButton) {
        try? viewModel.signOut()
        let login = storyboard!.instantiateViewController(withIdentifier: "Login")
        view.window?.rootViewController = login
    }
}
