//
//  SFDealsTemplateViewController.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/25/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import AlamofireImage
import DZNEmptyDataSet

class SFDealsTemplateViewController: SFSidebarViewController, UITableViewDelegate, UITableViewDataSource, SFDealsSearchBarDelegate, SFFiltersDelegate, UnlockFiltersDelegate, ConfirmCodeDelegate, DestinationsDelegate
{
    @IBOutlet var titleView: UIView!
    var dealType: DealType = .Alle
    var dealsView: SFDealsView!
    var page: Int = 1
    var selectedItemIndex: Int = 0
    var secondRowItemIndex: Int = 0
    var loadMoreDealsStatus: Bool = false
    var deals: [DealModel] = [] {
        didSet {
			dealsView.updateSource(with: deals, scrollToTop: page == 1)
        }
    }
    var destinations: [DestinationObject]?
    var dealState: DealState = .blue
    var destinationsBtn: UIButton?
    var expiredDealsBtn: UIButton?
    var applyFilters: Bool = true
    var dealsLoaded: Bool = false

    var expiredDealsEnabled: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: kUDExpiredDealsEnabled)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = true
        createTopTitle()
        createDealsView()
        page = 1
        deals = []
        loadMoreDealsStatus = false
        if let data = UserDefaults.standard.object(forKey: kUDSettingsDestinationsObjects) as? Data,
            let destination = NSKeyedUnarchiver.unarchiveObject(with: data) as? FilterDestinationObject {
            self.destinations = destination.items
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addHomeBackBtn()
        let image = (destinations?.filter({ !$0.selected }).isEmpty ?? true) ? #imageLiteral(resourceName: "globe_gold") : #imageLiteral(resourceName: "globe")
        destinationsBtn?.setImage(image, for: .normal)
        if !dealsLoaded {
            dealsLoaded = true
            getDeals()
        }
    }
    
    override func homeBackBtnTapped() {
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            navigationVC.setViewControllers([navigationVC.homeVC], animated: false)
        }
    }
    
    private func createTopTitle()
    {
        let titleLabel = SFFCAMLabel()
        titleLabel.type = .Heading
        titleLabel.textColor = fcamBlue
        title = DealType.printEnumValue(oFDealType: dealType)
        titleLabel.text = title?.removeWhitespace()
        titleLabel.sizeToFit()
        
        print(title!)
        
        let titleViewWidth = UIScreen.main.bounds.width
        var currentX = (titleViewWidth - titleLabel.frame.size.width) / 2
        let padding = CGFloat(10)
        
        if (title == "Favoriten")
        {
            let heartIcon = #imageLiteral(resourceName: "FavoriteButtonRed")
            currentX = (titleViewWidth - titleLabel.frame.size.width - padding - heartIcon.size.width) / 2
            let y = (titleView.frame.size.height - heartIcon.size.height) / 2
            
            let heartImageView = UIImageView(frame: CGRect(x: currentX, y: y, width: heartIcon.size.width, height: heartIcon.size.height))
            heartImageView.image = heartIcon
            titleView.addSubview(heartImageView)
            
            currentX += heartIcon.size.width + 5
        }
        
        titleView.backgroundColor = .white
        
        titleLabel.frame.origin.x = currentX
        titleLabel.frame.origin.y = (titleView.frame.size.height - titleLabel.frame.size.height) / 2
        
        switch dealType {
            case .Flüge, .Hotels, .Vielflieger_Status:
                if UserModel.sharedInstance.membership == .diamont {
                    destinationsBtn = UIButton(type: .custom)
                    let image = (destinations?.filter({ !$0.selected }).isEmpty ?? true) ? #imageLiteral(resourceName: "globe_gold") : #imageLiteral(resourceName: "globe")
                    destinationsBtn!.setImage(image, for: .normal)
                    destinationsBtn!.frame = CGRect(x: UIScreen.main.bounds.width - (titleView.frame.height - 8.0 * 2) - 8.0, y: 8.0, width: (titleView.frame.height - 8.0 * 2), height: titleView.frame.height - 8.0 * 2)
                    destinationsBtn!.addTarget(self, action: #selector(destinationsBtnPressed), for: .touchUpInside)
                    titleView.addSubview(destinationsBtn!)
                }
            default:
                break
        }
        if dealType != .Endet_Bald {
            destinationsBtn?.frame = CGRect(x: UIScreen.main.bounds.width - (titleView.frame.height - 8.0 * 2) * 2 - 8.0, y: 8.0, width: (titleView.frame.height - 8.0 * 2), height: titleView.frame.height - 8.0 * 2)
            expiredDealsBtn = UIButton(type: .custom)
            let image = expiredDealsEnabled ? #imageLiteral(resourceName: "cross") : #imageLiteral(resourceName: "tick")
            expiredDealsBtn!.setImage(image, for: .normal)
            expiredDealsBtn!.frame = CGRect(x: UIScreen.main.bounds.width - (titleView.frame.height - 10.0 * 2) - 8.0, y: 12.0, width: (titleView.frame.height - 12.0 * 2), height: titleView.frame.height - 12.0 * 2)
            expiredDealsBtn!.addTarget(self, action: #selector(expiredDealsBtnPressed), for: .touchUpInside)
            titleView.addSubview(expiredDealsBtn!)
        }
        
        titleView.addSubview(titleLabel)
    }
    
    private func createDealsView()
    {
        dealsView = SFDealsView(frame: CGRect(x: 0,
                                              y: titleView.frame.size.height,
                                              width: self.view.frame.size.width,
                                              height: self.view.frame.size.height - titleView.frame.size.height))
		dealsView.updateSource(with: deals)
        if let data = UserDefaults.standard.object(forKey: kUDSettingsPagesObjects) as? Data,
            let pages = NSKeyedUnarchiver.unarchiveObject(with: data) as? [FiltersObject] {
            switch dealType {
                case .Alle:
                    if let filters = pages.filter({ $0.title == "Alle Deals" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                case .Favoriten:
                    if let filters = pages.filter({ $0.title == "Favoriten" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                case .Endet_Bald:
                    if var filters = pages.filter({ $0.title == "Endet bald" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        filters.removeLast()
                        filters.append("Favoriten".uppercased())
                        dealsView.secondaryFilters = filters
                    }
                case .Flüge:
                    if let filters = pages.filter({ $0.title == "Flüge" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                    if let filters = pages.filter({ $0.title == "Flüge" }).first?.filters, filters.count > 1, let extraFilters = filters.last?.compactMap({ return $0.title ?? nil }) {
                        dealsView.extraSecondaryFilters = extraFilters
                    }
                case .Meilen_Programme:
                    if let filters = pages.filter({ $0.title == "Meilenprogramme" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                case .Vielflieger_Status:
                    if let filters = pages.filter({ $0.title == "Vielfliegerstatus" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                    if let filters = pages.filter({ $0.title == "Vielfliegerstatus" }).first?.filters, filters.count > 1, let extraFilters = filters.last?.compactMap({ return $0.title ?? nil }) {
                        dealsView.extraSecondaryFilters = extraFilters
                    }
                case .Hotels:
                    if let filters = pages.filter({ $0.title == "Hotels" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                    if let filters = pages.filter({ $0.title == "Hotels" }).first?.filters, filters.count > 1, let extraFilters = filters.last?.compactMap({ return $0.title ?? nil }) {
                        dealsView.extraSecondaryFilters = extraFilters
                    }
                case .Hotel_Programme:
                    if let filters = pages.filter({ $0.title == "Hotelprogramme" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                case .Kredit_Karten:
                    if let filters = pages.filter({ $0.title == "Kreditkarten" }).first?.filters?.first?.compactMap({ return $0.title ?? nil }) {
                        dealsView.secondaryFilters = filters
                    }
                default:
                    break
            }
        }
        switch dealType
        {
            case .Alle, .Favoriten, .Endet_Bald, .Flüge, .Meilen_Programme, .Vielflieger_Status, .Hotels, .Hotel_Programme, .Kredit_Karten:
                dealsView.isFiltersEnabled = true
            default:
                dealsView.isFiltersEnabled = false
        }
        dealsView.configureDealsView()
        self.view.addSubview(dealsView)
        self.view.bringSubviewToFront(dealsView)
        dealsView.dealsDelegate = self
        dealsView.searchBarDelegate = self
        dealsView.filtersDelegate = self
        dealsView.alpha = 0.0
    }
    
    func filterSelected(at: Int, row: RowNumber) {
        page = 1
        if row == .first {
            selectedItemIndex = at
        } else {
            secondRowItemIndex = at
        }
        getDeals()
    }
    
    func getDeals() {
        if let data = UserDefaults.standard.object(forKey: kUDSettingsPagesObjects) as? Data,
            let pages = NSKeyedUnarchiver.unarchiveObject(with: data) as? [FiltersObject] {
            switch dealType {
                case .Alle:
                    switch selectedItemIndex {
                        case 0:
                            loadDeals(.my)
                        case 1:
                            loadDeals(.highlights, param: HighlightsType.ohneLogin)
                        case 2:
                            loadDeals(.highlights, param: HighlightsType.gold)
                        case 3:
                            loadDeals(.highlights, param: HighlightsType.platin)
                        case 4:
                            loadDeals(.popular)
                        default:
                            break
                    }
                case .Favoriten:
                    if UserModel.sharedInstance.logined {
                        if let ids = pages.filter({ $0.title == "Favoriten"}).first?.filters?.first?.map({ return $0.ids }) {
                            if ids.count > selectedItemIndex {
                                let filterIds = ids[selectedItemIndex]
                                loadDeals(.favoriten, param: filterIds)
                            }
                        }
                    } else {
                        dealsView.alpha = 1.0
                    }
                case .Endet_Bald:
                    if let ids = pages.filter({ $0.title == "Endet bald"}).first?.filters?.first?.map({ return $0.ids }) {
                        if ids.count > selectedItemIndex {
                            let filterIds = ids[selectedItemIndex]
                            if selectedItemIndex != 0 && ids[selectedItemIndex] == nil {
                                loadDeals(.expiring, param: 1)
                            } else {
                                loadDeals(.expiring, param: filterIds)
                            }
                        }
                    }
                case .Flüge:
                    if let filters = pages.filter({ $0.title == "Flüge" }).first?.filters, filters.count > 1,
                        let firstRowIds = filters.first?.map({ return $0.ids }), let secondRowIds = filters.last?.map({ return $0.ids }) {
                        if firstRowIds.count > selectedItemIndex && secondRowIds.count > secondRowItemIndex {
                            let firstFilterIds = firstRowIds[selectedItemIndex]
                            let secondFilterIds = secondRowIds[secondRowItemIndex]
                            if let destinations = self.destinations {
                                var filteredDestinationIds = destinations.filter({ $0.selected }).compactMap({ $0.id })
                                filteredDestinationIds = destinations.filter({ !$0.selected }).isEmpty ? [] : filteredDestinationIds
                                loadDeals(.category, param: ["first": firstFilterIds, "second": secondFilterIds, "destinations": filteredDestinationIds])
                                return
                            }
                            loadDeals(.category, param: ["first": firstFilterIds, "second": secondFilterIds])
                        }
                    }
                case .Meilen_Programme:
                    if let ids = pages.filter({ $0.title == "Meilenprogramme"}).first?.filters?.first?.map({ return $0.ids }) {
                        if ids.count > selectedItemIndex {
                            let filterIds = ids[selectedItemIndex]
                            loadDeals(.category, param: filterIds)
                        }
                    }
                case .Vielflieger_Status:
                    if let ids = pages.filter({ $0.title == "Vielfliegerstatus"}).first?.filters?.first?.map({ return $0.ids }) {
                        if ids.count > selectedItemIndex {
                            let filterIds = ids[selectedItemIndex]
                            if let destinations = self.destinations {
                                var filteredDestinationIds = destinations.filter({ $0.selected }).compactMap({ $0.id })
                                filteredDestinationIds = destinations.filter({ !$0.selected }).isEmpty ? [] : filteredDestinationIds
                                loadDeals(.category, param: ["first": filterIds, "destinations": filteredDestinationIds])
                                return
                            }
                            loadDeals(.category, param: filterIds)
                        }
                    }
                case .Hotels:
                    if let ids = pages.filter({ $0.title == "Hotels"}).first?.filters?.first?.map({ return $0.ids }) {
                        if ids.count > selectedItemIndex {
                            let filterIds = ids[selectedItemIndex]
                            if let destinations = self.destinations {
                                var filteredDestinationIds = destinations.filter({ $0.selected }).compactMap({ $0.id })
                                filteredDestinationIds = destinations.filter({ !$0.selected }).isEmpty ? [] : filteredDestinationIds
                                loadDeals(.category, param: ["first": filterIds, "destinations": filteredDestinationIds])
                                return
                            }
                            loadDeals(.category, param: filterIds)
                        }
                    }
                case .Hotel_Programme:
                    if let ids = pages.filter({ $0.title == "Hotelprogramme"}).first?.filters?.first?.map({ return $0.ids }) {
                        if ids.count > selectedItemIndex {
                            let filterIds = ids[selectedItemIndex]
                            loadDeals(.category, param: filterIds)
                        }
                    }
                case .Kredit_Karten:
                    if let ids = pages.filter({ $0.title == "Kreditkarten"}).first?.filters?.first?.map({ return $0.ids }) {
                        if ids.count > selectedItemIndex {
                            let filterIds = ids[selectedItemIndex]
                            loadDeals(.category, param: filterIds)
                        }
                    }
                case .Ohne_Login:
                    loadDeals(.highlights, param: HighlightsType.ohneLogin)
                case .Gold_Highlights:
                    loadDeals(.highlights, param: HighlightsType.gold)
                case .Platin_Highlights:
                    loadDeals(.highlights, param: HighlightsType.platin)
            default:
                break
            }
        }
    }
    
    func loadDeals(_ type: DealRequest, param: Any? = nil) {
        if isConnectedToNetwork(repeatedFunction: {
            self.loadDeals(type, param: param)
        }) {
            if page == 1 {
                startLoading()
            }
            let shouldSendFilters = self.dealState == .blue && self.applyFilters
            Server.shared.loadDeals(type: type, param: param, page: page, shouldSendFilters: shouldSendFilters) { deals, error in
                DispatchQueue.main.async {
                    if self.page == 1 {
                        self.stopLoading()
                    }
                    if error != nil {
                        guard self.dealType != .Favoriten else { return }
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else {
                        if let deals = deals as? [DealModel] {
							// update local favorites ids
							if type == .favoriten {
								self.updateFavorites(deals)
							}
                            if self.page == 1 {
                                self.deals = deals
                            } else {
                                self.deals.append(contentsOf: deals)
                            }
                            if !self.expiredDealsEnabled && self.dealType != .Endet_Bald {
                                self.deals = self.deals.filter {
                                    if let expireDate = $0.expireDate?.date(format: "yyyy-MM-dd") {
                                        return Date().compare(expireDate) != .orderedDescending
                                    } else {
                                        return true
                                    }
                                }
                            }
                        }
                    }
                    UIView.animate(withDuration: 0.5) {
                        self.dealsView.alpha = 1.0
                    }
                }
            }
        }
    }
    
    func showAuthDialog(email: String?) {
        performSegue(withIdentifier: "showUnlockFiltersVC", sender: email)
    }
    
    func showConfirmCodeDialog(code: String, email: String) {
        performSegue(withIdentifier: "showConfirmCodeVC", sender: ["code": code, "email": email])
    }
    
    func showUnlockFiltersDialog() {
        performSegue(withIdentifier: "showUnlockFiltersVC", sender: nil)
    }
    
    @objc func destinationsBtnPressed() {
        let user = UserModel.sharedInstance
        if user.membership == .diamont {
            performSegue(withIdentifier: "showDestinationsFilterVC", sender: nil)
        } else {
            showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Dieser Bereich ist nicht für Ihr Mitgliedschafts-Level freigegeben", cancelBtn: false, okBtnCompletion: nil)
        }
    }

    @objc func expiredDealsBtnPressed() {
        let title = expiredDealsEnabled ? "Möchten Sie abgelaufene Deals wirklich deaktivieren?" : "Sind Sie sicher, dass Sie auch abgelaufene Deals anzeigen möchten?"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Ja", style: .default, handler: yesActionPressed)
        let cancelAction = UIAlertAction(title: "Nein", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func yesActionPressed(action: UIAlertAction) {
        let previousValue = UserDefaults.standard.bool(forKey: kUDExpiredDealsEnabled)
        UserDefaults.standard.set(!previousValue, forKey: kUDExpiredDealsEnabled)
        let image = expiredDealsEnabled ? #imageLiteral(resourceName: "cross") : #imageLiteral(resourceName: "tick")
        expiredDealsBtn!.setImage(image, for: .normal)
        page = 1
        getDeals()
    }
    
    func updateFilters() {
        dealsView.updateFilters()
    }
    
    func destinationsSelected(_ destinations: [DestinationObject]) {
        self.destinations = destinations
		getDeals()
    }
	
	func updateFavorites(_ deals: [DealModel]) {
		var favoritesSet = Set(UserModel.sharedInstance.favorites.map { $0 })
		let favorites = deals.compactMap { $0.id }
		for favoriteId in favorites {
			favoritesSet.insert(favoriteId)
		}
		let newFavorites = Array(favoritesSet)
		UserModel.sharedInstance.favorites = newFavorites
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "showWKWebViewVC":
                    let dvc = segue.destination as! WKWebViewController
                    dvc.pageLoaded = false
                    dvc.deal = sender as? DealModel
                    dvc.dealType = dealType
                case "showUnlockFiltersVC":
                    let dvc = segue.destination as! UnlockFIltersViewController
                    dvc.delegate = self
                    dvc.email = sender as? String
                case "showConfirmCodeVC":
                    let dvc = segue.destination as! ConfirmCodeViewController
                    let dict = sender as! [String: String]
                    dvc.delegate = self
                    dvc.code = dict["code"]!
                    dvc.email = dict["email"]!
                case "showDestinationsFilterVC":
                    let dvc = segue.destination as! DestinationsFilterViewController
                    dvc.delegate = self
                    dvc.destinations = destinations ?? []
                default:
                    break
            }
        }
    }
    
    // MARK: - Tableview Delegates & Datasource
    
    // infinite scroll implementation to load more news
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        if deltaOffset <= UIScreen.main.bounds.height * 0.25 {
            loadMoreDeals()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreDealsStatus = false
    }
    
    func loadMoreDeals() {
        if !loadMoreDealsStatus {
            loadMoreDealsStatus = true
            dealsView.tableViewFooterActivityIndicator?.startAnimating()
            dealsView.dealsTableView.tableFooterView!.isHidden = false
            page += 1
            getDeals()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return deals.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SFDealsCell", for: indexPath) as! SFDealsCell
        
        cell.dealsCategory.textColor = fcamBlue
        cell.dealsDate.textColor = fcamBlue
        cell.dealsDescription.textColor = fcamDarkGrey
        
        let index = indexPath.section
        let deal = deals[index]
        if let imageUrlString = deal.imageUrlString, let url = URL(string: imageUrlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!) {
            cell.imageActivityIndicator.startAnimating()
            //cell.dealsImage.image = nil
            cell.dealsImage.af_setImage(
                withURL: url,
                progressQueue: DispatchQueue.main,
                imageTransition: .crossDissolve(0.2),
                runImageTransitionIfCached: false,
                completion: { image in
                    cell.imageActivityIndicator.stopAnimating()
                }
            )
        }
        cell.ratingView.isHidden   = !(dealType == .Vielflieger_Status && selectedItemIndex == 1)
        cell.ratingLabel.text      = deal.rating
        cell.dealsExpireDate.isHidden = !(UserModel.sharedInstance.membership == .diamont || UserModel.sharedInstance.membership == .platin)
        cell.dealExpiredImageView.isHidden = true
        if let date = deal.expireDate?.date(format: "yyyy-MM-dd") {
            let stringDate = date.string(format: "dd-MM-yyyy") ?? ""
            if Date().isLowerThan(date, from: 3) {
                cell.dealsExpireDate.textColor = #colorLiteral(red: 0, green: 0.5, blue: 0, alpha: 1)
                cell.dealsExpireDate.text = "Buchbar bis \(stringDate)"
                cell.dealExpiredImageView.isHidden = true
            } else if Date().isLowerThan(date, from: 0) && Date().isGreaterThan(date, from: 3) {
                cell.dealsExpireDate.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                cell.dealsExpireDate.text = "Buchbar bis \(stringDate)"
                cell.dealExpiredImageView.isHidden = true
            } else if compareForExpiration(date: date) {
                cell.dealsExpireDate.isHidden = true
                cell.dealExpiredImageView.isHidden = false
            }
        } else {
            cell.dealsExpireDate.isHidden = true
        }
        if let date = deal.date?.date(format: "yyyy-MM-dd") {
            cell.dealsDate.text = date.string(format: "dd-MM-yyyy")
        }
        cell.dealsCategory.text    = deal.shortTitle
        cell.dealsTitle.text       = deal.title
        cell.dealsDescription.text = deal.teaser
        cell.dealsTierRibbon.image = deal.premium.ribbon
        cell.dealsTierRibbon.isHidden = deal.premium.ribbon == nil
        
        let user = UserModel.sharedInstance
        
        if user.logined {
            
            cell.favoriteButtonOutlet.isHidden = false
            
            if let dealId = deal.id {
                let favorites = UserModel.sharedInstance.favorites
                let favoriteBtnImage = favorites.contains(dealId) ? #imageLiteral(resourceName: "FavoriteButtonRed") : #imageLiteral(resourceName: "FavoriteButtonWhite")
                cell.favoriteButtonOutlet.setImage(favoriteBtnImage, for: .normal)
            }
            cell.favoriteBtnAction = favoriteBtnAction
            
        }
        else {
            
            cell.favoriteButtonOutlet.isHidden = true
            
        }
        
        
        return cell
    }
    
    private func compareForExpiration(date: Date) -> Bool {
        let now = Date()
        let result = Calendar.current.compare(now, to: date, toGranularity: .day)
        return result == .orderedDescending
    }
    
    func favoriteBtnAction(cell: UITableViewCell) {
        if let indexPath = dealsView.dealsTableView.indexPathForRow(at: cell.center) {
            let index = indexPath.section
            let deal = deals[index]
            if UserModel.sharedInstance.logined {
                if let dealId = deal.id {
                    let favorites = UserModel.sharedInstance.favorites
                    if favorites.contains(dealId) {
                        deleteFavorite(id: dealId, indexPath: indexPath)
                    } else {
                        addFavorite(id: dealId, indexPath: indexPath)
                    }
                }
            } else {
                showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Sie müssen eingeloggt sein, um diese Funktion zu nutzen", cancelBtn: false, okBtnCompletion: nil)
            }
        }
    }
    
    func deleteFavorite(id: Int, indexPath: IndexPath) {
        if isConnectedToNetwork(repeatedFunction: { self.deleteFavorite(id: id, indexPath: indexPath) }) {
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
                                user.favorites.remove(at: indexOfFavorite)
                                let data     = NSKeyedArchiver.archivedData(withRootObject: user)
                                let defaults = UserDefaults.standard
                                defaults.set(data, forKey: kUDSharedUserModel)
                                defaults.synchronize()
                                self.dealsView.dealsTableView.reloadRows(at: [indexPath], with: .automatic)
                                if self.dealType == .Favoriten {
                                    self.deals.remove(at: indexPath.section)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addFavorite(id: Int, indexPath: IndexPath) {
        if isConnectedToNetwork(repeatedFunction: { self.addFavorite(id: id, indexPath: indexPath) }) {
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
                            let data     = NSKeyedArchiver.archivedData(withRootObject: user)
                            let defaults = UserDefaults.standard
                            defaults.set(data, forKey: kUDSharedUserModel)
                            defaults.synchronize()
                            self.dealsView.dealsTableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.section
        let deal = deals[index]
        if let access = deal.access {
            if access == 0 {
                
                if deal.premium == Premium.gold {
                    
                    showPopupDialog(title: "", message: "Dieser Deal ist erst ab der GOLD-Mitgliedschaft freigegeben.", cancelBtn: false, okBtnCompletion: nil)
                    
                }
                else {
                    
                    showPopupDialog(title: "", message: "Dieser Deal ist nur für PLATIN/DIAMANT-Mitglieder freigegeben.", cancelBtn: false, okBtnCompletion: nil)
                    
                }
            }
            else {
                performSegue(withIdentifier: "showWKWebViewVC", sender: deal)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0
        {
            return 5
        }
        
        return 15
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 315
//    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // MARK: - SFDealsViewSearchBarDelegate
    func filterBarButtonTapped() {
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            navigationVC.pushViewController(navigationVC.filterIntroVC, animated: false)
        }
    }
    
    func displayError(description: String) {
        showPopupDialog(message: description, cancelBtn: false)
    }
}

// MARK: DZN Empty DataSource and Delegate
extension SFDealsTemplateViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "empty")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		
		var title: String
		switch dealType {
		case .Favoriten:
			title = "Keine Favoriten vorhanden"
		case .Endet_Bald:
			title = "Keine bald ablaufenden Deals vorhanden"
		default:
			title = "Keine Deals vorhanden"
		}
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 24.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = dealType == .Favoriten ? "Um Favoriten hinzuzufügen, müssen Sie bei einem Deal, der Ihnen gefällt, das Herzsymbol anklicken." : ""
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 17.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }
}
