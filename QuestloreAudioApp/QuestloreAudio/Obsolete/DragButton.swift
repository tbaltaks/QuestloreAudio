//
//  DragButton.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 22/3/2025.
//

import SwiftUI

struct CellButton<Label: View>: View
{
    init(
        durationToAction: TimeInterval = 0.0,
        durationToComplete: TimeInterval = 1.0,
        startAction: @escaping () -> Void = {},
        tapAction: @escaping () -> Void = {},
        slowTapStartAction: @escaping () -> Void = {},
        slowTapCancelAction: @escaping () -> Void = {},
        slowTapCompleteAction: @escaping () -> Void = {},
        endAction: @escaping () -> Void = {},
        label: @escaping () -> Label
    ) {
        self.durationToAction = durationToAction
        self.durationToComplete = durationToComplete
        self.startAction = startAction
        self.tapAction = tapAction
        self.slowTapStartAction = slowTapStartAction
        self.slowTapCancelAction = slowTapCancelAction
        self.slowTapCompleteAction = slowTapCompleteAction
        self.endAction = endAction
        self.label = label
        self.style = CellButtonStyle()
    }
    
    var durationToAction: TimeInterval
    var durationToComplete: TimeInterval
    var startAction: () -> Void
    var tapAction: () -> Void
    var slowTapStartAction: () -> Void
    var slowTapCancelAction: () -> Void
    var slowTapCompleteAction: () -> Void
    var endAction: () -> Void
    var label: () -> Label
    var style: CellButtonStyle
    
    @State private var isPointerDown = false
    @State private var pressStartTime: Date?
    @State private var isSlowTapActioned = false
    @State private var isSlowTapCompleted = false
    @State private var isValidGesture = true
    @State private var bounds: CGRect = .zero
    
    var body: some View
    {
        Button(action: endAction, label: label)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { bounds = geo.frame(in: .local) }
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: bounds.width * 0.1))
            .buttonStyle(style)
            .onTapGesture {
                if !isSlowTapActioned {
                    tapAction()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChange(value.location)
                    }
                    .onEnded { value in
                        handleDragEnd(location: value.location)
                    }
            )
    }
    
    private func handleDragChange(_ location: CGPoint)
    {
        let isInside = bounds.contains(location)
        
        guard isInside else {
            cancelGesture()
            return
        }
        
        if pressStartTime == nil {
            startNewGesture()
        }
    }
    
    private func handleDragEnd(location: CGPoint)
    {
        isPointerDown = false
        let isInside = bounds.contains(location)
        
        if isInside && isSlowTapActioned && !isSlowTapCompleted {
            slowTapCancelAction()
        }
        
        resetGestureState()
    }
    
    private func startNewGesture()
    {
        pressStartTime = Date()
        isPointerDown = true
        isValidGesture = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + durationToAction) { [pressStartTime] in
            guard isValidGesture, self.pressStartTime == pressStartTime else { return }
            isSlowTapActioned = true
            slowTapStartAction()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + durationToComplete) { [pressStartTime] in
                guard isValidGesture, self.pressStartTime == pressStartTime else { return }
                isSlowTapCompleted = true
                slowTapCompleteAction()
            }
        }
    }
    
    private func cancelGesture()
    {
        isValidGesture = false
        isPointerDown = false
        if isSlowTapActioned && !isSlowTapCompleted {
            slowTapCancelAction()
        }
        resetGestureState()
    }
    
    private func resetGestureState()
    {
        pressStartTime = nil
        isSlowTapActioned = false
        isSlowTapCompleted = false
    }
}


struct CellButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}
