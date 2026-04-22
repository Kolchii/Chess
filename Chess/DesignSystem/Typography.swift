import SwiftUI

// MARK: - Type scale matching the design tokens

extension Font {

    /// 34pt / semibold — hero titles
    static var cmDisplay: Font {
        .system(size: 34, weight: .semibold, design: .default)
    }

    /// 22pt / semibold — screen titles
    static var cmTitle1: Font {
        .system(size: 22, weight: .semibold, design: .default)
    }

    /// 17pt / semibold — section headers
    static var cmTitle2: Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// 15pt / regular — body text
    static var cmBody: Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    /// 13pt / medium — labels, buttons
    static var cmCallout: Font {
        .system(size: 13, weight: .medium, design: .default)
    }

    /// 11pt / regular — timestamps, meta
    static var cmCaption: Font {
        .system(size: 11, weight: .regular, design: .default)
    }

    /// Monospaced digits — ratings, timers, notation
    static var cmMono: Font {
        .system(size: 15, weight: .medium, design: .monospaced)
    }

    static func cmMonoSize(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - ViewModifier helpers

struct CMTextStyle: ViewModifier {
    let font: Font
    let color: Color
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
            .tracking(tracking)
    }
}

extension View {
    func cmText(_ font: Font, color: Color, tracking: CGFloat = 0) -> some View {
        modifier(CMTextStyle(font: font, color: color, tracking: tracking))
    }
}
