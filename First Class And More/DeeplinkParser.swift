//
//  DeeplinkParser.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 6/13/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import Foundation

class DeeplinkParser {

    static let shared = DeeplinkParser()
    private init() { }

    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        if let queryItems = components.queryItems {
            for item in queryItems {
                switch item.name {
                case "url":
                    guard let urlString = item.value else { return nil }
                    return DeeplinkType.webview(url: urlString)
                default:
                    break
                }
            }
        } else if let host = components.host {
            switch host {
            case "app_login":
                return DeeplinkType.appLogin
            default:
                break
            }
        }
        return nil
    }
}
