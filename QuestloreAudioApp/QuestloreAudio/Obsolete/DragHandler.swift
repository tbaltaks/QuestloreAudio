//
//  DragButton.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 22/3/2025.
//

import SwiftUI

struct DragHandler<Content: View>: View
{
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let durationToAction: TimeInterval
    let durationToComplete: TimeInterval
    let onToggle: () -> Void
    let onSoloActioned: () -> Void
    let onSoloCancelled: () -> Void
    let onSolo: () -> Void
    let content: () -> Content
    
    @State private var isPointerDown = false
    @State private var pressStartTime: Date?
    @State private var isSlowTapActioned = false
    @State private var isSlowTapCompleted = false
    @State private var isValidGesture = true
    
    var body: some View
    {
        content()
            .contentShape(RoundedRectangle(cornerRadius: cellWidth * 0.1))
            .onTapGesture { onToggle() }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChange(value.location)
                    }
                    .onEnded { value in
                        handleDragEnd(location: value.location)
                    }
            )
            .scaleEffect(isPointerDown ? 0.96 : 1)
    }
    
    private func handleDragChange(_ location: CGPoint)
    {
        let isInside = isLocationInsideBounds(location)
        
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
        let isInside = isLocationInsideBounds(location)
        
        if isInside {
            if !isSlowTapActioned {
                onToggle()
            } else if isSlowTapActioned && !isSlowTapCompleted {
                onSoloCancelled()
            }
        }
        
        resetGestureState()
    }
    
    private func isLocationInsideBounds(_ location: CGPoint) -> Bool {
        location.x >= 0 && location.x <= cellWidth &&
        location.y >= 0 && location.y <= cellHeight
    }
    
    private func startNewGesture()
    {
        pressStartTime = Date()
        isPointerDown = true
        isValidGesture = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + durationToAction) { [pressStartTime] in
            guard isValidGesture, self.pressStartTime == pressStartTime else { return }
            isSlowTapActioned = true
            onSoloActioned()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + durationToComplete) { [pressStartTime] in
                guard isValidGesture, self.pressStartTime == pressStartTime else { return }
                isSlowTapCompleted = true
                onSolo()
            }
        }
    }
    
    private func cancelGesture()
    {
        isValidGesture = false
        isPointerDown = false
        if isSlowTapActioned && !isSlowTapCompleted {
            onSoloCancelled()
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
