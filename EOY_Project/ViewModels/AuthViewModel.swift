import FirebaseAuth

final class AuthViewModel {
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSignInSuccess: (() -> Void)?
    var onSignUpSuccess: (() -> Void)?
    var onPasswordResetSent: (() -> Void)?

    private let userRepository = UserRepository()

    func checkAuthState() -> Bool {
        Auth.auth().currentUser != nil
    }

    func signIn(email: String, password: String) async {
        onLoadingChange?(true)
        defer { onLoadingChange?(false) }
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            onSignInSuccess?()
        } catch {
            onError?(friendlyMessage(for: error))
        }
    }

    func signUp(displayName: String, email: String, password: String) async {
        onLoadingChange?(true)
        defer { onLoadingChange?(false) }
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            try await userRepository.createUserWithPet(uid: result.user.uid, displayName: displayName, email: email)
            onSignUpSuccess?()
        } catch {
            onError?(friendlyMessage(for: error))
        }
    }

    func sendPasswordReset(email: String) async {
        onLoadingChange?(true)
        defer { onLoadingChange?(false) }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            onPasswordResetSent?()
        } catch {
            onError?(friendlyMessage(for: error))
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func friendlyMessage(for error: Error) -> String {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else {
            return "Something went wrong. Please try again."
        }
        switch code {
        case .wrongPassword, .invalidCredential:
            return "Incorrect password. Try again."
        case .userNotFound:
            return "No account found with that email."
        case .emailAlreadyInUse:
            return "That email is already registered."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .networkError:
            return "Network error. Check your connection and try again."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
