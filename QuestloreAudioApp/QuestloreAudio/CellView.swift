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
    
    // Computed property for the background color based on the color scheme
    var backgroundColor: Color
    {
        colorScheme == .dark ? Color(hex: "222222") : Color.white
    }
    
    var body: some View
    {
        ZStack
        {
            VStack (spacing: 0)
            {
                AudioVisualiser(cellModel: cellModel)
                ScaledText(cellModel: cellModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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


struct AudioVisualiser: View
{
    var cellModel: AudioCellModel
    
    @State var audioData = [Float](repeating: 0, count: 16)
    
    var body: some View
    {
        GeometryReader
        { geometry in
            let minStemHeight = geometry.size.height * 0.068
            let maxStemHeight = geometry.size.height * 0.82
            
            HStack (spacing: geometry.size.width * 0.034)
            {
                Spacer(minLength: 0)
                
                ForEach (0..<16, id: \.self)
                { index in
                    let computedStemHeight = min(minStemHeight + (maxStemHeight - minStemHeight) * CGFloat(audioData[index]), maxStemHeight)
                    
                    VisualiserStem(
                        color: cellModel.cellData.accentColor,
                        minHeight: minStemHeight,
                        targetHeight: computedStemHeight
                    )
                }
                
                Spacer(minLength: 0)
            }
            .frame(minHeight: geometry.size.height * 1.1)
            .onReceive(AudioManager.shared.$bandedSampleData) { newData in
                if let updatedBands = newData[cellModel.cellData.id] {
                    audioData = updatedBands
                }
            }
        }
    }
}


struct VisualiserStem: View
{
    var color: Color = .blue
    var minHeight: CGFloat
    var targetHeight: CGFloat = 0
    
    @State private var height: CGFloat = 0
    @State private var previousTargetHeight: CGFloat = 0
    
    var body: some View
    {
        VStack
        {
            Spacer(minLength: 0)
            
            RoundedRectangle(cornerRadius: .infinity)
                .fill(color)
                .frame(minHeight: minHeight)
                .frame(width: minHeight, height: height)
                .onAppear {
                    height = targetHeight
                    previousTargetHeight = targetHeight
                }
                .onChange(of: targetHeight) { newHeight in
                    let animation = newHeight > previousTargetHeight
                        ? Animation.easeInOut(duration: 0.2)
                        : Animation.easeInOut(duration: 0.4)
                    
                    previousTargetHeight = newHeight
                    
                    withAnimation(animation) {
                        height = newHeight
                    }
                }
        }
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
