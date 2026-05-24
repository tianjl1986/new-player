import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var libraryService = MusicLibraryService.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var isAddingFolder = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(
                title: loc.t("SETTINGS"),
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // 1. MEDIA FOLDERS
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.t("MEDIA FOLDERS"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 16) {
                            ForEach(libraryService.mediaFolders, id: \.self) { folder in
                                HStack {
                                    Text(folder)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(DesignTokens.textPrimary)
                                    Spacer()
                                    Image(systemName: "minus")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)
                                .background(DesignTokens.surfaceSecondary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(DesignTokens.textSecondary.opacity(0.1), lineWidth: 1)
                                )
                            }
                            
                            Button(action: { isAddingFolder = true }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                    Text(loc.t("Add Music Folder"))
                                        .font(.system(size: 14, weight: .heavy))
                                }
                                .foregroundColor(DesignTokens.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                            }
                            .buttonStyle(SkeuoRectButtonStyle(cornerRadius: 12))
                        }
                    }
                    
                    // 3. SCANNING OPTIONS
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.t("SCANNING OPTIONS"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                            .padding(.horizontal, 4)
                        
                        SkeuoSettingsGroup {
                            SkeuoSettingsRow(title: loc.t("Parse .cue sheets"), value: "[ ON ]", isLink: true, showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: loc.t("Search for .lrc lyrics"), value: "[ ON ]", isLink: true, showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: loc.t("Auto-scan on startup"), value: "[ OFF ]", isLink: false, showBackground: false)
                        }
                    }
                    
                    // 4. APPEARANCE & LOCALIZATION
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.t("APPEARANCE"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                            .padding(.horizontal, 4)
                        
                        SkeuoSettingsGroup {
                            HStack {
                                Text(loc.t("Dark Mode"))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DesignTokens.textPrimary)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { themeManager.isDark },
                                    set: { _ in themeManager.toggleTheme() }
                                ))
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: DesignTokens.textActive))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            
                            Divider().padding(.horizontal, 20)
                            
                            HStack {
                                Text(loc.t("Language"))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DesignTokens.textPrimary)
                                Spacer()
                                Button(action: {
                                    loc.language = (loc.language == "en" ? "zh" : "en")
                                }) {
                                    Text(loc.language == "en" ? "English" : "中文")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(DesignTokens.textActive)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                    
                    // 5. MAINTENANCE
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.t("MAINTENANCE"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 16) {
                            Button(action: { libraryService.scanLibrary() }) {
                                Text(loc.t("Rescan Now"))
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(DesignTokens.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            }
                            .buttonStyle(SkeuoRectButtonStyle(cornerRadius: 12))
                            
                            Button(action: { libraryService.clearLibrary() }) {
                                Text(loc.t("Clear Library"))
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(DesignTokens.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            }
                            .buttonStyle(SkeuoRectButtonStyle(cornerRadius: 12))
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
