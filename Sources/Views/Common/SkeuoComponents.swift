import SwiftUI

// MARK: - SkeuoSettingsGroup
struct SkeuoSettingsGroup<Content: View>: View {
    @ObservedObject var theme = ThemeManager.shared
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(DesignTokens.surfaceSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignTokens.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - SkeuoSettingsRow
struct SkeuoSettingsRow: View {
    @ObservedObject var theme = ThemeManager.shared
    let title: String
    var value: String = ""
    var isLink: Bool = false
    var isToggle: Bool = false
    var showBackground: Bool = true
    @State private var isOn = true
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignTokens.textPrimary)
            
            Spacer()
            
            if isToggle {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: DesignTokens.textActive))
            } else {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isLink ? DesignTokens.textActive : DesignTokens.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(showBackground ? DesignTokens.surfaceMain : Color.clear)
        .contentShape(Rectangle())
    }
}

// MARK: - AlbumCard
struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 155, height: 155)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignTokens.surfaceMain)
                        .frame(width: 155, height: 155)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 40))
                                .foregroundColor(DesignTokens.textSecondary.opacity(0.1))
                        )
                }
            }

            
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 2)
        }
        .frame(width: 155)
    }
}

// MARK: - TypewriterText
struct TypewriterText: View {
    let text: String
    let isCurrent: Bool
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(displayedText)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(isCurrent ? DesignTokens.textPrimary : DesignTokens.textSecondary.opacity(0.4))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            if isCurrent && currentIndex < text.count {
                Rectangle()
                    .fill(DesignTokens.textActive)
                    .frame(width: 2, height: 22)
                    .opacity(0.8)
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            if isCurrent {
                startTypewriter()
            } else {
                displayedText = text
            }
        }
        .onChange(of: isCurrent) { newValue in
            if newValue {
                startTypewriter()
            } else {
                // If it was already typing, stop it and show full
                stopTypewriter()
                displayedText = text
            }
        }
    }
    
    private func startTypewriter() {
        stopTypewriter()
        displayedText = ""
        currentIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText.append(text[index])
                currentIndex += 1
            } else {
                stopTypewriter()
            }
        }
    }
    
    private func stopTypewriter() {
        timer?.invalidate()
        timer = nil
    }
}

extension View {
    func skeuoRaised(cornerRadius: CGFloat = 16) -> some View {
        self.shadow(color: DesignTokens.skeuoShadowDark, radius: 4, x: 4, y: 4)
            .shadow(color: DesignTokens.skeuoShadowLight, radius: 4, x: -4, y: -4)
    }
    
    func skeuoSunken(cornerRadius: CGFloat = 16) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(DesignTokens.skeuoShadowDark.opacity(0.4), lineWidth: 2)
                .blur(radius: 2)
                .offset(x: 1, y: 1)
                .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(DesignTokens.skeuoShadowLight.opacity(0.4), lineWidth: 2)
                .blur(radius: 2)
                .offset(x: -1, y: -1)
                .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
        )
    }
}

// MARK: - Button Styles

struct SkeuoRectButtonStyle: ButtonStyle {
    @ObservedObject var theme = ThemeManager.shared
    var cornerRadius: CGFloat = 16
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(DesignTokens.surfaceMain)
                            .skeuoSunken(cornerRadius: cornerRadius)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(DesignTokens.surfaceMain)
                            .shadow(color: DesignTokens.skeuoShadowDark, radius: 4, x: 4, y: 4)
                            .shadow(color: DesignTokens.skeuoShadowLight.opacity(theme.isDark ? 1.0 : 0.9), radius: 4, x: -4, y: -4)
                    }
                }
            )
    }
}

