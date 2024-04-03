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
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack {
                if viewStore.state.isReaderMode {
                    Button(action: {
                        viewStore.send(.togglePlayPause)
                    }) {
                        Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
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
                        viewStore.send(.toggleMode)
                    }) {
                        Image(systemName: "headphones")
                            .configured(for: !viewStore.state.isReaderMode)
                    }

                    Button(action: {
                        viewStore.send(.toggleMode)
                    }) {
                        Image(systemName: "text.alignleft")
                            .configured(for: viewStore.state.isReaderMode)
                    }
                }
                .background(Capsule().foregroundColor(.white))
                .padding(.all, 4)
                .overlay(
                    Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
                .animation(.easeInOut(duration: 0.35), value: viewStore.book.mode)
            }
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
