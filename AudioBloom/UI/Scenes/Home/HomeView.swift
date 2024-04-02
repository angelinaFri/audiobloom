//
//  HomeView.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import SwiftUI
import ComposableArchitecture

typealias HomeFeatureViewStore = ViewStore<HomeFeature.State, HomeFeature.Action>

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.book.mode == .audio {
                    VStack {
                        bookCoverImage(viewStore)
                            .padding(.vertical, 40)
                        PlayerControlsView(store: self.store.scope(
                            state: \.playerControlState,
                            action: \.playerControlAction)
                        )
                        Spacer()
                    }
                } else {
                    BookReaderView(store: self.store.scope(
                        state: \.bookReaderState,
                        action: \.bookReaderAction)
                    )
                }

                VStack {
                    Spacer()
                    BookModeSwitcher(store: self.store.scope(
                        state: \.bookModeState,
                        action: \.bookModeSwitcherAction)
                    )
                    .padding(.top, 40)
                    .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 16)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cream.ignoresSafeArea())
    }

}

private extension HomeView {

    @ViewBuilder
    func bookCoverImage(_ store: HomeFeatureViewStore) -> some View {
        if let url = URL(string: store.book.coverPageImage) {
            CachedAsyncImage(url: url)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .padding(.horizontal, 64)
        } else {
            Image(.emptyBook)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .padding(.horizontal, 64)
        }
    }

}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State()) {
        HomeFeature(fetchBook: { Book.sample })
    })
}

