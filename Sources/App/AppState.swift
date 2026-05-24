import Foundation
import SwiftUI

enum AppTab: Int {
    case library = 0
    case search = 1
    case player = 2
    case equalizer = 3 // 均衡器可能需要独立入口或从设置/播放页进入。根据切片，暂定为主Tab或设置Tab
    case settings = 4
}

final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .player
    @Published var isPlaying: Bool = false
    
    // 全局共享服务
    // 将在后续引入 AudioEngineService 和 LocalMediaScanner
}
