//
//  BookReaderView.swift
//  AudioBloom
//
//  Created by Angelina on 02.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct BookReaderView: View {
    let store: StoreOf<BookReaderFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("Book text")
        }
    }
}

#Preview {
    BookReaderView(store: Store(initialState: BookReaderFeature.State()) {
        BookReaderFeature()
    })
}
