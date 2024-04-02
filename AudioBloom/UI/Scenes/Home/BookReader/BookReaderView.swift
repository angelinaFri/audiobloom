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
               NavigationStack {
                   TabView(selection: viewStore.binding(
                       get: \.currentChapterIndex,
                       send: BookReaderFeature.Action.setChapterIndex
                   )) {
                       ForEach(Array(viewStore.book.chapters.enumerated()), id: \.element.id) { index, chapter in
                           ScrollView {
                               VStack(spacing: 16) {
                                   Text(chapter.keyPoint)
                                       .font(.title2)
                                       .fontWeight(.medium)
                                       .multilineTextAlignment(.leading)
                                       .frame(maxWidth: .infinity, alignment: .leading)
                                   Text(chapter.text)
                               }
                               .padding()
                               .tag(index)
                           }
                       }
                   }
                   .tabViewStyle(PageTabViewStyle())
                   .navigationTitle(viewStore.book.name)
               }
           }
       }
}

#Preview {
    BookReaderView(store: Store(initialState: BookReaderFeature.State()) {
        BookReaderFeature()
    })
}
