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
        let allCellData: [AudioCellData] = [
            AudioCellData(audio: "Building_Interior_Music.mp3", label: "Building Interior Music", accentColor: .blue),
            AudioCellData(audio: "Dungeon_Ambience.mp3", label: "Dungeon Ambience", accentColor: .red),
            AudioCellData(audio: "Mystic_Desert_Music.mp3", label: "Mystic Desert Music", accentColor: .green),
            AudioCellData(audio: "Log_Fire_Ambience.m4a", label: "Log Fire Ambience", accentColor: .orange)
        ]
        
        gridModel = AudioGridModel(cellDataArray: allCellData)
    }
    
    // MARK: Grid Layout
    let columns = Array(repeating: GridItem(.flexible(), spacing: globalSpacing), count: 2)
    
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
            
            // Body Section
            ZStack
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
