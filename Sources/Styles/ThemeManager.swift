import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("app_theme") var currentTheme: String = "Light" {
        didSet {
            objectWillChange.send()
        }
    }
    
    var isDark: Bool {
        currentTheme == "Dark"
    }
    
    func toggleTheme() {
        currentTheme = (currentTheme == "Dark" ? "Light" : "Dark")
    }
}
