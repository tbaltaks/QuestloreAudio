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
    @State private var contentHeight: CGFloat = 0
    
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
                .background(GeometryReader { geometry in
                    Color.clear
//                        .border(.green)
                        .preference(key: ContentHeightKey.self, value: geometry.size.height)
                })
//                .border(.red)
                
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
                    .background(GeometryReader { geometry in
                        Color.clear
//                            .border(.green)
                            .preference(key: ContentHeightKey.self, value: geometry.size.height)
                    })
//                    .border(.orange)
                }
                .scrollDisabled(contentHeight < UIScreen.currentBounds.height + 10)
//                .border(.blue)
            }
            .frame(
                width: UIScreen.currentBounds.width,
                height: UIScreen.currentBounds.height,
                alignment: .top)
            .background(sceneBackground)
            .edgesIgnoringSafeArea(.all)
            .onPreferenceChange(ContentHeightKey.self) { height in
                contentHeight = height
                print("Content height: \(height)")
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
            
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.dark)
        }
    }
}


// PreferenceKey for height tracking
struct ContentHeightKey: PreferenceKey
{
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}


extension UIScreen
{
    static var currentBounds: CGRect
    {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        
        return window.bounds
    }
}
