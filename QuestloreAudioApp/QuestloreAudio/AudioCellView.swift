//
//  AudioCellView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct AudioCellData: Identifiable
{
    let id = UUID()
    let audio: String
    let label: String
    let accentColor: Color
}

struct AudioCell: View
{
    // The unique cell data
    let cellData: AudioCellData
    
    // The action to callback when the button is tapped.
    let action: () -> Void
    
    // Local state to track if the cell is currently playing audio.
    @State private var isPlaying: Bool = false
    
    // Detect the device theme
    @Environment(\.colorScheme) var colorScheme

    // Computed property for the background color based on the color scheme.
    var backgroundColor: Color
    {
        colorScheme == .dark ? Color(hex: "222222") : Color.white
    }

    // Build the cell.
    var body: some View
    {
        Button(action:
            {
                // Perform action
                action()
                
                // Toggle playback: if playing, fade out; if not, fade in.
                if isPlaying
                {
                    AudioManager.shared.stopAudio(for: cellData.audio)
                }
                else
                {
                    AudioManager.shared.playAudio(for: cellData.audio)
                }
                isPlaying.toggle()
            })
        {
            Text(cellData.label)
                .foregroundColor(cellData.accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.66, contentMode: .fit)
                .background(backgroundColor)
                .cornerRadius(16)
        }
    }
}


struct AudioCellButton_Previews: PreviewProvider
{
    static var previews: some View
    {
        // Preview in both light and dark mode for demonstration.
        Group
        {
            AudioCell(cellData: AudioCellData(audio: "", label: "Test", accentColor: .blue), action: { print("Audio cell toggled!") })
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .padding()
            
            AudioCell(cellData: AudioCellData(audio: "", label: "Test", accentColor: .blue), action: { print("Audio cell toggled!") })
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .padding()
        }
    }
}


// Extension to create a Color from a hex string.
extension Color
{
    init(hex: String)
    {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count
        {
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
