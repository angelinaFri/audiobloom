//
//  HomeFeatureTests.swift
//  AudioBloomTests
//
//  Created by Angelina on 05.04.2024.
//

import XCTest
import ComposableArchitecture
@testable import AudioBloom

final class HomeFeatureTests: XCTestCase {

    @MainActor
    func testBookFetchFailure() async {
        let store = TestStore(
            initialState: HomeFeature.State(book: .idle)
        ) {
            HomeFeature()
        } withDependencies: {
            $0.apiClient = .testErrorValue
        }

        await store.send(.onAppear)

        await store.receive(/.bookFetched(.failure(MockError.someError)))

        await store.finish(timeout: .seconds(5))
    }
}
