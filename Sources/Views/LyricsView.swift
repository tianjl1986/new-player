import SwiftUI

struct LyricsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var lyricsSearchFailed = false
    @State private var lyrics: [String] = [
        "第一句歌词示例",
        "这里是歌词滚动区域",
        "使用小票打印机风格",
        "跟随时间向上滚动",
        "高保真纹理已应用"
    ]
    
    var body: some View {
        ZStack {
            Color(white: 0.08).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(white: 0.6))
                    }
                    Spacer()
                }
                .padding()
                
                // 打印机顶部滚筒 (Asset)
                Image("lyrics_roller")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .zIndex(2) // Ensure roller stays on top of paper
                    .shadow(color: .black.opacity(0.8), radius: 10, x: 0, y: 10)
                
                // 连续纸张背景与歌词 (Asset)
                ZStack(alignment: .top) {
                    Image("lyrics_paper")
                        .resizable()
                        .padding(.horizontal, 20)
                        .padding(.top, -20) // Slightly tuck under roller
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    if lyricsSearchFailed {
                        VStack(spacing: 20) {
                            Text("未找到歌词")
                                .foregroundColor(.black)
                                .padding(.top, 100)
                            
                            Button(action: {
                                lyricsSearchFailed = false
                            }) {
                                Text("重新搜索")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(0..<lyrics.count, id: \.self) { index in
                                    Text(lyrics[index])
                                        .font(.system(size: 18, weight: .bold, design: .monospaced)) // Typewriter font
                                        .foregroundColor(index == 1 ? Color.blue.opacity(0.8) : Color.black.opacity(0.5)) // Highlight
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1) // Ink bleed effect
                                }
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 40)
                        }
                        // Mask the scrollview to paper bounds roughly
                        .padding(.horizontal, 30)
                    }
                }
                .frame(maxHeight: .infinity)
                .zIndex(1)
            }
        }
    }
}
