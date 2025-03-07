//
//  AudioCellView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct AudioCell: View {
    // The action to perform when the button is tapped.
    let action: () -> Void
    // The audio triggered by the cell.
    let audio: String
    // The label of the cell.
    let label: String
    // The background color of the cell.
    let accentColor: Color
    
    // Detect the device theme
    @Environment(\.colorScheme) var colorScheme

    // Computed property for the background color based on the color scheme.
    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "222222") : Color.white
    }

    // Build the cell.
    var body: some View {
        Button(action: {
            action()
            AudioManager.shared.playAudio(for: audio)
        }) {
            Text(label)
                .foregroundColor(accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Use PlainButtonStyle to avoid default button styling.
        .buttonStyle(PlainButtonStyle())
        .aspectRatio(1.66, contentMode: .fit)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct AudioCellButton_Previews: PreviewProvider {
    static var previews: some View {
        // Preview in both light and dark mode for demonstration.
        Group {
            AudioCell(action: {
                print("Audio cell toggled!")
            }, audio: "", label: "Test", accentColor: .blue)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .padding()
            
            AudioCell(action: {
                print("Audio cell toggled!")
            }, audio: "", label: "Test", accentColor: .blue)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .padding()
        }
    }
}

// Extension to create a Color from a hex string.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
