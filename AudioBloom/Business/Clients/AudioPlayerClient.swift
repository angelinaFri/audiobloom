//
//  AudioPlayerClient.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct AudioPlayerClient {
    var totalTime: @Sendable () async -> TimeInterval?
    var currentTime: @Sendable () async -> TimeInterval?
    var startPlaying: @Sendable (_ url: URL) async throws -> Bool
    var stopPlaying: @Sendable () async -> Void
    var seekTo: @Sendable (_ time: TimeInterval) async -> Void
}

extension AudioPlayerClient: TestDependencyKey {
    static var previewValue: Self {
        let isPlaying = ActorIsolated(false)
        let totalTime = ActorIsolated(45.0)
        let currentTime = ActorIsolated(0.0)

        return Self(
            totalTime: { await totalTime.value },
            currentTime: { await currentTime.value },
            startPlaying: { _ in
                await isPlaying.setValue(true)
                while await isPlaying.value {
                    let current = await currentTime.value
                    let total = await totalTime.value
                    // Check if the end of the playback is reached
                    if current >= total {
                        await isPlaying.setValue(false)
                        break
                    } else {
                        try await Task.sleep(for: .seconds(1))
                        await currentTime.withValue { $0 += 2 }
                    }
                }
                return true
            },
            stopPlaying: {
                await isPlaying.setValue(false)
            },
            seekTo: { time in
                await currentTime.setValue(time)
            }
        )
    }

    static let testValue = Self()
}



extension DependencyValues {

    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}
