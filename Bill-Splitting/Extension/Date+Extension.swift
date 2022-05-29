//
//  Date+Extension.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/19.
//

import UIKit

extension Date {
    
    static func countComponent(component: Calendar.Component, startDate: Date, endDate: Date) -> Int {
        let components = Calendar.current.dateComponents([component], from: startDate, to: endDate)
        if component == .month {
            let month = components.month ?? 0
            return month
        } else {
            let year = components.year ?? 0
            return year
        }
    }
    
    static func updateDateTimestamp(component: Calendar.Component, startDate: Date) -> Double {
        var dateComponent = DateComponents()
        
        if component == .month {
            dateComponent.month = 1
        } else if component == .year {
            dateComponent.year = 1
        }
        let startDate = Calendar.current.date(byAdding: dateComponent, to: startDate) ?? Date()
        let newDate = startDate.timeIntervalSince1970
        return newDate
    }
    
    static func getTimeDate(timeStamp: Double) -> Date {
        let timeStamp = timeStamp
        let timeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        return date
    }
    
    static func getTimeString(timeStamp: Double) -> String {
        let timeStamp = timeStamp
        let timeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let time = dateFormatter.string(from: date)
        return time
    }
}
