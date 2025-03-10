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

    init(cellData: AudioCellData)
    {
        self.cellData = cellData
        self.id = cellData.id
    }
    
    func toggle()
    {
        if isActive
        {
            AudioManager.shared.stopAudio(for: cellData.audio)
        }
        else
        {
            AudioManager.shared.playAudio(for: cellData.audio)
        }
        isActive.toggle()
    }
    
    func activate()
    {
        if !isActive
        {
            AudioManager.shared.playAudio(for: cellData.audio)
            isActive = true
        }
    }
    
    func deactivate()
    {
        if isActive
        {
            AudioManager.shared.stopAudio(for: cellData.audio)
            isActive = false
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
    func toggleCell(_ cell: AudioCellModel)
    {
        cell.toggle()
    }
    
    // Solos a given cell
    func soloCell(_ cell: AudioCellModel)
    {
        cell.activate() // Ensure this cell is active
        for other in cells where other.id != cell.id && other.isActive {
            other.deactivate()
        }
    }
}
