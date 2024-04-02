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
        case swipeChapter
    }
}
