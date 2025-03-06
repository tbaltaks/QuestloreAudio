//
//  AudioCellView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct AudioCellButton: View {
    // The action to perform when the button is tapped.
    let action: () -> Void
    // The background color of the cell.
    let accentColor: Color

    var body: some View {
        Button(action: action) {
            // Using an empty text label; you can add additional content if needed.
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Use PlainButtonStyle to avoid default button styling.
        .buttonStyle(PlainButtonStyle())
        // Set the aspect ratio to 1.66:1 (width to height).
        .aspectRatio(1.66, contentMode: .fit)
        .background(Color(UIColor.secondarySystemBackground))
        // Rounded corners for a softer look.
        .cornerRadius(12)
    }
}

struct AudioCellButton_Previews: PreviewProvider {
    static var previews: some View {
        AudioCellButton(action: {
            // Action for testing preview.
            print("Audio cell toggled")
        }, accentColor: .blue)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
