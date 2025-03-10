//
//  AudioManager.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 7/3/2025.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    // Store players keyed by their audio file name.
    var players: [String: AVAudioPlayer] = [:]
    // Store fade timers keyed by their audio file name.
    var fadeTimers: [String: Timer] = [:]
    
    
    // Play audio for a given file name.
    func playAudio(for audioFileName: String) {
        // If audio is already fading, cancel fade.
        if let player = players[audioFileName] {
                    // Cancel any ongoing fade.
                    fadeTimers[audioFileName]?.invalidate()
                    fadeTimers.removeValue(forKey: audioFileName)
                    // Start fade-in from current volume.
                    fade(player: player, for: audioFileName, toVolume: 1.0, duration: 2.0)
                    return
                }
        
        // Locate the file in the main bundle.
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
            print("Audio file \(audioFileName) not found!")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.0
            player.prepareToPlay()
            player.play()
            players[audioFileName] = player
            
            fade(player: player, for: audioFileName, toVolume: 1.0, duration: 2.0)
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    
    // Stop an audio file with a fade-out effect.
    func stopAudio(for audioFileName: String)
    {
        guard let player = players[audioFileName] else
        {
            print("No audio is playing for \(audioFileName)")
            return
        }
        
        fade(player: player ,for: audioFileName, toVolume: 0.0, duration: 2.0)
        {
            player.stop()
            self.players.removeValue(forKey: audioFileName)
        }
    }
    
    
    // The fade function now takes an extra parameter (for audioFileName) so we can manage the corresponding timer.
    private func fade(player: AVAudioPlayer, for audioFileName: String, toVolume targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil)
    {
        let steps = 50
        let stepDuration = duration / Double(steps)
        let volumeDelta = (targetVolume - player.volume) / Float(steps)
        var currentStep = 0
        
        // Cancel any existing fade timer for this file.
        fadeTimers[audioFileName]?.invalidate()
        
        let timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            if currentStep < steps {
                player.volume += volumeDelta
                currentStep += 1
            } else {
                timer.invalidate()
                self.fadeTimers.removeValue(forKey: audioFileName)
                completion?()
            }
        }
        fadeTimers[audioFileName] = timer
    }
}
