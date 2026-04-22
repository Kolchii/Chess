import UIKit

enum ChessTheme {

    // MARK: - Board
    enum Board {
        static let lightSquare   = UIColor(red: 0.941, green: 0.851, blue: 0.710, alpha: 1)
        static let darkSquare    = UIColor(red: 0.710, green: 0.533, blue: 0.388, alpha: 1)
        static let selectedOverlay   = UIColor.systemYellow.withAlphaComponent(0.50)
        static let lastMoveOverlay   = UIColor.systemYellow.withAlphaComponent(0.28)
        static let moveDotColor      = UIColor(white: 0.08, alpha: 0.22)
        static let captureRingColor  = UIColor(white: 0.08, alpha: 0.20)
        static let checkOverlay      = UIColor(red: 0.90, green: 0.15, blue: 0.10, alpha: 0.72)
        static let coordinateLight   = UIColor(red: 0.710, green: 0.533, blue: 0.388, alpha: 1)
        static let coordinateDark    = UIColor(red: 0.941, green: 0.851, blue: 0.710, alpha: 1)
    }

    // MARK: - Colors
    enum Color {
        static let background    = UIColor(red: 0.118, green: 0.118, blue: 0.137, alpha: 1)
        static let surface       = UIColor(red: 0.169, green: 0.169, blue: 0.188, alpha: 1)
        static let card          = UIColor(red: 0.220, green: 0.220, blue: 0.243, alpha: 1)
        static let accent        = UIColor(red: 0.784, green: 0.631, blue: 0.353, alpha: 1)
        static let accentMuted   = UIColor(red: 0.784, green: 0.631, blue: 0.353, alpha: 0.25)
        static let primaryText   = UIColor.white
        static let secondaryText = UIColor(white: 0.55, alpha: 1)
        static let divider       = UIColor(white: 0.22, alpha: 1)
        static let danger        = UIColor(red: 0.929, green: 0.298, blue: 0.243, alpha: 1)
        static let success       = UIColor(red: 0.298, green: 0.800, blue: 0.447, alpha: 1)
    }

    // MARK: - Clock
    enum Clock {
        static let activeBackground  = UIColor(red: 0.784, green: 0.631, blue: 0.353, alpha: 1)
        static let inactiveBackground = UIColor(red: 0.169, green: 0.169, blue: 0.188, alpha: 1)
        static let activeText        = UIColor(red: 0.10, green: 0.08, blue: 0.05, alpha: 1)
        static let inactiveText      = UIColor(white: 0.42, alpha: 1)
        static let warningBackground = UIColor(red: 0.85, green: 0.20, blue: 0.15, alpha: 1)
        static let warningText       = UIColor.white
        static let warningThreshold  = 30
    }

    // MARK: - Font
    enum Font {
        static func clock(size: CGFloat = 20) -> UIFont {
            .monospacedDigitSystemFont(ofSize: size, weight: .bold)
        }
        static func notation(size: CGFloat = 14) -> UIFont {
            .monospacedSystemFont(ofSize: size, weight: .medium)
        }
        static func moveNumber(size: CGFloat = 12) -> UIFont {
            .monospacedDigitSystemFont(ofSize: size, weight: .regular)
        }
        static func heading(size: CGFloat = 17) -> UIFont {
            .systemFont(ofSize: size, weight: .semibold)
        }
        static func body(size: CGFloat = 15) -> UIFont {
            .systemFont(ofSize: size, weight: .regular)
        }
        static func coordinate(size: CGFloat = 10) -> UIFont {
            .monospacedSystemFont(ofSize: size, weight: .semibold)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
}
