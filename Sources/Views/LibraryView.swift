import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                Text("Library Placeholder")
                    .foregroundColor(.white)
            }
            .navigationTitle("资料库")
        }
    }
}
