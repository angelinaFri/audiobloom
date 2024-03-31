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
            startPlaying: { url in try await audioPlayer.start(url: url) },
            stopPlaying: { await audioPlayer.stop() }, 
            seekTo: { time in await audioPlayer.seekTo(time) }
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

    func start(url: URL) async throws -> Bool {
        if let currentUrl = player?.currentItem?.asset as? AVURLAsset, currentUrl.url == url {
            self.player?.play()
            return true
        } else {
            self.stop()
            let playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            let isReadyToPlay = try await waitForPlayerItemReady(playerItem: playerItem)
            guard isReadyToPlay else { return false }
            if let currentTime = self.player?.currentTime() {
                logger.info("Current time: \(CMTimeGetSeconds(currentTime))")
            }
            self.player?.play()
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



