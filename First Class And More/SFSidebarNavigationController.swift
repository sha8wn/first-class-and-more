//
//  SFGenericNavigationController.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/6/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SFSidebarNavigationController : UINavigationController, SFSideBarViewDelegate, UITableViewDelegate, UITableViewDataSource
{
    lazy var homeVC: SFHomeViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! SFHomeViewController
    }()
    lazy var loginVC: LoginViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
    }()
    lazy var filterIntroVC: FilterIntroViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "FilterIntroVC") as! FilterIntroViewController
    }()
    lazy var webrungVC: WebrungViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "webrungViewController") as! WebrungViewController
    }()
    lazy var profileAndTestsVC: ProfileAndTestsViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "ProfileAndTestsVC") as! ProfileAndTestsViewController
    }()
    lazy var webVC: WKWebViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WKWebViewController
    }()
    lazy var newsletterVC: NewsletterViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "NewsletterViewController") as! NewsletterViewController
    }()
    lazy var tutorialVC: TutorialViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "tutorialViewController") as! TutorialViewController
    }()
    lazy var cardVC: FullScreenCardViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "FullScreenCardViewController") as! FullScreenCardViewController
    }()
    var contactVC: ContactViewController {
        return self.storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
    }
    
    var sidebarContainer: SFSidebarView!
    
    var menuOptions: [SFSidebarItem]?
    {
        willSet(newValue)
        {
            if let _ = newValue
            {
                setUpSideBar()
            }
        }
    }
	
	lazy var fileProvider = FileProvider(viewController: self)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playedDismissed), name: .kAVPlayerViewControllerDismissingNotification, object: nil)
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        navigationBar.barTintColor = fcamBlue
    }
    
    private func setUpSideBar()
    {
        let navigationBarHeight = navigationBar.frame.height
        
        sidebarContainer = SFSidebarView(frame: CGRect(x: -(UIApplication.shared.keyWindow?.frame.size.width)!,
                                                       y: navigationBarHeight + 20, // 20 is status bar height in normal situations except on calls
                                                       width: (UIApplication.shared.keyWindow?.frame.size.width)!,
                                                       height: (UIApplication.shared.keyWindow?.frame.size.height)! - navigationBarHeight))
        
        sidebarContainer.backgroundColor = .clear
        sidebarContainer.delegate = self
        sidebarContainer.shadowOn = true
        view.addSubview(sidebarContainer)
    }
    
    public func sideBarIsOpened() -> Bool {
        return sidebarContainer.frame.origin.x == 0
    }
    
    public func toggleMenu(toDestination destination: String? = nil, dealType: DealType? = nil, indexPath: IndexPath? = nil)
    {
        var xOrigin = -(UIApplication.shared.keyWindow?.frame.size.width)!
        
        if sidebarContainer.frame.origin.x < 0
        {
            xOrigin = 0
        }
        else
        {
            if let destination = destination
            {
                if let dealType = dealType
                {
                    if destination != "FilterIntroVC"
                    {
						if dealType == .Favoriten, !UserModel.sharedInstance.logined {
							showPremiumAccessOnlyPopup()
						}
                        else if let _ = self.storyboard?.instantiateViewController(withIdentifier: destination)
                        {
                            let dvc = self.storyboard?.instantiateViewController(withIdentifier: destination) as! SFDealsTemplateViewController
                            dvc.dealType = dealType
                            dvc.dealsLoaded = false
                            if [DealType.Alle, DealType.Ohne_Login, DealType.Gold_Highlights, DealType.Platin_Highlights].contains(dealType) {
                                dvc.applyFilters = false
                            }
							setViewControllers([dvc], animated: false)
                        }
                    }
                    else
                    {
                        setViewControllers([filterIntroVC], animated: true)
                    }
                }
                else
                {
					switch destination {
					case "HomeVC":
						homeVC.carouselLoaded = false
						setViewControllers([homeVC], animated: false)
					case "SettingsVC":
						if UserModel.sharedInstance.logined {
							let svc = storyboard?.instantiateViewController(withIdentifier: destination) as! SFSettingsViewController
							setViewControllers([svc], animated: false)
						}
						else {
							showPremiumAccessOnlyPopup()
						}
					case "LoginVC":
						setViewControllers([loginVC], animated: true)
					case "WebrungVC":
						setViewControllers([webrungVC], animated: true)
					case "ProfileAndTestsVC":
						if let index = indexPath?.row,
							let data = UserDefaults.standard.object(forKey: kUDSettingsPageDetails) as? Data,
							let pageDetailsObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? PageDetails {
							let categories: [[Int]] = [
								[908, 909],
								[1766],
								[255],
								[2385]
							]
							profileAndTestsVC.categories = categories[index - 1]
							switch index - 1 {
							case 0:
								profileAndTestsVC.profileAndTest = pageDetailsObject.destinationsProfile
                                profileAndTestsVC.orderBy = .title
                                profileAndTestsVC.layout = .oneColumn
							case 1:
								profileAndTestsVC.profileAndTest = pageDetailsObject.airlineProfile
                                profileAndTestsVC.orderBy = .title
                                profileAndTestsVC.layout = .oneColumn
							case 2:
								profileAndTestsVC.profileAndTest = pageDetailsObject.hoteltest
                                profileAndTestsVC.orderBy = .none
                                profileAndTestsVC.layout = .twoColumns
							case 3:
								profileAndTestsVC.profileAndTest = pageDetailsObject.flughafenLounges
                                profileAndTestsVC.orderBy = .none
                                profileAndTestsVC.layout = .twoColumns
							default:
								break
							}
							setViewControllers([profileAndTestsVC], animated: true)
						}
					case "SafariVC":
						if let index = indexPath?.row,
							let data = UserDefaults.standard.object(forKey: kUDSettingsSideBarObjects) as? Data,
							let sideBarObjects = NSKeyedUnarchiver.unarchiveObject(with: data) as? [SideBarObject],
							let urlString = sideBarObjects.filter({ $0.title == "REISEINFOS UND TESTS" }).first?.pages?[index - 1].url {
							webVC.urlString = urlString
							webVC.pageLoaded = false
							setViewControllers([webVC], animated: true)
						}
					case "WebVC":
						let urlKeys: [String] = [
							kUDSettingsAboutURL,
							kUDSettingsNewsletterURL,
							kUDSettingsFacebookURL,
							kUDSettingsInstagramURL,
							kUDSettingsContactURL
						]
						if let index = indexPath?.row, let urlString = UserDefaults.standard.string(forKey: urlKeys[index - 1]) {
                            switch index {
                            case 2, 5:
                                let vc = index == 2 ? newsletterVC : contactVC
                                definesPresentationContext = true
                                modalPresentationStyle = .overCurrentContext
                                modalTransitionStyle = .crossDissolve
                                present(vc, animated: true, completion: nil)
                            default:
                                webVC.urlString = urlString
                                webVC.pageLoaded = false
                                setViewControllers([webVC], animated: true)
                            }
						}
					case "AgbVC":
						fileProvider.open(.agb)
					case "DatenVC":
						fileProvider.open(.datenschutz)
					default:
						break
					}
                }
            }
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.sidebarContainer.frame.origin.x = xOrigin
            
        }, completion: { (finished: Bool) in
            
            self.sidebarContainer.scrollToTop()
        })
    }
	
	private func showPremiumAccessOnlyPopup() {
		showPopupDialog(title: nil, message: "Nur für Premium-Mitglieder zugänglich", cancelBtn: false, okBtnTitle: nil, okBtnCompletion: nil)
	}

    // MARK: - TableView delegate and datasource functions
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if let _ = menuOptions
        {
            return (menuOptions?.count)!
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let _ = menuOptions![section].optionName
        {
            return (menuOptions![section].optionName?.count)! + 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(indexPath.row == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as! SFMenuSectionTableViewCell
            cell.configureCell()
            cell.sectionLabel.text = menuOptions![indexPath.section].sectionName
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SFMenuTableViewCell
            
            let optionName = (menuOptions?[indexPath.section].optionName?[indexPath.row - 1])!
            let image = optionName.replacingOccurrences(of: " ", with: "").lowercased()
            cell.configureCell()
            cell.optionImage.image = UIImage(named: image)
            cell.optionId = ""
            cell.optionName.text = optionName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(indexPath.row != 0) // to make sure we aren't tapping on a "section row" and handling
        {
            // highlight effect and transition
            let cell = tableView.cellForRow(at: indexPath) as! SFMenuTableViewCell
            
            UIView.animate(withDuration: 0.1, animations: {
                
                cell.optionImage.alpha = 0.5
                
            }, completion: { (finished: Bool) in
                
                cell.optionImage.alpha = 1.0
                
            })
            
            let destination = menuOptions?[indexPath.section].destinationIdentifier?[indexPath.row - 1]
            
            if let dealType = menuOptions?[indexPath.section].dealType
            {
                toggleMenu(toDestination: destination, dealType: dealType[indexPath.row - 1])
            }
            else
            {
                toggleMenu(toDestination: destination, indexPath: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == menuOptions?[indexPath.section].optionName?.count {
            if let name = menuOptions?[indexPath.section].optionName?[indexPath.row - 1], name == "Promotions", (UserModel.sharedInstance.isGold || !UserModel.sharedInstance.logined) {
                return 0
            }
            return 50
        }
        return 40
    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // MARK: - SFSideBarViewDelegate
    
    func touchedOutsideMenu()
    {
        toggleMenu(toDestination: nil)
    }
    
    func loginBtnPressed() {
        toggleMenu(toDestination: "LoginVC")
    }
    
    func tutorialButtonPressed() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.timer?.invalidate()
            appDelegate.timer = nil
        }
        playTutorialVideo()
    }

    private func playTutorialVideo() {
        guard let path = Bundle.main.path(forResource: "tutorial", ofType: "mp4") else {
            debugPrint("tutorial.mp4 not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }

    @objc private func playedDismissed() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restartTimer()
        }
    }

    func cardViewTapped() {
        if UserModel.sharedInstance.logined {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.timer?.invalidate()
                appDelegate.timer = nil
            }
            definesPresentationContext = true
            modalPresentationStyle = .overCurrentContext
            modalTransitionStyle = .crossDissolve
            present(cardVC, animated: true, completion: nil)
        }
    }
    
    func userLoggedOut() {
        setViewControllers([homeVC], animated: true)
        if sideBarIsOpened() {
            toggleMenu()
        }
        if let topViewController = topViewController as? SFSidebarViewController {
            topViewController.updateNavigationButtons()
        }
        showPopupDialog(message: "Sie haben sich ausgeloggt", cancelBtn: false)
    }
    
    // MARK: - SFMenuTableViewCell Delegates
    
    func optionTapped(optionId: String)
    {
        // handle which view controller to show
    }
}

extension AVPlayerViewController {
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed == false {
            return
        }
        NotificationCenter.default.post(name: .kAVPlayerViewControllerDismissingNotification, object: nil)
    }
}

extension Notification.Name {
    static let kAVPlayerViewControllerDismissingNotification = Notification.Name.init("AVPlayerViewControllerDismissing")
}
