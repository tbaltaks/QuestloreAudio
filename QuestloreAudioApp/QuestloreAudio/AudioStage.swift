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
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
        
    private var isPhone: Bool {
        // iPhone will have at least one compact dimension in portrait
        !(horizontalSizeClass == .regular && verticalSizeClass == .regular)
    }
    
//    @State private var windowWidth: CGFloat = 0
//    @State private var windowHeight: CGFloat = 0
//    @State private var isWideScreen: Bool = true
    
    init()
    {
        gridModel = AudioCellGridModel(cellDataArray: AudioCellGridData.allCellData)
    }

//    // MARK: Grid Layout
//    let columns = Array(repeating: GridItem(.flexible(), spacing: globalSpacing), count: 10)
    
    var body: some View
    {
        GeometryReader
        { geometry in
            
            let windowWidth = geometry.size.width
            let windowHeight = geometry.size.height
            let isLandscape = windowWidth > windowHeight
            
            VStack (spacing: 0)
            {
                // Toolbar Section
                Toolbar(height: toolbarHeight, bottomOffset: isPhone ? 8 : 0, color: toolbarBackground)
//                .border(.red)
                
                // Body Section
                ScrollView
                {
                    Grid(alignment: .center, horizontalSpacing: globalSpacing, verticalSpacing: globalSpacing)
                    {
                        let columnCount = isPhone ? 4 : isLandscape ? 10 : 5
                        
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
                    .padding(globalSpacing)
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
            .frame(width: windowWidth, height: windowHeight, alignment: .top)
            .background(sceneBackground)
            .onPreferenceChange(ContentHeightKey.self) { height in
                gridHeight = height
                toolbarHeight = max(windowHeight - height, 46)
            }
            .onChange(of: gridModel.cells) { _ in
                // Force layout update when cells change
                gridModel.objectWillChange.send()
            }
//            .onAppear {
//                windowWidth = UIScreen.currentBounds.width
//                windowHeight = UIScreen.currentBounds.height
//                isWideScreen = windowWidth > 768
//            }
        }
//        .border(.pink)
        .edgesIgnoringSafeArea(isPhone ? .all.subtracting(.top) : .all)
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
                                
