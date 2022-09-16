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
    
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            do {
                let myJson = try JSONSerialization.jsonObject(with: data,
                                                              options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                
                return myJson
                
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    func withoutHtmlTags() -> String {
        let str = self.replacingOccurrences(of: "<style>[^>]+</style>", with: "", options: .regularExpression, range: nil)
        return str.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
