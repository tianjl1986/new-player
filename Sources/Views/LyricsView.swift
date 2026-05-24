import SwiftUI

struct LyricsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var lyricsSearchFailed = false
    @State private var lyrics: [String] = [
        "第一句歌词示例",
        "这里是歌词滚动区域",
        "使用小票打印机风格",
        "跟随时间向上滚动"
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
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                
                // 打印机顶部滚筒 (占位)
                // TODO: Replace with Image("lyrics_roller")
                Rectangle()
                    .fill(Color(white: 0.15))
                    .frame(height: 60)
                    .shadow(radius: 5)
                
                // 连续纸张背景与歌词 (占位)
                ZStack(alignment: .top) {
                    // TODO: Replace with Image("lyrics_paper")
                    Rectangle()
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.9)) // 纸张颜色
                        .padding(.horizontal, 20)
                    
                    if lyricsSearchFailed {
                        VStack(spacing: 20) {
                            Text("未找到歌词")
                                .foregroundColor(.black)
                                .padding(.top, 100)
                            
                            Button(action: {
                                // 重新搜索逻辑
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
                                        .font(.system(size: 18, weight: .medium, design: .monospaced)) // 类似打印机字体
                                        .foregroundColor(index == 1 ? .blue : .black.opacity(0.6)) // 高亮当前行
                                }
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 40)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}
