import UIKit

class ConnectSchoolViewController: UIViewController {
    @IBAction func continueTapped(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "ConnectCalendar")
        next.modalPresentationStyle = .fullScreen
        present(next, animated: true)
    }
}
