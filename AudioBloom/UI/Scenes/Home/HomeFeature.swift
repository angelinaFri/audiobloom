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
    }

    enum Action {
        case onAppear
        case bookFetched(Result<Book, Error>)
        case playerControlAction(PlayerControlsFeature.Action)
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
        Reduce { state, action in
            switch action {
            case .onAppear:
                return handleOnAppear()
            case .bookFetched(let result):
                switch result {
                case .success(let book):
                    state.book = book
                    state.playerControlState.book = book
                    logger.info("Book: \(state.playerControlState.book.name)")
                case .failure(let error):
                    logger.info("Failed to fetch book: \(error)")
                }
                return .none
            case .playerControlAction:
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

