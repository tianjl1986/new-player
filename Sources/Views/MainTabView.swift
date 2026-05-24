import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    init() {
        // 隐藏默认的 TabBar，因为我们要使用自定义的拟物化 SVG 图标
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                LibraryView()
                    .tag(AppTab.library)
                
                SearchView()
                    .tag(AppTab.search)
                
                PlayerView()
                    .tag(AppTab.player)
                
                SettingsView()
                    .tag(AppTab.settings)
            }
            
            // 自定义底部导航栏
            CustomBottomNavBar()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct CustomBottomNavBar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(tab: .library, iconName: "ic_library", title: "资料库")
            TabBarButton(tab: .search, iconName: "ic_search", title: "搜索")
            TabBarButton(tab: .player, iconName: "ic_player", title: "播放")
            TabBarButton(tab: .settings, iconName: "ic_settings", title: "设置")
        }
        .padding(.horizontal, 16)
        .padding(.bottom, safeAreaBottom)
        .padding(.top, 12)
        .background(Color(white: 0.1).shadow(radius: 10)) // 临时底部栏背景
    }
    
    private var safeAreaBottom: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

struct TabBarButton: View {
    @EnvironmentObject var appState: AppState
    let tab: AppTab
    let iconName: String
    let title: String
    
    var body: some View {
        Button(action: {
            appState.selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .opacity(appState.selectedTab == tab ? 1.0 : 0.4)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.white.opacity(appState.selectedTab == tab ? 1.0 : 0.4))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
