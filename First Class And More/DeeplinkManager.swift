//
//  DeeplinkManager.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 6/13/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import Foundation

let Deeplinker = DeepLinkManager()
class DeepLinkManager {
    fileprivate init() {}

    private var deeplinkType: DeeplinkType?

    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
        // reset deeplink after handling
        self.deeplinkType = nil
    }

    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }

    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        deeplinkType = NotificationParser.shared.handleNotification(notification)
    }
}
