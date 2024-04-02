//
//  CashedAsyncImage.swift
//  AudioBloom
//
//  Created by Angelina on 02.04.2024.
//

import SwiftUI

struct CachedAsyncImage: View {

    @StateObject private var loader = ImageLoaderManager()
    let url: URL

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loader.loadImage(fromURL: url)
        }
    }
}

#Preview {
    CachedAsyncImage(url: URL(string: Book.sample.coverPageImage)!)
}
