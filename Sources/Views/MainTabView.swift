import SwiftUI

struct MainTabView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Page Content
            Group {
                switch selectedTab {
                case 0: NavigationView { HomeView() }.navigationViewStyle(StackNavigationViewStyle())
                case 1: NavigationView { SearchView() }.navigationViewStyle(StackNavigationViewStyle())
                case 2: NavigationView { NowPlayingHostView() }.navigationViewStyle(StackNavigationViewStyle())
                case 3: NavigationView { SettingsView() }.navigationViewStyle(StackNavigationViewStyle())
                default: EmptyView()
                }
            }
            .padding(.bottom, 80) // Space for nav bar
            
            // Bottom Navigation Bar
            bottomNavBar
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $player.showNowPlaying) {
            NowPlayingView()
                .environmentObject(player)
                .environmentObject(libraryService)
                .environmentObject(loc)
        }
    }
    
    private var bottomNavBar: some View {
        HStack(spacing: 0) {
            TabButton(
                icon: "square.stack.fill",
                label: loc.t("LIBRARY"),
                isActive: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            TabButton(
                icon: "magnifyingglass",
                label: loc.t("SEARCH"),
                isActive: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            TabButton(
                icon: "play.circle.fill",
                label: loc.t("PLAYER"),
                isActive: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            TabButton(
                icon: "gearshape.fill",
                label: loc.t("SETTINGS"),
                isActive: selectedTab == 3,
                action: { selectedTab = 3 }
            )
        }
        .padding(.horizontal, 19)
        .padding(.bottom, 16)
        .padding(.top, 12)
        .background(
            ZStack {
                // Gradient background
                RoundedCorner(radius: 32, corners: [.topLeft, .topRight])
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hexString: "#18181B"), Color(hexString: "#09090B")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                // Top border
                RoundedCorner(radius: 32, corners: [.topLeft, .topRight])
                    .stroke(Color(hexString: "#27272A"), lineWidth: 1)
            }
        )
        .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: -8)
    }
}

// MARK: - Tab Button with Power Indicator Light
struct TabButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon with glow effect when active
                ZStack {
                    if isActive {
                        // Glow overlay
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(DesignTokens.indicatorActive)
                            .shadow(color: DesignTokens.indicatorActive.opacity(0.8), radius: 8, x: 0, y: 0)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(DesignTokens.indicatorInactive)
                    }
                }
                
                // Label
                Text(label)
                    .font(.system(size: 10, weight: isActive ? .bold : .regular))
                    .foregroundColor(isActive ? DesignTokens.indicatorActive : DesignTokens.indicatorInactive)
                
                // ⚡ Power Indicator Light
                Circle()
                    .fill(isActive ? DesignTokens.indicatorActive : Color.clear)
                    .frame(width: 4, height: 4)
                    .shadow(color: isActive ? DesignTokens.indicatorActive : .clear, radius: 8, x: 0, y: 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isActive ?
                    DesignTokens.indicatorActive.opacity(0.1)
                        .blur(radius: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 9999))
                    : nil
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Now Playing Host (for Tab navigation — shows turntable + controls inline)
struct NowPlayingHostView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showLyrics = false
    @State private var showQueue = false
    @State private var showEqualizer = false
    
    var body: some View {
        ZStack {
            DesignTokens.surfaceMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                AppHeader(
                    title: loc.t("NOW PLAYING"),
                    leftItem: AnyView(
                        Button(action: { showEqualizer = true }) {
                            Image(systemName: "slider.vertical.3")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DesignTokens.textPrimary)
                        }
                    ),
                    rightItem: AnyView(
                        Button(action: { showQueue = true }) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DesignTokens.textPrimary)
                        }
                    )
                )
                
                if player.currentTrack != nil {
                    // Turntable
                    ZStack {
                        VinylTurntableView(showLyrics: $showLyrics)
                    }
                    .frame(height: 320)
                    .padding(.top, 10)
                    
                    // Track Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(player.currentTrack?.title ?? "Unknown Title")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                            .lineLimit(1)
                        
                        Text(player.currentTrack?.artist ?? "Unknown Artist")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
                    
                    Spacer(minLength: 10)
                    
                    // Progress Bar
                    progressSection
                    
                    Spacer(minLength: 20)
                    
                    // Controls
                    BottomControlsView(showLyrics: $showLyrics)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                } else {
                    // Empty state
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "music.note")
                            .font(.system(size: 60))
                            .foregroundColor(DesignTokens.textSecondary.opacity(0.3))
                        Text("Select a track to play")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.textSecondary)
                    }
                    Spacer()
                }
            }
            .blur(radius: showLyrics ? 20 : 0)
            .animation(.easeInOut, value: showLyrics)
            
            // Lyrics Overlay
            if showLyrics {
                LyricsView(showLyrics: $showLyrics)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showQueue) {
            QueueView()
        }
        .sheet(isPresented: $showEqualizer) {
            EqualizerView()
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text(formatDuration(player.currentTime))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
                    .frame(width: 50, alignment: .leading)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 8)
                            .skeuoSunken(cornerRadius: 6)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2))
                            .frame(width: geo.size.width * CGFloat(player.currentTime / max(player.duration, 1)), height: 8)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let pct = min(max(0, value.location.x / geo.size.width), 1)
                                player.seek(to: player.duration * Double(pct))
                            }
                    )
                }
                .frame(height: 8)
                
                Text(formatDuration(player.duration))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .padding(.horizontal, 32)
    }
}
