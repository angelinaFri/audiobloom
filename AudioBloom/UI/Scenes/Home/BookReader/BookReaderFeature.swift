//
//  BookReaderFeature.swift
//  AudioBloom
//
//  Created by Angelina on 02.04.2024.
//

import Foundation
import ComposableArchitecture

private let logger = DLogger(identifier: String(describing: BookReaderFeature.self))

@Reducer
struct BookReaderFeature {
    
    @ObservableState
    struct State: Equatable {
        var book: Book = .idle
        var currentChapterIndex: Int = 0
    }
    
    enum Action {
        // For future, if I have buttons
        case nextChapter
        case previousChapter
        case setChapterIndex(Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .nextChapter:
                if state.currentChapterIndex < state.book.chapters.count - 1 {
                    state.currentChapterIndex += 1
                }
                return .none
            case .previousChapter:
                state.currentChapterIndex = max(state.currentChapterIndex - 1, 0)
                return .none
            case .setChapterIndex(let index):
                state.currentChapterIndex = max(0, min(index, state.book.chapters.count - 1))
                logger.info("Updated index: \(state.currentChapterIndex)")
                return .none
            }
        }
    }
}
