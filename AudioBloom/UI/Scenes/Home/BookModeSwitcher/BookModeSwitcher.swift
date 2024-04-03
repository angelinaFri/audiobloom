//
//  BookModeSwitcher.swift
//  AudioBloom
//
//  Created by Angelina on 31.03.2024.
//

import SwiftUI
import ComposableArchitecture

struct BookModeSwitcher: View {
    let store: StoreOf<BookModeSwitcherFeature>

    var body: some View {
        HStack {
            if store.state.isReaderMode {
                Button(action: {
                    store.send(.togglePlayPause)
                }) {
                    Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(.white)
                        .clipShape(Circle())
                        .overlay(
                            Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        )
                }
                .transition(.scale)
            }
            HStack(spacing: 8) {
                Button(action: {
                    store.send(.toggleMode)
                }) {
                    Image(systemName: "headphones")
                        .configured(for: !store.state.isReaderMode)
                }

                Button(action: {
                    store.send(.toggleMode)
                }) {
                    Image(systemName: "text.alignleft")
                        .configured(for: store.state.isReaderMode)
                }
            }
            .background(Capsule().foregroundColor(.white))
            .padding(.all, 4)
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
            .animation(.easeInOut(duration: 0.35), value: store.book.mode)
        }
    }
}

#Preview {
    BookModeSwitcher(store: Store(initialState: BookModeSwitcherFeature.State()) {
        BookModeSwitcherFeature()
    })
}

private extension Image {
    func configured(for isSelected: Bool) -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .padding(16)
            .foregroundColor(isSelected ? .white : .black)
            .background(isSelected ? Color.blue : Color.clear)
            .clipShape(Circle())
    }
}
