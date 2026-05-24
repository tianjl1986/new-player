import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var appState: AppState
    @State private var rotationDegree: Double = 0
    @State private var progress: Double = 0.3
    
    // Timer for turntable animation
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background dark texture placeholder
                Color(white: 0.1).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image("ic_more")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, geo.safeAreaInsets.top > 0 ? 10 : 30) // Dynamic Island avoidance
                    
                    Spacer()
                    
                    // Turntable Area
                    let turntableSize = min(geo.size.width * 0.85, 400)
                    ZStack {
                        // Platter
                        Image("record_platter")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: turntableSize, height: turntableSize)
                            .shadow(color: Color.black.opacity(0.8), radius: 20, x: 0, y: 15)
                        
                        // Album Cover Mask
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFill()
                            .frame(width: turntableSize * 0.35, height: turntableSize * 0.35)
                            .clipShape(Circle())
                            .background(Circle().fill(Color.gray))
                            
                        // Tonearm
                        Image("tonearm")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: turntableSize * 0.3, height: turntableSize * 0.8)
                            .offset(x: turntableSize * 0.35, y: -turntableSize * 0.15)
                            .rotationEffect(.degrees(appState.isPlaying ? 0 : -15), anchor: .top)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: appState.isPlaying)
                    }
                    .rotationEffect(.degrees(rotationDegree))
                    
                    Spacer()
                    
                    // Progress Bar
                    VStack(spacing: 12) {
                        ZStack(alignment: .leading) {
                            Image("progress_bg")
                                .resizable()
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            // Blue/Active fill
                            Rectangle()
                                .fill(Color.blue.opacity(0.8))
                                .frame(width: geo.size.width * 0.8 * progress, height: 8)
                                .cornerRadius(4)
                            
                            Image("progress_knob")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .offset(x: (geo.size.width * 0.8 * progress) - 10)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let percentage = min(max(0, value.location.x / (geo.size.width * 0.8)), 1)
                                            progress = percentage
                                        }
                                )
                        }
                        .frame(height: 20)
                        
                        HStack {
                            Text("1:20").font(.caption).foregroundColor(Color(white: 0.6))
                            Spacer()
                            Text("-3:15").font(.caption).foregroundColor(Color(white: 0.6))
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.1)
                    
                    Spacer()
                    
                    // Transport Controls
                    ZStack {
                        Image("transport_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * 0.8)
                            .opacity(0.8)
                        
                        HStack(spacing: geo.size.width * 0.12) {
                            Button(action: {}) {
                                Image("ic_prev")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                            }
                            
                            Button(action: {
                                appState.isPlaying.toggle()
                            }) {
                                ZStack {
                                    if !appState.isPlaying {
                                        Image("ic_play")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 64, height: 64)
                                    } else {
                                        Image(systemName: "pause.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.white)
                                            .frame(width: 64, height: 64)
                                            .background(Circle().fill(Color(white: 0.2)))
                                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
                                    }
                                }
                            }
                            
                            Button(action: {}) {
                                Image("ic_next")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 30 : 50)
                }
            }
        }
        .onReceive(timer) { _ in
            if appState.isPlaying {
                rotationDegree += 0.5
            }
        }
        .onAppear {
            if appState.isPlaying {
                rotationDegree += 0.5
            }
        }
    }
}
