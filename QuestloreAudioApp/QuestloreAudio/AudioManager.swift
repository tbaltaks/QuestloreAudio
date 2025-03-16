//
//  AudioManager.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 7/3/2025.
//
import Foundation
import AVFoundation   // For AVAudioFile, AVAudioEngine, etc.
import QuartzCore     // For CACurrentMediaTime
import Combine
import Accelerate    // For FFT processing

// Wrap an AVAudioPlayerNode along with its active fade timer.
class AudioPlaybackHandler {
    let playerNode: AVAudioPlayerNode
    var fadeTimer: Timer?
    var sampleDataScaler: Float = 0.0

    init(playerNode: AVAudioPlayerNode) {
        self.playerNode = playerNode
    }

    deinit {
        fadeTimer?.invalidate()
    }
}


class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var fftProcessingCancellable: AnyCancellable?
    let numberOfStems: Int = 16

    // Fade durations (in seconds)
    let fadeInDuration: TimeInterval = 4.0
    let fadeOutDuration: TimeInterval = 4.0

    // AVAudioEngine and a global mixer.
    let engine = AVAudioEngine()
    var globalMixer = AVAudioMixerNode()

    // Dictionaries mapping a cell's UUID to its playback handler and FFT data.
    var handlers: [UUID: AudioPlaybackHandler] = [:]
    var preloadedBuffers: [UUID: AVAudioPCMBuffer] = [:]
    @Published var bandedSampleData: [UUID: [Float]] = [:]

    // We'll also keep raw FFT sample data per cell (for debugging or further processing).
    var fftSampleData: [UUID: [Float]] = [:]

    private init()
    {
//        engine.attach(globalMixer)
//        engine.connect(globalMixer, to: engine.mainMixerNode, format: nil)
//
//        do {
//            try engine.start()
//        } catch {
//            print("Error starting AVAudioEngine: \(error)")
//        }
//
//        // Global FFT processing using Combine Timer – update at 20 Hz.
//        fftProcessingCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                // Process FFT for each cell that currently has FFT sample data.
//                for cellID in self.fftSampleData.keys {
//                    self.processFFTData(for: cellID)
//                }
//            }
    }

    // MARK: - Fade Logic
    // Fades the player's volume (via playerNode's output volume) using a Timer.
    private func fade(handler: AudioPlaybackHandler, toVolume targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let startVolume = handler.playerNode.volume
        let startTime = CACurrentMediaTime()

        handler.fadeTimer?.invalidate()

        handler.fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime
            let t = Float(min(elapsed / duration, 1.0))
            let easedT = self.easeInOutKe(t, isFadingIn: targetVolume != 0)
            let newVolume = startVolume + (targetVolume - startVolume) * easedT
            handler.playerNode.volume = newVolume
            handler.sampleDataScaler = newVolume

            if t >= 1.0 {
                timer.invalidate()
                handler.fadeTimer = nil
                handler.playerNode.volume = targetVolume
                handler.sampleDataScaler = targetVolume
                completion?()
            }
        }
    }

    private func easeInOutKe(_ t: Float, isFadingIn: Bool) -> Float {
        if isFadingIn {
            return pow(t, 3.6) * (2.8 - 1.8 * pow(t, 2))
        } else {
            return pow(t, 2.5) * (3 - 2 * pow(t, 1.25))
        }
    }

    // MARK: - Audio Control
    // Plays an audio file (by cell) with a fade-in effect using AVAudioPlayerNode.
    func playAudio(for cell: AudioCellData) {
        // If we already have a player for this cell, reuse it.
        if let handler = handlers[cell.id] {
            handler.fadeTimer?.invalidate()
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
            startFFTAnalysis(for: cell.id)
            return
        }

        // Locate the file in the main bundle.
        guard let url = Bundle.main.url(forResource: cell.audio, withExtension: nil) else {
            print("Audio file \(cell.audio) not found!")
            return
        }

        do {
            // Read the file.
            let file = try AVAudioFile(forReading: url)

            // Use a preloaded buffer if available; otherwise, load it now.
            let buffer: AVAudioPCMBuffer
            if let preBuffer = preloadedBuffers[cell.id] {
                buffer = preBuffer
            } else {
                guard let loadedBuffer = try AVAudioPCMBuffer(file: file) else {
                    print("Could not load buffer for \(cell.audio)")
                    return
                }
                buffer = loadedBuffer
                preloadedBuffers[cell.id] = buffer
            }

            // Create an AVAudioPlayerNode.
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            // Connect the player node to the engine's main mixer.
            engine.connect(playerNode, to: globalMixer, format: buffer.format)

            // Schedule the buffer for looping.
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)

            // Start playback.
            try engine.start()  // Engine is already started in init; this is safe.
            playerNode.play()

            // Create and store the handler.
            let handler = AudioPlaybackHandler(playerNode: playerNode)
            handlers[cell.id] = handler

            // Fade in and start FFT analysis.
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
            startFFTAnalysis(for: cell.id)
        } catch {
            print("Error playing audio: \(error)")
        }
    }

    // Stops an audio file (by cell) with a fade-out effect.
    func stopAudio(for cell: AudioCellData) {
        guard let handler = handlers[cell.id] else {
            print("No audio is playing for \(cell.audio)")
            return
        }

        handler.fadeTimer?.invalidate()

        fade(handler: handler, toVolume: 0.0, duration: fadeOutDuration) {
            handler.playerNode.stop()
            self.stopFFTAnalysis(for: cell.id)
            self.engine.detach(handler.playerNode)
            self.handlers.removeValue(forKey: cell.id)
        }
    }

    // MARK: - Audio Analysis
    // Installs an FFT tap on the player's output.
    func startFFTAnalysis(for cellID: UUID) {
        guard let handler = handlers[cellID] else {
            print("No player found for \(cellID)")
            return
        }

        // Remove any existing tap.
        handler.playerNode.removeTap(onBus: 0)

        // Install a tap on bus 0.
        handler.playerNode.installTap(onBus: 0, bufferSize: 1024, format: handler.playerNode.outputFormat(forBus: 0)) { (buffer, when) in
            // Process the buffer to generate FFT data.
            let fftData = self.processBuffer(buffer: buffer)
            DispatchQueue.main.async {
                self.fftSampleData[cellID] = fftData
            }
        }
    }

    func stopFFTAnalysis(for cellID: UUID) {
        bandedSampleData[cellID] = [Float](repeating: 0.0, count: numberOfStems)
        if let handler = handlers[cellID] {
            handler.playerNode.removeTap(onBus: 0)
        }
        fftSampleData.removeValue(forKey: cellID)
    }

    // Process the tapped buffer to generate FFT sample data.
    // This is a placeholder – you need to implement FFT using vDSP.
    func processBuffer(buffer: AVAudioPCMBuffer) -> [Float] {
        // Assume mono signal; otherwise, you may average channels.
        guard let channelData = buffer.floatChannelData?[0] else { return [] }
        let frameCount = Int(buffer.frameLength)

        // Copy the buffer data into an array.
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))

        // Perform FFT on 'samples' using vDSP.
        // For example, create a setup, perform FFT, compute magnitudes.
        // Then return an array of FFT magnitudes (of length 512 if using 1024 buffer).
        // This implementation is left as an exercise – there are many tutorials online.
        return performFFT(samples: samples)
    }

    // Example placeholder function for FFT processing.
    func performFFT(samples: [Float]) -> [Float] {
        // Implement FFT using vDSP.
        // Return an array of Float values representing the FFT magnitudes.
        // For now, return an array of zeros of length 512.
        return [Float](repeating: 0.0, count: 512)
    }

    // MARK: - FFT Band Processing
    // Process the raw FFT sample data into 'numberOfStems' bands.
    func processFFTData(for cellID: UUID) {
        guard let fftSamples = fftSampleData[cellID], fftSamples.count >= 512 else { return }
        var accruedSampleData = [Float](repeating: 0.0, count: numberOfStems)
        var sampleIndex = 0
        var rawSampleCount: Float = 1.0

        for i in 0..<numberOfStems {
            var sampleSum: Float = 0.0
            let roundedSampleCount = Int(round(rawSampleCount))
            for _ in 0..<roundedSampleCount {
                guard sampleIndex < fftSamples.count else { break }
                sampleSum += fftSamples[sampleIndex] * Float(sampleIndex + 1)
                sampleIndex += 1
            }
            let average: Float = sampleIndex > 0 ? sampleSum / Float(sampleIndex) : 0
            var bandValue = average * (handlers[cellID]?.sampleDataScaler ?? 0.0) * 10
            if bandValue.isNaN { bandValue = 0 }
            accruedSampleData[i] = bandValue
            rawSampleCount *= 1.39366
            print("Stem \(i + 1) for \(cellID): \(accruedSampleData[i])")
        }
        print("----------------------------------------------------------------------")
        bandedSampleData[cellID] = accruedSampleData
    }
}
