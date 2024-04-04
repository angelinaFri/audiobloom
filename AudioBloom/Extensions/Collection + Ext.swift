//
//  Collection + Ext.swift
//  AudioBloom
//
//  Created by Angelina on 03.04.2024.
//

import Foundation

extension Collection {

    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
