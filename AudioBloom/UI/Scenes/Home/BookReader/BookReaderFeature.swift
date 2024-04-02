//
//  BookReaderFeature.swift
//  AudioBloom
//
//  Created by Angelina on 02.04.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BookReaderFeature {
    
    @ObservableState
    struct State: Equatable {
        var book: Book = .idle
        var currentChapterIndex: Int = 0
    }
    
    enum Action {
        case nextChapter
        case previousChapter
        case setChapterIndex(Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .nextChapter:
                state.currentChapterIndex = min(state.currentChapterIndex + 1,
                                                state.book.chapters.count - 1)
                return .none
            case .previousChapter:
                state.currentChapterIndex = max(state.currentChapterIndex - 1, 0)
                return .none
            case .setChapterIndex(let index):
                state.currentChapterIndex = index
                return .none
            }
        }
    }
}
