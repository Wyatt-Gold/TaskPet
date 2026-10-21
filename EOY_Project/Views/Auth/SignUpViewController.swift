import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let viewModel = AuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        [displayNameField, emailField, passwordField, confirmPasswordField].forEach { Theme.style(input: $0) }
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        Theme.style(primaryButton: signUpButton)
        errorLabel.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            self?.signUpButton.isEnabled = !isLoading
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }
        viewModel.onError = { [weak self] message in
            self?.errorLabel.text = message
            self?.errorLabel.isHidden = false
        }
        viewModel.onSignUpSuccess = { [weak self] in
            let next = self?.storyboard?.instantiateViewController(withIdentifier: "ConnectSchool")
            next?.modalPresentationStyle = .fullScreen
            self?.present(next!, animated: true)
        }
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
        errorLabel.isHidden = true
        guard let name = displayNameField.text, !name.isEmpty else {
            return showError("Enter your name.")
        }
        guard let email = emailField.text, email.contains("@"), email.contains(".") else {
            return showError("Enter a valid email address.")
        }
        guard let password = passwordField.text, password.count >= 6 else {
            return showError("Password must be at least 6 characters.")
        }
        guard password == confirmPasswordField.text else {
            return showError("Passwords don't match.")
        }
        Task { await viewModel.signUp(displayName: name, email: email, password: password) }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
