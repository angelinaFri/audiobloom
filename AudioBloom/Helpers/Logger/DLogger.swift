//
//  DLogger.swift
//  AudioBloom
//
//  Created by Angelina on 29.03.2024.
//

import Foundation

struct DLogger {
    let identifier: String
    let outputs: [LoggerOutput]
    let silent: Bool

    init(identifier: String = "", outputs: [LoggerOutput] = [ConsoleLogger()], silent: Bool = false) {
        self.identifier = identifier
        self.outputs = outputs
        self.silent = silent
    }
}

extension DLogger {

    func debug(_ message: @autoclosure () -> String,
               function: String = #function,
               file: String = #file,
               line: Int = #line) {
        log(message(), level: .debug, function: function, file: file, line: line, silent: silent)
    }

    func error(_ message: @autoclosure () -> String,
               function: String = #function,
               file: String = #file,
               line: Int = #line) {
        log(message(), level: .error, function: function, file: file, line: line, silent: silent)
    }

    func critical(_ message: @autoclosure () -> String,
                  function: String = #function,
                  file: String = #file,
                  line: Int = #line) {
        log(message(), level: .critical, function: function, file: file, line: line, silent: silent)
    }

    func warning(_ message: @autoclosure () -> String,
                 function: String = #function,
                 file: String = #file,
                 line: Int = #line) {
        log(message(), level: .warning, function: function, file: file, line: line, silent: silent)
    }

    func info(_ message: @autoclosure () -> String,
              function: String = #function,
              file: String = #file,
              line: Int = #line) {
        log(message(), level: .info, function: function, file: file, line: line, silent: silent)
    }

    func log(_ message: @autoclosure () -> String,
             level: LogLevel,
             function: String = #function,
             file: String = #file,
             line: Int = #line,
             silent: Bool) {
        for output in outputs {
            output.log(tag: identifier, message: message(), level: level, function: function, file: file, line: line, silent: silent)
        }
    }

}

extension DLogger {

    enum LogLevel {
        case debug
        /// When we get an error. Usually we get it from a service and it's good place to use it there
        case error
        /// When unexpected behaviour.
        /// It has significant affect on a user. Should be investigated and maybe fixed
        case critical
        /// Something like an error but less important, just good to know that it happened.
        /// It doesn't have significant affect on a user but should be reviewed by a developer
        case warning
        /// When good to see what happened or what we passed.
        /// Let's say, you signed in, then we can print some user data using info: name, id, etc
        case info

        var emoji: String {
            switch self {
            case .debug: return "🤖"
            case .error: return "🤬"
            case .critical: return "🤯"
            case .warning: return "🧐"
            case .info: return "ℹ️"
            }
        }
    }
}

protocol LoggerOutput {
    func log(tag: String,
             message: @autoclosure () -> String,
             level: DLogger.LogLevel,
             function: String,
             file: String,
             line: Int,
             silent: Bool)
}

