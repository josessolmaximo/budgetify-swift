//
//  Logger.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 21/12/22.
//

import Foundation
import FirebaseCrashlytics

class Logger {
    enum LogEvent: String {
        case e = "[DEBUG][‼️]" // error
        case i = "[DEBUG][ℹ️]" // info
        case d = "[DEBUG][💬]" // debug
        case v = "[DEBUG][🔬]" // verbose
        case w = "[DEBUG][⚠️]" // warning
        case s = "[DEBUG][🔥]" // severe
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    class func e(_ object: Any,// 1
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 function: String = #function) {
        #if DEBUG
        print("\(Date().toString) \(LogEvent.e.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(function) -> \(object)")
        #endif
    }
    
    class func i(_ object: Any,// 1
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 function: String = #function) {
        #if DEBUG
        print("\(Date().toString) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(function) -> \(object)")
        #endif
    }
    
    class func d(_ object: Any,// 1
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 function: String = #function) {
        #if DEBUG
        print("\(Date().toString) \(LogEvent.d.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(function) -> \(object)")
        #endif
    }
    
    class func v(_ object: Any,// 1
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 function: String = #function) {
        #if DEBUG
        print("\(Date().toString) \(LogEvent.v.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(function) -> \(object)")
        #endif
    }
    
    class func w(_ object: Any,// 1
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 function: String = #function) {
        #if DEBUG
        print("\(Date().toString) \(LogEvent.w.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(function) -> \(object)")
        #endif
    }
    
    class func s(_ object: Any,// 1
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 function: String = #function) {
        #if DEBUG
        print("\(Date().toString) \(LogEvent.s.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(function) -> \(object)")
        #endif
    }
}
