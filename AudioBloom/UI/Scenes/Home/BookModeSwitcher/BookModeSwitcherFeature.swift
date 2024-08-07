//
//  BookModeSwitcherFeature.swift
//  AudioBloom
//
//  Created by Angelina on 02.04.2024.
//

import Foundation
import ComposableArchitecture

private let logger = DLogger(identifier: String(describing: BookModeSwitcherFeature.self))

@Reducer
struct BookModeSwitcherFeature {

    @ObservableState
    struct State: Equatable {
        var book: Book = .idle
        var isPlaying: Bool = false
        var isReaderMode: Bool = false
    }

    enum Action: Equatable {
        case togglePlayPause
        case toggleMode
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .togglePlayPause:
                state.isPlaying.toggle()
                return .none
            case .toggleMode:
                state.isReaderMode.toggle()
                return .none
            }
        }
    }
}
