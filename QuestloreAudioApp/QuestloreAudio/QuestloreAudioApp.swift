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
    @Environment(\.colorScheme) var systemColorScheme
    @StateObject private var globalColors = GlobalColors(colorScheme: .light)
    
    var body: some Scene
    {
        WindowGroup {
            AudioStage()
                .persistentSystemOverlays(.hidden)
                .environmentObject(globalColors)
                .onAppear {
                    globalColors.colorScheme = systemColorScheme
                }
                .onChange(of: systemColorScheme) { newScheme in
                    globalColors.colorScheme = newScheme
                }
        }
    }
    
    
    struct SceneView_Previews: PreviewProvider
    {
        static var previews: some View
        {
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.light)
                .environmentObject(GlobalColors(colorScheme: .light))
            
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.dark)
                .environmentObject(GlobalColors(colorScheme: .dark))
        }
    }
}
