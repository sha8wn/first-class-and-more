//
//  WKWebViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/25/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class WKWebViewController: SFSidebarViewController, UIWebViewDelegate {
    
    var webView: UIWebView!
    var toolBar: UIToolbar!
    var backBarButton, forwardBarButton, reloadBarButton: UIBarButtonItem!
    var favoriteBtn: UIButton?
    
    var deal: DealModel?
    var dealType: DealType?
    var slide: SlideModel?
    var urlString: String?
    
    var pageLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        if #available(iOS 11.0, *) {
            
            if toolBar == nil {
                toolBar = UIToolbar()
            }
            
            print(self.view.safeAreaInsets.bottom)
            toolBar.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.height - self.view.safeAreaInsets.bottom - 64.0 - toolBar.frame.height, width: UIScreen.main.bounds.width, height: toolBar.frame.height)
            
        }
        
        
    }
    
    func setupUI() {
        webView = UIWebView(
            frame: CGRect(
                x: 0, y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height - 64.0 - 44.0 // status bar, nav bar and toolbar
            )
        )
        webView.delegate = self
        webView.dataDetectorTypes = .all
        webView.scalesPageToFit = true
        view.addSubview(webView)
        // toolbar
        toolBar               = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor     = fcamBlue
        toolBar.sizeToFit()
        
        if #available(iOS 11.0, *) {
            
        } else {
            // Fallback on earlier versions
            toolBar.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.height - 64.0 - toolBar.frame.height, width: UIScreen.main.bounds.width, height: toolBar.frame.height)
        }
        
        toolBar.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.height - 64.0 - toolBar.frame.height, width: UIScreen.main.bounds.width, height: toolBar.frame.height)
        backBarButton     = UIBarButtonItem(image: #imageLiteral(resourceName: "chevron-left"), style: .plain, target: self, action: #selector(backBtnPressed))
        forwardBarButton  = UIBarButtonItem(image: #imageLiteral(resourceName: "chevron-right"), style: .plain, target: self, action: #selector(forwardBtnPressed))
        reloadBarButton   = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshBtnPressed))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([backBarButton, forwardBarButton, flexibleWidth, reloadBarButton], animated: false)
        view.addSubview(toolBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backBtn.setImage(#imageLiteral(resourceName: "backBtn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBarBtnPressed), for: .touchUpInside)
        let backBarBtnItem = UIBarButtonItem(customView: backBtn)
        navigationItem.setLeftBarButton(backBarBtnItem, animated: false)
        navigationItem.rightBarButtonItem = nil
        if let deal = deal {
            if UserModel.sharedInstance.logined, let id = deal.id {
                favoriteBtn = UIButton(type: .custom)
                favoriteBtn!.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
                let user = UserModel.sharedInstance
                favoriteBtn!.setImage(user.favorites.contains(id) ? #imageLiteral(resourceName: "FavoriteButtonRed") : #imageLiteral(resourceName: "FavoriteButtonWhite"), for: .normal)
                favoriteBtn!.addTarget(self, action: #selector(favoriteBtnPressed), for: .touchUpInside)
                let favoriteBarBtnItem = UIBarButtonItem(customView: favoriteBtn!)
                navigationItem.setRightBarButton(favoriteBarBtnItem, animated: false)
            }
            let leftBtn = UIButton(type: .custom)
            leftBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            leftBtn.setImage(#imageLiteral(resourceName: "backBtn"), for: .normal)
            leftBtn.addTarget(self, action: #selector(leftBtnPressed), for: .touchUpInside)
            let leftBarBtnItem = UIBarButtonItem(customView: leftBtn)
            navigationItem.setLeftBarButton(leftBarBtnItem, animated: false)
        }
        if !pageLoaded {
            pageLoaded = true
            loadNeededPage()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pageLoaded = false
    }
    
    @objc func backBarBtnPressed() {
        if let navigationVC = navigationController as? SFSidebarNavigationController, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restartTimer()
            navigationVC.setViewControllers([navigationVC.homeVC], animated: true)
        }
    }
    
    func loadNeededPage() {
        if let deal = deal, let urlString = deal.url, let url = URL(string: urlString) {
            startLoading()
            webView.loadRequest(URLRequest(url: url))
        } else if let slide = slide, let urlString = slide.url, let url = URL(string: urlString) {
            startLoading()
            webView.loadRequest(URLRequest(url: url))
        } else if let urlString = urlString {
            if let url = URL(string: urlString) {
                startLoading()
                webView.loadRequest(URLRequest(url: url))
            }
        }
    }
    
    @objc func leftBtnPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backBtnPressed() {
        webView.goBack()
    }
    
    @objc func forwardBtnPressed() {
        webView.goForward()
    }
    
    @objc func refreshBtnPressed() {
        webView.reload()
    }
    
    func updateButtons(_ reload: Bool) {
        backBarButton.isEnabled    = webView.canGoBack
        forwardBarButton.isEnabled = webView.canGoForward
        reloadBarButton.isEnabled  = reload
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        updateButtons(false)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopLoading()
        updateButtons(true)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        stopLoading()
        updateButtons(true)
    }
    
    // favorite btn press
    @objc func favoriteBtnPressed() {
        if let dealId = deal?.id {
            let favorites = UserModel.sharedInstance.favorites
            if favorites.contains(dealId) {
                deleteFavorite(id: dealId)
            } else {
                addFavorite(id: dealId)
            }
        }
    }
    
    // delete deal from favorites
    func deleteFavorite(id: Int) {
        if isConnectedToNetwork(repeatedFunction: { self.deleteFavorite(id: id) }) {
            startLoading()
            Server.shared.deleteFavorite(id: id) { success, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else {
                        if let success = success as? Bool, success {
                            let user = UserModel.sharedInstance
                            if let indexOfFavorite = user.favorites.index(of: id) {
                                self.favoriteBtn?.setImage(#imageLiteral(resourceName: "FavoriteButtonWhite"), for: .normal)
                                user.favorites.remove(at: indexOfFavorite)
                                let data     = NSKeyedArchiver.archivedData(withRootObject: user)
                                let defaults = UserDefaults.standard
                                defaults.set(data, forKey: kUDSharedUserModel)
                                defaults.synchronize()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addFavorite(id: Int) {
        if isConnectedToNetwork(repeatedFunction: { self.addFavorite(id: id) }) {
            startLoading()
            Server.shared.addFavorite(id: id) { success, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else {
                        if let success = success as? Bool, success {
                            let user = UserModel.sharedInstance
                            user.favorites.append(id)
                            self.favoriteBtn?.setImage(#imageLiteral(resourceName: "FavoriteButtonRed"), for: .normal)
                            let data     = NSKeyedArchiver.archivedData(withRootObject: user)
                            let defaults = UserDefaults.standard
                            defaults.set(data, forKey: kUDSharedUserModel)
                            defaults.synchronize()
                        }
                    }
                }
            }
        }
    }
}
