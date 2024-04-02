//
//  BookModeSwitcher.swift
//  AudioBloom
//
//  Created by Angelina on 31.03.2024.
//

import SwiftUI

struct BookModeSwitcher: View {
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

#Preview {
    BookModeSwitcher()
}
