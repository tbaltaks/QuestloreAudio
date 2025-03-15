//
//  CellModel.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 10/3/2025.
//

import SwiftUI

struct AudioCellData: Identifiable
{
    let id = UUID()
    let audio: String
    let label: String
    let accentColor: Color
}

class AudioCellModel: ObservableObject, Identifiable
{
    let id: UUID
    let cellData: AudioCellData
    @Published var isActive: Bool = false
    
    @Published var durationToAction: TimeInterval = 0.25
    @Published var durationToComplete: TimeInterval = 1.0
    
    @Published var borderProgress: CGFloat = 0.0
    @Published var borderInverted: Bool = false
    
    @Published var outerBorderProgress: CGFloat = 0.0
    @Published var outerBorderInverted: Bool = false

    init(cellData: AudioCellData)
    {
        self.cellData = cellData
        self.id = cellData.id
    }
    
    func Toggle()
    {
        if isActive
        {
            Deactivate()
            AnimateBorder(startFill: 0.0, targetFill: -1.0, isInverted: true)
        }
        else
        {
            Activate()
            AnimateBorder(startFill: 0.0, targetFill: 1.0)
        }
    }
    
    func Activate()
    {
        if isActive { return }
        
        isActive = true
        AKAudioManager.shared.playAudio(for: cellData)
    }
    
    func Deactivate()
    {
        if !isActive { return }
        
        isActive = false
        AKAudioManager.shared.stopAudio(for: cellData)
    }
    
    
    func AnimateBorder(startFill: CGFloat = 69.0, targetFill: CGFloat = 1.0, duration: Double = 0.28, isInverted: Bool = false)
    {
        withTransaction(Transaction(animation: nil))
        {
            if (!isActive && borderProgress == -1.0)
            {
                borderProgress = 0.0
            }
            else
            {
                borderProgress = startFill == 69.0 ? borderProgress : startFill
            }
            
            borderInverted = isInverted
        }
        
        withAnimation(.easeInOut(duration: duration))
        {
            borderProgress = targetFill
        }
    }
    
    func AnimateOuterBorder(startFill: CGFloat = 69.0, targetFill: CGFloat, duration: Double, isInverted: Bool = false)
    {
        withTransaction(Transaction(animation: nil))
        {
            if (outerBorderProgress == -1.0)
            {
                outerBorderProgress = 0.0
            }
            else
            {
                outerBorderProgress = startFill == 69.0 ? outerBorderProgress : startFill
            }
            
            outerBorderInverted = isInverted
        }
        
        withAnimation(.easeInOut(duration: duration))
        {
            outerBorderProgress = targetFill
        }
    }
}


class AudioGridModel: ObservableObject
{
    @Published var cells: [AudioCellModel]
    
    init(cellDataArray: [AudioCellData])
    {
        self.cells = cellDataArray.map { AudioCellModel(cellData: $0) }
        AKAudioManager.shared.preloadAudio(for: cellDataArray)
    }
    
    func ToggleCell(_ cell: AudioCellModel)
    {
        cell.Toggle()
    }
    
    func SoloCellActioned(_ cell: AudioCellModel)
    {
        if (cell.isActive) {
            cell.AnimateOuterBorder(targetFill: 1.0, duration: cell.durationToComplete)
        } else {
            cell.AnimateBorder(duration: cell.durationToComplete)
        }
        
        for other in cells where other.id != cell.id && other.isActive
        {
            other.AnimateBorder(startFill: 1.0, targetFill: 0.0, duration: other.durationToComplete)
        }
    }
    
    func SoloCellCancelled(_ cell: AudioCellModel)
    {
        if (cell.isActive) {
            cell.AnimateOuterBorder(targetFill: 0.0, duration: 0.28)
        } else {
            cell.AnimateBorder(startFill: cell.borderProgress, targetFill: 0.0)
        }
        
        for other in cells where other.id != cell.id && other.isActive
        {
            other.AnimateBorder(targetFill: 1.0)
        }
    }
    
    func SoloCell(_ cell: AudioCellModel)
    {
        cell.Activate()
        if (cell.outerBorderProgress > 0) { cell.AnimateOuterBorder(startFill: 0.0, targetFill: -1.0, duration: 0.24, isInverted: true) }
        
        for other in cells where other.id != cell.id && other.isActive
        {
            other.Deactivate()
        }
    }
}
