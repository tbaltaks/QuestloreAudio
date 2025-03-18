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
    var toolbarBackground: Color {
        colorScheme == .dark ? Color(hex: "222222") : Color(hex: "cecece")
    }
    
    @ObservedObject var gridModel: AudioCellGridModel
    
    @State private var toolbarHeight: CGFloat = 46
    @State private var gridHeight: CGFloat = 0
    
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
                Toolbar(height: toolbarHeight, color: toolbarBackground)
//                .border(.red)
                
                // Body Section
                ScrollView
                {
                    Grid(alignment: .center, horizontalSpacing: globalSpacing, verticalSpacing: globalSpacing)
                    {
                        ForEach(Array(gridModel.cells.chunked(into: 10).enumerated()), id: \.offset) { index, row in
                            GridRow {
                                ForEach(row) { cellModel in
                                    AudioCell(
                                        cellModel: cellModel,
                                        onToggle: { gridModel.ToggleCell(cellModel) },
                                        onSoloActioned: { gridModel.SoloCellActioned(cellModel) },
                                        onSoloCancelled: { gridModel.SoloCellCancelled(cellModel) },
                                        onSolo: { gridModel.SoloCell(cellModel) }
                                    )
//                                    .border(.purple)
                                }
                            }
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
                .scrollDisabled(gridHeight + toolbarHeight < UIScreen.currentBounds.height + 10)
//                .border(.blue)
            }
            .frame(width: UIScreen.currentBounds.width, height: UIScreen.currentBounds.height, alignment: .top)
            .background(sceneBackground)
            .edgesIgnoringSafeArea(.all)
            .onPreferenceChange(ContentHeightKey.self) { height in
                gridHeight = height
                toolbarHeight = max(UIScreen.currentBounds.height - height, 46)
                print("Grid height: \(height)")
                print("Toolbar height: \(toolbarHeight)")
            }
            .onChange(of: gridModel.cells) { _ in
                // Force layout update when cells change
                gridModel.objectWillChange.send()
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
                                
                                
extension Array
{
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
                                
