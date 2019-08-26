//
//  String+Extension.swift
//  First Class And More
//
//  Created by Shawn Frank on 8/26/19.
//  Copyright © 2019 Shawn Frank. All rights reserved.
//

import Foundation

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: "\n", replacement: "")
    }
}
