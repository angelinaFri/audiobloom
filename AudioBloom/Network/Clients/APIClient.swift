//
//  APIClient.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import Foundation
import ComposableArchitecture

enum MockError: Error {
    case someError
}

@DependencyClient
struct APIClient {
    var fetchBook: @Sendable () async throws -> Book
}

extension APIClient: TestDependencyKey {
    static var previewValue: Self {
        return Self(
            fetchBook: {
                Book(
                    id: 1,
                    name: "Sample Book",
                    coverPageImage: URL(string: "https://example.com/sample.jpg"),
                    chapters: [
                        Chapter(
                            id: 1,
                            text: "This is the first chapter.",
                            audio: URL(string: "https://example.com/chapter1.mp3")!,
                            keyPoint: "Key point of chapter 1"
                        ),
                        Chapter(
                            id: 2,
                            text: "This is the second chapter.",
                            audio: URL(string: "https://example.com/chapter2.mp3")!,
                            keyPoint: "Key point of chapter 2"
                        )
                    ],
                    mode: .audio
                )
            }
        )
    }

    static let testValue = Self(
        fetchBook: {
            return try await Bundle.main.decode(Book.self, from: "book.json")
        }
    )

    static let testErrorValue = Self(
        fetchBook: {
            throw MockError.someError
        }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

