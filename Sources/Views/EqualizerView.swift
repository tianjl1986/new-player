import SwiftUI

struct EqualizerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // 10 bands frequencies
    let bands = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    @State private var bandGains: [Double] = Array(repeating: 0.0, count: 10)
    @State private var masterGain: Double = 0.0
    
    var body: some View {
        ZStack {
            Color(white: 0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Equalizer")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Reset") {
                        withAnimation {
                            bandGains = Array(repeating: 0.0, count: 10)
                            masterGain = 0.0
                        }
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                // 10 Band EQ ScrollView + Master
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        // Master Slider
                        VStack {
                            Text("MASTER")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SkeuoSlider(value: $masterGain, isMaster: true)
                                .frame(width: 40, height: 250)
                            
                            Text(String(format: "%.1f dB", masterGain))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 250)
                            .padding(.horizontal, 8)
                        
                        // 10 Bands
                        ForEach(0..<10, id: \.self) { index in
                            VStack {
                                Text("\(bands[index])Hz")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                SkeuoSlider(value: $bandGains[index], isMaster: false)
                                    .frame(width: 40, height: 250)
                                
                                Text(String(format: "%.1f", bandGains[index]) + "dB")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
    }
}

// Custom Slider component using high-fidelity assets
struct SkeuoSlider: View {
    @Binding var value: Double // Range -24 to 24
    let isMaster: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Track Background
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.05))
                    .frame(width: 6)
                    .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: 1) // Sunken effect
                
                // Track Fill
                let range: Double = 48
                let percentage = (value + 24) / range
                let trackHeight = CGFloat(percentage) * geometry.size.height
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue)
                    .frame(width: 6, height: trackHeight)
                
                // Knob Image
                Image(isMaster ? "eq_master_knob" : "eq_fader_knob")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isMaster ? 36 : 28, height: isMaster ? 36 : 28)
                    // Offset: from bottom alignment, move up by trackHeight, but center the knob
                    .offset(y: -trackHeight + (isMaster ? 18 : 14))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let relativeY = max(0, min(geometry.size.height, gesture.location.y))
                                let percentFromTop = relativeY / geometry.size.height
                                let percentFromBottom = 1.0 - percentFromTop
                                
                                let newValue = (Double(percentFromBottom) * range) - 24
                                value = newValue
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}
