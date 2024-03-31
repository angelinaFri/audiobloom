//
//  ConsoleLogger.swift
//  AudioBloom
//
//  Created by Angelina on 29.03.2024.
//

import Foundation

private let loggerQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "").logger.loggerQueue")

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "[dd-MM-yyyy, hh:mm:ss.SSS]"
    return formatter
}()

struct ConsoleLogger: LoggerOutput {

    func log(tag: String,
             message: @autoclosure () -> String,
             level: DLogger.LogLevel,
             function: String,
             file: String,
             line: Int,
             silent: Bool) {
        #if DEBUG
        guard !silent else { return }
        let msg = message()
        loggerQueue.async {
            let formattedDate = dateFormatter.string(from: .now)
            if tag.isEmpty {
                print(level.emoji, formattedDate, msg)
            } else {
                print(level.emoji, formattedDate, tag + ":", msg)
            }
        }
        #endif
    }

}
