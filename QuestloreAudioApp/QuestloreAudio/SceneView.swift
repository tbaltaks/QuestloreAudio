//
//  SceneView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct SceneView: View {
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
            .background(Color(UIColor.secondarySystemBackground))
            
            // Body Section
            ZStack {
                AudioCellButton(action: {
                    print("Audio cell toggled!")
                }, accentColor: Color(UIColor.secondarySystemBackground))
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .previewInterfaceOrientation(.landscapeRight)
    }
}
