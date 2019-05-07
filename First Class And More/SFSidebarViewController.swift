//
//  SFGenericViewController.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/6/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class SFSidebarViewController: UIViewController
{
    var sidebarButton: UIButton!
    var loginButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setUpNavBar()
    }
    
    private func setUpNavBar()
    {
        // Setting Up the Logo
        let logo = UIImage(named: "NavLogo")
        let imageView = UIImageView(image: logo)
        navigationItem.titleView = imageView
        
        // Set Up the two buttons
        sidebarButton = UIButton(type: .custom)
        sidebarButton.setImage(UIImage(named: "MenuButton"), for: .normal)
        sidebarButton.addTarget(self, action: #selector(sidebarButtonTapped), for: .touchUpInside)
        sidebarButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        sidebarButton.contentHorizontalAlignment = .left
        sidebarButton.contentVerticalAlignment = .center
        
        // Set Up the two buttons
        loginButton = UIButton(type: .custom)
        loginButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        loginButton.setImage(#imageLiteral(resourceName: "lock"), for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        let user = UserModel.sharedInstance
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: sidebarButton), animated: false)
        self.navigationItem.setRightBarButton(user.logined ? nil : UIBarButtonItem(customView: loginButton), animated: false)
    }
    
    func addHomeBtn() {
        let homeBtn = UIButton(type: .custom)
        homeBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        homeBtn.setImage(#imageLiteral(resourceName: "backBtn"), for: .normal)
        homeBtn.addTarget(self, action: #selector(homeBtnTapped), for: .touchUpInside)
        let homeBarBtn = UIBarButtonItem(customView: homeBtn)
        navigationItem.setLeftBarButtonItems([homeBarBtn], animated: false)
    }
    
    // UIBarButtonItem(customView: sidebarButton),
    
    @objc func homeBtnTapped() { }
    
    func addHomeBackBtn() {
        let homeBtn = UIButton(type: .custom)
        homeBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        homeBtn.setImage(#imageLiteral(resourceName: "backBtn"), for: .normal)
        homeBtn.addTarget(self, action: #selector(homeBackBtnTapped), for: .touchUpInside)
        let homeBarBtn = UIBarButtonItem(customView: homeBtn)
        navigationItem.setLeftBarButtonItems([homeBarBtn], animated: false)
    }
    
    @objc func homeBackBtnTapped() { }
    
    func updateNavigationButtons() {
        let user = UserModel.sharedInstance
        loginButton = UIButton(type: .custom)
        loginButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        loginButton.setImage(#imageLiteral(resourceName: "lock"), for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        self.navigationItem.setRightBarButton(user.logined ? nil : UIBarButtonItem(customView: loginButton), animated: false)
    }
    
    @objc private func sidebarButtonTapped()
    {
        let navBar = self.navigationController as! SFSidebarNavigationController
        navBar.toggleMenu(toDestination: nil)
    }
    
    @objc private func loginButtonTapped()
    {
        guard let navigationVC = navigationController as? SFSidebarNavigationController else { return }
        // do not open loginVC if it's opened
        if let _ = navigationVC.topViewController as? LoginViewController { return }        
        navigationVC.setViewControllers([navigationVC.loginVC], animated: true)
        // hide menu if its open
        if navigationVC.sideBarIsOpened() {
            navigationVC.toggleMenu()
        }
    }
    
    // MARK: - Resource Management
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
