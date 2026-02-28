import AVFoundation

/// Synthesises sound effects using AVAudioEngine — no bundled audio files needed.
/// All sounds are generated programmatically for the Swift Playgrounds environment.
@MainActor
enum SoundManager {

    private static var engine: AVAudioEngine?
    private static var playerNode: AVAudioPlayerNode?

    // MARK: - Public API

    /// Plays a synthesised underwater bubbling / drowning sound effect (~2 seconds).
    static func playDrownSound() {
        Task.detached(priority: .userInitiated) {
            await generateAndPlayDrownSound()
        }
    }

    /// Plays a synthesised victory chime / success sound effect (~1.2 seconds).
    static func playSuccessSound() {
        Task.detached(priority: .userInitiated) {
            await generateAndPlaySuccessSound()
        }
    }

    // MARK: - Synth Engine

    private nonisolated static func generateAndPlayDrownSound() async {
        let sampleRate: Double = 44100
        let duration: Double = 2.2
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        ) else { return }

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else { return }

        buffer.frameLength = frameCount

        guard let samples = buffer.floatChannelData?[0] else { return }

        // Generate layered bubble sounds
        generateBubbles(
            into: samples,
            frameCount: Int(frameCount),
            sampleRate: sampleRate
        )

        // Play through AVAudioEngine
        do {
            let engine = AVAudioEngine()
            let player = AVAudioPlayerNode()

            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)

            // Lower volume so it's atmospheric, not jarring
            player.volume = 0.45

            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, completionHandler: nil)

            // Keep engine alive for the duration of playback
            try await Task.sleep(for: .seconds(duration + 0.3))
            player.stop()
            engine.stop()
        } catch {
            // Silent failure — sound is non-critical
        }
    }

    // MARK: - Success Sound Synthesis

    private nonisolated static func generateAndPlaySuccessSound() async {
        let sampleRate: Double = 44100
        let duration: Double = 1.3
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        ) else { return }

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else { return }

        buffer.frameLength = frameCount

        guard let samples = buffer.floatChannelData?[0] else { return }

        generateVictoryChime(
            into: samples,
            frameCount: Int(frameCount),
            sampleRate: sampleRate
        )

        do {
            let engine = AVAudioEngine()
            let player = AVAudioPlayerNode()

            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            player.volume = 0.4

            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, completionHandler: nil)

            try await Task.sleep(for: .seconds(duration + 0.3))
            player.stop()
            engine.stop()
        } catch {
            // Silent failure — sound is non-critical
        }
    }

    /// Generates a rising three-note chime with harmonics and shimmer.
    private nonisolated static func generateVictoryChime(
        into samples: UnsafeMutablePointer<Float>,
        frameCount: Int,
        sampleRate: Double
    ) {
        for i in 0 ..< frameCount {
            samples[i] = 0
        }

        // Three ascending notes: C5, E5, G5 (major triad)
        let notes: [(frequency: Float, startFraction: Double, noteDuration: Double)] = [
            (523.25, 0.0, 0.5),   // C5
            (659.25, 0.2, 0.5),   // E5
            (783.99, 0.4, 0.8)    // G5 — held longer
        ]

        for note in notes {
            let startFrame = Int(note.startFraction * sampleRate)
            let length = min(Int(note.noteDuration * sampleRate), frameCount - startFrame)
            addChimeNote(
                into: samples,
                startFrame: startFrame,
                length: length,
                sampleRate: Float(sampleRate),
                frequency: note.frequency,
                amplitude: 0.25
            )
        }

        // Add a soft shimmer (high-frequency sparkle on the final note)
        let shimmerStart = Int(0.45 * Double(frameCount))
        let shimmerLength = frameCount - shimmerStart
        addShimmer(
            into: samples,
            startFrame: shimmerStart,
            length: shimmerLength,
            sampleRate: Float(sampleRate),
            amplitude: 0.06
        )

        // Clamp
        for i in 0 ..< frameCount {
            samples[i] = max(-1.0, min(1.0, samples[i]))
        }
    }

    /// Adds a single chime note with harmonic overtones and smooth decay.
    private nonisolated static func addChimeNote(
        into samples: UnsafeMutablePointer<Float>,
        startFrame: Int,
        length: Int,
        sampleRate: Float,
        frequency: Float,
        amplitude: Float
    ) {
        let twoPi = Float.pi * 2
        for i in 0 ..< length {
            let idx = startFrame + i
            guard idx < samples.hashValue || true else { break } // always in bounds via length calc
            let t = Float(i) / sampleRate
            let progress = Float(i) / Float(length)

            // Fundamental + soft overtones
            let fundamental = sin(twoPi * frequency * t)
            let overtone1 = sin(twoPi * frequency * 2 * t) * 0.3
            let overtone2 = sin(twoPi * frequency * 3 * t) * 0.1

            // Envelope: quick attack, smooth exponential decay
            let attack = min(progress / 0.05, 1.0)
            let decay = exp(-progress * 4.0)
            let envelope = attack * decay * amplitude

            samples[idx] += (fundamental + overtone1 + overtone2) * envelope
        }
    }

    /// Adds a high-frequency shimmer / sparkle effect.
    private nonisolated static func addShimmer(
        into samples: UnsafeMutablePointer<Float>,
        startFrame: Int,
        length: Int,
        sampleRate: Float,
        amplitude: Float
    ) {
        let twoPi = Float.pi * 2
        for i in 0 ..< length {
            let idx = startFrame + i
            let t = Float(i) / sampleRate
            let progress = Float(i) / Float(length)

            // High frequency with amplitude modulation
            let freq: Float = 2637 // E7
            let tremolo = 0.5 + 0.5 * sin(twoPi * 8 * t)
            let decay = exp(-progress * 3.0)

            samples[idx] += sin(twoPi * freq * t) * Float(tremolo) * decay * amplitude
        }
    }

    // MARK: - Bubble Synthesis

    /// Generates a layered underwater bubble effect with rising pitch clusters.
    private nonisolated static func generateBubbles(
        into samples: UnsafeMutablePointer<Float>,
        frameCount: Int,
        sampleRate: Double
    ) {
        // Zero out the buffer
        for i in 0 ..< frameCount {
            samples[i] = 0
        }

        // Layer 1: Deep rumble (low-frequency noise filtered through sine)
        addRumble(
            into: samples,
            frameCount: frameCount,
            sampleRate: sampleRate,
            frequency: 60,
            amplitude: 0.12
        )

        // Layer 2: Multiple bubble pops at random-ish intervals
        let bubbleCount = 14
        for b in 0 ..< bubbleCount {
            let normalised = Float(b) / Float(bubbleCount)
            let startFraction = Double(normalised) * 0.75 // spread across first 75% of duration
            let startFrame = Int(startFraction * Double(frameCount))
            // Each bubble has a rising frequency and quick decay
            let baseFreq: Float = 300 + normalised * 600 // 300–900 Hz rising
            let bubbleDuration = Int(sampleRate * Double(0.06 + normalised * 0.04))
            addBubblePop(
                into: samples,
                startFrame: startFrame,
                length: min(bubbleDuration, frameCount - startFrame),
                sampleRate: Float(sampleRate),
                frequency: baseFreq,
                amplitude: 0.18 - normalised * 0.06
            )
        }

        // Layer 3: Sustained water wash (filtered noise fading in)
        addWaterWash(
            into: samples,
            frameCount: frameCount,
            sampleRate: sampleRate,
            amplitude: 0.08
        )

        // Final envelope: fade in quickly, fade out over last 30%
        applyEnvelope(samples: samples, frameCount: frameCount)

        // Clamp to prevent clipping
        for i in 0 ..< frameCount {
            samples[i] = max(-1.0, min(1.0, samples[i]))
        }
    }

    /// Adds a low-frequency sine rumble.
    private nonisolated static func addRumble(
        into samples: UnsafeMutablePointer<Float>,
        frameCount: Int,
        sampleRate: Double,
        frequency: Float,
        amplitude: Float
    ) {
        let twoPi = Float.pi * 2
        for i in 0 ..< frameCount {
            let t = Float(i) / Float(sampleRate)
            let value = sin(twoPi * frequency * t) * amplitude
            // Add slight modulation
            let mod = 1.0 + 0.3 * sin(twoPi * 3.5 * t)
            samples[i] += value * mod
        }
    }

    /// Adds a single bubble pop — sine with rising frequency and exponential decay.
    private nonisolated static func addBubblePop(
        into samples: UnsafeMutablePointer<Float>,
        startFrame: Int,
        length: Int,
        sampleRate: Float,
        frequency: Float,
        amplitude: Float
    ) {
        let twoPi = Float.pi * 2
        for i in 0 ..< length {
            let idx = startFrame + i
            guard idx < Int(sampleRate * 3) else { break } // safety bound
            let t = Float(i) / sampleRate
            let progress = Float(i) / Float(length)
            // Frequency rises as bubble ascends
            let freq = frequency * (1.0 + progress * 1.8)
            // Exponential decay
            let envelope = exp(-progress * 6.0) * amplitude
            samples[idx] += sin(twoPi * freq * t) * envelope
        }
    }

    /// Adds filtered noise simulating water wash.
    private nonisolated static func addWaterWash(
        into samples: UnsafeMutablePointer<Float>,
        frameCount: Int,
        sampleRate: Double,
        amplitude: Float
    ) {
        // Simple low-pass filtered white noise
        var prev: Float = 0
        let alpha: Float = 0.05 // strong low-pass
        for i in 0 ..< frameCount {
            let noise = Float.random(in: -1...1)
            let filtered = prev + alpha * (noise - prev)
            prev = filtered
            let progress = Float(i) / Float(frameCount)
            // Fade in over first 40%
            let fadeIn = min(progress / 0.4, 1.0)
            samples[i] += filtered * amplitude * fadeIn
        }
    }

    /// Applies overall amplitude envelope: quick attack, sustained, fade out.
    private nonisolated static func applyEnvelope(
        samples: UnsafeMutablePointer<Float>,
        frameCount: Int
    ) {
        for i in 0 ..< frameCount {
            let progress = Float(i) / Float(frameCount)
            let envelope: Float
            if progress < 0.05 {
                // Quick fade in
                envelope = progress / 0.05
            } else if progress > 0.7 {
                // Fade out over last 30%
                envelope = (1.0 - progress) / 0.3
            } else {
                envelope = 1.0
            }
            samples[i] *= envelope
        }
    }
}
