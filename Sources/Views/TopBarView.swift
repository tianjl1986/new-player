import SwiftUI

struct TopBarView: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, Tin Player")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                Text("Enjoy your vinyl")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: { /* Search Action */ }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                        .padding(12)
                        .skeuoRaised(cornerRadius: 12)
                }
                
                Button(action: { /* Profile Action */ }) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                        .padding(12)
                        .skeuoRaised(cornerRadius: 12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
}
