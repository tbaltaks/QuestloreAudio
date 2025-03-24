//
//  AudioManager.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 7/3/2025.
//

import Foundation
import AVFoundation
import QuartzCore // For CACurrentMediaTime
import Combine
import Accelerate

// Wrap an AVAudioPlayer along with its active fade timer
class AudioPlaybackHandler
{
    let player: AVAudioPlayer
    var fadeTimer: Timer?
    var sampleDataScaler: Float = 0.0

    init(player: AVAudioPlayer) {
        self.player = player
    }

    deinit {
        fadeTimer?.invalidate()
    }
}

class AudioManager: ObservableObject
{
    static let shared = AudioManager()
    private var fftProcessingCancellable: AnyCancellable?
    
    let numberOfStems: Int = 16

    // Fade durations (in seconds)
    let fadeInDuration: TimeInterval = 4.0
    let fadeOutDuration: TimeInterval = 4.0

    // Dictionaries storing handler, audio files, and audio data (keyed by cell ID)
    var handlers: [UUID: AudioPlaybackHandler] = [:]
    var audioFiles: [UUID: AVAudioFile] = [:]
    var fftSampleData: [UUID: [Float]] = [:]
    @Published var bandedSampleData: [UUID: [Float]] = [:]
    
    private init()
    {
        // Start a global Combine timer to update FFT processing.
        fftProcessingCancellable = Timer.publish(every: 0.025, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                for cellID in self.audioFiles.keys {
                    self.processFFTData(for: cellID)
                }
            }
    }
    
    // MARK: - Fade Logic
    private func fade(handler: AudioPlaybackHandler, toVolume targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let startVolume = handler.player.volume
        let startTime = CACurrentMediaTime()
        
        handler.fadeTimer?.invalidate()
        handler.fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime
            let t = Float(min(elapsed / duration, 1.0))
            let easedT = self.easeInOutKe(t, isFadingIn: targetVolume != 0)
            let newVolume = startVolume + (targetVolume - startVolume) * easedT
            handler.player.volume = newVolume
            handler.sampleDataScaler = newVolume
            
            if t >= 1.0 {
                timer.invalidate()
                handler.fadeTimer = nil
                handler.player.volume = targetVolume
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
    func playAudio(for cell: AudioCellData) {
        // If already playing, simply fade in.
        if let handler = handlers[cell.id] {
            handler.fadeTimer?.invalidate()
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
            return
        }
        
        guard let url = Bundle.main.url(forResource: cell.audio, withExtension: nil) else {
            print("Audio file \(cell.audio) not found!")
            return
        }
        
        do {
            // Create AVAudioPlayer for playback.
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.0
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
            
            let handler = AudioPlaybackHandler(player: player)
            handlers[cell.id] = handler
            
            // Also open an AVAudioFile for FFT processing.
            let audioFile = try AVAudioFile(forReading: url)
            audioFiles[cell.id] = audioFile
            
            fade(handler: handler, toVolume: 1.0, duration: fadeInDuration)
        }
        catch {
            print("Error playing audio: \(error)")
        }
    }
    
    func stopAudio(for cell: AudioCellData) {
        guard let handler = handlers[cell.id] else {
            print("No audio is playing for \(cell.audio)")
            return
        }
        
        handler.fadeTimer?.invalidate()
        fade(handler: handler, toVolume: 0.0, duration: fadeOutDuration) {
            handler.player.stop()
            self.handlers.removeValue(forKey: cell.id)
            self.audioFiles.removeValue(forKey: cell.id)
            self.fftSampleData.removeValue(forKey: cell.id)
            self.bandedSampleData[cell.id] = [Float](repeating: 0.0, count: self.numberOfStems)
        }
    }
    
    
    // MARK: - FFT Analysis and Processing
    func processFFTData(for cellID: UUID)
    {
        guard let audioFile = audioFiles[cellID],
              let player = handlers[cellID]?.player else {
            return
        }
        
//        let peakAmplitude = audioFile.peak?.amplitude
        let sampleRate = audioFile.processingFormat.sampleRate
        let currentTime = player.currentTime
        let startFrame = AVAudioFramePosition(currentTime * sampleRate)
        let frameCount: AVAudioFrameCount = 1024
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount) else {
            return
        }
        
        do {
            audioFile.framePosition = startFrame
            try audioFile.read(into: buffer, frameCount: frameCount)
        } catch {
            print("Error reading audio for FFT: \(error)")
            return
        }
        
        // Assume mono signal for simplicity.
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let sampleCount = Int(buffer.frameLength)
        let halfSampleCount = sampleCount / 2
        let samples = Array(UnsafeBufferPointer(start: channelData, count: sampleCount))
        
        // Apply a Hanning window.
        let window = vDSP.window(ofType: Float.self, usingSequence: .hamming, count: sampleCount, isHalfWindow: false)
        var windowedSamples = [Float](repeating: 0, count: sampleCount)
        vDSP_vmul(samples, 1, window, 1, &windowedSamples, 1, vDSP_Length(sampleCount))
        
        // Create FFT setup.
        guard let fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Float(sampleCount))), FFTRadix(FFT_RADIX2)) else { return }
        
        // Prepare a DSPSplitComplex to hold FFT input
        var realp = [Float](repeating: 0, count: halfSampleCount)
        var imagp = [Float](repeating: 0, count: halfSampleCount)
        realp.withUnsafeMutableBufferPointer { realPtr in
            imagp.withUnsafeMutableBufferPointer { imagPtr in
                var complexBuffer = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                
                windowedSamples.withUnsafeBufferPointer { pointer in
                    pointer.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: sampleCount) { typeConvertedTransferBuffer in
                        vDSP_ctoz(typeConvertedTransferBuffer, 2, &complexBuffer, 1, vDSP_Length(halfSampleCount))
                    }
                }
                
                // Perform the FFT
                vDSP_fft_zrip(fftSetup, &complexBuffer, 1, vDSP_Length(log2(Float(sampleCount))), FFTDirection(FFT_FORWARD))
                
                // Compute magnitudes
                var fftMagnitudes = [Float](repeating: 0.0, count: halfSampleCount)
                vDSP_zvabs(&complexBuffer, 1, &fftMagnitudes, 1, vDSP_Length(halfSampleCount))
                
                // Normalise magnitudes
//                for i in 0..<fftMagnitudes.count
//                {
//                    print("Magnitude \(i + 1): \(fftMagnitudes[i])")
//                    fftMagnitudes[i] /= peakAmplitude ?? 1
//                    print("Normalised Magnitude \(i + 1): \(fftMagnitudes[i])")
//                    print("~~~  NEXT  ~~~")
//                }
//                print("----------------------------------oh-kayyy--------------------------------------")
                
                // Save the raw FFT data
                DispatchQueue.main.async {
                    self.fftSampleData[cellID] = fftMagnitudes
                }
                
                // Now process the FFT data into bands
                var accruedSampleData = [Float](repeating: 0.0, count: numberOfStems)
                var sampleIndex = 0
                var rawSampleCount: Float = 2.0
                
                for i in 0..<numberOfStems
                {
                    var sampleSum: Float = 0.0
                    let perBinSampleCount = i + 1 < numberOfStems ? Int(round(rawSampleCount)) : 512 - (sampleIndex + 1)
                    
                    for _ in 0..<perBinSampleCount
                    {
                        if sampleIndex < fftMagnitudes.count {
                            sampleSum += fftMagnitudes[sampleIndex] * Float(sampleIndex + 1)
                            sampleIndex += 1
                        } else {
                            break
                        }
                    }
                    
                    let average: Float = sampleIndex > 0 ? sampleSum / Float(sampleIndex) : 0
                    let scaler = self.handlers[cellID]?.sampleDataScaler ?? 0.0
                    var bandValue = average / 80 * scaler
                    if bandValue.isNaN {
                        bandValue = 0
                    }
                    
                    accruedSampleData[i] = bandValue
                    rawSampleCount *= 1.28
//                    print("Stem \(i + 1) for \(cellID): \(accruedSampleData[i])")
                }
//                print("----------------------------------hell-yea--------------------------------------")
                
                // Save the processed band data.
                DispatchQueue.main.async {
                    self.bandedSampleData[cellID] = accruedSampleData
                }
            }
        }
        
        vDSP_destroy_fftsetup(fftSetup)
    }
}
