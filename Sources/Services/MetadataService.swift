import Foundation
import UIKit

@MainActor
class MetadataService: ObservableObject {
    static let shared = MetadataService()
    @Published var artistImages: [String: UIImage] = [:]
    @Published var albumCovers: [String: UIImage] = [:]
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        return URLSession(configuration: config)
    }()
    
    func fetchArtistImage(name: String) async -> UIImage? {
        if let cached = artistImages[name] { return cached }
        
        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=album&limit=5"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(iTunesResponse.self, from: data)
            
            let match = response.results.first { $0.artistName.lowercased() == name.lowercased() } ?? response.results.first
            
            if let imageUrlString = match?.artworkUrl100 {
                let highResUrlString = imageUrlString.replacingOccurrences(of: "100x100bb", with: "600x600bb").replacingOccurrences(of: "100x100", with: "600x600")
                if let highResUrl = URL(string: highResUrlString) {
                    let (imgData, _) = try await session.data(from: highResUrl)
                    if let image = UIImage(data: imgData) {
                        self.artistImages[name] = image
                        return image
                    }
                }
            }
        } catch { print("Error fetching artist image: \(error)") }
        return nil
    }
    
    func fetchAlbumCover(albumName: String, artistName: String) async -> UIImage? {
        let cacheKey = "\(albumName)-\(artistName)"
        if let cached = albumCovers[cacheKey] { return cached }
        
        let query = "\(albumName) \(artistName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=album&limit=1"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(iTunesResponse.self, from: data)
            
            if let match = response.results.first, let imageUrlString = match.artworkUrl100 {
                let highResUrlString = imageUrlString.replacingOccurrences(of: "100x100bb", with: "600x600bb").replacingOccurrences(of: "100x100", with: "600x600")
                if let highResUrl = URL(string: highResUrlString) {
                    let (imgData, _) = try await session.data(from: highResUrl)
                    if let image = UIImage(data: imgData) {
                        self.albumCovers[cacheKey] = image
                        return image
                    }
                }
            }
        } catch { print("Error fetching album cover: \(error)") }
        return nil
    }
}

struct iTunesResponse: Codable { let results: [iTunesResult] }
struct iTunesResult: Codable {
    let artistName: String
    let collectionName: String?
    let artworkUrl100: String?
}
