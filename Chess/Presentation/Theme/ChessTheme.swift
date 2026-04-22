import UIKit

// MARK: - ChessMate design tokens (UIKit)

enum ChessTheme {

    // MARK: - Board
    enum Board {
        static let lightSquare      = UIColor(hex: "#EED7B5")
        static let darkSquare       = UIColor(hex: "#B08869")
        static let selectedOverlay  = UIColor(hex: "#FAC775").withAlphaComponent(0.50)
        static let lastMoveOverlay  = UIColor(hex: "#FAC775").withAlphaComponent(0.28)
        static let moveDotColor     = UIColor(white: 0.06, alpha: 0.22)
        static let captureRingColor = UIColor(white: 0.06, alpha: 0.20)
        static let checkOverlay     = UIColor(hex: "#D85A30").withAlphaComponent(0.70)
        static let coordinateLight  = UIColor(hex: "#B08869")
        static let coordinateDark   = UIColor(hex: "#EED7B5")
    }

    // MARK: - Colors (dark-first palette)
    enum Color {
        static let background    = UIColor(hex: "#0F0F10")
        static let surface       = UIColor(hex: "#1A1A1C")
        static let elevated      = UIColor(hex: "#242428")
        static let elevated2     = UIColor(hex: "#2E2E33")
        static let border        = UIColor.white.withAlphaComponent(0.08)
        static let borderStrong  = UIColor.white.withAlphaComponent(0.14)

        static let accent        = UIColor(hex: "#FAC775")
        static let accentDeep    = UIColor(hex: "#E8A94A")
        static let accentMuted   = UIColor(hex: "#FAC775").withAlphaComponent(0.18)

        static let primaryText   = UIColor(hex: "#F5F5F5")
        static let secondaryText = UIColor(hex: "#A0A0A5")
        static let tertiaryText  = UIColor(hex: "#6B6B70")

        static let success = UIColor(hex: "#1D9E75")
        static let danger  = UIColor(hex: "#D85A30")
        static let neutral = UIColor(hex: "#888780")
        static let info    = UIColor(hex: "#378ADD")

        // Backward-compat aliases
        static var card:    UIColor { elevated }
        static var divider: UIColor { border }
    }

    // MARK: - Clock
    enum Clock {
        static let activeBackground   = UIColor(hex: "#FAC775")
        static let inactiveBackground = UIColor(hex: "#1A1A1C")
        static let activeText         = UIColor(hex: "#0F0F10")
        static let inactiveText       = UIColor(hex: "#6B6B70")
        static let warningBackground  = UIColor(hex: "#D85A30")
        static let warningText        = UIColor.white
        static let warningThreshold   = 30
    }

    // MARK: - Font
    enum Font {
        static func display(size: CGFloat = 34) -> UIFont {
            .systemFont(ofSize: size, weight: .semibold)
        }
        static func title1(size: CGFloat = 22) -> UIFont {
            .systemFont(ofSize: size, weight: .semibold)
        }
        static func heading(size: CGFloat = 17) -> UIFont {
            .systemFont(ofSize: size, weight: .semibold)
        }
        static func body(size: CGFloat = 15) -> UIFont {
            .systemFont(ofSize: size, weight: .regular)
        }
        static func callout(size: CGFloat = 13) -> UIFont {
            .systemFont(ofSize: size, weight: .medium)
        }
        static func caption(size: CGFloat = 11) -> UIFont {
            .systemFont(ofSize: size, weight: .regular)
        }
        static func clock(size: CGFloat = 20) -> UIFont {
            .monospacedDigitSystemFont(ofSize: size, weight: .bold)
        }
        static func notation(size: CGFloat = 14) -> UIFont {
            .monospacedSystemFont(ofSize: size, weight: .medium)
        }
        static func moveNumber(size: CGFloat = 12) -> UIFont {
            .monospacedDigitSystemFont(ofSize: size, weight: .regular)
        }
        static func coordinate(size: CGFloat = 9) -> UIFont {
            .monospacedSystemFont(ofSize: size, weight: .semibold)
        }
        static func mono(size: CGFloat = 14) -> UIFont {
            .monospacedSystemFont(ofSize: size, weight: .medium)
        }
    }

    // MARK: - Spacing (4-based scale)
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs:  CGFloat = 8
        static let sm:  CGFloat = 12
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 20
        static let xl:  CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Radius
    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 20
        static let pill: CGFloat = 999
    }
}

// MARK: - UIColor hex init

extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat
        switch h.count {
        case 6:
            r = CGFloat((int >> 16) & 0xFF) / 255
            g = CGFloat((int >> 8)  & 0xFF) / 255
            b = CGFloat(int         & 0xFF) / 255
            a = 1
        case 8:
            r = CGFloat((int >> 16) & 0xFF) / 255
            g = CGFloat((int >> 8)  & 0xFF) / 255
            b = CGFloat(int         & 0xFF) / 255
            a = CGFloat((int >> 24) & 0xFF) / 255
        default: r = 0; g = 0; b = 0; a = 1
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
