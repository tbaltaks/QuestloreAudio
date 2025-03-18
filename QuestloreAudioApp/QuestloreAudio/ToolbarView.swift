//
//  ToolbarView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 18/3/2025.
//

import SwiftUI

struct Toolbar: View
{
    var height: CGFloat
    var color: Color
    
    var body: some View
    {
        HStack
        {
            Spacer(minLength: 0)

            Image("QLAudioLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: height * 0.8)
                .colorMultiply(.gray)
            
            Spacer(minLength: 0)
        }
        .frame(height: height)
        .background(color)
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
