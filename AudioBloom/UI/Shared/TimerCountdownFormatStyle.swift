//
//  TimerCountdownFormatStyle.swift
//  AudioBloom
//
//  Created by Angelina on 03.04.2024.
//

import Foundation
import SwiftUI

struct TimerCountdownFormatStyle: FormatStyle {
    func format(_ value: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        let timeInterval = TimeInterval(value)
        return formatter.string(from: timeInterval) ?? "0:00"
    }
}

extension FormatStyle where Self == TimerCountdownFormatStyle {

    static var timerCountdown: TimerCountdownFormatStyle { TimerCountdownFormatStyle() }

}
