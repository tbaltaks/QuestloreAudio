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
    
    @ObservedObject var gridModel: AudioGridModel
    
    init()
    {
        // Array of cell data.
        let allCellData =
        
        (1...100).map { _ in
            AudioCellData(audio: "", label: "", accentColor: .gray)
        }
        
//        [
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .purple),
//            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
//            AudioCellData(audio: "Jungle_Ambience.mp3", label: "Jungle Ambience", accentColor: .green),
//            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .yellow),
//            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange),
//            AudioCellData(audio: "Boss_Combat_Music.mp3", label: "Boss Combat Music", accentColor: .red),
//        ]
        
        gridModel = AudioGridModel(cellDataArray: allCellData)
    }
    
    // MARK: Grid Layout
    let columns = Array(repeating: GridItem(.flexible(), spacing: globalSpacing), count: 10)
    
    var body: some View
    {
        VStack (spacing: 0)
        {
            // Toolbar Section
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
            .frame(height: 48)
            .background(toolbarBackground)
//            .border(.red)
            
            // Body Section
            ScrollView
            {
                LazyVGrid (columns: columns, spacing: globalSpacing)
                {
                    ForEach(gridModel.cells)
                    { cellModel in
                        AudioCell(
                            cellModel: cellModel,
                            onToggle: { gridModel.ToggleCell(cellModel) },
                            onSoloActioned: { gridModel.SoloCellActioned(cellModel) },
                            onSoloCancelled: { gridModel.SoloCellCancelled(cellModel) },
                            onSolo: { gridModel.SoloCell(cellModel) }
                        )
                    }
                }
                .padding(globalSpacing)
                .drawingGroup()
//                .border(.orange)
            }
//            .border(.blue)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(sceneBackground)
//        .border(.yellow)
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
