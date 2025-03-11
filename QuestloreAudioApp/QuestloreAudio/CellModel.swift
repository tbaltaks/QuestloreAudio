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
    @Published var borderInverted: Bool = true

    init(cellData: AudioCellData)
    {
        self.cellData = cellData
        self.id = cellData.id
    }
    
    func Toggle()
    {
        isActive.toggle()
        
        if isActive
        {
            AudioManager.shared.stopAudio(for: cellData.audio)
        }
        else
        {
            AudioManager.shared.playAudio(for: cellData.audio)
        }
        
        AnimateBorder(startFill: 0.0, isInverted: !isActive)
    }
    
    func Activate()
    {
        if isActive { return }
        
        isActive = true
        AudioManager.shared.playAudio(for: cellData.audio)
    }
    
    func Deactivate()
    {
        if !isActive { return }
        
        isActive = false
        AudioManager.shared.stopAudio(for: cellData.audio)
    }
    
    
    func AnimateBorder(startFill: CGFloat = 10.0, targetFill: CGFloat = 1.0, duration: Double = 0.28, isInverted: Bool = false)
    {
        withTransaction(Transaction(animation: nil))
        {
            borderProgress = startFill == 10.0 ? borderProgress : startFill
            borderInverted = isInverted
        }
        
        withAnimation(.easeInOut(duration: duration))
        {
            borderProgress = targetFill
        }
    }
}

class AudioGridModel: ObservableObject
{
    @Published var cells: [AudioCellModel]
    
    init(cellDataArray: [AudioCellData])
    {
        self.cells = cellDataArray.map { AudioCellModel(cellData: $0) }
    }
    
    // Toggles a given cell
    func ToggleCell(_ cell: AudioCellModel)
    {
        cell.Toggle()
    }
    
    func SoloCellActioned(_ cell: AudioCellModel)
    {
        cell.AnimateBorder(duration: cell.durationToComplete)
        
        for other in cells where other.id != cell.id && other.isActive
        {
            cell.AnimateBorder(startFill: 1.0, targetFill: 0.0, duration: cell.durationToComplete)
        }
    }
    
    func SoloCellCancelled(_ cell: AudioCellModel)
    {
        cell.AnimateBorder(targetFill: 0.0)
        
        for other in cells where other.id != cell.id && other.isActive
        {
            cell.AnimateBorder(targetFill: 1.0)
        }
    }
    
    // Solos a given cell
    func SoloCell(_ cell: AudioCellModel)
    {
        cell.Activate() // Ensure this cell is active
        
        for other in cells where other.id != cell.id && other.isActive
        {
            other.Deactivate()
        }
    }
}
