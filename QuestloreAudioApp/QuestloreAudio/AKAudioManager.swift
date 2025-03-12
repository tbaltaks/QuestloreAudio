//
//  AudioManager.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 7/3/2025.
//

import Foundation
import AVFoundation // For AVAudioFile reading
import QuartzCore // For CACurrentMediaTime
import AudioKit

// Wrap an AudioKit AudioPlayer along with its active fade timer
class AKAudioPlaybackHandler
{
    let player: AudioPlayer
    var fadeTimer: Timer?
    
    init(player: AudioPlayer)
    {
        self.player = player
    }
    
    deinit
    {
        fadeTimer?.invalidate()
    }
}

class AKAudioManager
{
    static let shared = AKAudioManager()
    
    // Fade durations (in seconds)
    let fadeInDuration: TimeInterval = 4.0
    let fadeOutDuration: TimeInterval = 4.0
    
    // AudioKit engine and a mixer to combine multiple players.
    let engine = AudioEngine()
    let mixer = Mixer()
    
    // Dictionaries mapping an audio file’s name to its handler and data
    var players: [String: AKAudioPlaybackHandler] = [:]
    var fftTaps: [String: FFTTap] = [:]
    var fftSampleData: [String: [Float]] = [:]
    
    private init()
    {
        engine.output = mixer
        
        do {
            try engine.start()
        }
        catch {
            print("Error starting AudioKit engine: \(error)")
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
            
            if t >= 1.0
            {
                timer.invalidate()
                handler.fadeTimer = nil
                handler.player.volume = targetVolume
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
    // Plays an audio file (by name) with a fade-in effect
    func playAudio(for audioFileName: String)
    {
        // If we already have a player for this file, cancel any fade-out and fade in...
        if let handler = players[audioFileName]
        {
            handler.fadeTimer?.invalidate()
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
            startFFTAnalysis(for: audioFileName)
            return
        }
        
        //...otherwise:

        // Locate the file in the main bundle
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
            print("Audio file \(audioFileName) not found!")
            return
        }
        
        do {
            // Use AVAudioFile to read the file
            let file = try AVAudioFile(forReading: url)
            guard let player = AudioPlayer(file: file) else {
                print("Error: Could not create AudioPlayer for file \(audioFileName)")
                return
            }
            
            player.volume = 0.0
            player.isLooping = true
            
            // Add player to Mixer and start playback
            mixer.addInput(player)
            player.play()
            
            let handler = AKAudioPlaybackHandler(player: player)
            players[audioFileName] = handler
            
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
            startFFTAnalysis(for: audioFileName)
        }
        catch {
            print("Error playing audio: \(error)")
        }
    }
    
    // Stops an audio file (by name) with a fade-out effect
    func stopAudio(for audioFileName: String)
    {
        guard let handler = players[audioFileName] else {
            print("No audio is playing for \(audioFileName)")
            return
        }
        
        // Cancel any ongoing fade before starting the fade-out.
        handler.fadeTimer?.invalidate()
        
        fade(handler: handler, toVolume: 0.0, duration: fadeOutDuration)
        {
            handler.player.stop()
            
            self.stopFFTAnalysis(for: audioFileName)
            
            self.mixer.removeInput(handler.player)
            self.players.removeValue(forKey: audioFileName)
        }
    }
    
    
    // MARK: - Audio Analysis
    func startFFTAnalysis(for audioFileName: String)
    {
        guard let handler = players[audioFileName] else {
            print("No player found for \(audioFileName)")
            return
        }
        
        // Cancel any existing tap for this file
        fftTaps[audioFileName]?.stop()
        
        let tap = FFTTap(handler.player, callbackQueue: DispatchQueue.main)
        { fftData in
            self.fftSampleData[audioFileName] = fftData
            
            self.fftSampleData[audioFileName]?.forEach
            { fftSample in
                print(fftSample)
            }
        }
        
        tap.start()
        fftTaps[audioFileName] = tap
    }

    func stopFFTAnalysis(for audioFileName: String)
    {
        fftTaps[audioFileName]?.stop()
        fftTaps.removeValue(forKey: audioFileName)
        fftSampleData.removeValue(forKey: audioFileName)
    }
}
