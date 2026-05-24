import SwiftUI

struct HomeView: View {
    @ObservedObject private var player = MusicPlayer.shared
    @ObservedObject private var libraryService = MusicLibraryService.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Standardized Header for consistency with other views
            AppHeader(
                title: loc.t("LIBRARY"),
                leftItem: nil,
                rightItem: nil
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    
                    // Section: CLASSIFICATION
                    VStack(alignment: .leading, spacing: 16) {
                        Text(loc.t("CLASSIFICATION"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            NavigationLink(destination: LibraryShelfView()) {
                                SkeuoSettingsRow(title: loc.t("By Album"), value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.horizontal, 20)
                            
                            NavigationLink(destination: ArtistListView()) {
                                SkeuoSettingsRow(title: loc.t("By Artist"), value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Section: MEDIA LIBRARY (Quick Access)
                    VStack(alignment: .leading, spacing: 16) {
                        Text(loc.t("MEDIA LIBRARY"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            NavigationLink(destination: LibraryShelfView()) {
                                SkeuoSettingsRow(title: loc.t("Browse All Music"), value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.horizontal, 20)
                            
                            SkeuoSettingsRow(title: loc.t("Recently Added"), value: loc.t("12 New"), showBackground: false)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
