//
//  PlayerControlsFeature.swift
//  AudioBloom
//
//  Created by Angelina on 01.04.2024.
//

import Foundation
import ComposableArchitecture

private let logger = DLogger(identifier: String(describing: PlayerControlsFeature.self))

@Reducer
struct PlayerControlsFeature {

    @ObservableState
    struct State: Equatable {
        let speeds: [Double] = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0]
        var book: Book = .idle
        var duration: TimeInterval = 0
        var currentTime: TimeInterval = 0
        var currentSpeed: Double = 1
        var mode = Mode.notPlaying
        var currentChapterIndex: Int = 0
    }

    @CasePathable
    @dynamicMemberLookup
    enum Mode: Equatable {
        case notPlaying
        case playing(progress: Double)
    }

    enum Action {
        case delegate(Delegate)
        case playButtonTapped
        case fastForward
        case rewind
        case playForward
        case playBackward
        case sliderToTime(Double)
        case changeSpeed
        case updateDuration(TimeInterval)
        case updateCurrentTime(TimeInterval)

        @CasePathable
        enum Delegate {
            case playbackStarted
            case playbackFailed
        }
    }

    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.mainQueue) var mainQueue

    private enum CancelID {
        case play
        case fetch
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate(let playbackAction):
                return handlePlaybackDelegateActions(playbackAction, state: &state)
            case .playButtonTapped:
                return handlePlayButtonTapped(state: &state)
            case let .updateDuration(duration):
                return handleUpdateDuration(duration, state: &state)
            case let .updateCurrentTime(currentTime):
                return handleUpdateCurrentTime(currentTime, state: &state)
            case .fastForward:
                return handleFastForward(state: &state)
            case .rewind:
                return handleRewind(state: &state)
            case let .sliderToTime(newTime):
                return handleSliderToTime(newTime, state: &state)
            case .changeSpeed:
                return handleChangeSpeed(state: &state)
            case .playForward:
                if state.currentChapterIndex < state.book.chapters.count - 1 {
                    state.currentChapterIndex += 1
                    resetStateForNewChapter(state: &state)
                    return play(state: &state)
                } else {
                    return .none
                }
            case .playBackward:
                if state.currentChapterIndex > 0 {
                    state.currentChapterIndex -= 1
                    resetStateForNewChapter(state: &state)
                    return play(state: &state)
                } else {
                    return .none
                }
            }
        }
    }

}

// MARK: - Private

private extension PlayerControlsFeature {

    func handlePlaybackDelegateActions(_ action: Action.Delegate, state: inout State) -> Effect<Action> {
        switch action {
        case .playbackFailed:
            logger.info("Playback failed")
            // TODO: - Show an alert
            return .none
        case .playbackStarted:
            logger.info("Playback started")
            return startPlaybackMonitoring(state: &state)
        }
    }

    func handlePlayButtonTapped(state: inout State) -> Effect<Action> {
        switch state.mode {
        case .notPlaying:
            if state.currentTime > 0 {
                return seekAndPlay(currentTime: state.currentTime, state: &state)
            } else {
                return play(state: &state)
            }
        case .playing:
            state.mode = .notPlaying
            return .run { [audioPlayer] _ in
                await audioPlayer.stopPlaying()
            }
            .cancellable(id: CancelID.play, cancelInFlight: true)
        }
    }

    func handleUpdateDuration(_ duration: TimeInterval, state: inout State) -> Effect<Action> {
        state.duration = duration
        logger.info("Total Time: \(String(describing: state.duration))")
        return .none
    }

    func handleUpdateCurrentTime(_ currentTime: TimeInterval, state: inout State) -> Effect<Action> {
        state.currentTime = currentTime
        updateProgressBasedOnCurrentTime(&state)
        return .none
    }

    func handleFastForward(state: inout State) -> Effect<Action> {
        let newTime = min(state.currentTime + 10, state.duration)
        return seekAndPlay(currentTime: newTime, state: &state)
    }

    func handleRewind(state: inout State) -> Effect<Action> {
        let newTime = max(state.currentTime - 5, 0)
        return seekAndPlay(currentTime: newTime, state: &state)
    }

    func handleSliderToTime(_ newTime: TimeInterval, state: inout State) -> Effect<Action> {
        state.currentTime = newTime
        return seekAndPlay(currentTime: newTime, state: &state)
    }

    func handleChangeSpeed(state: inout State) -> Effect<Action> {
        if let currentIndex = state.speeds.firstIndex(of: state.currentSpeed) {
            let nextIndex = (currentIndex + 1) % state.speeds.count
            state.currentSpeed = state.speeds[nextIndex]
        } else {
            // Default to 1x if current speed is not found
            state.currentSpeed = 1.0
        }
        let speed = state.currentSpeed
        return .run { _ in
            await self.audioPlayer.setRate(Float(speed))
        }
    }

    func startPlaybackMonitoring(state: inout State) -> Effect<Action> {
        logger.info("Playback started")
        return .run { send in
            if let duration = await self.audioPlayer.totalTime() {
                await send(.updateDuration(duration))
            }
            for await _ in mainQueue.timer(interval: .seconds(1)) {
                Task {
                    if let currentTime = await self.audioPlayer.currentTime() {
                        await send(.updateCurrentTime(currentTime))
                    }
                    // TODO: - Handle if nil
                }
            }
        }
        .cancellable(id: CancelID.play, cancelInFlight: true)
    }

    func startPlayback(currentTime: Double? = nil, state: inout State) -> Effect<Action> {
        let chapterUrl = state.book.chapters[state.currentChapterIndex].audio
        guard let url = URL(string: chapterUrl) else {
            return .run { send in
                await send(.delegate(.playbackFailed))
            }
        }

        if let currentTime = currentTime {
            state.mode = .playing(progress: currentTime / state.duration)
        } else {
            state.mode = .playing(progress: 0)
        }

        return .run { send in
            // If there's a specific time to seek to, do that first
            if let currentTime = currentTime {
                await self.audioPlayer.seekTo(time: currentTime)
            }

            do {
                _ = try await self.audioPlayer.startPlaying(url: url)
                await send(.delegate(.playbackStarted))
            } catch {
                await send(.delegate(.playbackFailed))
            }
        }
        .cancellable(id: CancelID.play, cancelInFlight: true)
    }

    func play(state: inout State) -> Effect<Action> {
        return startPlayback(state: &state)
    }

    func seekAndPlay(currentTime: Double, state: inout State) -> Effect<Action> {
        return startPlayback(currentTime: currentTime, state: &state)
    }

    func updateProgressBasedOnCurrentTime(_ state: inout State) {
        if case .playing(_) = state.mode, state.duration > 0 {
            let progress = state.currentTime / state.duration
            state.mode = .playing(progress: progress)
        }
        logger.info("Current Time: \(String(describing: state.currentTime))")
    }

    func resetStateForNewChapter(state: inout State) {
        state.currentTime = 0
        state.duration = 0
        state.currentSpeed = 1
        state.mode = .notPlaying
    }
}

