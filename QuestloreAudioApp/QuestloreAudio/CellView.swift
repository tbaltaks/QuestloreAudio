//
//  AudioCellView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 6/3/2025.
//

import SwiftUI

struct AudioCell: View
{
    @ObservedObject var cellModel: AudioCellModel
    
    // Callbacks provided by the parent (AudioGridModel)
    var onToggle: (() -> Void)? = nil
    var onSoloActioned: (() -> Void)? = nil
    var onSoloCancelled: (() -> Void)? = nil
    var onSolo: (() -> Void)? = nil
    
    //Gesture Timing States
    @State private var pressStartTime: Date? = nil
    @State private var isSlowTapActioned: Bool = false
    @State private var isSlowTapCompleted: Bool = false
    @State private var isPointerDown: Bool = false
    
    // Detect the device theme
    @Environment(\.colorScheme) var colorScheme
    
    // Computed property for the background color based on the color scheme.
    var backgroundColor: Color
    {
        colorScheme == .dark ? Color(hex: "222222") : Color.white
    }
    
    // Build the cell.
    var body: some View
    {
        ZStack
        {
            // Background and label
            Text(cellModel.cellData.label)
                .foregroundColor(cellModel.cellData.accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contentShape(Rectangle()) // makes full area tappable
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged
            { _ in
                // On first detection, record the start time
                if pressStartTime == nil
                {
                    pressStartTime = Date()
                    isPointerDown = true
                    
                    // After durationToAction, if still pressed, mark as slow tap actioned
                    DispatchQueue.main.asyncAfter(deadline: .now() + cellModel.durationToAction)
                    {
                        if isPointerDown && !isSlowTapActioned
                        {
                            isSlowTapActioned = true
                            onSoloActioned?()
                            
                            // After additional durationToComplete, if still pressed, complete slow tap
                            DispatchQueue.main.asyncAfter(deadline: .now() + cellModel.durationToComplete)
                            {
                                if isPointerDown && isSlowTapActioned && !isSlowTapCompleted
                                {
                                    isSlowTapCompleted = true
                                    onSolo?()
                                }
                            }
                        }
                    }
                }
            }
            .onEnded
            { _ in
                isPointerDown = false
                
                // Decide action based on whether a slow tap was actioned
                if !isSlowTapActioned
                {
                    // Quick tap detected: toggle cell
                    onToggle?()
                }
                else if isSlowTapActioned && !isSlowTapCompleted
                {
                    // Slow tap was cancelled
                    onSoloCancelled?()
                }
                
                // Reset gesture state
                pressStartTime = nil
                isSlowTapActioned = false
                isSlowTapCompleted = false
            }
        )
        .aspectRatio(1.66, contentMode: .fit)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(CellBorder(
                color: cellModel.cellData.accentColor,
                progress: cellModel.borderProgress,
                isInverted: cellModel.borderInverted
            )
            .allowsHitTesting(false)
        )
        .overlay(OuterCellBorder(
                color: cellModel.cellData.accentColor,
                progress: cellModel.outerBorderProgress,
                isInverted: cellModel.outerBorderInverted
            )
            .allowsHitTesting(false)
        )
    }
}


struct CellBorder: View, Animatable
{
    // Style settings
    var lineWidth: CGFloat = 2
    var cornerRadius: CGFloat = 12
    var color: Color = .blue
    
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
    var color: Color = .blue
    
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



struct AudioCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack {
                AudioCell(
                    cellModel: AudioCellModel(
                        cellData: AudioCellData(audio: "test.mp3", label: "Preview", accentColor: .blue)
                    ),
                    onToggle: { print("Cell toggled!") },
                    onSolo: { print("Cell soloed!") }
                )
                
                AudioCell(
                    cellModel: AudioCellModel(
                        cellData: AudioCellData(audio: "test.mp3", label: "Preview", accentColor: .blue)
                    ),
                    onToggle: { print("Cell toggled!") },
                    onSolo: { print("Cell soloed!") }
                )
            }
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .padding()
            
            
            HStack {
                AudioCell(
                    cellModel: AudioCellModel(
                        cellData: AudioCellData(audio: "test.mp3", label: "Preview", accentColor: .blue)
                    ),
                    onToggle: { print("Cell toggled!") },
                    onSolo: { print("Cell soloed!") }
                )
                
                AudioCell(
                    cellModel: AudioCellModel(
                        cellData: AudioCellData(audio: "test.mp3", label: "Preview", accentColor: .blue)
                    ),
                    onToggle: { print("Cell toggled!") },
                    onSolo: { print("Cell soloed!") }
                )
            }
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .padding()
        }
    }
}
    

// Extension to create a Color from a hex string.
extension Color
{
    init(hex: String)
    {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count
        {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
