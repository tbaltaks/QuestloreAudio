//
//  AudioManager.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 7/3/2025.
//

import Foundation
import AVFoundation
import QuartzCore // For CACurrentMediaTime
import AudioKit // For FFT analysis
import Combine

// Wrap an AudioKit AudioPlayer along with its active fade timer
class AKAudioPlaybackHandler
{
    let player: AudioPlayer
    var fadeTimer: Timer?
    var sampleDataScaler: Float = 0.0
    
    init(player: AudioPlayer) {
        self.player = player
    }
    
    deinit {
        fadeTimer?.invalidate()
    }
}

class AKAudioManager: ObservableObject
{
    static let shared = AKAudioManager()
    private var fftProcessingCancellable: AnyCancellable?
    let numberOfStems: Int = 16
    
    // Fade durations (in seconds)
    let fadeInDuration: TimeInterval = 4.0
    let fadeOutDuration: TimeInterval = 4.0
    
    // AudioKit engine and a mixer to combine multiple players.
    let engine = AudioEngine()
    let globalMixer = Mixer()
    
    // Dictionaries mapping an audio file’s name to its handler and data
    var handlers: [UUID: AKAudioPlaybackHandler] = [:]
    var fftTaps: [UUID: FFTTap] = [:]
    var fftSampleData: [UUID: [Float]] = [:]
    @Published var bandedSampleData: [UUID: [Float]] = [:]
    
    private init()
    {
        engine.output = globalMixer
        
        do {
            try engine.start()
        }
        catch {
            print("Error starting AudioKit engine: \(error)")
        }
        
        fftProcessingCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Process FFT data for each active audio file (using handlers keys)
                for cellID in self.fftSampleData.keys {
                    self.processFFTData(for: cellID)
                }
            }
    }
    
    
    // MARK: - Fade Logic
    // Fades the player's volume to a target value over the given duration using a smooth ease
    private func fade(handler: AKAudioPlaybackHandler, toVolume targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil)
    {
        let startVolume = handler.player.volume
        let startTime = CACurrentMediaTime()
        
        // Cancel any existing fade
        handler.fadeTimer?.invalidate()
        
        handler.fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true)
        { timer in
            let elapsed = CACurrentMediaTime() - startTime
            let t = Float(min(elapsed / duration, 1.0))
            let easedT = self.easeInOutKe(t, isFadingIn: targetVolume != 0)
            let newVolume = startVolume + (targetVolume - startVolume) * easedT
            handler.player.volume = newVolume
            handler.sampleDataScaler = newVolume
            
            if t >= 1.0
            {
                timer.invalidate()
                handler.fadeTimer = nil
                handler.player.volume = targetVolume
                handler.sampleDataScaler = targetVolume
                completion?()
            }
        }
    }
    
    // Easing function
    private func easeInOutKe(_ t: Float, isFadingIn: Bool) -> Float
    {
        var newT: Float

        if isFadingIn {
            newT = pow(t, 3.6) * (2.8 - 1.8 * pow(t, 2))
        } else {
            newT = pow(t, 2.5) * (3 - 2 * pow(t, 1.25))
        }

        return newT
    }
    
    
    // MARK: - Audio Control
    // Plays an audio file (by cell) with a fade-in effect
    func playAudio(for cell: AudioCellData)
    {
        // If we already have a player for this file, cancel any fade-out and fade in
        if let handler = handlers[cell.id] {
            handler.fadeTimer?.invalidate()
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
            return
        }
        
        // Locate the file in the main bundle
        guard let url = Bundle.main.url(forResource: cell.audio, withExtension: nil) else {
            print("Audio file \(cell.audio) not found!")
            return
        }
        do {
            // Use AVAudioFile to read the file
            let file = try AVAudioFile(forReading: url)

            guard let player = AudioPlayer(file: file) else {
                print("Could not load buffer for \(cell.audio)")
                return
            }
            
            player.volume = 0.0
            player.isLooping = true

            let handler = AKAudioPlaybackHandler(player: player)
            handlers[cell.id] = handler
            globalMixer.addInput(player)

            handler.player.play()
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
            startFFTAnalysis(for: cell.id)
        }
        catch {
            print("Error playing audio: \(error)")
        }
    }
    
    // Stops an audio file (by name) with a fade-out effect
    func stopAudio(for cell: AudioCellData)
    {
        guard let handler = handlers[cell.id] else {
            print("Player for \(cell.id) not found!")
            return
        }
        
        // Cancel any ongoing fade before starting the fade-out.
        handler.fadeTimer?.invalidate()
        
        fade(handler: handler, toVolume: 0.0, duration: fadeOutDuration)
        {
            self.stopFFTAnalysis(for: cell.id)
            
            handler.player.stop()
            self.globalMixer.removeInput(handler.player)
            self.handlers.removeValue(forKey: cell.id)
        }
    }
    
    
    // MARK: - Audio Analysis
    func startFFTAnalysis(for cellID: UUID)
    {
        guard let handler = handlers[cellID] else {
            print("No player found for \(cellID)")
            return
        }
        
        if fftTaps[cellID] == nil
        {
            let tap = FFTTap(handler.player, bufferSize: 1024, fftValidBinCount: .fiveHundredAndTwelve, callbackQueue: DispatchQueue.main)
            { fftData in
                self.fftSampleData[cellID] = fftData
            }
            
            tap.start()
            fftTaps[cellID] = tap
        }
    }

    func stopFFTAnalysis(for cellID: UUID)
    {
        bandedSampleData[cellID] = [Float](repeating: 0.0, count: numberOfStems)
        
        fftTaps[cellID]?.stop()
        fftTaps.removeValue(forKey: cellID)
        fftSampleData.removeValue(forKey: cellID)
    }
    
    func processFFTData(for cellID: UUID)
    {
        var accruedSampleData = [Float](repeating: 0.0, count: numberOfStems)
        
        var sampleIndex: Int = 0
        var rawSampleCount: Float = 1.0
        
        for i in 0..<numberOfStems
        {
            var sampleSum: Float = 0.0
            let roundedSampleCount = Int(round(rawSampleCount))
            
            for _ in 0..<roundedSampleCount
            {
                guard let fftSamples = fftSampleData[cellID], sampleIndex < fftSamples.count else { break }
                sampleSum += fftSamples[sampleIndex] * Float(sampleIndex + 1)
                sampleIndex += 1
            }
            
            let average = sampleSum / Float(sampleIndex + 1)
            var bandValue = average * (handlers[cellID]?.sampleDataScaler ?? 0.0) * 10
            if bandValue.isNaN {
                bandValue = 0
            }
            
            accruedSampleData[i] = bandValue
            rawSampleCount *= 1.39366
            
            print("Stem \(i + 1) for \(cellID): \(accruedSampleData[i])")
        }
        print("----------------------------------------------------------------------")
        
        bandedSampleData[cellID] = accruedSampleData
    }
}
