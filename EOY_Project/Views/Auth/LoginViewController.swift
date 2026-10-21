import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let viewModel = AuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.style(input: emailField)
        Theme.style(input: passwordField)
        passwordField.isSecureTextEntry = true
        Theme.style(primaryButton: loginButton)
        errorLabel.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            self?.loginButton.isEnabled = !isLoading
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }
        viewModel.onError = { [weak self] message in
            self?.errorLabel.text = message
            self?.errorLabel.isHidden = false
        }
        viewModel.onSignInSuccess = { [weak self] in
            self?.goTo(identifier: "Home")
        }
        viewModel.onPasswordResetSent = { [weak self] in
            self?.showAlert(title: "Check your email", message: "A password reset link has been sent.")
        }
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        errorLabel.isHidden = true
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            errorLabel.text = "Enter your email and password."
            errorLabel.isHidden = false
            return
        }
        Task { await viewModel.signIn(email: email, password: password) }
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        let signUpVC = storyboard!.instantiateViewController(withIdentifier: "SignUp")
        signUpVC.modalPresentationStyle = .fullScreen
        present(signUpVC, animated: true)
    }

    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email address.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Email"; $0.keyboardType = .emailAddress }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
            Task { await self?.viewModel.sendPasswordReset(email: email) }
        })
        present(alert, animated: true)
    }

    private func goTo(identifier: String) {
        let next = storyboard!.instantiateViewController(withIdentifier: identifier)
        view.window?.rootViewController = next
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
