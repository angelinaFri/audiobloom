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

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                bookCoverImage(viewStore)
                PlayerControlsView(store: self.store.scope(
                    state: \.playerControlState, action: \.playerControlAction)
                )
                BookModeSwitcher()
                    .padding(.vertical, 40)
                
            }
            .padding(.horizontal, 16)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.cream.ignoresSafeArea()
        }
    }

}

private extension HomeView {

    private func bookCoverImage(_ store: HomeFeatureViewStore) -> some View {
        AsyncImage(url: URL(string: store.book.coverPageImage)) { phase in
            if let image = phase.image {
                image.resizable().aspectRatio(contentMode: .fit)
            } else if phase.error != nil {
                Image(.emptyBook)
            } else {
                ProgressView()
            }
        }
        .cornerRadius(16)
        .padding(.horizontal, 64)
    }

}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State()) {
        HomeFeature(fetchBook: { Book.sample })
    })
}

