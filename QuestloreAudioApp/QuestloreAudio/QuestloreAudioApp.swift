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
    @StateObject private var audioSettings = AudioSettings.shared
    
    var body: some Scene
    {
        WindowGroup {
            AudioStage()
                .persistentSystemOverlays(.hidden)
                .environmentObject(globalColors)
                .environmentObject(audioSettings)
                .onAppear {
                    globalColors.colorScheme = systemColorScheme
                }
                .onChange(of: systemColorScheme) { newScheme in
                    globalColors.colorScheme = newScheme
                }
        }
    }
}


struct App_Previews: PreviewProvider
{
    static var previews: some View
    {
        AudioStage()
            .previewInterfaceOrientation(.landscapeRight)
            .preferredColorScheme(.light)
            .environmentObject(GlobalColors(colorScheme: .light))
            .environmentObject(AudioSettings.shared)
        
        AudioStage()
            .previewInterfaceOrientation(.landscapeRight)
            .preferredColorScheme(.dark)
            .environmentObject(GlobalColors(colorScheme: .dark))
            .environmentObject(AudioSettings.shared)
    }
}
