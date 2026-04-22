import SwiftUI

// MARK: - Color Tokens

extension Color {

    // Brand
    static let cmAmber      = Color(hex: "#FAC775")
    static let cmAmberDeep  = Color(hex: "#E8A94A")
    static let cmBoardLight = Color(hex: "#EED7B5")
    static let cmBoardDark  = Color(hex: "#B08869")

    // Semantic
    static let cmSuccess = Color(hex: "#1D9E75")
    static let cmDanger  = Color(hex: "#D85A30")
    static let cmNeutral = Color(hex: "#888780")
    static let cmInfo    = Color(hex: "#378ADD")

    // Dark surfaces
    static let cmDarkBase    = Color(hex: "#0F0F10")
    static let cmDarkSurface = Color(hex: "#1A1A1C")
    static let cmDarkElev    = Color(hex: "#242428")
    static let cmDarkElev2   = Color(hex: "#2E2E33")
    static let cmDarkT1      = Color(hex: "#F5F5F5")
    static let cmDarkT2      = Color(hex: "#A0A0A5")
    static let cmDarkT3      = Color(hex: "#6B6B70")

    // Light surfaces
    static let cmLightBase    = Color(hex: "#FAFAF7")
    static let cmLightSurface = Color.white
    static let cmLightElev    = Color(hex: "#F1EFE8")
    static let cmLightElev2   = Color(hex: "#E8E5DC")
    static let cmLightT1      = Color(hex: "#1A1A1C")
    static let cmLightT2      = Color(hex: "#5F5E5A")
    static let cmLightT3      = Color(hex: "#888780")

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a: UInt64, r: UInt64, g: UInt64, b: UInt64
        switch h.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Adaptive palette

struct CMPalette {
    let base:    Color
    let surface: Color
    let elev:    Color
    let elev2:   Color
    let border:  Color
    let t1:      Color
    let t2:      Color
    let t3:      Color

    static let dark = CMPalette(
        base:    .cmDarkBase,
        surface: .cmDarkSurface,
        elev:    .cmDarkElev,
        elev2:   .cmDarkElev2,
        border:  Color.white.opacity(0.08),
        t1:      .cmDarkT1,
        t2:      .cmDarkT2,
        t3:      .cmDarkT3
    )

    static let light = CMPalette(
        base:    .cmLightBase,
        surface: .cmLightSurface,
        elev:    .cmLightElev,
        elev2:   .cmLightElev2,
        border:  Color.black.opacity(0.08),
        t1:      .cmLightT1,
        t2:      .cmLightT2,
        t3:      .cmLightT3
    )
}

// MARK: - Environment key

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = CMPalette.dark
}

extension EnvironmentValues {
    var cmPalette: CMPalette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}
