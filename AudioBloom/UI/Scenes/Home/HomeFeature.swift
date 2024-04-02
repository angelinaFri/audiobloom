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
        var book: Book = .idle
        var playerControlState = PlayerControlsFeature.State()
        var bookModeState = BookModeSwitcherFeature.State()
        var bookReaderState = BookReaderFeature.State()
    }

    enum Action {
        case onAppear
        case bookFetched(Result<Book, Error>)
        case playerControlAction(PlayerControlsFeature.Action)
        case bookModeSwitcherAction(BookModeSwitcherFeature.Action)
        case bookReaderAction(BookReaderFeature.Action)
    }

    var fetchBook: @Sendable () async throws -> Book
    private enum CancelID {
        case fetch
    }

    static let liveBook = Self(
        fetchBook: APIClient.live.fetchBook
    )

    var body: some Reducer<State, Action> {
        Scope(state: \.playerControlState, action: /HomeFeature.Action.playerControlAction) {
            PlayerControlsFeature()
        }
        Scope(state: \.bookModeState, action: /HomeFeature.Action.bookModeSwitcherAction) {
            BookModeSwitcherFeature()
        }
        Scope(state: \.bookReaderState, action: /HomeFeature.Action.bookReaderAction) {
            BookReaderFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return handleOnAppear()
            case .bookFetched(let result):
                switch result {
                case .success(let book):
                    state.book = book
                    state.playerControlState.book = book
                    state.bookReaderState.book = book
                    state.bookModeState.book = book
                    state.bookModeState.book.mode = .audio
                case .failure(let error):
                    logger.info("Failed to fetch book: \(error)")
                }
                return .none
            case .playerControlAction:
                return .none
            case .bookModeSwitcherAction(.toggleMode):
                state.book.mode = state.book.mode == .audio ? .reader : .audio
                logger.info("\(state.book.mode)")
                return .none
            case .bookModeSwitcherAction(.togglePlayPause):
                return .none
            case .bookReaderAction:
                return .none

            }
        }
    }

}

// MARK: - Private

private extension HomeFeature {

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
}

