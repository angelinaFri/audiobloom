//
//  RootFeature.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import Foundation
import ComposableArchitecture

private let logger = DLogger(identifier: String(describing: HomeFeature.self))

@Reducer
struct HomeFeature {

    @ObservableState
    struct State: Equatable {
        let speeds: [Double] = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0]
        var book: Book = .idle
        var duration: TimeInterval = 0
        var currentTime: TimeInterval = 0
        var currentSpeed: Double = 1
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
        case changeSpeed
        case updateDuration(TimeInterval)
        case updateCurrentTime(TimeInterval)
        case onAppear
        case bookFetched(Result<Book, Error>)

        @CasePathable
        enum Delegate {
            case playbackStarted
            case playbackFailed
        }
    }

    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.mainQueue) var mainQueue

    var fetchBook: @Sendable () async throws -> Book
    private enum CancelID {
        case play
        case fetch
    }

    static let liveBook = Self(
        fetchBook: APIClient.live.fetchBook
    )

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
            case .onAppear:
                return handleOnAppear()
            case .bookFetched(let result):
                switch result {
                case .success(let book):
                    state.book = book
                case .failure(let error):
                    logger.info("Failed to fetch book: \(error)")
                }
                return .none
            }
        }
    }

}

// MARK: - Private

private extension HomeFeature {

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
        return seekAndPlay(currentTime: newTime, url: state.url, state: &state)
    }

    func handleRewind(state: inout State) -> Effect<Action> {
        let newTime = max(state.currentTime - 5, 0)
        return seekAndPlay(currentTime: newTime, url: state.url, state: &state)
    }

    func handleSliderToTime(_ newTime: TimeInterval, state: inout State) -> Effect<Action> {
        state.currentTime = newTime
        return seekAndPlay(currentTime: newTime, url: state.url, state: &state)
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

    func handleOnAppear() -> Effect<Action> {
        .run { send in
            do {
                let book = try await APIClient.live.fetchBook()
                await send(.bookFetched(.success(book)))
            } catch {
                await send(.bookFetched(.failure(error)))
            }
        }
        .cancellable(id: CancelID.fetch, cancelInFlight: true)
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

