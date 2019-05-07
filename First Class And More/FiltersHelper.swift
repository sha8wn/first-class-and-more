//
//  FiltersHelper.swift
//  First Class And More
//
//  Created by Vadim on 26/03/2019.
//  Copyright © 2019 Shawn Frank. All rights reserved.
//

import Foundation

struct FiltersHelper {
    
    static var hasUnselectedItems: Bool {
        return (unselectedFilters.count > 0) ||
               (unselectedDestinations.count > 0) ||
               (unselectedCategories.count > 0)
    }
    
    static var unselectedFilters: [Int] {
        return (UserDefaults.standard.object(forKey: kUDUnselectedFilters) as? [Int] ?? [])
    }
    
    static var unselectedDestinations: [DestinationObject] {
        guard let filterDestination = FiltersHelper.getFilterDestination(),
            let items = filterDestination.items else { return [] }
        
        return items.filter({ $0.selected == false })
    }
    
    static var unselectedCategories: [CategoryObject] {
        var filteredObjects: [CategoryObject] = []
        
        for category in FiltersHelper.getCategoryObjects() {
            if let sections = category.sections {
                for section in sections {
                    if let items = section.items {
                        for item in items {
                            if !item.selected {
                                filteredObjects.append(category)
                            }
                        }
                    }
                }
                
            }
        }
        
        return filteredObjects
    }
    
    static func getFilterDestination() -> FilterDestinationObject? {
        guard let data = UserDefaults.standard.object(forKey: kUDSettingsDestinationsObjects) as? Data else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? FilterDestinationObject
    }
    
    static func saveFilterDestination(_ filterDestination: FilterDestinationObject) {
        let data = NSKeyedArchiver.archivedData(withRootObject: filterDestination)
        UserDefaults.standard.set(data, forKey: kUDSettingsDestinationsObjects)
    }
    
    static func getCategoryObjects() -> [CategoryObject] {
        guard let data = UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) as? Data else { return [] }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [CategoryObject] ?? []
    }
    
    static func saveCategoryObjects(_ categoryObjects: [CategoryObject]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: categoryObjects)
        UserDefaults.standard.set(data, forKey: kUDSettingsCategoriesObjects)
    }
    
    static func resetAllFilters() {
        UserDefaults.standard.set([], forKey: kUDUnselectedFilters)
        
        if let filterDestination = FiltersHelper.getFilterDestination() {
            filterDestination.items?.forEach({ $0.selected = true })
            FiltersHelper.saveFilterDestination(filterDestination)
        }
        
        let categories = FiltersHelper.getCategoryObjects()
        for category in categories {
            if let sections = category.sections {
                for section in sections {
                    if let items = section.items {
                        for item in items {
                            item.selected = true
                        }
                    }
                }
            }
        }
        FiltersHelper.saveCategoryObjects(categories)
    }
    
}
