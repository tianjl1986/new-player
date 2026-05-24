import SwiftUI

struct EqualizerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // 10 bands frequencies
    let bands = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    @State private var bandGains: [Double] = Array(repeating: 0.0, count: 10)
    
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
                        bandGains = Array(repeating: 0.0, count: 10)
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                // 10 Band EQ ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ForEach(0..<10, id: \.self) { index in
                            VStack {
                                Text("\(bands[index])Hz")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                // 垂直滑块
                                GeometryReader { geometry in
                                    ZStack(alignment: .bottom) {
                                        Rectangle()
                                            .fill(Color.black)
                                            .frame(width: 4)
                                        
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: 4, height: CGFloat((bandGains[index] + 24) / 48) * geometry.size.height)
                                        
                                        // TODO: 替换为 eq_fader_knob 切片
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 24, height: 24)
                                            .offset(y: -CGFloat((bandGains[index] + 24) / 48) * geometry.size.height + 12)
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        let percentage = 1.0 - (value.location.y / geometry.size.height)
                                                        let gain = (Double(percentage) * 48) - 24
                                                        bandGains[index] = min(max(gain, -24), 24)
                                                    }
                                            )
                                    }
                                }
                                .frame(width: 40, height: 200)
                                
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
