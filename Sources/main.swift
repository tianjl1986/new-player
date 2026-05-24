import SwiftUI

struct SkeuoPlayerApp: App {
    @StateObject private var musicPlayer = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioEQService = AudioEQService.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(musicPlayer)
                .environmentObject(libraryService)
                .environmentObject(localizationManager)
                .environmentObject(themeManager)
                .environmentObject(audioEQService)
                .preferredColorScheme(themeManager.isDark ? .dark : .light)
        }
    }
}

SkeuoPlayerApp.main()
