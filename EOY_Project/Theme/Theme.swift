import UIKit

enum Theme {
    enum Colors {
        static let background = UIColor(named: "AppBackground")!
        static let primaryTeal = UIColor(named: "PrimaryTeal")!
        static let text = UIColor(named: "PrimaryText")!
        static let secondaryText = UIColor(named: "SecondaryText")!
    }

    enum Fonts {
        static func body(size: CGFloat) -> UIFont {
            UIFont(name: "Nunito-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular).rounded
        }

        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "Nunito-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold).rounded
        }
    }

    enum Metrics {
        static let inputHeight: CGFloat = 52
        static let inputCornerRadius: CGFloat = 14
        static let buttonHeight: CGFloat = 56
        static let buttonCornerRadius: CGFloat = 18
        static let minTouchTarget: CGFloat = 44
    }

    static func style(input field: UITextField) {
        field.font = Fonts.body(size: 16)
        field.layer.cornerRadius = Metrics.inputCornerRadius
        field.layer.masksToBounds = true
    }

    static func style(primaryButton button: UIButton) {
        button.titleLabel?.font = Fonts.bold(size: 17)
        button.layer.cornerRadius = Metrics.buttonCornerRadius
        button.layer.masksToBounds = true
    }

    static func style(linkButton button: UIButton) {
        button.titleLabel?.font = Fonts.body(size: 15)
    }
}

private extension UIFont {
    var rounded: UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
