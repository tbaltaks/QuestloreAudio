//
//  SceneView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

let globalSpacing = 16.0

struct SceneView: View
{
    @Environment(\.colorScheme) var colorScheme
    
    // Computed property for the toolbar background color
    var toolbarBackground: Color
    {
        colorScheme == .dark ? Color(hex: "222222") : Color(hex: "cecece")
    }
    
    // Computed property for the scene background color
    var sceneBackground: Color
    {
        colorScheme == .dark ? Color(hex: "171717") : Color(hex: "f1f1f1")
    }
    
    // Array of sample cell data.
    let allCellData: [AudioCellData] = [
        AudioCellData(audio: "audio1.mp3", label: "Cell 1", accentColor: .blue),
        AudioCellData(audio: "audio2.mp3", label: "Cell 2", accentColor: .red),
        AudioCellData(audio: "audio3.mp3", label: "Cell 3", accentColor: .green),
        AudioCellData(audio: "audio4.mp3", label: "Cell 4", accentColor: .orange)
    ]
    
    let audioFiles =
    [
        "Building_Interior_Music.mp3", "Dungeon_Ambience.mp3", "Mystic_Desert_Music.mp3", "Log_Fire_Ambience.mp3"
    ]
    
    let labels =
    [
        "Building Interior Music", "Dungeon Ambience", "Mystic Desert Music", "Log Fire Ambience"
    ]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
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
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: globalSpacing), count: 10)
            
            // Body Section
            ZStack
            {
                LazyVGrid (columns: columns, spacing: globalSpacing)
                {
                    ForEach(allCellData)
                    { cellData in
                        AudioCell(action: { print("Playing \(cellData.audio)") }, cellData: cellData)
                    }
                }
            }
            .padding(globalSpacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(sceneBackground)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    struct SceneView_Previews: PreviewProvider
    {
        static var previews: some View
        {
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
}
