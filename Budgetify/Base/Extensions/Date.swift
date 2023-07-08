//
//  Date.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 25/11/22.
//

import Foundation

extension Date {
    var getMonthString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        return dateFormatter.string(from: self)
    }
    
    var getDateAndMonthString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: self)
    }
    
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM YYYY"
        return dateFormatter.string(from: self)
    }
    
    var toShortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        return dateFormatter.string(from: self)
    }
    
    var toHourAndMinute: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
    }
    
    var getYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }
    
    func removeTimeValue() -> Date {
        let timeInterval = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!.timeIntervalSince1970
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    var removedTime: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    var startOfDay: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    
    var startOfWeek: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = SettingsManager.shared.startOfWeekAS
        
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        
        return calendar.date(byAdding: .day, value: 0, to: sunday!)!
    }
    
    var endOfWeek: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = SettingsManager.shared.startOfWeekAS
        
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        
        return calendar.date(byAdding: .day, value: 6, to: sunday!)!
    }
    
    var startOfYear: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: self)))!
    }
    
    var endOfYear: Date {
        return Calendar.current.date(bySetting: .month, value: 12, of: self.startOfYear)!
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    var setTimeToZero: Date {
        //TODO: Check if this is necessary
        let df = DateFormatter()
        
        df.dateFormat = "dd/MM/yyyy HH.mm"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        return df.date(from: self.formatted()) ?? Date()
    }
    
    var formattedWithoutYear: String {
        let df = DateFormatter()
        
        df.dateFormat = "EEEE, d MMMM"
         
        return df.string(from: self)
    }
    
    var addOneSecond: Date {
        if let newDate = Calendar.current.date(byAdding: .second, value: 1, to: self){
            return newDate
        } else {
            return self
        }
    }
}

extension Date {
    func formatAs(_ format: DateFormat) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        
        return formatter.string(from: self)
    }
    
    enum DateFormat: String {
        case date = "d"
        case day = "E"
        case shortMonth = "MMM"
        case dateString = "d MMMM YYYY"
        case hourAndMinute = "HH:mm"
        case dayAndShortMonth = "d MMM"
        case dateSeperatedByHyphen = "d-MM-YYYY"
    }
}
