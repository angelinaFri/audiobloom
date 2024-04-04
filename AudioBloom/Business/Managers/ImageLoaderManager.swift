//
//  ImageLoaderManager.swift
//  AudioBloom
//
//  Created by Angelina on 02.04.2024.
//

import Foundation
import Combine
import SwiftUI

class ImageLoaderManager: ObservableObject {
    private var cache = NSCache<NSURL, UIImage>()
    private var cancellable: AnyCancellable?
    
    @Published var image: UIImage?
    
    func loadImage(fromURL url: URL) {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image = $0
                if let image = $0 {
                    self?.cache.setObject(image, forKey: url as NSURL)
                }
            }
    }
}
