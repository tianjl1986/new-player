import SwiftUI

@main
struct NewPlayerApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .preferredColorScheme(.dark) // 强制深色模式以配合拟物风格
        }
    }
}
