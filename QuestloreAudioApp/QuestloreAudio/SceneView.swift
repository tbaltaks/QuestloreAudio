//
//  SceneView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct SceneView: View {
    
    @Environment(\.colorScheme) var colorScheme
        
        // Computed property for the toolbar background color
        var toolbarBackground: Color {
            colorScheme == .dark ? Color(hex: "222222") : Color(hex: "cecece")
        }
        
        // Computed property for the scene background color
        var sceneBackground: Color {
            colorScheme == .dark ? Color(hex: "171717") : Color(hex: "f1f1f1")
        }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar Section
            HStack {
                Spacer()
                Image("QLAudioLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Spacer()
            }
            .frame(height: 50)
            .background(toolbarBackground)
            
            // Body Section
            ZStack {
                AudioCellButton(action: {
                    print("Audio cell toggled!")
                }, accentColor: Color(.secondarySystemBackground))
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(sceneBackground)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .previewInterfaceOrientation(.landscapeRight)
            .preferredColorScheme(.light)
        
        SceneView()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .previewInterfaceOrientation(.landscapeRight)
            .preferredColorScheme(.dark)
    }
}
