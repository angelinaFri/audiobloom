//
//  Double + Ext.swift
//  AudioBloom
//
//  Created by Angelina on 31.03.2024.
//

import Foundation

extension Double {
    /// Converts the double to a string, showing as an integer if there's no fractional part,
    /// or with its fractional part if it's not a whole number.
    func asString() -> String {
        if self == floor(self) {
            // Whole number, show as integer
            return String(format: "%d", Int(self))
        } else {
            // Has fractional part, show with minimal decimal digits necessary
            return self.truncatingRemainder(dividingBy: 1) == 0.5 ?
                   String(format: "%.1f", self) :
                   String(format: "%.2f", self)
        }
    }
}
