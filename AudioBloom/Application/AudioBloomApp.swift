//
//  AudioBloomApp.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct AudioBloomApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(store: Store(initialState: HomeFeature.State()) {
                HomeFeature.liveBook
            })
        }
    }
}

