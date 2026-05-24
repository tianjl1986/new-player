import SwiftUI

struct ArtistListView: View {
    @ObservedObject private var libraryService = MusicLibraryService.shared
    @ObservedObject private var metadata = MetadataService.shared
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var artists: [String] {
        Array(Set(libraryService.albums.map { $0.artist })).sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Standardized Header
            AppHeader(
                title: loc.t("ARTISTS"),
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(artists, id: \.self) { artist in
                        NavigationLink(destination: ArtistDetailView(artist: artist)) {
                            HStack {
                                ZStack {
                                    if let image = MetadataService.shared.artistImages[artist] {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 48, height: 48)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(DesignTokens.surfaceSecondary)
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(DesignTokens.textSecondary)
                                            )
                                            .onAppear {
                                                Task {
                                                    await MetadataService.shared.fetchArtistImage(name: artist)
                                                }
                                            }
                                    }
                                }
                                .skeuoSunken(cornerRadius: 24)
                                
                                Text(artist.uppercased())
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundColor(DesignTokens.textPrimary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(libraryService.albums.filter { $0.artist == artist }.count) ALBUMS")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(DesignTokens.textSecondary)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(DesignTokens.textSecondary)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 80)
                            .background(DesignTokens.surfaceMain)
                            .cornerRadius(16)
                            .skeuoRaised(cornerRadius: 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(24)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ArtistDetailView: View {
    let artist: String
    @ObservedObject private var libraryService = MusicLibraryService.shared
    @Environment(\.presentationMode) var presentationMode
    
    var albumsByArtist: [Album] {
        libraryService.albums.filter { $0.artist == artist }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Standardized Header
            AppHeader(
                title: artist.uppercased(),
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                    ForEach(albumsByArtist) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            AlbumCard(album: album)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(24)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
