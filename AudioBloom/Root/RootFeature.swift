//
//  RootFeature.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import Foundation
import ComposableArchitecture

private let logger = DLogger(identifier: String(describing: RootFeature.self))

@Reducer
struct RootFeature {

    @ObservableState
    struct State: Equatable {
        var book: Book = .sample
        var duration: TimeInterval = 0
        var currentTime: TimeInterval = 0
        var mode = Mode.notPlaying
        var url: URL = URL(string: Book.sample.chapters[0].audio)!
        var id: URL { self.url }
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
        case sliderToTime(Double)
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

    var fetchBook: @Sendable () async throws -> Book
    private enum CancelID { case play }

    static let live = Self(
        fetchBook: APIClient.live.fetchBook
    )

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate(.playbackFailed):
                logger.info("Playback failed")
                // TODO: - Show an alert
                return .none
            case .delegate(.playbackStarted):
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
            case .playButtonTapped:
                switch state.mode {
                case .notPlaying:
                    if state.currentTime > 0 {
                        // Seek to current time and start playback
                        return seekAndPlay(currentTime: state.currentTime, url: state.url, state: &state)
                    } else {
                        // Start playback from the beginning
                        state.mode = .playing(progress: 0)
                        return .run { [url = state.url] send in
                            let isSuccess = try? await self.audioPlayer.startPlaying(url: url) == true
                            await send(.delegate(isSuccess ?? false ? .playbackStarted : .playbackFailed))
                        }
                        .cancellable(id: CancelID.play, cancelInFlight: true)
                    }
                case .playing:
                    state.mode = .notPlaying
                    return .run { [audioPlayer] _ in
                        await audioPlayer.stopPlaying()
                    }
                    .cancellable(id: CancelID.play, cancelInFlight: true)
                }
            case let .updateDuration(duration):
                state.duration = duration
                logger.info("Total Time: \(String(describing: state.duration))")
                return .none
            case let .updateCurrentTime(currentTime):
                state.currentTime = currentTime
                updateProgressBasedOnCurrentTime(&state)
                return .none
            case .fastForward:
                let newTime = min(state.currentTime + 10, state.duration)
                return seekAndPlay(currentTime: newTime, url: state.url, state: &state)
            case .rewind:
                let newTime = max(state.currentTime - 5, 0)
                return seekAndPlay(currentTime: newTime, url: state.url, state: &state)
            case let .sliderToTime(newTime):
               state.currentTime = newTime
               return seekAndPlay(currentTime: newTime, url: state.url, state: &state)
            }
        }
    }

}

// MARK: - Private

private extension RootFeature {

    func seekAndPlay(currentTime: Double, url: URL, state: inout State) -> Effect<Action> {
        state.mode = .playing(progress: currentTime / state.duration)
        return .run { send in
            await self.audioPlayer.seekTo(time: currentTime)
            do {
                _ = try await self.audioPlayer.startPlaying(url: url)
                await send(.delegate(.playbackStarted))
            } catch {
                await send(.delegate(.playbackFailed))
            }
        }
        .cancellable(id: CancelID.play, cancelInFlight: true)
    }

    func updateProgressBasedOnCurrentTime(_ state: inout State) {
        if case .playing(_) = state.mode, state.duration > 0 {
            let progress = state.currentTime / state.duration
            state.mode = .playing(progress: progress)
        }
        logger.info("Current Time: \(String(describing: state.currentTime))")
    }

}
