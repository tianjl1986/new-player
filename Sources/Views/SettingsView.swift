import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    // 语言切换状态保存
    @AppStorage("appLanguage") private var appLanguage: String = "zh"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("本地媒体")) {
                    Button("扫描本地音频文件") {
                        // 调用 LocalMediaScannerService
                    }
                    Text("共找到 0 首歌曲")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("语言 / Language")) {
                    Picker("界面语言", selection: $appLanguage) {
                        Text("中文").tag("zh")
                        Text("English").tag("en")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("关于")) {
                    Text("New Player v1.0.0")
                }
            }
            .navigationTitle("设置")
        }
    }
}
