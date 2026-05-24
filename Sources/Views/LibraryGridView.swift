import SwiftUI

struct LibraryGridView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Standardized Header
            AppHeader(
                title: "COLLECTION".localized,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Page Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Library")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(DesignTokens.textPrimary)
                        
                        HStack(spacing: 6) {
                            Text("\(libraryService.albums.count) ALBUMS FOUND")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Album Grid
                    LazyVGrid(columns: columns, spacing: 32) {
                        ForEach(libraryService.albums) { album in
                            NavigationLink(destination: AlbumDetailView(album: album)) {
                                AlbumCard(album: album)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
                .padding(.top, 24)
            }
        }
        .background(DesignTokens.surfaceSecondary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
