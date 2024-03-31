//
//  RootView.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import SwiftUI

import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootFeature>

    @State private var sliderValue: Double = .zero

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                VStack(spacing: 40) {
                    AsyncImage(url: URL(string: viewStore.book.coverPageImage)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if phase.error != nil {
                            Image(.emptyBook)
                        } else {
                            ProgressView()
                        }
                    }
                    .cornerRadius(16)
                    .padding(.horizontal, 64)
                    HStack {
                        Text("KEY POINT")
                        Text("\(viewStore.book.chapters[0].id)")
                        Text("OF")
                        Text("\(viewStore.book.chapters[0].id)")
                    }
                }
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                VStack(spacing: 12) {
                    Text("\(viewStore.book.chapters[0].keyPoint)")
                        .multilineTextAlignment(.center)
                        .fontWeight(.medium)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                    HStack {
                        if let timeString = DateComponentsFormatter.minuteSecondFormatter.string(from: viewStore.currentTime) {
                            Text(timeString)
                                .frame(minWidth: 50)
                                .foregroundColor(.secondary).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        }
                        Slider(
                            value: Binding(
                                get: { viewStore.currentTime },
                                set: { newTime in
                                    viewStore.send(.sliderToTime(newTime))
                                }
                            ),
                            in: 0...max(viewStore.duration, 1)
                        )
                        .disabled(viewStore.mode == .notPlaying)
                        if let timeString = DateComponentsFormatter.minuteSecondFormatter.string(from: viewStore.duration) {
                            Text(timeString)
                                .frame(minWidth: 50)
                                .foregroundColor(.secondary).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        }
                    }
                    Text("Speed x1")
                        .fontWeight(.bold)
                        .font(.subheadline)
                        .padding(12)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
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
                        viewStore.send(.rewind)
                    }) {
                        Image(systemName: "gobackward.5")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }

                    Button(action: {
                        viewStore.send(.playButtonTapped)
                    }) {
                        Image(systemName: store.mode.is(\.playing) ? "pause.fill" : "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 34, height: 34)
                    }

                    Button(action: {
                        viewStore.send(.fastForward)
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
                CustomSwitcher()
                    .padding(.vertical, 40)

            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.cream.ignoresSafeArea() }
    }
}

#Preview {
    RootView(store: Store(initialState: RootFeature.State()) {
        RootFeature(fetchBook: { Book.sample })
    })
}

struct CustomSwitcher: View {
    @State private var isSelected: Bool = false // false for headphones, true for text.alignleft
    @State private var isPlaying: Bool = false

    var body: some View {
        HStack {
            // Conditional play/pause button
            if isSelected {
                Button(action: {
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
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
                    withAnimation {
                        isSelected = false
                    }
                }) {
                    Image(systemName: "headphones")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(!isSelected ? .white : .black)
                        .padding(16)
                        .background(!isSelected ? Color.blue : Color.clear)
                        .clipShape(Circle())
                }

                Button(action: {
                    withAnimation {
                        isSelected = true
                    }
                }) {
                    Image(systemName: "text.alignleft")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(16)
                        .foregroundColor(isSelected ? .white : .black)
                        .background(isSelected ? Color.blue : Color.clear)
                        .clipShape(Circle())
                }
            }
            .background(Capsule().foregroundColor(.white))
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
            .animation(.easeInOut(duration: 0.35), value: isSelected)
        }
    }
}



