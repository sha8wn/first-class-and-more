//
//  FilterIntroViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/17/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class FilterIntroViewController: SFSidebarViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    func setupData() {
        if FiltersHelper.hasUnselectedItems {
            titleLabel.text = "Filter definieren"
            bodyLabel.text = "Sie haben bereits Filtereinstellungen vorgenommen und abgespeichert. Sie können diese jetzt weiter bearbeiten oder alle Filter mit einem Reset der Filter-Einstellungen wieder aufheben."
            continueButton.setTitle("AKTUELLE FILTER BEARBEITEN", for: .normal)
            resetButton.isHidden = false
            return
        }
        
        if let data = UserDefaults.standard.object(forKey: kUDSettingsFilter) as? Data,
            let filter = NSKeyedUnarchiver.unarchiveObject(with: data) as? FilterObject {
            if let title = filter.title {
                titleLabel.text = title
            }
            if let body = filter.body {
                bodyLabel.text = body
            }
        }
        
        continueButton.setTitle("LOS GEHT‘S", for: .normal)
        resetButton.isHidden = true
    }
    
    @IBAction func continueBtnPressed() {
        performSegue(withIdentifier: "showFilterVC", sender: nil)
    }
    
    @IBAction func resetBtnPressed() {
        FiltersHelper.resetAllFilters()
        continueBtnPressed()
    }
}
