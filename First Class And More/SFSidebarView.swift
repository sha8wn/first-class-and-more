//
//  SFSidebarView.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/23/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

@objc protocol SFSideBarViewDelegate: class
{
    func touchedOutsideMenu()
    func loginBtnPressed()
    func userLoggedOut()
    func tutorialButtonPressed()
    func cardViewTapped()
}

class SFSidebarView: UIView
{
    var menuContainer: UIView!
    var userContainer: UIView!
    var dismissContainer: UIView!
    var menuTableView: SFTableView!
    var userTierImage: UIImageView!
    var expandImageView: UIImageView!
    var userNameLabel: SFFCAMLabel!
    var userTierLabel: SFFCAMLabel!
    var userJoinLabel: SFFCAMLabel!
    var loginLogoutButton: UIButton!
    var tutorialButton: UIButton!
	var playImageView: UIImageView!
    
    var shadowOn: Bool

    var delegate: SFSideBarViewDelegate!
    
    override init(frame: CGRect)
    {
        shadowOn = false
        
        super.init(frame: frame)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        setUpSidebar()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpSidebar()
    {
        menuContainer = UIView(frame: CGRect(x: 0, y: 0, width: 0.80 * frame.size.width, height: frame.size.height))
        userContainer = UIView(frame: CGRect(x: 0, y: 0, width: menuContainer.frame.size.width, height: 0.9 * (CGFloat(219) / 3) + 50.0 * 2 + 38.0))
        menuTableView = SFTableView(frame: CGRect(x: 0, y: userContainer.frame.size.height, width: menuContainer.frame.size.width, height: menuContainer.frame.size.height - userContainer.frame.size.height),
                                    style: .plain)
        dismissContainer = UIView(frame: CGRect(x: 0.80 * frame.size.width, y: 0, width: frame.size.width - 0.80 * frame.size.width, height: frame.size.height))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchedOutsideMenu(_:)))
        dismissContainer.addGestureRecognizer(tap)
        dismissContainer.isUserInteractionEnabled = true
        
        menuContainer.backgroundColor = .white
        
        if shadowOn
        {
            menuContainer.layer.shadowColor = UIColor.black.cgColor
            menuContainer.layer.shadowOpacity = 1
            menuContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
            menuContainer.layer.shadowRadius = 5
        }
        else
        {
            menuContainer.layer.shadowOpacity = 0
        }
        
        addSubview(menuContainer)
        addSubview(dismissContainer)
        menuContainer.addSubview(userContainer)
        menuContainer.addSubview(menuTableView)
        
        setUpUserView()
        setUpMenuTableView()
    }
    
    func setUpUserView()
    {
        userContainer.backgroundColor = .white
        
        let user = UserModel.sharedInstance
        let logined = user.logined
        let userContainerSize = userContainer.frame.size
        let cardTierImage = user.membership.image
        let cardSize = CGSize(width: 0.9 * (CGFloat(348) / 3), height: 0.9 * (CGFloat(219) / 3))
        var currentY: CGFloat = 50.0
        var currentX = CGFloat(15)
        
        userTierImage = UIImageView(frame: CGRect(x: currentX, y: currentY, width: cardSize.width, height: cardSize.height))
        userTierImage.isUserInteractionEnabled = true
        userTierImage.image = cardTierImage
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(carViewTapped))
        userTierImage.addGestureRecognizer(tapGesture)
        
        expandImageView = UIImageView(image: #imageLiteral(resourceName: "expand"))
        expandImageView.frame = CGRect(
            x: userTierImage.frame.origin.x + (userTierImage.frame.width - expandImageView.frame.width / 2) / 2,
            y: userTierImage.frame.origin.y + (userTierImage.frame.height - expandImageView.frame.height / 2) / 2,
            width: expandImageView.frame.width / 2,
            height: expandImageView.frame.height / 2
        )
        expandImageView.image = logined ? #imageLiteral(resourceName: "expand") : nil
        
        currentX += userTierImage.frame.size.width + 18
        
        userNameLabel = SFFCAMLabel(frame:CGRect(x: currentX, y: currentY, width: userContainerSize.width - currentX - 5, height: CGFloat(15)))
        userNameLabel.fontSize = 15
        userNameLabel.textColor = fcamBlue
        userNameLabel.text = "\(user.name) \(user.surname)"
        
        currentY += userNameLabel.frame.size.height + 6
        
        userTierLabel = SFFCAMLabel(frame:CGRect(x: currentX, y: currentY, width: userContainerSize.width - currentX - 5, height: CGFloat(10)))
        userTierLabel.fontSize = 12
        userTierLabel.textColor = .black
        userTierLabel.isHidden = !logined
        userTierLabel.text = user.membership.rawValue
        
        currentY += userTierLabel.frame.size.height + 6
        
        userJoinLabel = SFFCAMLabel(frame:CGRect(x: currentX, y: currentY, width: userContainerSize.width - currentX - 5, height: CGFloat(10)))
        userJoinLabel.fontSize = 12
        userJoinLabel.textColor = fcamDarkGrey
        userJoinLabel.isHidden = !logined
        userJoinLabel.text = "bis \(user.membershipExpires.date(format: "yyyy-MM-dd")?.string(format: "dd. MMMM yyyy") ?? "")"
        
        
        
        currentY += userTierLabel.frame.size.height + 6
        
        loginLogoutButton = UIButton(frame: CGRect(x: currentX, y: currentY, width: 70, height: CGFloat(40)))
        loginLogoutButton.contentVerticalAlignment = .top
        loginLogoutButton.contentHorizontalAlignment = .left
        let loginLogoutBtnTitle = logined ? "AUSLOGGEN" : "ANMELDUNG"
        loginLogoutButton.setTitle(loginLogoutBtnTitle, for: .normal)
        loginLogoutButton.setTitleColor(fcamGold, for: .normal)
        loginLogoutButton.setTitleColor(fcamDarkGold, for: .highlighted)
        loginLogoutButton.titleLabel?.font = UIFont(name: "RobotoCondensed-Regular", size: 12)
        loginLogoutButton.addTarget(self, action: #selector(sidebarLoginLogoutButtonTapped), for: .touchUpInside)
        
        userNameLabel.frame.origin.y = logined ? 50.0 : loginLogoutButton.frame.origin.y - 6 - userNameLabel.frame.height
        
        tutorialButton = UIButton(type: .custom)
        tutorialButton.frame = CGRect(x: 0.0, y: userContainer.frame.height - 40.0 - 8.0, width: userContainer.frame.width, height: 40.0)
        tutorialButton.backgroundColor = fcamGold
        tutorialButton.setTitle("Tutorial".uppercased(), for: .normal)
        tutorialButton.setImage(#imageLiteral(resourceName: "help"), for: .normal)
        tutorialButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tutorialButton.titleLabel!.font = UIFont(name: "RobotoCondensed-Regular", size: 14)
        tutorialButton.contentHorizontalAlignment = .left
        tutorialButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 20.0, bottom: 0, right: 0)
        tutorialButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 16.0, bottom: 0, right: 0)
        tutorialButton.addTarget(self, action: #selector(tutorialButtonPressed), for: .touchUpInside)
		tutorialButton.addTarget(self, action: #selector(tutorialButtonTouchedDown), for: .touchDown)
		tutorialButton.adjustsImageWhenHighlighted = false

        playImageView = UIImageView(frame: CGRect(x: userContainer.frame.width - 22.0 - 16.0, y: 9.0, width: 22.0, height: 22.0))
        playImageView.image = #imageLiteral(resourceName: "play")
        playImageView.contentMode = .scaleAspectFit
        tutorialButton.addSubview(playImageView)
        
        userContainer.addSubview(userTierImage)
        userContainer.addSubview(expandImageView)
        
        
        if let _ = user.membershipExpires.date(format: "yyyy-MM-dd") {
            if user.membershipExpires.date(format: "yyyy-MM-dd")! < Date() {
                
                let expireOverlay = UIView(frame: userTierImage.frame)
                expireOverlay.backgroundColor = .white
                expireOverlay.alpha = 0.65
                userContainer.addSubview(expireOverlay)
            }
        }
        
        
        userContainer.addSubview(userNameLabel)
        userContainer.addSubview(userTierLabel)
        userContainer.addSubview(userJoinLabel)
        userContainer.addSubview(loginLogoutButton)
        userContainer.addSubview(tutorialButton)
    }
    
    func setUpMenuTableView()
    {
        menuTableView.backgroundColor = .white
        menuTableView.delegate = delegate as? UITableViewDelegate
        menuTableView.dataSource = delegate as? UITableViewDataSource
        menuTableView.register(SFMenuTableViewCell.self, forCellReuseIdentifier: "Cell")
        menuTableView.register(SFMenuSectionTableViewCell.self, forCellReuseIdentifier: "SectionCell")
        menuTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        menuTableView.tableFooterView = UIView(frame: .zero)
        menuTableView.configure()
    }
    
    func scrollToTop()
    {
        menuTableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func updateUserView() {
        let user = UserModel.sharedInstance
        let logined = user.logined
        let cardTierImage = user.membership.image
        
        userTierImage.image = cardTierImage
        expandImageView.image = logined ? #imageLiteral(resourceName: "expand") : nil
        userContainer.bringSubviewToFront(expandImageView)
        
        let loginLogoutBtnTitle = logined ? "AUSLOGGEN" : "ANMELDUNG"
        loginLogoutButton.setTitle(loginLogoutBtnTitle, for: .normal)
        
        userNameLabel.text = "\(user.name) \(user.surname)"
        userNameLabel.frame.origin.y = logined ? 50.0 : loginLogoutButton.frame.origin.y - 6 - userNameLabel.frame.height
        
        userTierLabel.isHidden = !logined
        userTierLabel.text = user.membership.rawValue
        
        userJoinLabel.isHidden = !logined
        userJoinLabel.text = "bis \(user.membershipExpires.date(format: "yyyy-MM-dd")?.string(format: "dd MMMM yyyy") ?? "")"
        menuContainer.layoutIfNeeded()
    }
    
    // MARK: - EVENT HANDLERS
    
    @objc private func touchedOutsideMenu(_ sender: UITapGestureRecognizer)
    {
        delegate.touchedOutsideMenu()
    }
	
  	@objc func carViewTapped() {
        delegate.cardViewTapped()
    }
	
  	@objc func tutorialButtonPressed() {
		playImageView.alpha = 1.0
        delegate.tutorialButtonPressed()
    }
	
	@objc func tutorialButtonTouchedDown() {
		playImageView.alpha = 0.2
	}
    
    @objc func sidebarLoginLogoutButtonTapped()
    {
        if !UserModel.sharedInstance.logined {
            delegate.loginBtnPressed()
        } else {
            showLogoutAlert()
        }
    }
    
    private func showLogoutAlert() {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.showPopupDialog(title: "Möchten Sie sich wirklich abmelden?", message: nil, cancelBtn: true, okBtnTitle: "JA", okBtnCompletion: {
                UserModel.sharedInstance = UserModel()
                UserDefaults.standard.removeObject(forKey: kUDSharedUserModel)
                self.updateUserView()
                self.delegate.userLoggedOut()
            })
        }
    }
}
