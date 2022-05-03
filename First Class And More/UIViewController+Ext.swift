//
//  UIViewController+Ext.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/18/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import Foundation
import PopupDialog
import NVActivityIndicatorView

extension UIViewController: NVActivityIndicatorViewable {
    // popup
    func showPopupDialog(title: String? = nil, message: String? = nil, cancelBtn: Bool = true, okBtnTitle: String? = nil, okBtnCompletion: (() -> Void)? = nil) {
        // dialog appearance
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor      = .white
        dialogAppearance.titleFont            = UIFont(name: "Roboto-Medium", size: 20.0)!
        dialogAppearance.titleColor           = .black
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont(name: "Roboto-Regular", size: 16.0)!
        dialogAppearance.messageColor         = .darkGray
        dialogAppearance.messageTextAlignment = .center
        // buttons appearance
        let defaultBtnAppearance        = DefaultButton.appearance()
        defaultBtnAppearance.titleFont  = UIFont(name: "Roboto-Regular", size: 14.0)!
        defaultBtnAppearance.titleColor = fcamBlue
        let cancelBtnAppearance         = CancelButton.appearance()
        cancelBtnAppearance.titleFont   = UIFont(name: "Roboto-Regular", size: 14.0)!
        cancelBtnAppearance.titleColor  = fcamDarkGold
        // creating popup
        let popup = PopupDialog(title: title,
                                message: message,
                                tapGestureDismissal: cancelBtn,
                                panGestureDismissal: cancelBtn)
        
        popup.buttonAlignment = .horizontal
        popup.transitionStyle = .bounceUp
        let okBtn = DefaultButton(title: okBtnTitle ?? "OK") {
            okBtnCompletion?()
        }
        if cancelBtn {
            let cancelBtn = CancelButton(title: "ABBRECHEN".uppercased(), action: nil)
            popup.addButtons([cancelBtn, okBtn])
        } else {
            okBtn.dismissOnTap = false
            popup.addButtons([okBtn])
        }
        present(popup, animated: true, completion: nil)
    }
    
    // spinner
    func startLoading(message: String? = nil) {
        let size = UIScreen.main.bounds.height * 0.05
        let spinnerSize = CGSize(width: size, height: size)
        let messageFont = UIFont(name: "RobotoCondensed-Regular", size: 14.0)
        startAnimating(
            spinnerSize,
            message: message,
            messageFont: messageFont,
            type: .ballTrianglePath,
            color: fcamGold,
            textColor: fcamGold
        )
    }
    
    func stopLoading() {
        stopAnimating()
    }
    
    // check internet connection
    func isConnectedToNetwork(repeatedFunction: (() -> Void)?) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let reach = appDelegate.reach else {
            return false
        }        
        let condition = reach.isReachableViaWiFi() || reach.isReachableViaWWAN()
        if !condition {
            showPopupDialog(
                title: "Ein Fehler ist aufgetreten..",
                message: "Bitte sorgen Sie für eine stabile Internet-Verbindung",
                okBtnCompletion: repeatedFunction
            )
        }
        return condition
    }
}
