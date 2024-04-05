//
//  PlayerControlsFeatureTests.swift
//  AudioBloomTests
//
//  Created by Angelina on 04.04.2024.
//

import XCTest
import ComposableArchitecture
@testable import AudioBloom

final class PlayerControlsFeatureTests: XCTestCase {

    @MainActor
    func testTogglePlayPause() async {
        let store = TestStore(
            initialState: PlayerControlsFeature.State(book: .sample)
        ) {
            PlayerControlsFeature()
        } withDependencies: {
            $0.audioPlayer = .testValue
        }

        await store.send(.togglePlayPause) {
            $0.mode = .playing(progress: 0)
        }

        try? await Task.sleep(nanoseconds: 1_000_000_000)


        await store.send(.togglePlayPause) {
            $0.mode = .notPlaying
        }
    }

}
