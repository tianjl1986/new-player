import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var appState: AppState
    
    // 转动动画状态
    @State private var rotationDegree: Double = 0
    
    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header (e.g., Now Playing text, Equalizer button)
                HStack {
                    Spacer()
                    Button(action: {
                        // Navigate to EQ or Lyrics
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 黑胶唱盘与专辑封面组合
                ZStack {
                    // 底盘 (拟物 svg/png)
                    // TODO: Replace with Image("record_platter")
                    Circle()
                        .fill(Color(white: 0.15))
                        .frame(width: 300, height: 300)
                        .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
                    
                    // 专辑封面 (裁剪为圆形)
                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .background(Circle().fill(Color.gray))
                }
                .rotationEffect(.degrees(rotationDegree))
                .animation(
                    appState.isPlaying ? Animation.linear(duration: 4.0).repeatForever(autoreverses: false) : .default,
                    value: appState.isPlaying
                )
                
                Spacer()
                
                // 进度条 (使用导出的拟物资源)
                VStack(spacing: 8) {
                    // TODO: 替换为 progress_bg 和 progress_knob
                    Slider(value: .constant(0.3))
                        .tint(.blue)
                    
                    HStack {
                        Text("1:20").font(.caption).foregroundColor(.gray)
                        Spacer()
                        Text("-3:15").font(.caption).foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 32)
                
                // 播放控制
                HStack(spacing: 40) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill").font(.title)
                    }
                    
                    Button(action: {
                        appState.isPlaying.toggle()
                    }) {
                        Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 44))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "forward.fill").font(.title)
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            if appState.isPlaying {
                // 启动时如果已经在播放，触发动画
                rotationDegree = 360
            }
        }
        .onChange(of: appState.isPlaying) { playing in
            if playing {
                rotationDegree = 360
            } else {
                rotationDegree = 0 // 或者保存当前角度以实现平滑暂停
            }
        }
    }
}
