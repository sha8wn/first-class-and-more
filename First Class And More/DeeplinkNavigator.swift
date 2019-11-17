//
//  DeeplinkNavigator.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 6/13/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import Foundation
import UIKit

class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    private init() { }

    private var alertController = UIAlertController()

    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        case .webview(var url):
            
            //print(UIApplication.shared.keyWindow?.rootViewController)
            guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? SFSidebarNavigationController else { return }
            let token = UserModel.sharedInstance.token
            
            if url.contains("/blog/mobile/") {
                
                if !token.isEmpty {
                    url += "&t=\(token)"
                }
                
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            navigationController.webVC = storyboard.instantiateViewController(withIdentifier: "WebVC") as! WKWebViewController
            navigationController.webVC.urlString = url
            navigationController.setViewControllers([navigationController.webVC], animated: true)
        
        case .appLogin:
            guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? SFSidebarNavigationController else { return }
            navigationController.loginVC.shouldReturn = true
            navigationController.setViewControllers([navigationController.loginVC], animated: true)
        }
    }
}
