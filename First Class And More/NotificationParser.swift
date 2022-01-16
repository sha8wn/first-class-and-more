//
//  NotificationParser.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 6/13/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import Foundation

class NotificationParser {
    static let shared = NotificationParser()
    private init() { }
    
    func handleNotification(_ userInfo: [AnyHashable : Any]) -> DeeplinkType? {
        guard let urlString = userInfo["url"] as? String else { return nil }
        return DeeplinkType.webview(url: urlString)
    }
}
