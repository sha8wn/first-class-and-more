//
//  SFHomeViewController.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/6/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

enum DealState {
    case blue, gold
}

class SFHomeViewController: SFSidebarViewController, SFHomeMeineDealsViewDelegate
{
    enum HomeType
    {
        case MeineDeals
        case NeuesteDeals
    }
    
    var carouselContainer: SFHomeCarouselView!
    var meineDealsView: SFHomeMeineDealsView!

    var meineDealsButton: SFFCAMSegmentButton!
    var neuesteDealsButton: SFFCAMSegmentButton!
	
	private var isSubviewsConfigured = false
    
    private var dealState: DealState = .blue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = self.navigationController as! SFSidebarNavigationController
        navBar.menuOptions = [
            SFSidebarItem(
				section: "MEINE DEALS (mit Filter)",
				option: ["Meine Deals", "Favoriten", "Endet bald", "Filter definieren"],
				destination: ["HomeVC", "DealTemplateVC", "DealTemplateVC", "FilterIntroVC"],
				deal: [nil, DealType.Favoriten, DealType.Endet_Bald, DealType.Filter_Definieren]),
            SFSidebarItem(
				section: "ALLE DEALS (ohne Filter)",
				option: ["Alle Deals", "Ohne Login", "GOLD Deals", "PLATIN Deals"],
				destination: ["DealTemplateVC", "DealTemplateVC", "DealTemplateVC", "DealTemplateVC"],
				deal: [DealType.Alle, DealType.Ohne_Login, DealType.Gold_Highlights, DealType.Platin_Highlights]),
            SFSidebarItem(
				section: "REISEINFOS UND TESTS",
				option: ["Destinations-Profile", "Airline-Profile", "Hoteltests", "Flughafen Lounges"],
				destination: ["ProfileAndTestsVC", "ProfileAndTestsVC", "ProfileAndTestsVC", "ProfileAndTestsVC"],
				deal: nil),
//            SFSidebarItem(
//				section: "REISEINFOS UND TESTS",
//				option: ["Destinations-Profile", "Stadt-Profile", "Airline-Profile", "Airlinetests", "Hoteltests", "Loungetests"],
//				destination: ["SafariVC", "SafariVC", "SafariVC", "SafariVC", "SafariVC", "SafariVC"],
//				deal: nil),
            SFSidebarItem(
				section: "Einstellungen".uppercased(),
				option: ["Push-Benachrichtigungen", "Promotions"],
				destination: ["SettingsVC", "WebrungVC"],
				deal: nil),
            SFSidebarItem(
				section: "FIRST CLASS & MORE",
				option: ["Über uns", "Newsletter", "Facebook", "Instagram", "Kontakt", "AGB", "Datenschutzerklärung"],
				destination: ["WebVC", "WebVC", "WebVC", "WebVC", "WebVC", "AgbVC", "DatenVC"],
				deal: nil)
        ]
		
		configureSubviews()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadCarouselData),
                                               name: Notification.Name(rawValue: "user_updated"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var carouselLoaded: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !carouselLoaded {
            carouselLoaded = true
            loadCarouselData()
        }
        segmentTapped(withButton: meineDealsButton)
    }
    
    // MARK: - UI Development
	
    private func createCarousel()
    {
        carouselContainer = SFHomeCarouselView()
        carouselContainer.delegate = self
        view.addSubview(carouselContainer)
    }
    
    @objc func loadCarouselData() {
        if isConnectedToNetwork(repeatedFunction: loadCarouselData) {
            startLoading()
            Server.shared.getSliderData() { slides, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else {
                        if let slides = slides as? [SlideModel] {
                            self.updateCarousel(slides: slides)
                        }
                    }
                }
            }
        }
    }
    
    private func updateCarousel(slides: [SlideModel]) {
		carouselContainer.configureCarousel()
        carouselContainer.updateCarousel(slides: slides)
    }
    
    private func createSegment()
    {
        let buttonWidth = view.frame.size.width / 2
        let buttonHeight = view.frame.size.height * 0.085
        
        meineDealsButton = SFFCAMSegmentButton(frame: CGRect(x: 0, y: carouselContainer.frame.size.height, width: buttonWidth, height: buttonHeight))
        meineDealsButton.titleLabel!.numberOfLines = 2
        meineDealsButton.backgroundColor = fcamBlue
        meineDealsButton.setTitleColor(.white, for: .normal)
        meineDealsButton.titleLabel!.textAlignment = .center
        meineDealsButton.setTitle("MEINE DEALS\n(mit Filter)", for: .normal)
        meineDealsButton.addTarget(self, action: #selector(segmentTapped(withButton:)), for: .touchUpInside)
        
        neuesteDealsButton = SFFCAMSegmentButton(frame: CGRect(x: meineDealsButton.frame.size.width, y: carouselContainer.frame.size.height, width: buttonWidth, height: buttonHeight))
        neuesteDealsButton.titleLabel!.numberOfLines = 2
        neuesteDealsButton.backgroundColor = fcamLightGrey
        neuesteDealsButton.setTitleColor(fcamBlue, for: .normal)
        neuesteDealsButton.titleLabel!.textAlignment = .center
        neuesteDealsButton.setTitle("ALLE DEALS\n(ohne Filter)", for: .normal)
        neuesteDealsButton.addTarget(self, action: #selector(segmentTapped(withButton:)), for: .touchUpInside)
        
        view.addSubview(meineDealsButton)
        view.addSubview(neuesteDealsButton)
    }
    
    private func createMeineDealsView()
    {
        meineDealsView = SFHomeMeineDealsView(frame: CGRect(x: 0,
                                                            y: meineDealsButton.frame.origin.y + meineDealsButton.frame.size.height,
                                                            width: view.frame.size.width,
                                                            height: view.frame.size.height - (meineDealsButton.frame.origin.y + meineDealsButton.frame.size.height)))
		
        meineDealsView.delegate = self
        view.addSubview(meineDealsView)
    }
	
	private func configureSubviews() {
		createCarousel()
		createSegment()
		createMeineDealsView()
		addContraints()
		meineDealsView.setUpButtons()
	}
	
	private func addContraints() {
		let screenBounds = UIScreen.main.bounds
		
		carouselContainer.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			carouselContainer.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
			carouselContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			carouselContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			carouselContainer.heightAnchor.constraint(equalToConstant: screenBounds.height * 0.25)
			])
		
		meineDealsButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			meineDealsButton.topAnchor.constraint(equalTo: carouselContainer.bottomAnchor),
			meineDealsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			meineDealsButton.widthAnchor.constraint(equalToConstant: screenBounds.width / 2),
			meineDealsButton.heightAnchor.constraint(equalToConstant: screenBounds.height * 0.085)
			])
		
		neuesteDealsButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			neuesteDealsButton.topAnchor.constraint(equalTo: carouselContainer.bottomAnchor),
			neuesteDealsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			neuesteDealsButton.widthAnchor.constraint(equalTo: meineDealsButton.widthAnchor),
			neuesteDealsButton.heightAnchor.constraint(equalTo: meineDealsButton.heightAnchor)
			])
		
		meineDealsView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			meineDealsView.topAnchor.constraint(equalTo: meineDealsButton.bottomAnchor),
			meineDealsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			meineDealsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			meineDealsView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
			])
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "showWKWebViewVC":
                    let dvc   = segue.destination as! WKWebViewController
                    dvc.pageLoaded = false
                    dvc.slide = sender as? SlideModel
                    dvc.deal  = sender as? DealModel
                default:
                    break
            }
        }
    }
    
    // MARK: - SFHomeMeinDealsView Delegate
	
	func meineDealItemTapped(with type: DealType) {
		let dvc = self.storyboard?.instantiateViewController(withIdentifier: "DealTemplateVC") as! SFDealsTemplateViewController
		dvc.dealType = type
		dvc.dealState = dealState
		self.navigationController?.setViewControllers([dvc], animated: false)
	}
    
    // MARK: - Event Handlers
    
    @objc private func segmentTapped(withButton segment: UIButton) {
        if segment == meineDealsButton {
            dealState = .blue
            neuesteDealsButton.backgroundColor = fcamLightGrey
            neuesteDealsButton.setTitleColor(fcamBlue, for: .normal)
            segment.setTitleColor(.white, for: .normal)
            segment.backgroundColor = fcamBlue
            meineDealsView.updateButtons(with: dealState)
        } else if segment == neuesteDealsButton {
            dealState = .gold
            meineDealsButton.backgroundColor = fcamLightGrey
            meineDealsButton.setTitleColor(fcamBlue, for: .normal)
            segment.setTitleColor(.white, for: .normal)
            segment.backgroundColor = fcamGold
            meineDealsView.updateButtons(with: dealState)
        }
    }
}

extension SFHomeViewController: CarouselDelegate {
    
    func slideSelected(slide: SlideModel) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as? WKWebViewController else {
            return
        }
        controller.slide = slide
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showPopup() {
        showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Dieser Deal ist nicht für Ihr Mitgliedschafts-Level freigegeben", cancelBtn: false, okBtnCompletion: nil)
    }
    
}
