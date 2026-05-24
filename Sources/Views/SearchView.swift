import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedFilter = 0 // 0: 艺术家, 1: 专辑, 2: 年代
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Filter Strip
                    Picker("过滤", selection: $selectedFilter) {
                        Text("艺术家").tag(0)
                        Text("专辑").tag(1)
                        Text("年代").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    Spacer()
                    Text("Search Results for: \(searchText)")
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .navigationTitle("搜索")
            .searchable(text: $searchText, prompt: "查找歌曲、专辑或艺术家")
        }
    }
}
