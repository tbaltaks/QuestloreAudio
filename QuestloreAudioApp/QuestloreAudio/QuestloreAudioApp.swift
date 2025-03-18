//
//  QuestloreAudioApp.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 5/3/2025.
//

import SwiftUI

@main
struct QuestloreAudioApp: App
{
    var body: some Scene
    {
        WindowGroup {
            AudioStage()
                .persistentSystemOverlays(.hidden)
        }
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
