//
//  SceneView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct AudioStage: View
{
    @EnvironmentObject var globalColors: GlobalColors
    @ObservedObject var gridModel: AudioCellGridModel
    
    @State private var toolbarHeight: CGFloat = 46
    @State private var gridHeight: CGFloat = 0
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
        
    private var isPhone: Bool {
        // iPhone will have at least one compact dimension in portrait
        !(horizontalSizeClass == .regular && verticalSizeClass == .regular)
    }
    
    init()
    {
        gridModel = AudioCellGridModel(cellDataArray: AudioCellGridData.allCellData)
    }
    
    var body: some View
    {
        GeometryReader
        { geometry in
            
            let windowWidth = geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing
            let windowHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
            
            let isLandscape: Bool = windowWidth > windowHeight
//            let probablyHasBlackBar: Bool = isLandscape
//            ? geometry.safeAreaInsets.leading > 40 || geometry.safeAreaInsets.trailing > 40
//            : geometry.safeAreaInsets.top > 40
            
            let columnCount: Int = isPhone ? (isLandscape ? 5 : 4) : (isLandscape ? 10 : 5)
//            let columnCount = Int(windowWidth / 115)
            
            let gridSpacing: CGFloat = windowWidth / CGFloat(columnCount) * 0.1
            
            VStack (spacing: 0)
            {
                // Toolbar Section
                Toolbar(
                    height: toolbarHeight + (isLandscape ? 0 : windowHeight * 0.01),
                    bottomOffset: isLandscape ? 0 : (isPhone ? 8 : 0)
                )
//                .border(.red)
                
                // Body Section
                ScrollView
                {
                    Grid(alignment: .center, horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing)
                    {
                        ForEach(Array(gridModel.cells.chunked(into: columnCount).enumerated()), id: \.offset) { index, row in
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
                    .padding(gridSpacing)
                    .drawingGroup()
                    .background(GeometryReader { geometry in
                        Color.clear
//                            .border(.green)
                            .preference(key: ContentHeightKey.self, value: geometry.size.height)
                    })
//                    .border(.orange)
                }
                .scrollDisabled(gridHeight + toolbarHeight < windowHeight + 10)
//                .border(.blue)
            }
            .edgesIgnoringSafeArea(computeSafeEdges(isPhone, isLandscape))
            .background(globalColors.sceneBackground)
            .onPreferenceChange(ContentHeightKey.self) { height in
                gridHeight = height
                toolbarHeight = max(windowHeight - height, 46)
            }
            .onChange(of: gridModel.cells) { _ in
                // Force layout update when cells change
                gridModel.objectWillChange.send()
            }
        }
    }
    
    
    func computeSafeEdges(_ isPhone: Bool, _ isLandscape: Bool) -> Edge.Set
    {
        if isLandscape {
            return isPhone
            ? .all.subtracting(.horizontal)
            : .all
        } else {
            return isPhone
            ? .all.subtracting(.top)
            : .all
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


struct ContentHeightKey: PreferenceKey
{
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
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
                                
