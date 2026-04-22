import UIKit

extension UILabel {

    convenience init(text: String, font: UIFont = .boldSystemFont(ofSize: 22), color: UIColor = .label) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = color
    }
}
