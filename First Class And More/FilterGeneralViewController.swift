//
//  FilterGeneralViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 10/7/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class FilterGeneralViewController: SFSidebarViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    
    let defaults = UserDefaults.standard
    var sections: [SectionObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    func setupUI() {
        let header = UINib(nibName: "FilterGeneralHeader", bundle: nil)
        tableView.register(header, forHeaderFooterViewReuseIdentifier: "FilterGeneralHeader")
        let user = UserModel.sharedInstance
        continueBtn.setTitle(!user.isGold && user.logined ? "Weiter" : "Fertig", for: .normal)
    }
    
    func setupData() {
        if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
            let categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject],
            let generalCategory = categories.filter({ $0.name == "Generell" }).first {
            if let sections = generalCategory.sections {
                self.sections = sections
                tableView.reloadData()
            }
        }
    }
    
    func saveData() {
        if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
            let categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject],
            let generalCategory = categories.filter({ $0.name == "Generell" }).first {
            generalCategory.sections = sections
            let data = NSKeyedArchiver.archivedData(withRootObject: categories)
            defaults.set(data, forKey: kUDSettingsCategoriesObjects)
            defaults.synchronize()
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
    
    func getItems(selected: Bool) -> [String] {
        var selectedItems: [String] = []
        for section in sections {
            if let items = section.items {
                for item in items {
                    if item.selected == selected, let name = item.name, !selectedItems.contains(name) {
                        selectedItems.append(name)
                    }
                }
            }
        }
        return selectedItems
    }
    
    @IBAction func filterBtnPressed() {
//        clearSelectedFilters()
        var unselectedIdentifiers = getFilters(selected: false)
        if !unselectedIdentifiers.isEmpty {
            if let oldIdentifiers = defaults.object(forKey: kUDUnselectedFilters) as? [Int], !oldIdentifiers.isEmpty {
                unselectedIdentifiers = unselectedIdentifiers.union(oldIdentifiers)
            }
            defaults.set(Array(unselectedIdentifiers), forKey: kUDUnselectedFilters)
            defaults.synchronize()
        }
        saveData()
        let user = UserModel.sharedInstance
        if !user.isGold && user.logined {
            checkForSelectedFilters()
        } else {
            showMainScreen()
        }
    }
    
    func clearSelectedFilters() {
        if let oldIdentifiersArray = defaults.object(forKey: kUDUnselectedFilters) as? [Int] {
            let selectedIdentifiers = getFilters(selected: true)
            let selectedItems = getItems(selected: true)
            var oldIdentifiers = Set(oldIdentifiersArray)
            if !oldIdentifiers.isEmpty {
                let oldCount = oldIdentifiers.count
                oldIdentifiers.subtract(selectedIdentifiers)
                if oldCount != oldIdentifiers.count {                    
                    updateAdvancedFilters(array: selectedItems, selected: true)
                }
                if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
                    let categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject] {
                    for arrayItem in selectedItems {
                        if let category = categories.filter({ $0.name == arrayItem }).first {
                            if let sequenceIds = category.sections?.compactMap({ $0.items?.compactMap { $0.id }}) {
                                let categoryIds = Array(sequenceIds.joined())
                                oldIdentifiers.subtract(categoryIds)
                            }
                        } else if let category = categories.filter({ $0.name == "Andere" }).first {
                            if let currentSection = category.sections?.filter({ $0.name == arrayItem }).first, let index = category.sections?.index(of: currentSection) {
                                if let categoryIds = category.sections?[index].items?.compactMap({ $0.id }) {
                                    oldIdentifiers.subtract(categoryIds)
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
    
    func checkForSelectedFilters() {
        let selectedItems = getItems(selected: true)
        let unSelectedItems = getItems(selected: false)
        updateAdvancedFilters(array: unSelectedItems, selected: false)
        let categories = FiltersHelper.getCategoryObjects()
        
        var categoriesToExclude: [String] = []
        for category in categories {
            guard let categoryName = category.name else { continue }
            if unSelectedItems.contains(categoryName) {
                categoriesToExclude.append(categoryName)
            }
            let selectedSections = (category.sections ?? []).filter { (sectionObject) -> Bool in
                guard let sectionName = sectionObject.name else { return false }
                return !unSelectedItems.contains(sectionName)
            }
            if selectedSections.count == 0 {
                categoriesToExclude.append(categoryName)
            }
        }
        
        var categoriesNames = categories.compactMap{ $0.name }
        categoriesNames = categoriesNames.filter{ !categoriesToExclude.contains($0) }
        
        if categoriesNames.count > 0 {
            categoriesNames[0] = "Destination"
        }
        if !selectedItems.isEmpty {
            let advancedFilterVC = self.storyboard?.instantiateViewController(withIdentifier: "advancedFilterVC") as! AdvancedFiltersViewController
            advancedFilterVC.selectedCategories = categoriesNames
            advancedFilterVC.selectedItems = selectedItems
            advancedFilterVC.unselectedItems = unSelectedItems
            advancedFilterVC.currentScreen = 2
            navigationController?.pushViewController(advancedFilterVC, animated: true)
        } else {
            showMainScreen()
        }
    }
    
    func updateAdvancedFilters(array: [String], selected: Bool) {
        if let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data,
            let categories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject] {
            for arrayItem in array {
                if let category = categories.filter({ $0.name == arrayItem }).first {
                    _ = category.sections?.map { $0.items?.map { $0.selected = selected } }
                } else if let category = categories.filter({ $0.name == "Andere" }).first {
                    if let currentSection = category.sections?.filter({ $0.name == arrayItem }).first, let index = category.sections?.index(of: currentSection) {
                        _ = category.sections?[index].items?.map { $0.selected = selected }
                    }
                }
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: categories)
            defaults.set(data, forKey: kUDSettingsCategoriesObjects)
            defaults.synchronize()
        }
    }
    
    func showMainScreen() {
        if let navigationController = navigationController as? SFSidebarNavigationController {
            navigationController.setViewControllers([navigationController.homeVC], animated: true)
        }
    }
}

extension FilterGeneralViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].isOpened ? sections[section].items?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterRowCell", for: indexPath) as! FilterGeneralTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: FilterGeneralTableViewCell, atIndexPath indexPath: IndexPath) {
        let index = indexPath.row
        let section = sections[indexPath.section]
        if let item = section.items?[index] {
            cell.name.text = item.name?.html2String
            cell.filterSwitch.on = item.selected
            cell.filterSwitchTapped = filterSwitchTapped
        }
    }
    
    func filterSwitchTapped(cell: UITableViewCell, isOn: Bool) {
        if let indexPath = tableView.indexPathForRow(at: cell.center) {
            if let item = sections[indexPath.section].items?[indexPath.row] {
                item.selected = !item.selected
            }
        }
    }
    
    func expandBtnTapped(indexPath: IndexPath?) {
        if let indexPath = indexPath {
            var indexes = [indexPath.section]
            if let openedSection = sections.filter({ $0.isOpened }).first, let section = sections.index(of: openedSection), section != indexPath.section {
                indexes.append(section)
                openedSection.isOpened = false
            }
            sections[indexPath.section].isOpened = !sections[indexPath.section].isOpened
            UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == sections.count - 1 ? .leastNormalMagnitude : 14.0
    }
}
