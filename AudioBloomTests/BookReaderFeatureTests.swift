//
//  BookReaderFeatureTests.swift
//  AudioBloomTests
//
//  Created by Angelina on 04.04.2024.
//

import XCTest
import ComposableArchitecture
@testable import AudioBloom

final class BookReaderFeatureTests: XCTestCase {

    @MainActor
    func testNextChapter() async {
        let store = TestStore(
            initialState: BookReaderFeature.State(book: .sample, currentChapterIndex: 0)
        ) {
            BookReaderFeature()
        }

        await store.send(.nextChapter) {
            $0.currentChapterIndex = 1
        }
    }

    @MainActor
    func testPreviousChapter() async {
        let store = TestStore(
            initialState: BookReaderFeature.State(book: .sample, currentChapterIndex: 1)
        ) {
            BookReaderFeature()
        }

        await store.send(.previousChapter) {
            $0.currentChapterIndex = 0
        }
    }

    @MainActor
    func testSetChapterIndexWithinBounds() async {
        let store = TestStore(
            initialState: BookReaderFeature.State(book: .sample, currentChapterIndex: 0)
        ) {
            BookReaderFeature()
        }

        await store.send(.setChapterIndex(2)) {
            $0.currentChapterIndex = 2
        }
    }

    @MainActor
    func testSetChapterIndexOutOfBounds() async {
        let store = TestStore(
            initialState: BookReaderFeature.State(book: .sample, currentChapterIndex: 0)
        ) {
            BookReaderFeature()
        }

        await store.send(.setChapterIndex(4)) {
            $0.currentChapterIndex = 2
        }
    }

    @MainActor
    func testNextChapterAtLastChapter() async {
        let lastChapterIndex = 2
        let store = TestStore(
            initialState: BookReaderFeature.State(book: .sample, currentChapterIndex: lastChapterIndex)
        ) {
            BookReaderFeature()
        }

        let initialState = store.state

        await store.send(.nextChapter)

        XCTAssertEqual(store.state.currentChapterIndex, initialState.currentChapterIndex, "The currentChapterIndex should not change when on the last chapter.")
    }

    @MainActor
    func testPreviousChapterAtFirstChapter() async {
        let store = TestStore(
            initialState: BookReaderFeature.State(book: .sample, currentChapterIndex: 0)
        ) {
            BookReaderFeature()
        }

        let initialState = store.state

        await store.send(.previousChapter)

        XCTAssertEqual(store.state.currentChapterIndex, initialState.currentChapterIndex, "The currentChapterIndex should not change when on the last chapter.")
    }

}



