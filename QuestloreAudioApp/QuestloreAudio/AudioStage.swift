//
//  SceneView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct AudioStage: View
{
//    @EnvironmentObject var windowSize: WindowSize
    @EnvironmentObject var globalColors: GlobalColors
    @ObservedObject var gridModel: AudioCellGridModel
    
    @State private var windowSize: CGSize = CGSize(width: 0, height: 0)
    @State private var toolbarHeight: CGFloat = 46
    @State private var gridHeight: CGFloat = 0
    
    @State var fadeInButtonExpanded: Bool = false
    @State var fadeOutButtonExpanded: Bool = false
    
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
            
            let fullWindowWidth = geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing
            let fullWindowHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
            
            let isLandscape: Bool = fullWindowWidth > fullWindowHeight
//            let probablyHasBlackBar: Bool = isLandscape
//            ? geometry.safeAreaInsets.leading > 40 || geometry.safeAreaInsets.trailing > 40
//            : geometry.safeAreaInsets.top > 40
            
            let windowWidth = fullWindowWidth - (isLandscape ? (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing) : 0)
            let windowHeight = fullWindowHeight - (isPhone ? geometry.safeAreaInsets.top : 0)
            
            let columnCount: Int = isPhone ? (isLandscape ? 5 : 4) : (isLandscape ? 10 : 5)
//            let columnCount = Int(windowWidth / 115)
            let gridSpacing: CGFloat = windowWidth / CGFloat(columnCount) * 0.1
            
            VStack (spacing: 0)
            {
                // Toolbar Section
                Toolbar(
                    fadeInButtonExpanded: $fadeInButtonExpanded,
                    fadeOutButtonExpanded: $fadeOutButtonExpanded,
                    height: toolbarHeight + (isLandscape ? 0 : windowHeight * 0.01),
                    bottomOffset: isLandscape ? 0 : (isPhone ? 8 : 0)
                )
//                .border(.red)
                
                ZStack
                {
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
                    
                    // Dismissal Overlay
                    if fadeInButtonExpanded || fadeOutButtonExpanded
                    {
                        DismissalOverlay(
                            width: windowWidth,
                            height: windowHeight,
                            action: {
                                fadeInButtonExpanded = false
                                fadeOutButtonExpanded = false
                            }
                        )
//                        .border(.mint)
                    }
                }
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
            .onChange(of: windowWidth) { width in
                windowSize.width = width
            }
            .onChange(of: windowHeight) { height in
                windowSize.height = height
            }
            .onAppear {
                windowSize.width = windowWidth
                windowSize.height = windowHeight
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
    
    
    struct Previews: PreviewProvider
    {
        static var previews: some View
        {
            App_Previews.previews
        }
    }
}


struct DismissalOverlay: View
{
    var width: CGFloat = .infinity
    var height: CGFloat = .infinity
    var action: () -> Void
    
    var body: some View
    {
        Color.clear
            .contentShape(Rectangle())
            .frame(width: width, height: height)
            .onTapGesture {
                action()
            }
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
                                
