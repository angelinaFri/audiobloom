//
//  LiveAPIClient.swift
//  AudioBloom
//
//  Created by Angelina on 03.04.2024.
//

import Dependencies
import Foundation

extension APIClient: DependencyKey {
    static let liveValue = Self(
        fetchBook: {
            // Implement fetching a book from a real source, for example, a network request
            return try await Bundle.main.decode(Book.self, from: "book.json")
        }
    )
}
