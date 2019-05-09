//
//  AdvancedFiltersViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/17/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class AdvancedFiltersViewController: SFSidebarViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var hintLabelTop: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    let defaults = UserDefaults.standard
    var selectedCategories: [String] = []
    var selectedItems: [String] = []
    var unselectedItems: [String] = []
    var currentScreen: Int = 0
    var accessRules: [String: [(String, Membership)]] = [
        "Flüge": [
            ("Flugdealklassifikation", .platin),
            ("Serviceklassen", .platin),
            ("Flugallianz", .platin),
            ("Airlines", .diamont)
        ],
        "Meilenprogramme": [
            ("Meilenprogramm-Themen", .platin),
            ("Meilenprogramm-Liste", .diamont)
        ],
        "Vielfliegerstatus": [
            ("Vielfliegerstatus Allianz", .platin),
            ("Vielfliegerstatus Airline", .platin),
            ("Vielfliegerstatus Insider", .platin)
        ],
        "Hotels": [
            ("Hoteldealklassifikation", .platin),
            ("Hotelkategorie", .platin),
            ("Hoteltyp", .platin),
            ("Hotelketten", .diamont),
            ("Buchungsportale", .diamont)
        ],
        "Hotelprogramme": [
            ("Hotelprogramm Themen", .platin),
            ("Hotelstatus Insider", .platin),
            ("Hotelprogramm Liste", .diamont)
        ],
        "Weitere Themen": [
            ("Kreditkarten", .platin),
            ("Generelle Beiträge", .platin),
            ("Insider Publikationen", .platin),
            ("Tests", .platin),
            ("Veranstaltungen", .platin)
        ]
    ]
    var sections: [SectionObject] = []
    var sectionsNamesAffecteByAlliance = [
        "Airlines",
        "Vielfliegerstatus Airline"
    ]
    
    var unselectedAlliances: [String] = []
    var allianceDict: [String: [Int]]?
    var isSelectAllAirlinesShowed: Bool = false
    var ignoreAffectingByAlliance: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        for section in sections {
            if let sectionName = section.name, sectionName == "Flugallianz" {
                for item in section.items ?? [] {
                    if let id = item.id, !item.selected {
                        unselectedAlliances.append("\(id)")
                    }
                }
            }
        }
        if let data = UserDefaults.standard.object(forKey: kUDSettingsAllianceObject) as? Data,
            let allianceObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? AllianceObject,
            let allianceDictionary = allianceObject.dictionary {
            self.allianceDict = allianceDictionary
        }
    }
    
    func setupUI() {
        let header = UINib(nibName: "FilterGeneralHeader", bundle: nil)
        tableView.register(header, forHeaderFooterViewReuseIdentifier: "FilterGeneralHeader")
        hintLabel.text = nil
        hintLabelTop.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backBtn.setImage(#imageLiteral(resourceName: "backBtn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        let backBarBtnItem = UIBarButtonItem(customView: backBtn)
        navigationItem.setLeftBarButton(backBarBtnItem, animated: false)
    }
    
    @objc func backBtnPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupData() {
        if !selectedCategories.isEmpty {
            if selectedCategories.count > currentScreen - 2 && currentScreen - 2 >= 0 {
                let first = selectedCategories[currentScreen - 2]
                updateUI(category: first)
                if let rules = accessRules[first] {
                    for rule in rules {
                        if rule.1 == .platin || (rule.1 == .diamont && UserModel.sharedInstance.membership == .diamont) {
                            if let sectionObject = getSection(sectionName: rule.0) {
                                if let sectionName = sectionObject.name, unselectedItems.contains(sectionName) {
                                    continue
                                }
                                self.sections.append(sectionObject)
                            }
                        }
                    }
                    tableView.reloadData()
                } else if let destinationData = UserDefaults.standard.object(forKey: kUDSettingsDestinationsObjects) as? Data,
                    let destination = NSKeyedUnarchiver.unarchiveObject(with: destinationData) as? FilterDestinationObject {
                    continueBtn.setTitle(currentScreen == (selectedCategories.count + 1) ? "Fertig" : "Weiter", for: .normal)
                    saveBtn.isHidden = currentScreen == (selectedCategories.count + 1)
                    titleLabel.text = "Schritt \(currentScreen) von \(selectedCategories.count + 1) – \(destination.name ?? "")"
                    subtitleLabel.text = destination.subtitle
                    sections = [SectionObject(name: "Destination", items: destination.items)]
                }
            }
        }
    }
    
    func updateUI(category: String) {
        continueBtn.setTitle(currentScreen == (selectedCategories.count + 1) ? "Fertig" : "Weiter", for: .normal)
        saveBtn.isHidden = currentScreen == (selectedCategories.count + 1)
        if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
            let categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject] {
            if let category = categories.filter({ $0.name == category }).first {
                titleLabel.text = "Schritt \(currentScreen) von \(selectedCategories.count + 1) – \(category.name ?? "")"
                subtitleLabel.text = category.subtitle
                hintLabel.text = category.note
            } else if let category = categories.filter({ $0.name == "Weitere Themen" }).first {
                titleLabel.text = "Schritt \(currentScreen) von \(selectedCategories.count + 1) – Weitere Themen"
                subtitleLabel.text = category.subtitle
                hintLabel.text = category.note
            }
            hintLabelTop.constant = (hintLabel.text?.isEmpty ?? true) ? 0 : 14
        }
    }
    
    func getSection(sectionName: String) -> SectionObject? {
        if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
            var categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject] {
            // remove first not needed
            if let generalCategory = categories.filter({ $0.name == "Generell" }).first, let index = categories.index(of: generalCategory) {
                categories.remove(at: index)
            }
            for category in categories {
                if let section = category.sections?.filter({ $0.name == sectionName }).first {
                    return section
                }
            }
        }
        return nil
    }
    
    @IBAction func saveBtnPressed() {
        let first = selectedCategories[currentScreen - 2]
        if first == "Destination", let destinationData = UserDefaults.standard.object(forKey: kUDSettingsDestinationsObjects) as? Data,
            let destination = NSKeyedUnarchiver.unarchiveObject(with: destinationData) as? FilterDestinationObject {
            destination.items = sections.first?.items ?? []
            let data = NSKeyedArchiver.archivedData(withRootObject: destination)
            defaults.set(data, forKey: kUDSettingsDestinationsObjects)
            defaults.synchronize()
        } else {
//            clearSelectedFilters()
            var unselectedIdentifiers = getFilters(selected: false)
            if !unselectedIdentifiers.isEmpty {
                if let oldIdentifiers = defaults.object(forKey: kUDUnselectedFilters) as? [Int], !oldIdentifiers.isEmpty {
                    unselectedIdentifiers = unselectedIdentifiers.union(oldIdentifiers)
                }
                defaults.set(Array(unselectedIdentifiers), forKey: kUDUnselectedFilters)
                defaults.synchronize()
                saveData()
            }
        }
        showMainScreen()
    }
    
    @IBAction func continueBtnPressed() {
        let first = selectedCategories[currentScreen - 2]
        if first == "Destination", let destinationData = UserDefaults.standard.object(forKey: kUDSettingsDestinationsObjects) as? Data,
            let destination = NSKeyedUnarchiver.unarchiveObject(with: destinationData) as? FilterDestinationObject {
            destination.items = sections.first?.items ?? []
            let data = NSKeyedArchiver.archivedData(withRootObject: destination)
            defaults.set(data, forKey: kUDSettingsDestinationsObjects)
            defaults.synchronize()
        } else {
//            clearSelectedFilters()
            var unselectedIdentifiers = getFilters(selected: false)
            if !unselectedIdentifiers.isEmpty {
                if let oldIdentifiers = defaults.object(forKey: kUDUnselectedFilters) as? [Int], !oldIdentifiers.isEmpty {
                    unselectedIdentifiers = unselectedIdentifiers.union(oldIdentifiers)
                }
                defaults.set(Array(unselectedIdentifiers), forKey: kUDUnselectedFilters)
                defaults.synchronize()
            }
            saveData()
        }
        if currentScreen != selectedCategories.count + 1 {
            let advancedFilterVC = self.storyboard?.instantiateViewController(withIdentifier: "advancedFilterVC") as! AdvancedFiltersViewController
            advancedFilterVC.selectedCategories = selectedCategories
            advancedFilterVC.currentScreen = currentScreen + 1
            advancedFilterVC.selectedItems = selectedItems
            advancedFilterVC.unselectedItems = unselectedItems
            navigationController?.pushViewController(advancedFilterVC, animated: true)
        } else {
            showMainScreen()
        }
    }
    
    func clearSelectedFilters() {
        let selectedIdentifiers = getFilters(selected: true)
        if let oldIdentifiersArray = defaults.object(forKey: kUDUnselectedFilters) as? [Int] {
            var oldIdentifiers = Set(oldIdentifiersArray)
            if !oldIdentifiers.isEmpty {
                oldIdentifiers.subtract(selectedIdentifiers)
                if !selectedCategories.isEmpty {
                    if selectedCategories.count > currentScreen - 2 && currentScreen - 2 >= 0 {
                        let first = selectedCategories[currentScreen - 2]
                        if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
                            let categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject] {
                            for arrayItem in selectedCategories {
                                if let category = categories.filter({ $0.name == arrayItem }).first {
                                    if let sequenceIds = category.sections?.compactMap({ $0.items?.compactMap { $0.id }}) {
                                        let categoryIds = Array(sequenceIds.joined())
                                        oldIdentifiers.subtract(categoryIds)
                                    }
                                } else if let tuple = accessRules[first]?.first,
                                    let category = categories.filter({ $0.name == "Weitere Themen" }).first {
                                    if let currentSection = category.sections?.filter({ $0.name == tuple.0 }).first,
                                        let index = category.sections?.index(of: currentSection) {
                                        if let categoryIds = category.sections?[index].items?.compactMap({ $0.id }) {
                                            oldIdentifiers.subtract(categoryIds)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                defaults.set(Array(oldIdentifiers), forKey: kUDUnselectedFilters)
                defaults.synchronize()
            }
        }
    }
    
    func saveData() {
        if !selectedCategories.isEmpty {
            if selectedCategories.count > currentScreen - 2 && currentScreen - 2 >= 0 {
                let first = selectedCategories[currentScreen - 2]
                if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
                    let categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject] {
                    if let category = categories.filter({ $0.name == first }).first {
                        category.sections = sections
                    } else if let tuple = accessRules[first]?.first,
                        let category = categories.filter({ $0.name == "Weitere Themen" }).first,
                        let activeSection = self.sections.first {
                        if let currentSection = category.sections?.filter({ $0.name == tuple.0 }).first, let index = category.sections?.index(of: currentSection) {
                            category.sections?[index] = activeSection
                        }
                    }
                    let data = NSKeyedArchiver.archivedData(withRootObject: categories)
                    defaults.set(data, forKey: kUDSettingsCategoriesObjects)
                    defaults.synchronize()
                }
            }
        }
    }
    
    func getFilters(selected: Bool) -> Set<Int> {
        var identifiers: Set<Int> = []
        for section in sections {
            if let items = section.items {
                for item in items {
                    if item.selected == selected, let id = item.id {
                        identifiers.insert(id)
                    }
                }
            }
        }
        return identifiers
    }
    
    func showMainScreen() {
        if let navigationController = navigationController as? SFSidebarNavigationController {
            navigationController.setViewControllers([navigationController.homeVC], animated: true)
        }
    }
}

extension AdvancedFiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func isAirlinesFirstRow(_ indexPath: IndexPath) -> Bool {
        return sections[indexPath.section].isAirlines && indexPath.row == 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let current = sections[section]
        if !current.isOpened {
            return 0
        }
        
        let count = current.items?.count ?? 0
        return current.isAirlines ? count + 1 : count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAirlinesFirstRow(indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! FilterButtonCell
            cell.isSelectAllShowed = isSelectAllAirlinesShowed
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterRowCell", for: indexPath) as! FilterGeneralTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: FilterGeneralTableViewCell, atIndexPath indexPath: IndexPath) {
        var index = indexPath.row
        let section = sections[indexPath.section]
        if section.isAirlines {
            index -= 1
        }
        
        if let item = section.items?[index] {
            cell.name.text                     = item.name?.html2String
            cell.filterSwitch.on               = item.selected
            cell.name.textColor                = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.filterSwitch.thumbTintColor   = #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
            cell.filterSwitch.onThumbTintColor = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1)
            
            if !ignoreAffectingByAlliance {
                if let sectionName = section.name,
                    sectionsNamesAffecteByAlliance.contains(sectionName),
                    let id = item.id,
                    let allianceDict = self.allianceDict {
                    var identifiers: [Int] = []
                    for alliance in unselectedAlliances {
                        if let ids = allianceDict[alliance] {
                            identifiers.append(contentsOf: ids)
                        }
                    }
                    cell.name.textColor                = identifiers.contains(id) ? #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    cell.filterSwitch.thumbTintColor   = identifiers.contains(id) ? #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
                    cell.filterSwitch.onThumbTintColor = identifiers.contains(id) ? #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1)
                    item.selected                      = identifiers.contains(id) ? false : item.selected
                    cell.filterSwitch.on               = item.selected
                }
            }
            
            cell.filterSwitchTapped = filterSwitchTapped
        }
    }
    
    func filterSwitchTapped(cell: UITableViewCell, isOn: Bool) {
        if let indexPath = tableView.indexPathForRow(at: cell.center) {
            if let sectionName = sections[indexPath.section].name,
                sectionsNamesAffecteByAlliance.contains(sectionName),
                let id = sections[indexPath.section].items?[indexPath.row].id,
                let allianceDict = self.allianceDict {
                var identifiers: [Int] = []
                for alliance in unselectedAlliances {
                    if let ids = allianceDict[alliance] {
                        identifiers.append(contentsOf: ids)
                    }
                }
                if identifiers.contains(id), let cell = cell as? FilterGeneralTableViewCell {
                    showPopupDialog(title: "Allianz-Fehler", message: "Bitte aktivieren Sie zunächst die jeweilige Allianz, wenn Sie eine Fluggesellschaft aus dieser auswählen möchten.", cancelBtn: false) {
                        cell.filterSwitch.setOn(false, animated: true)
                    }
                }
            } else if let sectionName = sections[indexPath.section].name, (sectionName == "Flugallianz" || sectionName == "Vielfliegerstatus Allianz") {
                if let item = sections[indexPath.section].items?[indexPath.row] {
                    item.selected = !item.selected
                    if item.selected, let id = item.id, let index = unselectedAlliances.index(of: "\(id)") {
                        unselectedAlliances.remove(at: index)
                    } else if let id = item.id {
                        unselectedAlliances.append("\(id)")
                    }
                }
            } else if let item = sections[indexPath.section].items?[indexPath.row] {
                item.selected = !item.selected
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let indexPath = IndexPath(row: 0, section: section)
        let section = sections[section]
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterGeneralHeader") as! FilterGeneralHeader
        cell.nameLabel.text = section.name
        cell.indexPath = indexPath
        cell.expanded = section.isOpened
        cell.expandBtnTapped = expandBtnTapped
        return cell
    }
    
    func expandBtnTapped(indexPath: IndexPath?) {
        if let indexPath = indexPath {
            var indexes = [indexPath.section]
            if let openedSection = sections.filter({ $0.isOpened }).first, let section = sections.index(of: openedSection), section != indexPath.section {
                indexes.append(section)
                openedSection.isOpened = false
            }
			let isOpened = !sections[indexPath.section].isOpened
            sections[indexPath.section].isOpened = isOpened
            UIView.transition(with: tableView,
							  duration: 0.2,
							  options: .transitionCrossDissolve,
							  animations: {
								self.tableView.reloadData()
			},
							  completion: { finished in
								guard finished else { return }
								if isOpened {
									self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
								}
			})
		}
		
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == sections.count - 1 ? .leastNormalMagnitude : 14.0
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return isAirlinesFirstRow(indexPath) ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isAirlinesFirstRow(indexPath) else { return }
        
        let previousValue = isSelectAllAirlinesShowed
        isSelectAllAirlinesShowed = !isSelectAllAirlinesShowed
        
        let cell = tableView.cellForRow(at: indexPath) as! FilterButtonCell
        cell.isSelectAllShowed = isSelectAllAirlinesShowed
        
        selectAllAirlines(!isSelectAllAirlinesShowed, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard isAirlinesFirstRow(indexPath) else { return }
        
        showPopupDialog(title: nil, message: "Wenn Sie z. B. nur wenige Airlines in den Beiträgen sehen wollen, ist es einfacher, zunächst alle zu deaktivieren und dann die relevanten auszuwählen.", cancelBtn: false, okBtnTitle: nil, okBtnCompletion: nil)
    }
    
    private func selectAllAirlines(_ shouldSelect: Bool, indexPath: IndexPath) {
        for item in sections[indexPath.section].items ?? [] {
            item.selected = shouldSelect
        }
        
        let itemsCount = sections[indexPath.section].items?.count ?? 0
        var indexPaths: [IndexPath] = []
        for i in 1..<itemsCount {
            indexPaths.append(IndexPath(row: i, section: indexPath.section))
        }
        
        ignoreAffectingByAlliance = true
        tableView.reloadRows(at: indexPaths, with: .automatic)
        ignoreAffectingByAlliance = false
    }
    
}
