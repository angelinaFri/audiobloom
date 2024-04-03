//
//  LiveAudioPlayerClient.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

@preconcurrency import AVFoundation
import Dependencies

private let logger = DLogger(identifier: String(describing: AudioPlayerClient.self))

extension AudioPlayerClient: DependencyKey {
    static var liveValue: Self {
        let audioPlayer = AudioPlayer()
        return Self(
            totalTime: { await audioPlayer.totalTime },
            currentTime: { await audioPlayer.currentTime },
            startPlaying: { url, speed in
                try await audioPlayer.start(url: url, speed: speed)
            },
            stopPlaying: { await audioPlayer.stop() },
            seekTo: { time in await audioPlayer.seekTo(time) },
            setRate: { rate in await audioPlayer.setRate(rate) }
        )
    }
}

private actor AudioPlayer {
    var player: AVPlayer?
    var playerItem: AVPlayerItem?

    private var playerStatusObserver: NSKeyValueObservation?

    var totalTime: TimeInterval? {
        guard let duration = self.player?.currentItem?.duration else { return nil }
        return CMTimeGetSeconds(duration)
    }

    var currentTime: TimeInterval? {
        guard let currentTime = self.player?.currentTime() else { return nil }
        return CMTimeGetSeconds(currentTime)
    }

    func stop() {
        self.player?.pause()
    }

    func seekTo(_ time: TimeInterval) async {
        await withCheckedContinuation { continuation in
            let cmTime = CMTime(seconds: time, preferredTimescale: 600)
            self.player?.seek(to: cmTime, completionHandler: { _ in
                continuation.resume()
            })
        }
    }

    func setRate(_ rate: Float) async {
        self.player?.rate = rate
    }

    func start(url: URL, speed: Float) async throws -> Bool {
        if let currentUrl = player?.currentItem?.asset as? AVURLAsset, currentUrl.url == url {
            logger.info("Resuming at player rate: \(speed)")
            self.player?.rate = speed
            self.player?.play()
            return true
        } else {
            self.stop()
            self.playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: self.playerItem!)
            let isReadyToPlay = try await waitForPlayerItemReady(playerItem: self.playerItem!)
            guard isReadyToPlay else { return false }
            if let currentTime = self.player?.currentTime() {
                logger.info("Current time: \(CMTimeGetSeconds(currentTime))")
            }
            logger.info("Starting new URL at player rate: \(speed)")
            self.player?.playImmediately(atRate: speed)
            return true
        }
    }

}

private extension AudioPlayer {
    
    func waitForPlayerItemReady(playerItem: AVPlayerItem) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.playerStatusObserver = playerItem.observe(\.status, options: [.new, .initial]) { item, change in
                switch item.status {
                case .readyToPlay:
                    logger.info("Status: readyToPlay")
                    continuation.resume(returning: true)
                case .failed:
                    logger.error("Status: failed error with error " + (item.error?.localizedDescription ?? ""))
                    continuation.resume(throwing: item.error ?? NSError(domain: "PlayerItemError", code: -1, userInfo: nil))
                case .unknown:
                    logger.info("Status: unknown")
                    break //
                @unknown default:
                    logger.info("Unhandled player item status")
                    fatalError("Unhandled player item status")
                }
            }
        }
    }

}



