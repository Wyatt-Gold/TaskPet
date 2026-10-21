import UIKit

class ConnectCalendarViewController: UIViewController {
    @IBAction func continueTapped(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "Home")
        view.window?.rootViewController = next
    }
}
