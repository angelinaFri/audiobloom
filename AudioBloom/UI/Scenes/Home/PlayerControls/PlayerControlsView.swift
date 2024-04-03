//
//  PlayerControlsView.swift
//  AudioBloom
//
//  Created by Angelina on 01.04.2024.
//

import SwiftUI
import ComposableArchitecture

typealias PlayerControlsFeatureViewStore = ViewStore<PlayerControlsFeature.State, PlayerControlsFeature.Action>

struct PlayerControlsView: View {
    let store: StoreOf<PlayerControlsFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    VStack(spacing: 4) {
                        keyPointCounter(viewStore)
                        keyPointView(viewStore)
                    }
                    sliderView(viewStore)
                    speedButton(viewStore)
                }
                playerControlButton(viewStore)
            }
        }
    }
}

private extension PlayerControlsView {

    func keyPointCounter(_ store: PlayerControlsFeatureViewStore) -> some View {
        HStack {
            Text("KEY POINT")
            Text("\(store.book.chapters[store.currentChapterIndex].id)")
            Text("OF")
            Text("\(store.book.chapters.count)")
        }
        .fontWeight(.medium)
        .foregroundColor(.secondary)
    }

    func keyPointView(_ store: PlayerControlsFeatureViewStore) -> some View {
        Text("\(store.book.chapters[store.currentChapterIndex].keyPoint)")
            .multilineTextAlignment(.center)
            .fontWeight(.medium)
            .padding(.horizontal, 32)
            .padding(.top, 8)
    }

    func sliderView(_ store: PlayerControlsFeatureViewStore) -> some View {
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
                in: 0...max(store.duration, 0.1)
            )
            .disabled(store.mode == .notPlaying)
            if let timeString = DateComponentsFormatter.minuteSecondFormatter.string(from: store.duration) {
                Text(timeString)
                    .frame(minWidth: 50)
                    .foregroundColor(.secondary).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            }
        }
    }

    func speedButton(_ store: PlayerControlsFeatureViewStore) -> some View {
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

    func playerControlButton(_ store: PlayerControlsFeatureViewStore) -> some View {
        HStack(spacing: 32) {
            Button(action: {
                store.send(.playBackward)
            }) {
                Image(systemName: "backward.end.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
            }
            .disabled(store.currentChapterIndex == 0)
            .opacity(store.currentChapterIndex == 0 ? 0.3 : 1)
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
                store.send(.playForward)
            }) {
                Image(systemName: "forward.end.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
            }
            .disabled(store.currentChapterIndex == store.book.chapters.count - 1)
            .opacity(store.currentChapterIndex == store.book.chapters.count - 1 ? 0.3 : 1)
        }
        .foregroundColor(.black)
        .padding(.top, 40)
    }
}

#Preview {
    PlayerControlsView(store: Store(initialState: PlayerControlsFeature.State()) {
        PlayerControlsFeature()
    })
}
