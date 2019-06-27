//
//  SFQLPreviewController.swift
//  First Class And More
//
//  Created by Shawn Frank on 6/26/19.
//  Copyright © 2019 Shawn Frank. All rights reserved.
//

import Foundation
import QuickLook

/*class SFQLPreviewController: QLPreviewController
{
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if self.QLNavigationBar!.isHidden {
            self.overlayNavigationBar?.isHidden = self.QLNavigationBar!.isHidden
        }
        
        dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.QLNavigationBar?.superview?.sendSubviewToBack(self.QLNavigationBar!)
            
            if !self.QLNavigationBar!.hidden {
                self.overlayNavigationBar?.hidden = self.QLNavigationBar!.hidden
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.handleNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.overlayNavigationBar?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 64.0)
    }
    
    var QLNavigationBar: UINavigationBar?
    var overlayNavigationBar: UINavigationBar?
    
    func getQLNavigationBar(fromView view: UIView) -> UINavigationBar? {
        for v in view.subviews {
            if v is UINavigationBar {
                return v as? UINavigationBar
            } else {
                if let navigationBar = self.getQLNavigationBar(fromView: (v )) {
                    return navigationBar
                }
            }
        }
        
        return nil
    }
    
    func handleNavigationBar() {
        self.QLNavigationBar = self.getQLNavigationBar(fromView: self.navigationController!.view)
        
        self.overlayNavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 64.0))
        self.overlayNavigationBar?.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        
        if let qln = self.QLNavigationBar {
            qln.addObserver(self, forKeyPath: "hidden", options: (NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue)), context: nil)
            qln.superview?.addSubview(self.overlayNavigationBar!)
        }
        
        let item = UINavigationItem(title: self.navigationItem.title!)
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: Selector(("doneBtnPressed")))
        
        item.leftBarButtonItem = doneBtn
        item.hidesBackButton = true
        
        self.overlayNavigationBar?.pushItem(item, animated: false)
        self.overlayNavigationBar?.tintColor = .white
        self.overlayNavigationBar?.barTintColor = .black
        self.overlayNavigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
}*/
