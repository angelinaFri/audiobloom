//
//  DateComponentsFormatter + Ext.swift
//  AudioBloom
//
//  Created by Angelina on 30.03.2024.
//

import Foundation

extension DateComponentsFormatter {

    static var minuteSecondFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

}
