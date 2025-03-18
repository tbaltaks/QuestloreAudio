//
//  ToolbarView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 18/3/2025.
//

import SwiftUI

struct Toolbar: View {
    @Environment(\.colorScheme) var colorScheme
    
    var toolbarBackground: Color {
        colorScheme == .dark ? Color(hex: "222222") : Color(hex: "cecece")
    }
    
    var body: some View
    {
        HStack
        {
            Spacer(minLength: 0)

            Image("QLAudioLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 36)
                .colorMultiply(.gray)
            
            Spacer(minLength: 0)
        }
        .frame(height: 46)
        .background(toolbarBackground)
    }
    
    
    struct SceneView_Previews: PreviewProvider
    {
        static var previews: some View
        {
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.light)
            
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.dark)
        }
    }
}
