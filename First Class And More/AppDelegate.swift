//
//  AppDelegate.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/6/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireNetworkActivityLogger
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var reach: Reachability?
    
    var timerSettings = TimerSettings()
    var timerFrequency: TimeInterval = 20.0
    weak var timer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        //ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
        UNUserNotificationCenter.current().delegate = self
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        setupReachability()
        checkUserToken()
        getSettings()
        getAdvertisements()
        setupAppearance()
        setupPushNotifications(application)
		loadInitialScreen()
        checkForAvailableUpdate()
        return true
    }
	
	func loadInitialScreen() {
		window = UIWindow(frame: UIScreen.main.bounds)
		let isRegistered = UserDefaults.standard.bool(forKey: kUDUserRegistered)
		if isRegistered {
			let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
			window?.rootViewController = homeViewController
		} else {
			let welcomeViewController = UIStoryboard(name: "Registration", bundle: nil).instantiateInitialViewController()
			window?.rootViewController = welcomeViewController
		}
		window?.makeKeyAndVisible()
	}

    func checkForAvailableUpdate() {
        enum VersionError: Error {
            case invalidResponse, invalidBundleInfo
        }

        func isUpdateAvailable(completion: @escaping (Bool?, Bool?, Error?) -> Void) throws -> URLSessionDataTask {
            guard let info = Bundle.main.infoDictionary,
                  let currentVersion = info["CFBundleShortVersionString"] as? String,
                  let url = URL(string: "https://www.first-class-and-more.de/blog/fcam-api/app/v1/app-version-v2?auth=tZKWXujQ&app=1") else {
                throw VersionError.invalidBundleInfo
            }
            print("url: ", url)
            print("current version", currentVersion)
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    if let error = error
                    {
                        throw error
                        
                    }
                    
                    if data == nil {
                        throw VersionError.invalidResponse
                    }
                    
                    let data = data!
                    
                    print()
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                    
                    guard let responseData = json?["data"] as? [String: Any],
                          let version = responseData["version"] as? String
                    else {
                        throw VersionError.invalidResponse
                    }
                    
                    
                    var isUpdateForced = false
                    
                    if let forceUpdate = responseData["force_update"] as? Bool,
                       forceUpdate {
                        isUpdateForced = true
                    }
                    
                    print(version)
                    
                    completion(version > currentVersion, isUpdateForced, nil)
                } catch {
                    completion(nil, nil, error)
                }
            }
            task.resume()
            return task
        }

    _ = try? isUpdateAvailable { (update, isUpdateForced, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                } else if let update = update, update,
                          let isUpdateForced = isUpdateForced {
                    self.showUpdateAlert(isForced: isUpdateForced)
                }
            }
        }
    }
    
    private func showUpdateAlert(isForced: Bool = true) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            var popupTitle = "Eine neue Version der First Class & More Reisedeals-App ist im App Store verfügbar. Bitte führen Sie das Update jetzt durch, um die App weiter nutzen zu können."
            
            if !isForced {
                popupTitle = "Eine neue Version der First Class & More Reisedeals-App ist im App Store verfügbar. Möchten Sie jetzt updaten?"
            }
            
            topController.showPopupDialog(title: popupTitle,
                                          message: nil,
                                          cancelBtn: !isForced,
                                          okBtnTitle: "Updaten",
                                          canDismiss: false,
                                          okBtnCompletion: {
                
                if let url = URL(string: "itms-apps://itunes.apple.com/app/first-class-more-reisedeals/id1474514915"),
                    UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
        }
    }
    
    func setupReachability() {
        reach = Reachability.forInternetConnection()
        reach!.reachableOnWWAN = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: NSNotification.Name.reachabilityChanged,
            object: nil
        )
        reach!.startNotifier()
    }
    
    @objc func reachabilityChanged(_ notification: NSNotification) {
        let condition = reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN()
        if condition {
            checkUserToken()
            getSettings()
            getAdvertisements()
        }
    }
    
    func checkUserToken() {
        let condition = reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN()
        if condition, UserModel.sharedInstance.logined {
            Server.shared.checkUserToken() { statusCode, error in
                if error == nil {
                    if let statusCode = statusCode as? Int {
                        switch statusCode {
                            case 1:
                                break
                            case 2:
                                // update token
                                self.updateToken()
                            case 3:
                                // logout
                                self.logout()
                            default:
                                break
                        }
                    }
                }
            }
        }
    }
    
    func updateToken() {
        let condition = reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN()
        let user = UserModel.sharedInstance
        if condition, user.logined {
            Server.shared.getPasswordSalt(email: user.email) { salt, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.logout()
                    } else {
                        if let salt = salt as? String {
                            self.getUserToken(email: user.email, password: user.password, salt: salt)
                        }
                    }
                }
            }
        }
    }
    
    func getUserToken(email: String, password: String, salt: String) {
        let condition = reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN()
        if condition {
            Server.shared.login(email: email, password: password, salt: salt) { success, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.logout()
                    } else {
                        if let success = success as? Bool, success {
                            self.getSettings()
                        }
                    }
                }
            }
        }
    }
    
    func logout() {
        UserModel.sharedInstance = UserModel()
        UserDefaults.standard.removeObject(forKey: kUDSharedUserModel)
    }
    
    func getSettings() {
        guard reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() else { return }
        Server.shared.getSettings() { success, error in
            // timer settings
            if let success = success as? Bool, success, let timerSettingsObjectData = UserDefaults.standard.object(forKey: kUDTimerSettingsObject) as? Data,
                let timerSettingsObject = NSKeyedUnarchiver.unarchiveObject(with: timerSettingsObjectData) as? TimerSettings {
                self.timerSettings = timerSettingsObject
                self.timerFrequency = Double(timerSettingsObject.firstAd)
            }
        }
    }
    
    func getAdvertisements() {
        guard reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() else { return }
        let defaults = UserDefaults.standard
        // if last load was yesterday - get new ads from server
        let calendar = Calendar.current
        let lastDate = defaults.object(forKey: kUDAdsLastDownloadDate) as? Date ?? calendar.date(byAdding: .day, value: -1, to: Date())!
        if calendar.isDateInYesterday(lastDate) {
            // load new ads
            
        }
        
        Server.shared.getAdvertisements() { advertisements, error in
            if let ads = advertisements as? [AdvertisementModel] {
                // save new ads and current load time
                let adsManager = AdvertisementsManager.sharedInstance
                adsManager.advertisements = ads
                let data = NSKeyedArchiver.archivedData(withRootObject: adsManager)
                defaults.set(data, forKey: kUDSharedAdvertisementsManager)
                let now = Date()
                defaults.set(now, forKey: kUDAdsLastDownloadDate)
                defaults.synchronize()
                // load ad images
                for ad in ads {
                    let urlString = ad.imageUrl
                    if let url = URL(string: urlString) {
                        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let fileURL = documentsURL.appendingPathComponent("ads/\(url.lastPathComponent)")
                            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                        }
                        _ = Alamofire.download(urlString, to: destination)
                    }
                }
                // start timer
                self.restartTimer()
                return
            }
        }
        
        // start timer
        restartTimer()
    }
    
    func restartTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: self.timerFrequency, target: self, selector: #selector(self.showAd), userInfo: nil, repeats: true)
        }
    }
    
    @objc func showAd() {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            var navigationController:SFSidebarNavigationController!
            
            if UIApplication.shared.keyWindow?.rootViewController is SFSidebarNavigationController
            {
                navigationController = UIApplication.shared.keyWindow?.rootViewController as? SFSidebarNavigationController
            }
            else
            {
                let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
                
                for vc in navController!.viewControllers {
                    
                    if vc is SFSidebarNavigationController {
                        
                        navigationController = vc as? SFSidebarNavigationController
                        
                    }
                    
                }
            }
            
            let isNavigationBar: Bool = topController.classForCoder == SFSidebarNavigationController.classForCoder()
            let navigationBar: SFSidebarNavigationController? = topController as? SFSidebarNavigationController
            if (isNavigationBar && !(navigationController.sideBarIsOpened())) &&
                (navigationBar?.topViewController?.classForCoder != FilterIntroViewController.classForCoder() &&
                navigationBar?.topViewController?.classForCoder != FilterGeneralViewController.classForCoder() &&
                navigationBar?.topViewController?.classForCoder != WebrungViewController.classForCoder() &&
                navigationBar?.topViewController?.classForCoder != AdvancedFiltersViewController.classForCoder()) &&
                topController.classForCoder != AdsViewController.classForCoder() {
                
                let adsManager = AdvertisementsManager.sharedInstance
                if adsManager.advertisements.count > 0 {
                    
                    let randomAdIndex = Int.random(in: 0 ..< adsManager.advertisements.count)
                    
                    let ad = adsManager.advertisements[randomAdIndex]
                    let url = URL(string: ad.imageUrl)
                    let adViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "adsVC") as! AdsViewController
                    adViewController.imageName = url?.lastPathComponent
                    adViewController.ad = ad
                    adsManager.advertisements.remove(at: adsManager.advertisements.index(of: ad)!)
                    adsManager.advertisements.append(ad)
                    let data = NSKeyedArchiver.archivedData(withRootObject: adsManager)
                    let defaults = UserDefaults.standard
                    defaults.set(data, forKey: kUDSharedAdvertisementsManager)
                    defaults.synchronize()
                    timer?.invalidate()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "promotionWillDisplay"), object: nil)
                    adViewController.modalPresentationStyle = .overFullScreen
                    topController.definesPresentationContext = true
                    topController.present(adViewController, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func showWebView(_ urlString: String) {
        if let webViewViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as? WKWebViewController {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                    if presentedViewController is UINavigationController {
                        break
                    }
                }
                webViewViewController.pageLoaded = false
                
                let token = UserModel.sharedInstance.token
                
                if !token.isEmpty {
                    webViewViewController.urlString = urlString + "&t=\(token)"
                }
                else {
                    webViewViewController.urlString = urlString
                }
                
                
                (topController as? UINavigationController)?.pushViewController(webViewViewController, animated: false)
            }
        }
    }
    
    func updatePushNotificationSettings() {
        
        UNUserNotificationCenter.current().delegate = self
        let condition = reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN()
        let setting = UserDefaults.standard.bool(forKey: kUDApplicationLaunched) ? UserModel.sharedInstance.notificationSetting : 1
        if condition {
            Server.shared.updatePushNotificationSettings(setting: setting) { success, error in
                if let success = success as? Bool, success {
                    UserDefaults.standard.set(true, forKey: kUDApplicationLaunched)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    func setupAppearance() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 20.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    func setupPushNotifications(_ application: UIApplication) {
        /*let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = 0*/
        
        // Use Firebase library to configure APIs
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        UNUserNotificationCenter.current().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        print("---------------------------------------")
        print("fcmToken===\(fcmToken)")
        print("---------------------------------------")
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = fcmToken
        print("")
        UserDefaults.standard.set(fcmToken, forKey: kUDFCMToken)
        updatePushNotificationSettings()
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        print(#file, #line, error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(#line, "token", deviceTokenString)
        UserDefaults.standard.set(deviceTokenString, forKey: kUDDevicePushToken)
        updatePushNotificationSettings()
        print("---------------------------------------")
        print("APNs device token: \(deviceTokenString)")
        print("---------------------------------------")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        Deeplinker.handleRemoteNotification(userInfo)
        if UIApplication.shared.applicationState != .background {
            
        }
        Deeplinker.checkDeepLink()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        Deeplinker.handleRemoteNotification(userInfo)
        if UIApplication.shared.applicationState != .background {
            
        }
        Deeplinker.checkDeepLink()
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Deeplinker.handleRemoteNotification(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Deeplinker.handleRemoteNotification(userInfo)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        timerFrequency = Double(timerSettings.firstAd)
        restartTimer()
        UIApplication.shared.applicationIconBadgeNumber = 0
        let condition = reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN()
        if condition {
            checkUserToken()
            getSettings()
            getAdvertisements()
        }
    }

    /*func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        _ = Deeplinker.handleDeeplink(url: url)
        if app.applicationState != .background {
            Deeplinker.checkDeepLink()
        }
        
        return handled
    }*/

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // handle any deeplink
        
        Deeplinker.checkDeepLink()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

