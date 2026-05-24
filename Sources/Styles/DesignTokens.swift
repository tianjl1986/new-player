import SwiftUI

struct DesignTokens {
    // 1. Dynamic Backgrounds
    static var surfaceMain: Color {
        ThemeManager.shared.isDark ? Color(hexString: "#09090B") : Color(hexString: "#F0F0F0")
    }
    
    static var surfaceSecondary: Color {
        ThemeManager.shared.isDark ? Color(hexString: "#18181B") : Color(hexString: "#FFFFFF")
    }
    
    // 2. Text Colors
    static var textPrimary: Color {
        ThemeManager.shared.isDark ? .white : .black
    }
    
    static var textSecondary: Color {
        ThemeManager.shared.isDark ? Color(hexString: "#8E8E93") : Color(hexString: "#666666")
    }
    
    static let textActive = Color(hexString: "#3B82F6") // Accent blue
    
    // 3. Specialized Colors for Skeuomorphism
    static var skeuoShadowLight: Color {
        ThemeManager.shared.isDark ? Color(hexString: "#2C2C2C") : Color.white
    }
    
    static var skeuoShadowDark: Color {
        ThemeManager.shared.isDark ? Color.black : Color(hexString: "#B3B3B3")
    }
    
    static var surfaceFlat: Color {
        ThemeManager.shared.isDark ? Color(hexString: "#1C1C1E") : Color(hexString: "#F2F2F7")
    }
    
    // 4. Navigation Bar
    static var navBarBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(hexString: "#18181B"), Color(hexString: "#09090B")]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var navBarBorder: Color {
        Color(hexString: "#27272A")
    }
    
    // 5. Power Indicator Light
    static let indicatorActive = Color(hexString: "#3B82F6")
    static let indicatorInactive: Color = Color(hexString: "#71717A")
    
    // 6. EQ Colors
    static let eqSliderTrack = Color(hexString: "#27272A")
    static let eqSliderFill = Color(hexString: "#3B82F6")
    static let eqMasterFill = Color(hexString: "#DC2626")
    
    // 7. Backward Compatibility Aliases
    static var surfaceLight: Color { surfaceMain }
    static var background: Color { surfaceMain }
}

// Helper for Hex Colors
extension Color {
    init(hexString: String) {
        self.init(UIColor(hexString: hexString))
    }
}

// Helper for Hex Colors
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
