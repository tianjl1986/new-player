import SwiftUI

struct EqualizerView: View {
    @ObservedObject private var eqService = AudioEQService.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
                Spacer()
                Text(loc.t("EQUALIZER").uppercased())
                    .font(.system(size: 17, weight: .black))
                    .kerning(1.5)
                    .foregroundColor(DesignTokens.textPrimary)
                Spacer()
                Button(action: {
                    eqService.isEnabled.toggle()
                }) {
                    Text(eqService.isEnabled ? loc.t("ON") : loc.t("OFF"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(eqService.isEnabled ? DesignTokens.textActive : DesignTokens.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 64)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Presets
                    VStack(alignment: .leading, spacing: 16) {
                        Text(loc.t("PRESETS"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(EQPreset.allPresets) { preset in
                                    Button(action: {
                                        eqService.applyPreset(preset)
                                    }) {
                                        Text(loc.t(preset.name))
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(eqService.selectedPreset.id == preset.id ? .white : DesignTokens.textPrimary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                eqService.selectedPreset.id == preset.id ?
                                                DesignTokens.textActive : DesignTokens.surfaceSecondary
                                            )
                                            .cornerRadius(20)
                                            .shadow(color: eqService.selectedPreset.id == preset.id ? DesignTokens.textActive.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(.top, 16)
                    
                    // 10-Band EQ & Master (Horizontal Scroll for bands, Master fixed or scrollable)
                    VStack(alignment: .leading, spacing: 16) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 24) {
                                // Master Slider
                                VStack(spacing: 16) {
                                    Text(loc.t("MASTER"))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(DesignTokens.textSecondary)
                                    
                                    SkeuoSlider(value: $eqService.masterGain, range: -12...12, isMaster: true)
                                        .frame(height: 200)
                                    
                                    Text("\(Int(eqService.masterGain))")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(DesignTokens.textPrimary)
                                }
                                .padding(.trailing, 16)
                                
                                // Divider
                                Rectangle()
                                    .fill(DesignTokens.textSecondary.opacity(0.2))
                                    .frame(width: 1, height: 200)
                                
                                // 10 Bands
                                ForEach(0..<10, id: \.self) { index in
                                    VStack(spacing: 16) {
                                        Text(eqService.bandLabels[index])
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(DesignTokens.textSecondary)
                                        
                                        SkeuoSlider(
                                            value: Binding(
                                                get: { eqService.bandGains[index] },
                                                set: { eqService.setBandGain(index: index, gain: $0) }
                                            ),
                                            range: -12...12,
                                            isMaster: false
                                        )
                                        .frame(height: 200)
                                        
                                        Text("\(Int(eqService.bandGains[index]))")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(DesignTokens.textPrimary)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Button(action: {
                        eqService.resetAll()
                    }) {
                        Text(loc.t("RESET"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(DesignTokens.surfaceSecondary)
                            .cornerRadius(12)
                            .skeuoRaised(cornerRadius: 12)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}

// Custom Slider component replacing default slider
struct SkeuoSlider: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let isMaster: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Track Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.eqSliderTrack)
                    .frame(width: 8)
                    .skeuoSunken(cornerRadius: 4)
                
                // Track Fill
                let percentage = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
                let trackHeight = geometry.size.height * percentage
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(isMaster ? DesignTokens.eqMasterFill : DesignTokens.eqSliderFill)
                    .frame(width: 8, height: trackHeight)
                
                // Knob image from assets (SVG)
                Image(isMaster ? "master_knob" : "fader_knob")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isMaster ? 36 : 28)
                    // Offset based on value. Knob center should be at trackHeight from bottom
                    .offset(y: (geometry.size.height / 2) - trackHeight) 
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                // y is from top (0) to bottom (height)
                                // We want bottom=min, top=max
                                let relativeY = max(0, min(geometry.size.height, gesture.location.y))
                                let percentFromTop = relativeY / geometry.size.height
                                let percentFromBottom = 1.0 - percentFromTop
                                
                                let newValue = range.lowerBound + Float(percentFromBottom) * (range.upperBound - range.lowerBound)
                                value = newValue
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}
