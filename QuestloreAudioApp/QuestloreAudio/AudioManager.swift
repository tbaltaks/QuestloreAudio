//
//  AudioManager.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 7/3/2025.
//

import AVFoundation
import Foundation
import QuartzCore // For CACurrentMediaTime

// Wrap an AVAudioPlayer along with its active fade timer.
class AudioPlaybackHandler {
    let player: AVAudioPlayer
    var fadeTimer: Timer?
    
    init(player: AVAudioPlayer) {
        self.player = player
    }
    
    deinit {
        fadeTimer?.invalidate()
    }
}

class AudioManager {
    static let shared = AudioManager()
    
    // Fade duration in seconds
    let fadeDuration: TimeInterval = 4.0
    
    // Dictionary mapping an audio file's name to its playback handler.
    var players: [String: AudioPlaybackHandler] = [:]
    
    private init() {}
    
    // MARK: - Fade Logic
    // Fades the player's volume to a target value over the given duration using a smooth ease.
    private func fade(handler: AudioPlaybackHandler, toVolume targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let startVolume = handler.player.volume
        let startTime = CACurrentMediaTime()
        
        // Cancel any existing fade.
        handler.fadeTimer?.invalidate()
        
        // Initiate timer (with interval 0.01s)
        handler.fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime
            let t = Float(min(elapsed / duration, 1.0))
            let easedT = self.missKCurve(t, isFadingIn: targetVolume != 0)
            let newVolume = startVolume + (targetVolume - startVolume) * easedT
            handler.player.volume = newVolume
            
            if t >= 1.0 {
                timer.invalidate()
                handler.fadeTimer = nil
                handler.player.volume = targetVolume
                completion?()
            }
        }
    }
    
    // MARK: Easing helper functions
    
    private func missKCurve(_ t: Float, isFadingIn: Bool) -> Float
    {
        var newT: Float

        if isFadingIn
        {
            newT = pow(t, 3.6) * (2.8 - 1.8 * pow(t, 2))
        }
        else
        {
//            newT = -(pow(abs(t - 1), 3.6)) * (2.8 - 1.8 * pow(abs(t - 1), 2)) + 1
            newT = pow(t, 2.5) * (3 - 2 * pow(t, 1.25))
        }

        return newT
    }
    
    private func fadeInCurve(_ t: Float) -> Float {
        return 2.1 * t * t - 1.1 * t
    }
    
    private func easeInOutQuart(_ t: Float) -> Float {
        return t < 0.5 ? 8 * t * t * t * t : 1 - pow(-2 * t + 2, 4) / 2
    }
    
    private func easeInOutQuad(_ t: Float) -> Float {
        return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    private func smoothStep(_ t: Float) -> Float {
        return t * t * (3 - 2 * t)
    }
    
    // MARK: - Audio Control
    // Plays an audio file (by name) with a fade-in effect.
    func playAudio(for audioFileName: String) {
        // If we already have a player for this file, cancel any fade-out and fade in.
        if let handler = players[audioFileName] {
            handler.fadeTimer?.invalidate()
            fade(handler: handler, toVolume: 1.0, duration: fadeDuration)
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
            // Loop indefinitely.
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
            
            let handler = AudioPlaybackHandler(player: player)
            players[audioFileName] = handler
            
            fade(handler: handler, toVolume: 1.0, duration: fadeDuration)
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    // Stops an audio file (by name) with a fade-out effect.
    func stopAudio(for audioFileName: String) {
        guard let handler = players[audioFileName] else {
            print("No audio is playing for \(audioFileName)")
            return
        }
        
        // Cancel any ongoing fade before starting the fade-out.
        handler.fadeTimer?.invalidate()
        fade(handler: handler, toVolume: 0.0, duration: fadeDuration) {
            handler.player.stop()
            self.players.removeValue(forKey: audioFileName)
        }
    }
}
