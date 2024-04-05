//
//  BookModeSwitcherFeatureTests.swift
//  AudioBloom
//
//  Created by Angelina on 04.04.2024.
//

import XCTest
import ComposableArchitecture
@testable import AudioBloom

final class BookModeSwitcherFeatureTests: XCTestCase {

    @MainActor
    func testTogglePlayPause() async {
        let store = TestStore(initialState: BookModeSwitcherFeature.State()) {
            BookModeSwitcherFeature()
        }

        await store.send(.togglePlayPause) {
            $0.isPlaying = true
        }

        await store.send(.togglePlayPause) {
            $0.isPlaying = false
        }
    }

    @MainActor
    func testToggleMode() async {
        let store = TestStore(initialState: BookModeSwitcherFeature.State()) {
            BookModeSwitcherFeature()
        }

        await store.send(.toggleMode) { state in
            state.isReaderMode.toggle()
        }

    }

    @MainActor
    func testInitialState() async {
        let store = TestStore(initialState: BookModeSwitcherFeature.State()) {
            BookModeSwitcherFeature()
        }

        XCTAssertEqual(store.state.isPlaying, false)
        XCTAssertEqual(store.state.isReaderMode, false)
    }

    @MainActor
    func testTogglePlayPauseFromPlayingState() async {
        let store = TestStore(
            initialState: BookModeSwitcherFeature.State(isPlaying: true, isReaderMode: false)
        ) {
            BookModeSwitcherFeature()
        }

        await store.send(.togglePlayPause) {
            $0.isPlaying = false
        }
    }

    @MainActor
    func testToggleModeFromReaderModeState() async {
        let store = TestStore(
            initialState: BookModeSwitcherFeature.State(isPlaying: false, isReaderMode: true)
        ) {
            BookModeSwitcherFeature()
        }

        await store.send(.toggleMode) { state in
            state.isReaderMode = false
        }
    }

    @MainActor
    func testRepeatedTogglePlayPause() async {
        let store = TestStore(
            initialState: BookModeSwitcherFeature.State(isPlaying: false, isReaderMode: false)
        ) {
            BookModeSwitcherFeature()
        }

        // Repeat toggle to see if it stabilizes or oscillates
        for _ in 1...3 {
            await store.send(.togglePlayPause) {
                $0.isPlaying.toggle()
            }
        }

        XCTAssertEqual(store.state.isPlaying, true, "The isPlaying state should end as true after an odd number of toggles.")
    }

    @MainActor
    func testToggleModeDoesNotAffectOtherStates() async {
        let store = TestStore(
            initialState: BookModeSwitcherFeature.State(book: .idle, isPlaying: true)
        ) {
            BookModeSwitcherFeature()
        }

        await store.send(.toggleMode) {
            $0.isReaderMode = true
        }
        // Verify that other state variables remain unchanged
        XCTAssertTrue(store.state.isPlaying, "Toggling mode should not affect playback state.")
        XCTAssertEqual(store.state.book, .idle, "Toggling mode should not affect book state.")
    }

    @MainActor
    func testSequentialTogglesWithDelays() async throws {
        let store = TestStore(
            initialState: BookModeSwitcherFeature.State(book: .sample, isPlaying: false)
        ) {
            BookModeSwitcherFeature()
        }

        await store.send(.togglePlayPause) {
            $0.isPlaying = true
        }

        try await Task.sleep(nanoseconds: 1_000_000_000)
        await store.send(.togglePlayPause) {
            $0.isPlaying = false
        }
        
        // Verify the state after a delay
        XCTAssertFalse(store.state.isPlaying, "Playback should be paused after toggling twice with a delay.")
    }






}
