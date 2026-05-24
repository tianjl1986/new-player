import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @State private var showPlayer = false
    
    var body: some View {
        if let track = player.currentTrack {
            Button(action: { showPlayer = true }) {
                HStack(spacing: 16) {
                    // Small Rotating Record
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 48, height: 48)
                            .skeuoRaised(cornerRadius: 24)
                        
                        if let cover = player.currentAlbum?.coverImage {
                            Image(uiImage: cover)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .rotationEffect(.degrees(player.isPlaying ? 360 : 0))
                                .animation(player.isPlaying ? .linear(duration: 10).repeatForever(autoreverses: false) : .default, value: player.isPlaying)
                        } else {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                .frame(width: 40, height: 40)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                            .lineLimit(1)
                        Text(track.artist)
                            .font(.system(size: 13))
                            .foregroundColor(DesignTokens.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { player.togglePlayPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(DesignTokens.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(DesignTokens.surfaceMain)
                                .skeuoRaised(cornerRadius: 22)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { player.skipNext() }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(DesignTokens.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(DesignTokens.surfaceMain)
                                .skeuoRaised(cornerRadius: 22)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(DesignTokens.surfaceMain)
                .skeuoSunken(cornerRadius: 16)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
