import SwiftUI

struct AppHeader: View {
    let title: String
    let leftItem: AnyView?
    let rightItem: AnyView?
    
    // 🚀 Figma 1:1 像素级设计参数 (iPhone 14 Pro 适配)
    private let headerHeight: CGFloat = 64
    private let horizontalPadding: CGFloat = 24
    
    init(title: String, leftItem: AnyView? = nil, rightItem: AnyView? = nil) {
        self.title = title
        self.leftItem = leftItem
        self.rightItem = rightItem
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Action Area - Fixed 44x44 tap target
            ZStack(alignment: .leading) {
                if let left = leftItem {
                    left
                }
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            // Title (Pixel-Perfect Typography & Truncation)
            Text(title.uppercased())
                .font(.system(size: 17, weight: .black))
                .kerning(1.5)
                .foregroundColor(DesignTokens.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Right Action Area - Fixed 44x44 tap target
            ZStack(alignment: .trailing) {
                if let right = rightItem {
                    right
                }
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: headerHeight)
        .background(Color.clear) // Transparent by default
    }
}
