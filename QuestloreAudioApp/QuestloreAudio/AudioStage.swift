//
//  SceneView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

let globalSpacing = 16.0

struct AudioStage: View
{
    @Environment(\.colorScheme) var colorScheme
    
    var sceneBackground: Color {
        colorScheme == .dark ? Color(hex: "171717") : Color(hex: "f1f1f1")
    }
    
    @ObservedObject var gridModel: AudioCellGridModel
    
    init()
    {
        gridModel = AudioCellGridModel(cellDataArray: AudioCellGridData.allCellData)
    }
    
    // MARK: Grid Layout
    let columns = Array(repeating: GridItem(.flexible(), spacing: globalSpacing), count: 10)
    
    var body: some View
    {
        GeometryReader
        { geometry in
            VStack (spacing: 0)
            {
                // Toolbar Section
                Toolbar()
    //            .border(.red)
                
                // Body Section
                VStack
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
    //                .border(.orange)
                }
                .padding(globalSpacing)
                .drawingGroup()
    //            .border(.blue)
            }
//            .border(.yellow)
            .background(sceneBackground)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .edgesIgnoringSafeArea(.all)
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
