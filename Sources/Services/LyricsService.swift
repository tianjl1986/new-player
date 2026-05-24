import Foundation

class LyricsService {
    static let shared = LyricsService()
    
    // MARK: - LRCLIB Models
    struct LRCLibResponse: Codable {
        let syncedLyrics: String?
        let plainLyrics: String?
        let artistName: String?
        let trackName: String?
        let duration: Double?
    }
    
    // MARK: - Netease Models
    struct NeteaseSearchResponse: Codable {
        struct Result: Codable {
            struct Song: Codable {
                let id: Int
                let name: String
                let artists: [Artist]
                let duration: Int
            }
            struct Artist: Codable {
                let name: String
            }
            let songs: [Song]?
        }
        let result: Result?
        let code: Int
    }
    
    struct NeteaseLyricResponse: Codable {
        struct Lyric: Codable {
            let lyric: String?
        }
        let lrc: Lyric?
        let tlyric: Lyric?
        let code: Int
    }
    
    func searchLyrics(for title: String, artist: String, duration: Double? = nil) async -> [LyricLine] {
        let cleanTitle = cleanSearchTerm(title)
        let cleanArtist = cleanSearchTerm(artist)
        
        print("🎵 Searching lyrics for: \(cleanTitle) - \(cleanArtist)")
        
        // 🚀 Strategy 1: LRCLIB Exact Match
        if let lyrics = await tryExactMatchLRCLib(artist: artist, title: title, duration: duration) {
            print("✅ Found on LRCLIB (Exact Match)")
            return lyrics
        }
        
        // 🚀 Strategy 2: LRCLIB Search
        let lrcSearchUrl = "https://lrclib.net/api/search?q=\(urlEncode(cleanArtist))%20\(urlEncode(cleanTitle))"
        if let lyrics = await fetchLyricsFromLRCLibSearch(from: lrcSearchUrl, targetArtist: cleanArtist, targetTitle: cleanTitle, targetDuration: duration) {
            print("✅ Found on LRCLIB (Search)")
            return lyrics
        }
        
        // 🚀 Strategy 3: Netease Fallback
        print("⚠️ LRCLIB failed, trying Netease...")
        if let lyrics = await searchNeteaseLyrics(title: cleanTitle, artist: cleanArtist, duration: duration) {
            print("✅ Found on Netease")
            return lyrics
        }
        
        print("❌ No lyrics found on any platform")
        return [
            LyricLine(text: "Lyrics not found online", startTime: 0),
            LyricLine(text: "Please try manual search in Settings", startTime: 5)
        ]
    }
    
    // MARK: - LRCLIB Methods
    
    private func tryExactMatchLRCLib(artist: String, title: String, duration: Double?) async -> [LyricLine]? {
        var url = "https://lrclib.net/api/get?artist=\(urlEncode(artist))&track_name=\(urlEncode(title))"
        if let dur = duration {
            url += "&duration=\(Int(dur))"
        }
        return await fetchLyricsFromURL(from: url)
    }
    
    private func fetchLyricsFromLRCLibSearch(from urlString: String, targetArtist: String, targetTitle: String, targetDuration: Double?) async -> [LyricLine]? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let responses = try JSONDecoder().decode([LRCLibResponse].self, from: data)
            
            let candidate = responses.first { res in
                let artistMatch = res.artistName?.lowercased().contains(targetArtist.lowercased()) ?? false
                let titleMatch = res.trackName?.lowercased().contains(targetTitle.lowercased()) ?? false
                
                var durationMatch = true
                if let targetDur = targetDuration, let resDur = res.duration {
                    durationMatch = abs(targetDur - resDur) < 8.0
                }
                
                return (artistMatch || titleMatch) && durationMatch
            }
            
            if let bestRes = candidate {
                if let synced = bestRes.syncedLyrics {
                    return parseLRC(synced)
                } else if let plain = bestRes.plainLyrics {
                    return parsePlain(plain)
                }
            }
        } catch {
            print("LRCLIB search failed: \(error)")
        }
        return nil
    }
    
    private func fetchLyricsFromURL(from urlString: String) async -> [LyricLine]? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(LRCLibResponse.self, from: data)
            if let synced = response.syncedLyrics {
                return parseLRC(synced)
            } else if let plain = response.plainLyrics {
                return parsePlain(plain)
            }
        } catch { }
        return nil
    }
    
    // MARK: - Netease Methods
    
    private func searchNeteaseLyrics(title: String, artist: String, duration: Double?) async -> [LyricLine]? {
        let query = "\(artist) \(title)"
        let searchUrl = "https://music.163.com/api/search/get/web?s=\(urlEncode(query))&type=1&limit=5"
        
        guard let url = URL(string: searchUrl) else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(NeteaseSearchResponse.self, from: data)
            
            guard let songs = response.result?.songs, !songs.isEmpty else { return nil }
            
            // Filter by duration if available
            let bestSong = songs.first { song in
                if let targetDur = duration {
                    let songDur = Double(song.duration) / 1000.0
                    return abs(targetDur - songDur) < 10.0
                }
                return true
            } ?? songs[0]
            
            return await fetchNeteaseLyrics(for: bestSong.id)
        } catch {
            print("Netease search failed: \(error)")
        }
        return nil
    }
    
    private func fetchNeteaseLyrics(for songId: Int) async -> [LyricLine]? {
        let lyricUrl = "https://music.163.com/api/song/lyric?id=\(songId)&lv=1&kv=1&tv=-1"
        guard let url = URL(string: lyricUrl) else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(NeteaseLyricResponse.self, from: data)
            
            if let lrc = response.lrc?.lyric, !lrc.isEmpty {
                return parseLRC(lrc)
            }
        } catch {
            print("Netease lyric fetch failed: \(error)")
        }
        return nil
    }
    
    // MARK: - Helpers
    
    private func parsePlain(_ plain: String) -> [LyricLine] {
        return plain.components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .enumerated()
            .map { (index, line) in
                LyricLine(text: line, startTime: Double(index * 5))
            }
    }
    
    private func urlEncode(_ string: String) -> String {
        let allowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&+?="))
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
    
    private func cleanSearchTerm(_ term: String) -> String {
        var cleaned = term
        let patterns = [
            "^\\d+[\\s\\.\\-、]*",
            "\\s*\\(.*?\\)",
            "\\s*\\[.*?\\]",
            "\\s*-\\s*(Remaster|Remastered|Studio|Single|Explicit|Live).*$",
            "\\s*feat\\..*$",
            "\\s*ft\\..*$",
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: NSRange(location: 0, length: cleaned.utf16.count), withTemplate: "")
            }
        }
        
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? term : cleaned
    }
    
    private func parseLRC(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        let pattern = "\\[(\\d+):(\\d+(?:[.:]\\d+)?)\\](.*)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let nsString = lrc as NSString
        let matches = regex.matches(in: lrc, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            guard match.numberOfRanges >= 4 else { continue }
            
            let minStr = nsString.substring(with: match.range(at: 1))
            let secStr = nsString.substring(with: match.range(at: 2)).replacingOccurrences(of: ":", with: ".")
            let text = nsString.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines or technical tags like [by:xxx]
            if text.isEmpty || text.contains(":") { continue }
            
            if let min = Double(minStr), let sec = Double(secStr) {
                let time = min * 60 + sec
                lines.append(LyricLine(text: text, startTime: time))
            }
        }
        
        return lines.sorted { $0.startTime < $1.startTime }
    }
}
