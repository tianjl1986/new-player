import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @Binding var showLyrics: Bool
    @State private var rotation: Double = 0
    
    private let baseSize: CGFloat = 400 // Increased size
    
    var body: some View {
        ZStack {
            // 1. Bottom Base (Image Asset)
            Image(theme.isDark ? "turntable_base_dark" : "turntable_base_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: baseSize, height: baseSize)
                .skeuoRaised(cornerRadius: 40) // Added skeuomorphic shadow to base
            
            // 1.5 Platter (Using PNG Assets)
            Image(theme.isDark ? "platter_dark" : "platter_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            
            // 2. Spinning Vinyl (Image Asset)
            ZStack {
                Image(theme.isDark ? "vinyl_record_dark" : "vinyl_record_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 280)
                
                // Album Art Center
                Group {
                    if let cover = player.currentAlbum?.coverImage {
                        ZStack {
                            Image(uiImage: cover)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 115, height: 115) // Increased by 20px
                                .clipShape(Circle())
                            
                            // 2.5 Center Spindle (Size reduced by half)
                            Image(theme.isDark ? "spindle_dark" : "spindle_light")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16) // 16x16
                        }
                    }
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 3. Tonearm Assembly
            TonearmView(isMoving: player.isPlaying)
                .offset(x: 110, y: -90) 
        }
        .onReceive(Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()) { _ in
            if player.isPlaying {
                rotation += 0.5
            }
        }
    }
}

struct TonearmView: View {
    var isMoving: Bool
    @ObservedObject var theme = ThemeManager.shared
    
    var body: some View {
        // The Tonearm is a single slice image
        Image(theme.isDark ? "tonearm_dark" : "tonearm_light")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 110, height: 290) 
            .rotationEffect(.degrees(isMoving ? 0 : -10), anchor: .top) // Playing: 0, Paused: -10
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isMoving)
    }
}
