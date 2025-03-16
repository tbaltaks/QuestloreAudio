////
////  AudioManager.swift
////  QuestloreAudio
////
////  Created by Tom Baltaks on 7/3/2025.
////
//
//import Foundation
//import AVFoundation
//import Accelerate
//import QuartzCore // For CACurrentMediaTime
//import Combine
//
//// Wrap an AVAudioPlayer along with its active fade timer.
//class AudioPlaybackHandler
//{
//    let player: AVAudioPlayer
//    var fadeTimer: Timer?
//    var sampleDataScaler: Float = 0.0
//
//    init(player: AVAudioPlayer) {
//        self.player = player
//    }
//
//    deinit {
//        fadeTimer?.invalidate()
//    }
//}
//
//
//class AudioManager: ObservableObject
//{
//    static let shared = AudioManager()
//    private var fftProcessingCancellable: AnyCancellable?
//    let numberOfStems: Int = 16
//
//    // Fade durations (in seconds)
//    let fadeInDuration: TimeInterval = 4.0
//    let fadeOutDuration: TimeInterval = 4.0
//
//    // AudioKit engine and a mixer to combine multiple players.
//    let engine = AVAudioEngine()
//
//    // Dictionaries mapping an audio file’s name to its handler and data
//    var handlers: [UUID: AudioPlaybackHandler] = [:]
//    var preloadedBuffers: [UUID: AVAudioPCMBuffer] = [:]
////    var fftTaps: [UUID: FFTTap] = [:]
//    var fftSampleData: [UUID: [Float]] = [:]
//    @Published var bandedSampleData: [UUID: [Float]] = [:]
//
//    private init() {}
//
//
//    // MARK: - Fade Logic
//    // Fades the player's volume to a target value over the given duration using a smooth ease
//    private func fade(handler: AudioPlaybackHandler, toVolume targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
//        let startVolume = handler.player.volume
//        let startTime = CACurrentMediaTime()
//
//        // Cancel any existing fade.
//        handler.fadeTimer?.invalidate()
//
//        // Initiate timer (with interval 0.01s)
//        handler.fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
//            let elapsed = CACurrentMediaTime() - startTime
//            let t = Float(min(elapsed / duration, 1.0))
//            let easedT = self.missKCurve(t, isFadingIn: targetVolume != 0)
//            let newVolume = startVolume + (targetVolume - startVolume) * easedT
//            handler.player.volume = newVolume
//            handler.sampleDataScaler = newVolume
//
//            if t >= 1.0 {
//                timer.invalidate()
//                handler.fadeTimer = nil
//                handler.player.volume = targetVolume
//                handler.sampleDataScaler = targetVolume
//                completion?()
//            }
//        }
//    }
//
//    // Easing helper function
//    private func missKCurve(_ t: Float, isFadingIn: Bool) -> Float
//    {
//        var newT: Float
//
//        if isFadingIn {
//            newT = pow(t, 3.6) * (2.8 - 1.8 * pow(t, 2))
//        } else {
//            newT = pow(t, 2.5) * (3 - 2 * pow(t, 1.25))
//        }
//
//        return newT
//    }
//
//
//    // MARK: - Audio Control
//    // Plays an audio file (by cell) with a fade-in effect
//    func playAudio(for cell: AudioCellData) {
//        // If we already have a player for this file, cancel any fade-out and fade in.
//        if let handler = handlers[cell.id] {
//            handler.fadeTimer?.invalidate()
//            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
//            return
//        }
//
//        // Locate the file in the main bundle.
//        guard let url = Bundle.main.url(forResource: cell.audio, withExtension: nil) else {
//            print("Audio file \(cell.audio) not found!")
//            return
//        }
//
//        do {
//            let player = try AVAudioPlayer(contentsOf: url)
//            player.volume = 0.0
//            player.numberOfLoops = -1 // Loop indefinitely
//            player.prepareToPlay()
//            player.play()
//
//            let handler = AudioPlaybackHandler(player: player)
//            handlers[cell.id] = handler
//
//            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
//        } catch {
//            print("Error playing audio: \(error)")
//        }
//    }
//
//    // Stops an audio file (by name) with a fade-out effect.
//    func stopAudio(for cell: AudioCellData) {
//        guard let handler = handlers[cell.id] else {
//            print("No audio is playing for \(cell.audio)")
//            return
//        }
//
//        // Cancel any ongoing fade before starting the fade-out.
//        handler.fadeTimer?.invalidate()
//        fade(handler: handler, toVolume: 0.0, duration: fadeOutDuration) {
//            handler.player.stop()
//            self.handlers.removeValue(forKey: cell.id)
//        }
//    }
//}
