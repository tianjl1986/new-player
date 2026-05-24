import SwiftUI

struct QueueView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
                Spacer()
                Text(loc.t("QUEUE").uppercased())
                    .font(.system(size: 17, weight: .black))
                    .kerning(1.5)
                    .foregroundColor(DesignTokens.textPrimary)
                Spacer()
                Button(action: {
                    player.playlist = []
                }) {
                    Text(loc.t("Clear Queue"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(DesignTokens.textActive)
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 64)
            
            if player.playlist.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 48))
                        .foregroundColor(DesignTokens.textSecondary.opacity(0.2))
                    Text(loc.t("No tracks in queue"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.textSecondary)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Currently Playing
                        if let current = player.currentTrack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(loc.t("NOW PLAYING"))
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(DesignTokens.textSecondary)
                                    .padding(.horizontal, 24)
                                
                                queueTrackRow(current, isCurrent: true)
                            }
                            .padding(.top, 16)
                        }
                        
                        // Up Next
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.t("UP NEXT"))
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(DesignTokens.textSecondary)
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                            
                            ForEach(Array(upNextTracks.enumerated()), id: \.offset) { index, track in
                                queueTrackRow(track, isCurrent: false)
                                
                                if index < upNextTracks.count - 1 {
                                    Divider().padding(.horizontal, 40)
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
    
    private var upNextTracks: [Track] {
        guard let current = player.currentTrack,
              let idx = player.playlist.firstIndex(where: { $0.id == current.id }) else {
            return player.playlist
        }
        return Array(player.playlist.suffix(from: min(idx + 1, player.playlist.count)))
    }
    
    private func queueTrackRow(_ track: Track, isCurrent: Bool) -> some View {
        Button(action: {
            if !isCurrent {
                player.playTrack(track)
            }
        }) {
            HStack(spacing: 16) {
                // Playing indicator
                if isCurrent {
                    ZStack {
                        Circle()
                            .fill(DesignTokens.textActive.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: player.isPlaying ? "speaker.wave.2.fill" : "pause.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignTokens.textActive)
                    }
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 14))
                        .foregroundColor(DesignTokens.textSecondary.opacity(0.5))
                        .frame(width: 32, height: 32)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 15, weight: isCurrent ? .black : .bold))
                        .foregroundColor(isCurrent ? DesignTokens.textActive : DesignTokens.textPrimary)
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DesignTokens.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(track.duration)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(isCurrent ? DesignTokens.surfaceSecondary : Color.clear)
            .cornerRadius(isCurrent ? 12 : 0)
            .padding(.horizontal, isCurrent ? 16 : 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
