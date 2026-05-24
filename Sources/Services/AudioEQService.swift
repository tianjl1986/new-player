import Foundation
import AVFoundation

struct EQPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let bands: [Float] // 10 bands: 32, 64, 125, 250, 500, 1K, 2K, 4K, 8K, 16K
    
    static let flat = EQPreset(id: "flat", name: "Flat", bands: [0,0,0,0,0,0,0,0,0,0])
    static let rock = EQPreset(id: "rock", name: "Rock", bands: [5,4,3,1,-1,-1,2,3,4,5])
    static let pop = EQPreset(id: "pop", name: "Pop", bands: [-1,1,3,4,3,1,-1,-1,1,2])
    static let jazz = EQPreset(id: "jazz", name: "Jazz", bands: [3,2,1,2,0,-1,0,1,2,3])
    static let classical = EQPreset(id: "classical", name: "Classical", bands: [4,3,2,1,0,0,0,1,3,4])
    static let bassBoost = EQPreset(id: "bass_boost", name: "Bass Boost", bands: [6,5,4,3,1,0,0,0,0,0])
    static let trebleBoost = EQPreset(id: "treble_boost", name: "Treble Boost", bands: [0,0,0,0,0,1,2,4,5,6])
    
    static let allPresets: [EQPreset] = [flat, rock, pop, jazz, classical, bassBoost, trebleBoost]
}

@MainActor
class AudioEQService: ObservableObject {
    static let shared = AudioEQService()
    
    let bandLabels = ["32", "64", "125", "250", "500", "1K", "2K", "4K", "8K", "16K"]
    let bandFrequencies: [Float] = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    
    @Published var isEnabled: Bool = true
    @Published var bandGains: [Float] = [0,0,0,0,0,0,0,0,0,0] // -12 to +12 dB
    @Published var masterGain: Float = 0 // -12 to +12 dB
    @Published var selectedPreset: EQPreset = .flat
    
    func applyPreset(_ preset: EQPreset) {
        selectedPreset = preset
        bandGains = preset.bands
    }
    
    func resetAll() {
        applyPreset(.flat)
        masterGain = 0
    }
    
    func setBandGain(index: Int, gain: Float) {
        guard index >= 0 && index < 10 else { return }
        bandGains[index] = max(-12, min(12, gain))
        // Mark as custom if no preset matches
        if bandGains != selectedPreset.bands {
            selectedPreset = EQPreset(id: "custom", name: "Custom", bands: bandGains)
        }
    }
}
