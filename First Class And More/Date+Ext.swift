//
//  Date+Ext.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 11/7/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

extension Date {
    func string(format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
		dateFormatter.locale = Locale(identifier: "de")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT +0:00")
        return dateFormatter.string(from: self)
    }
    
    func isLowerThan(_ date: Date, from days: Int) -> Bool {
        let beginDate = date.addingTimeInterval(TimeInterval(-days * 60 * 60 * 24))
        return self.compare(beginDate) == .orderedAscending
    }

    func isGreaterThan(_ date: Date, from days: Int) -> Bool {
        let beginDate = date.addingTimeInterval(TimeInterval(-days * 60 * 60 * 24))
        return self.compare(beginDate) == .orderedDescending
    }
}
