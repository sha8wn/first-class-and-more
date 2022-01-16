//
//  WelcomeViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 9/24/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import UIKit

enum RegisterType {
    case new, newsletter, premium
}

class WelcomeViewController: UIViewController {

    @IBOutlet weak var newUserBtn: UIButton!
    @IBOutlet weak var newsletterUserBtn: UIButton!
    @IBOutlet weak var premiumUserBtn: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var agbButton: UIButton!
    @IBOutlet weak var datenschutzButton: UIButton!
	
	lazy var fileProvider = FileProvider(viewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// detect if scroll is enabled and not scroll yet
		if scrollView.contentSize.height > scrollView.frame.height && scrollView.contentOffset.y == 0 {
			scrollView.setContentOffset(CGPoint(x: 0, y: 20), animated: true)
		}
	}

    private func setupView() {
        setupButton(button: newUserBtn, string: String(.newUser), mediumPart: String(.newbie))
        setupButton(button: newsletterUserBtn, string: String(.alreadySubscriber), mediumPart: String(.subscriber))
        setupButton(button: premiumUserBtn, string: String(.premiumUser), mediumPart: String(.premiumer))
    }

    private func setupButton(button: UIButton, string: String, mediumPart: String) {
        let attributedTitle = NSMutableAttributedString(string: string)
        attributedTitle.addAttributes([
            .font: UIFont(name: "Roboto-Light", size: 14.0)!,
            .foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ], range: NSRange(location: 0, length: attributedTitle.length))
        attributedTitle.addAttributes([
            .font: UIFont(name: "Roboto-Medium", size: 14.0)!,
            .foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ], range: (attributedTitle.string as NSString).range(of: mediumPart))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
    }

    @IBAction func newUserBtnPressed() {
        performSegue(withIdentifier: "showRegister", sender: RegisterType.new)
    }

    @IBAction func newsLetterUserBtnPressed() {
        performSegue(withIdentifier: "showRegister", sender: RegisterType.newsletter)
    }

    @IBAction func premiumUserBtnPressed() {
        performSegue(withIdentifier: "showRegister", sender: RegisterType.premium)
    }

    @IBAction func agbBtnPressed() {
		fileProvider.open(.agb)
    }

    @IBAction func datenschutzBtnPressed() {
        fileProvider.open(.datenschutz)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "showRegister":
            let dvc = segue.destination as? RegisterViewController
            dvc?.type = sender as? RegisterType
        default:
            break
        }
    }
}
