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
                VStack(spacing: 40) {
                    bookCoverImage(viewStore)
                    keyPointCounter(viewStore)
                }
                VStack(spacing: 12) {
                    keyPointView(viewStore)
                    sliderView(viewStore)
                    speedButton(viewStore)
                }
                playerControlButton(viewStore)
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

    private func keyPointCounter(_ store: HomeFeatureViewStore) -> some View {
        HStack {
            Text("KEY POINT")
            Text("\(store.book.chapters[0].id)")
            Text("OF")
            Text("\(store.book.chapters[0].id)")
        }
        .fontWeight(.medium)
        .foregroundColor(.secondary)
    }

    private func keyPointView(_ store: HomeFeatureViewStore) -> some View {
        Text("\(store.book.chapters[0].keyPoint)")
            .multilineTextAlignment(.center)
            .fontWeight(.medium)
            .padding(.horizontal, 32)
            .padding(.top, 8)
    }

    private func sliderView(_ store: HomeFeatureViewStore) -> some View {
        HStack {
            if let timeString = DateComponentsFormatter.minuteSecondFormatter.string(from: store.currentTime) {
                Text(timeString)
                    .frame(minWidth: 50)
                    .foregroundColor(.secondary).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            }
            Slider(
                value: Binding(
                    get: { store.currentTime },
                    set: { newTime in
                        store.send(.sliderToTime(newTime))
                    }
                ),
                in: 0...max(store.duration, 1)
            )
            .disabled(store.mode == .notPlaying)
            if let timeString = DateComponentsFormatter.minuteSecondFormatter.string(from: store.duration) {
                Text(timeString)
                    .frame(minWidth: 50)
                    .foregroundColor(.secondary).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            }
        }
    }

    private func speedButton(_ store: HomeFeatureViewStore) -> some View {
        Button(action: {
            store.send(.changeSpeed)
        }) {
            Text("Speed \(store.currentSpeed.asString())x")
                .fontWeight(.bold)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(12)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func playerControlButton(_ store: HomeFeatureViewStore) -> some View {
        HStack(spacing: 32) {
            Button(action: {
                // Action for playing backward
            }) {
                Image(systemName: "backward.end.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
            }

            Button(action: {
                store.send(.rewind)
            }) {
                Image(systemName: "gobackward.5")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }

            Button(action: {
                store.send(.playButtonTapped)
            }) {
                Image(systemName: store.mode.is(\.playing) ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
            }

            Button(action: {
                store.send(.fastForward)
            }) {
                Image(systemName: "goforward.10")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }

            Button(action: {
                // forward item
            }) {
                Image(systemName: "forward.end.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
            }
        }
        .foregroundColor(.black)
        .padding(.top, 40)
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State()) {
        HomeFeature(fetchBook: { Book.sample })
    })
}



