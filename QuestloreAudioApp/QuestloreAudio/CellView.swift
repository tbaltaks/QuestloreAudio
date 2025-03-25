//
//  AudioCellView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct AudioCell: View
{
    @EnvironmentObject var globalColors: GlobalColors
    @ObservedObject var cellModel: AudioCellModel
    
    // Callbacks provided by the parent (AudioGridModel)
    var onToggle: (() -> Void)? = nil
    var onSoloActioned: (() -> Void)? = nil
    var onSoloCancelled: (() -> Void)? = nil
    var onSolo: (() -> Void)? = nil
    
    @State private var cellWidth: CGFloat = 0
    @State private var cellHeight: CGFloat = 0
    @State private var cornerRadius: CGFloat = 12
    @State private var borderThickness: CGFloat = 2
    
    var body: some View
    {
        GestureButton(
            longPressTime: cellModel.durationToAction,
            completeTime: cellModel.durationToComplete,
            releaseAction: { onToggle?() },
            longPressAction: { onSoloActioned?() },
            cancelAction: { onSoloCancelled?() },
            completeAction: { onSolo?() }
        ){
            ZStack
            {
                VStack (spacing: 0)
                {
                    AudioVisualiser(cellModel: cellModel)
                    ScaledText(cellModel: cellModel)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
    //            .border(.pink)
            }
            .aspectRatio(1.66, contentMode: .fit)
            .background(GeometryReader { geometry in
                globalColors.cellBackground
    //                .border(.green)
                    .preference(key: CellSizeKey.self, value: geometry.size.width)
            })
            .onPreferenceChange(CellSizeKey.self) { cellWidth in
                cornerRadius = cellWidth * 0.1
                borderThickness = cellWidth * 0.018
            }
            .cornerRadius(cornerRadius)
            .overlay(
                CellBorder(
                    lineWidth: borderThickness,
                    cornerRadius: cornerRadius,
                    color: cellModel.cellData.accentColor,
                    progress: cellModel.borderProgress,
                    isInverted: cellModel.borderInverted
                )
                .allowsHitTesting(false)
            )
            .overlay(
                OuterCellBorder(
                    lineWidth: borderThickness * 1.8,
                    cornerRadius: cornerRadius,
                    color: cellModel.cellData.accentColor,
                    progress: cellModel.outerBorderProgress,
                    isInverted: cellModel.outerBorderInverted
                )
                .allowsHitTesting(false)
            )
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


struct AudioVisualiser: View
{
    private static let VISUALIZER_BANDS = 16
    private static let STEM_SPACING_RATIO: CGFloat = 0.034
    private static let MIN_STEM_HEIGHT_RATIO: CGFloat = 0.068
    private static let MAX_STEM_HEIGHT_RATIO: CGFloat = 0.82
    private static let ANIMATION_DURATION: Double = 0.4
    
    var cellModel: AudioCellModel
    @State private var audioData = [Float](repeating: 0, count: VISUALIZER_BANDS)
    
    var body: some View
    {
        GeometryReader
        { geometry in
            let minStemHeight = geometry.size.height * Self.MIN_STEM_HEIGHT_RATIO
            let maxStemHeight = geometry.size.height * Self.MAX_STEM_HEIGHT_RATIO
            
            HStack (spacing: geometry.size.width * Self.STEM_SPACING_RATIO)
            {
                Spacer(minLength: 0)
                
                ForEach (0..<Self.VISUALIZER_BANDS, id: \.self)
                { index in
                    let newStemHeight = min(minStemHeight + (maxStemHeight - minStemHeight) * CGFloat(audioData[index]), maxStemHeight)
                    
                    VisualiserStem(
                        id: index,
                        color: cellModel.cellData.accentColor,
                        minHeight: minStemHeight,
                        height: newStemHeight
                    )
                }
                
                Spacer(minLength: 0)
            }
            .frame(minHeight: geometry.size.height * 1.1)
            .onReceive(AudioManager.shared.$bandedSampleData) { newData in
                if let updatedBands = newData[cellModel.cellData.id] {
                    withAnimation(.easeInOut(duration: AudioVisualiser.ANIMATION_DURATION)) {
                        audioData = updatedBands
                    }
                }
            }
        }
    }
}


struct VisualiserStem: View, Equatable
{
    var id: Int
    var color: Color = .blue
    var minHeight: CGFloat
    var height: CGFloat = 0
    
    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }
    
    var body: some View
    {
        VStack
        {
            Spacer(minLength: 0)
            
            RoundedRectangle(cornerRadius: .infinity)
                .fill(color)
                .frame(minHeight: minHeight)
                .frame(width: minHeight, height: height)
        }
    }
    
    static func == (lhs: VisualiserStem, rhs: VisualiserStem) -> Bool {
        lhs.color == rhs.color && lhs.minHeight == rhs.minHeight && lhs.height == rhs.height
    }
}


struct ScaledText: View
{
    let cellModel: AudioCellModel
    var body: some View
    {
        GeometryReader
        { geometry in
            Text(cellModel.cellData.label)
                .foregroundColor(cellModel.cellData.accentColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(.system(size: geometry.size.width * 0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .border(.green)
                .padding(.top, geometry.size.width * 0.058)
                .padding(.horizontal, geometry.size.width * 0.06)
                .padding(.bottom, geometry.size.width * 0.028)
        }
    }
}


struct CellBorder: View, Animatable
{
    // Style settings
    var lineWidth: CGFloat = 2
    var cornerRadius: CGFloat = 12
    var color: Color
    
    // The starting angle of the fill
    var startAngle: Angle = .degrees(-90)
    
    // Progress and direction condtion of fill
    var progress: CGFloat
    var isInverted: Bool
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    private var animatedStops: [Gradient.Stop]
    {
        if isInverted
        {
            let absProgress = abs(progress)
            
            return [
                .init(color: .clear, location: 0),
                .init(color: .clear, location: absProgress),
                .init(color: color, location: absProgress),
                .init(color: color, location: 1)
            ]
        }
        else
        {
            return [
                .init(color: color, location: 0),
                .init(color: color, location: progress),
                .init(color: .clear, location: progress),
                .init(color: .clear, location: 1)
            ]
        }
    }
    
    var body: some View
    {
        AngularGradient(
            gradient: Gradient(stops: animatedStops),
            center: .center,
            startAngle: startAngle,
            endAngle: startAngle + .degrees(360)
        )
        .mask(RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(lineWidth: lineWidth)
        )
    }
}

struct OuterCellBorder: View, Animatable
{
    // Style settings
    var lineWidth: CGFloat = 4
    var cornerRadius: CGFloat = 12
    var color: Color
    
    // The starting angle of the fill
    var startAngle: Angle = .degrees(-90)
    
    // Progress and direction condtion of fill
    var progress: CGFloat
    var isInverted: Bool
    
    var animatableData: CGFloat {
            get { progress }
            set { progress = newValue }
        }
    
    private var animatedStops: [Gradient.Stop]
    {
        if isInverted
        {
            let absProgress = abs(progress)
            
            return [
                .init(color: .clear, location: 0),
                .init(color: .clear, location: absProgress),
                .init(color: color, location: absProgress),
                .init(color: color, location: 1)
            ]
        }
        else
        {
            return [
                .init(color: color, location: 0),
                .init(color: color, location: progress),
                .init(color: .clear, location: progress),
                .init(color: .clear, location: 1)
            ]
        }
    }
    
    var body: some View
    {
        AngularGradient(
            gradient: Gradient(stops: animatedStops),
            center: .center,
            startAngle: startAngle,
            endAngle: startAngle + .degrees(360)
        )
        .mask(RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(lineWidth: lineWidth)
        )
    }
}
