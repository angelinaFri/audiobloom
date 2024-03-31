//
//  APIClient.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import Foundation
import ComposableArchitecture

struct APIClient {
    var fetchBook: @Sendable () async throws -> Book

    struct Failure: Error, Equatable {}
}

extension APIClient {
    static let live = Self(
        fetchBook: {
            return try await Bundle.main.decode(Book.self, from: "book.json")
        }
    )
}
