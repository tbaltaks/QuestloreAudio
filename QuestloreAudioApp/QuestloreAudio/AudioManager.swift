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
    
    var players: [String: AVAudioPlayer] = [:]
    
    // Play audio for a given file name.
    func playAudio(for audioFileName: String) {
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
            
            // Fade in effect (using a simple timer-based fade)
            fade(player: player, toVolume: 1.0, duration: 2.0)
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
        
        fade(player: player, toVolume: 0.0, duration: 2.0)
        {
            player.stop()
            self.players.removeValue(forKey: audioFileName)
        }
    }
    
    // Simple fade function using Timer.
    private func fade(player: AVAudioPlayer, toVolume targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil)
    {
        let steps = 50
        let stepDuration = duration / Double(steps)
        let volumeDelta = (targetVolume - player.volume) / Float(steps)
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            if currentStep < steps {
                player.volume += volumeDelta
                currentStep += 1
            } else {
                timer.invalidate()
                completion?()
            }
        }
    }
}
