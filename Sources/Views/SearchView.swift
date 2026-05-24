import SwiftUI

struct SearchView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var searchText = ""
    @State private var selectedFilter = 0
    private let filterOptions = ["ALL", "SONGS", "ALBUMS", "ARTISTS"]
    
    var filteredTracks: [Track] {
        guard !searchText.isEmpty else { return [] }
        let q = searchText.lowercased()
        return libraryService.playlist.filter { $0.title.lowercased().contains(q) || $0.artist.lowercased().contains(q) }
    }
    var filteredAlbums: [Album] {
        guard !searchText.isEmpty else { return [] }
        let q = searchText.lowercased()
        return libraryService.albums.filter { $0.title.lowercased().contains(q) || $0.artist.lowercased().contains(q) }
    }
    var filteredArtists: [String] {
        guard !searchText.isEmpty else { return [] }
        let q = searchText.lowercased()
        return Array(Set(libraryService.albums.map { $0.artist })).filter { $0.lowercased().contains(q) }.sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: loc.t("SEARCH"))
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    searchBar.padding(.top, 16)
                    filterPills
                    if searchText.isEmpty {
                        emptyState
                    } else if filteredTracks.isEmpty && filteredAlbums.isEmpty && filteredArtists.isEmpty {
                        noResults
                    } else {
                        resultsSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").font(.system(size: 16, weight: .bold)).foregroundColor(DesignTokens.textSecondary)
            TextField(loc.t("Search music..."), text: $searchText)
                .font(.system(size: 15, weight: .medium)).foregroundColor(DesignTokens.textPrimary)
                .autocapitalization(.none).disableAutocorrection(true)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 16)).foregroundColor(DesignTokens.textSecondary)
                }
            }
            Image(systemName: "mic.fill").font(.system(size: 16, weight: .bold)).foregroundColor(DesignTokens.textSecondary)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(DesignTokens.surfaceSecondary).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DesignTokens.textSecondary.opacity(0.2), lineWidth: 1))
        .skeuoSunken(cornerRadius: 12)
    }
    
    private var filterPills: some View {
        HStack(spacing: 8) {
            ForEach(Array(filterOptions.enumerated()), id: \.offset) { i, f in
                Button(action: { selectedFilter = i }) {
                    Text(loc.t(f)).font(.system(size: 11, weight: .black))
                        .foregroundColor(selectedFilter == i ? .white : DesignTokens.textSecondary)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(selectedFilter == i ? DesignTokens.textActive : DesignTokens.surfaceSecondary)
                        .cornerRadius(20)
                }
            }
            Spacer()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            Image(systemName: "magnifyingglass").font(.system(size: 48)).foregroundColor(DesignTokens.textSecondary.opacity(0.2))
            Text(loc.t("Type to search your library")).font(.system(size: 14, weight: .medium)).foregroundColor(DesignTokens.textSecondary)
        }
    }
    private var noResults: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)
            Image(systemName: "doc.text.magnifyingglass").font(.system(size: 48)).foregroundColor(DesignTokens.textSecondary.opacity(0.2))
            Text(loc.t("No results found")).font(.system(size: 14, weight: .medium)).foregroundColor(DesignTokens.textSecondary)
        }.frame(maxWidth: .infinity)
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if (selectedFilter == 0 || selectedFilter == 1) && !filteredTracks.isEmpty {
                trackResults
            }
            if (selectedFilter == 0 || selectedFilter == 2) && !filteredAlbums.isEmpty {
                albumResults
            }
            if (selectedFilter == 0 || selectedFilter == 3) && !filteredArtists.isEmpty {
                artistResults
            }
        }
    }
    
    private var trackResults: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.t("SONGS")).font(.system(size: 11, weight: .black)).foregroundColor(DesignTokens.textSecondary)
            SkeuoSettingsGroup {
                ForEach(Array(filteredTracks.prefix(10).enumerated()), id: \.offset) { i, track in
                    Button(action: {
                        if let alb = libraryService.albums.first(where: { $0.tracks.contains(where: { $0.id == track.id }) }) { player.currentAlbum = alb }
                        player.playTrack(track, in: filteredTracks); player.showNowPlaying = true
                    }) {
                        HStack(spacing: 12) {
                            trackThumb(track)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.title).font(.system(size: 14, weight: .bold))
                                    .foregroundColor(player.currentTrack?.id == track.id ? DesignTokens.textActive : DesignTokens.textPrimary).lineLimit(1)
                                Text(track.artist).font(.system(size: 12)).foregroundColor(DesignTokens.textSecondary).lineLimit(1)
                            }
                            Spacer()
                            Text(track.duration).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(DesignTokens.textSecondary)
                        }.padding(.horizontal, 16).padding(.vertical, 12)
                    }.buttonStyle(PlainButtonStyle())
                    if i < min(filteredTracks.count, 10) - 1 { Divider().padding(.horizontal, 16) }
                }
            }
        }
    }
    
    private func trackThumb(_ track: Track) -> some View {
        Group {
            if let alb = libraryService.albums.first(where: { $0.tracks.contains(where: { $0.id == track.id }) }), let cover = alb.coverImage {
                Image(uiImage: cover).resizable().aspectRatio(contentMode: .fill).frame(width: 40, height: 40).cornerRadius(6)
            } else {
                RoundedRectangle(cornerRadius: 6).fill(DesignTokens.surfaceFlat).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "music.note").font(.system(size: 16)).foregroundColor(DesignTokens.textSecondary.opacity(0.3)))
            }
        }
    }
    
    private var albumResults: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.t("ALBUMS")).font(.system(size: 11, weight: .black)).foregroundColor(DesignTokens.textSecondary)
            SkeuoSettingsGroup {
                ForEach(Array(filteredAlbums.prefix(5).enumerated()), id: \.offset) { i, album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        HStack(spacing: 12) {
                            if let c = album.coverImage { Image(uiImage: c).resizable().aspectRatio(contentMode: .fill).frame(width: 48, height: 48).cornerRadius(8) }
                            else { RoundedRectangle(cornerRadius: 8).fill(DesignTokens.surfaceFlat).frame(width: 48, height: 48) }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(album.title).font(.system(size: 14, weight: .bold)).foregroundColor(DesignTokens.textPrimary).lineLimit(1)
                                Text("\(album.artist) • \(album.tracks.count) tracks").font(.system(size: 12)).foregroundColor(DesignTokens.textSecondary).lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(DesignTokens.textSecondary)
                        }.padding(.horizontal, 16).padding(.vertical, 12)
                    }.buttonStyle(PlainButtonStyle())
                    if i < min(filteredAlbums.count, 5) - 1 { Divider().padding(.horizontal, 16) }
                }
            }
        }
    }
    
    private var artistResults: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.t("ARTISTS")).font(.system(size: 11, weight: .black)).foregroundColor(DesignTokens.textSecondary)
            SkeuoSettingsGroup {
                ForEach(Array(filteredArtists.prefix(5).enumerated()), id: \.offset) { i, artist in
                    NavigationLink(destination: ArtistDetailView(artist: artist)) {
                        HStack(spacing: 12) {
                            Circle().fill(DesignTokens.surfaceFlat).frame(width: 40, height: 40)
                                .overlay(Image(systemName: "person.fill").foregroundColor(DesignTokens.textSecondary.opacity(0.3)))
                            Text(artist).font(.system(size: 14, weight: .bold)).foregroundColor(DesignTokens.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(DesignTokens.textSecondary)
                        }.padding(.horizontal, 16).padding(.vertical, 12)
                    }.buttonStyle(PlainButtonStyle())
                    if i < min(filteredArtists.count, 5) - 1 { Divider().padding(.horizontal, 16) }
                }
            }
        }
    }
}
