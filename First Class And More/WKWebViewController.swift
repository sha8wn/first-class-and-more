//
//  WKWebViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/25/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: SFSidebarViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var toolBar: UIToolbar!
    var backBarButton, forwardBarButton, reloadBarButton: UIBarButtonItem!
    var favoriteBtn: UIButton?
    var urlAdd: UILabel!
    
    @IBOutlet weak var urlAddress: UILabel!
    var deal: DealModel?
    var dealType: DealType?
    var slide: SlideModel?
    var urlString: String?
    
    var pageLoaded: Bool = false
    
    var isUISetup: Bool = false
    
    var isDisplayingPromotion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willDisplayPromotion(_:)), name: Notification.Name("promotionWillDisplay"), object: nil)
    }
    
    @objc func willDisplayPromotion(_ notification: Notification)
    {
        isDisplayingPromotion = true
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
        
        // https://stackoverflow.com/questions/25977764/wkwebkit-no-datadetectortypes-parameter
        let webviewConfiguration = WKWebViewConfiguration.init()
        webviewConfiguration.dataDetectorTypes = .all
        
        webView = WKWebView(
            frame: CGRect(
                x: 0, y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height - 64.0 - 44.0 // status bar, nav bar and toolbar
            ), configuration: webviewConfiguration)
        
        webView.navigationDelegate = self
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        webView.evaluateJavaScript(jScript, completionHandler: nil)
        
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
        
        var navigationBarHeight = self.navigationController?.navigationBar.frame.height
        
        if #available(iOS 13.0, *) {
            navigationBarHeight! += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                } else {
                    navigationBarHeight! += UIApplication.shared.statusBarFrame.height
                }
        
        toolBar.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.height - navigationBarHeight! - toolBar.frame.height, width: UIScreen.main.bounds.width, height: toolBar.frame.height)
        backBarButton     = UIBarButtonItem(image: #imageLiteral(resourceName: "chevron-left"), style: .plain, target: self, action: #selector(backBtnPressed))
        forwardBarButton  = UIBarButtonItem(image: #imageLiteral(resourceName: "chevron-right"), style: .plain, target: self, action: #selector(forwardBtnPressed))
        reloadBarButton   = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshBtnPressed))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([backBarButton, forwardBarButton, flexibleWidth, reloadBarButton], animated: false)
        view.addSubview(toolBar)
        
        /* To check URL
        urlAdd = UILabel.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 100))
        urlAdd.textColor = .black
        urlAdd.numberOfLines = 0
        view.addSubview(urlAdd)*/
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
        
        if !isUISetup {
            setupUI()
            isUISetup = true
        }
        
        if !pageLoaded {
            pageLoaded = true
            loadNeededPage()
        }
        
        
        
        //self.urlAdd.text = urlString
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
        
        if !isDisplayingPromotion {
            
            if let deal = deal, let urlString = deal.url, let url = URL(string: urlString) {
                startLoading()
                webView.load(URLRequest(url: url))
            } else if let slide = slide, let urlString = slide.url, let url = URL(string: urlString) {
                startLoading()
                webView.load(URLRequest(url: url))
            } else if var urlString = urlString {
                
                if UserModel.sharedInstance.logined && !urlString.contains(UserModel.sharedInstance.token) {
                    
                    if urlString.contains("/blog/mobile/") && !urlString.contains("&t=") {
                        urlString.append("&t=\(UserModel.sharedInstance.token)")
                    }
                }
                
                if let url = URL(string: urlString) {
                    startLoading()
                    webView.load(URLRequest(url: url))
                }
            }
        }
        else {
            isDisplayingPromotion = false
        }
    }
    
    @objc func leftBtnPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backBtnPressed() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func forwardBtnPressed() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func refreshBtnPressed() {
        webView.reload()
    }
    
    func updateButtons(_ reload: Bool) {
        backBarButton.isEnabled    = webView.canGoBack
        forwardBarButton.isEnabled = webView.canGoForward
        reloadBarButton.isEnabled  = reload
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateButtons(false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopLoading()
        updateButtons(true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        stopLoading()
        updateButtons(true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else { return }
        
        print(url.scheme ?? "no scheme value")
        
        if url.scheme == "fcam" {
            
            let destination = DeeplinkParser.shared.parseDeepLink(url)
            
            if destination != nil {
                DeeplinkNavigator.shared.proceedToDeeplink(destination!)
            }
            
            decisionHandler(.cancel)
        }
        else if navigationAction.targetFrame == nil {
            
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
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
