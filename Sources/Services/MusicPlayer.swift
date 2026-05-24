import Foundation
import AVFoundation
import MediaPlayer

enum PlaybackMode {
    case list, loopOne, shuffle
    var iconName: String {
        switch self {
        case .list: return "repeat"
        case .loopOne: return "repeat.1"
        case .shuffle: return "shuffle"
        }
    }
}

@MainActor
class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()
    
    var player: AVPlayer?
    private var playerObserver: Any?
    private var timeObserver: Any?
    
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackMode: PlaybackMode = .list
    @Published var playlist: [Track] = []
    @Published var currentTrackLyrics: [LyricLine] = []
    @Published var currentLyricIndex: Int = 0
    @Published var isSearchingLyrics: Bool = false
    @Published var showNowPlaying: Bool = false
    @Published var currentAlbum: Album? = nil
    
    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.resume() }
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.skipNext() }
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.skipPrevious() }
            return .success
        }
    }
    
    func updateNowPlaying() {
        guard let track = currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Try to load artwork from album or track metadata
        if let album = currentAlbum, let image = album.coverImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 600, height: 600)) { _ in image }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func playTrack(_ track: Track, in list: [Track] = []) {
        if !list.isEmpty {
            self.playlist = list
        } else if self.playlist.isEmpty {
            self.playlist = [track]
        }
        
        self.currentTrack = track
        self.currentTrackLyrics = []
        
        Task {
            isSearchingLyrics = true
            // 🚀 注入时长校验，防止误匹配
            let trackDuration = parseDuration(track.duration)
            let lyrics = await LyricsService.shared.searchLyrics(for: track.title, artist: track.artist, duration: trackDuration)
            
            await MainActor.run {
                if self.currentTrack?.id == track.id {
                    self.currentTrackLyrics = lyrics
                    self.isSearchingLyrics = false
                }
            }
        }
        
        let url: URL?
        if track.fileName.hasPrefix("ipod-library://") {
            url = URL(string: track.fileName)
        } else if track.fileName.isEmpty {
            url = Bundle.main.url(forResource: track.title, withExtension: "mp3")
        } else {
            url = URL(fileURLWithPath: track.fileName)
        }
        
        guard let validURL = url else { return }
        
        stopObserver()
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }
        
        let playerItem = AVPlayerItem(url: validURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer
        
        Task {
            do {
                let duration = try await playerItem.asset.load(.duration)
                await MainActor.run { self.duration = duration.seconds }
            } catch { print("❌ Error loading duration: \(error)") }
        }
        
        newPlayer.play()
        self.isPlaying = true
        updateNowPlaying()
        startObserver()
        
        playerObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                switch self.playbackMode {
                case .loopOne:
                    self.seek(to: 0)
                    self.resume()
                case .list:
                    if let current = self.currentTrack,
                       let idx = self.playlist.firstIndex(where: { $0.id == current.id }),
                       idx < self.playlist.count - 1 {
                        self.skipNext()
                    } else {
                        self.pause()
                        self.seek(to: 0)
                    }
                case .shuffle:
                    self.skipNext()
                }
            }
        }
    }
    
    func playAlbum(_ album: Album) {
        guard !album.tracks.isEmpty else { return }
        self.currentAlbum = album
        playTrack(album.tracks[0], in: album.tracks)
    }
    
    func togglePlayPause() {
        if isPlaying { pause() } else { resume() }
    }
    
    func manualSearchLyrics() async {
        guard let track = currentTrack else { return }
        await MainActor.run { isSearchingLyrics = true }
        let trackDuration = parseDuration(track.duration)
        let lyrics = await LyricsService.shared.searchLyrics(for: track.title, artist: track.artist, duration: trackDuration)
        await MainActor.run {
            self.currentTrackLyrics = lyrics
            self.isSearchingLyrics = false
        }
    }
    
    private func parseDuration(_ durationStr: String) -> Double? {
        let components = durationStr.components(separatedBy: ":")
        if components.count == 2, let min = Double(components[0]), let sec = Double(components[1]) {
            return min * 60 + sec
        }
        return nil
    }
    
    func pause() { 
        player?.pause()
        isPlaying = false 
        updateNowPlaying()
    }
    func resume() { 
        player?.play()
        isPlaying = true 
        updateNowPlaying()
    }
    
    func skipNext() {
        guard !playlist.isEmpty, let current = currentTrack, 
              let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        
        let nextIdx: Int
        if playbackMode == .shuffle {
            nextIdx = Int.random(in: 0..<playlist.count)
        } else {
            nextIdx = (idx + 1) % playlist.count
        }
        playTrack(playlist[nextIdx])
    }
    
    func skipPrevious() {
        guard !playlist.isEmpty, let current = currentTrack, 
              let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        
        let prevIdx: Int
        if playbackMode == .shuffle {
            prevIdx = Int.random(in: 0..<playlist.count)
        } else {
            prevIdx = (idx - 1 + playlist.count) % playlist.count
        }
        playTrack(playlist[prevIdx])
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
        updateNowPlaying()
    }
    
    func togglePlaybackMode() {
        switch playbackMode {
        case .list: playbackMode = .loopOne
        case .loopOne: playbackMode = .shuffle
        case .shuffle: playbackMode = .list
        }
    }
    
    private func stopObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    private func startObserver() {
        stopObserver()
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = time.seconds
                
                // 🚀 同步歌词索引
                if let index = self.currentTrackLyrics.lastIndex(where: { $0.startTime <= time.seconds }) {
                    self.currentLyricIndex = index
                }
                
                // 🚀 每隔 5 秒强制同步一次系统元数据，防止漂移
                if Int(time.seconds) % 5 == 0 {
                    self.updateNowPlaying()
                }
            }
        }
    }
}
