//
//  AppDelegate.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/6/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var reach: Reachability?
    
    var timerSettings = TimerSettings()
    var timerFrequency: TimeInterval = 20.0
    weak var timer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        setupReachability()
        checkUserToken()
        getSettings()
        getAdvertisements()
        setupAppearance()
        setupPushNotifications()
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

        func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
            guard let info = Bundle.main.infoDictionary,
                let currentVersion = info["CFBundleShortVersionString"] as? String,
                let identifier = info["CFBundleIdentifier"] as? String,
                let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                    throw VersionError.invalidBundleInfo
            }
            print("current version", currentVersion)
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    if let error = error { throw error }
                    guard let data = data else { throw VersionError.invalidResponse }
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                    guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                        throw VersionError.invalidResponse
                    }
                    completion(version != currentVersion, nil)
                } catch {
                    completion(nil, error)
                }
            }
            task.resume()
            return task
        }

        _ = try? isUpdateAvailable { (update, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                } else if let update = update, update {
                    let updateViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as! UpdateViewController
                    self.window?.rootViewController?.present(updateViewController, animated: true, completion: nil)
                }
            }
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
                }
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
        let adsManager = AdvertisementsManager.sharedInstance
        if let ad = adsManager.advertisements.first, let url = URL(string: ad.imageUrl) {
            let adViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "adsVC") as! AdsViewController
            adViewController.imageName = url.lastPathComponent
            adViewController.ad = ad
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let isNavigationBar: Bool = topController.classForCoder == SFSidebarNavigationController.classForCoder()
                let navigationBar: SFSidebarNavigationController? = topController as? SFSidebarNavigationController
                if (isNavigationBar && !(navigationBar?.sideBarIsOpened() ?? false)) &&
                    (navigationBar?.topViewController?.classForCoder != FilterIntroViewController.classForCoder() &&
                    navigationBar?.topViewController?.classForCoder != FilterGeneralViewController.classForCoder() &&
                    navigationBar?.topViewController?.classForCoder != WebrungViewController.classForCoder() &&
                    navigationBar?.topViewController?.classForCoder != AdvancedFiltersViewController.classForCoder()) &&
                    topController.classForCoder != AdsViewController.classForCoder() {
                    adsManager.advertisements.remove(at: adsManager.advertisements.index(of: ad)!)
                    adsManager.advertisements.append(ad)
                    let data = NSKeyedArchiver.archivedData(withRootObject: adsManager)
                    let defaults = UserDefaults.standard
                    defaults.set(data, forKey: kUDSharedAdvertisementsManager)
                    defaults.synchronize()
                    timer?.invalidate()
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
                webViewViewController.urlString = urlString
                (topController as? UINavigationController)?.pushViewController(webViewViewController, animated: false)
            }
        }
    }
    
    func updatePushNotificationSettings() {
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
    
    func setupPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(#line, "token", deviceTokenString)
        UserDefaults.standard.set(deviceTokenString, forKey: kUDDevicePushToken)
        updatePushNotificationSettings()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(#file, #line, error.localizedDescription)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Deeplinker.handleRemoteNotification(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Deeplinker.handleRemoteNotification(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Deeplinker.handleRemoteNotification(userInfo)
        if UIApplication.shared.applicationState != .background {
            Deeplinker.checkDeepLink()
        }
        completionHandler()
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
        let condition = reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN()
        if condition {
            checkUserToken()
            getSettings()
            getAdvertisements()
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let shouldOpen = Deeplinker.handleDeeplink(url: url)
        if app.applicationState != .background {
            Deeplinker.checkDeepLink()
        }
        return shouldOpen
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // handle any deeplink
        Deeplinker.checkDeepLink()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

