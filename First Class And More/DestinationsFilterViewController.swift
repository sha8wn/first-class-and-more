//
//  DestinationsFilterViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 8/21/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

protocol DestinationsDelegate {
    func destinationsSelected(_ destinations: [DestinationObject])
}

class DestinationsFilterViewController: UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableView.automaticDimension
        }
    }
    
    var delegate: DestinationsDelegate?
    var destinations: [DestinationObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        setupNavBar()
        createTopTitle()
    }
    
    func setupNavBar() {
        // backBtn
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backBtn.setImage(#imageLiteral(resourceName: "backBtn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        let backBarBtn = UIBarButtonItem(customView: backBtn)
        navigationItem.setLeftBarButtonItems([backBarBtn], animated: false)
        // logo
        let logo = UIImage(named: "NavLogo")
        let imageView = UIImageView(image: logo)
        navigationItem.titleView = imageView
    }
    
    func createTopTitle() {
        let titleLabel = SFFCAMLabel()
        titleLabel.type = .Heading
        titleLabel.textColor = fcamBlue
        titleLabel.text = "Filter nach Destinationen"
        titleLabel.sizeToFit()
        let currentX = (titleView.frame.size.width - titleLabel.frame.size.width) / 2
        titleView.backgroundColor = .white
        titleLabel.frame.origin.x = currentX
        titleLabel.frame.origin.y = (titleView.frame.size.height - titleLabel.frame.size.height) / 2
        titleView.addSubview(titleLabel)
    }
    
    @IBAction func doneBtnPressed() {
        navigationController?.popViewController(animated: true)
        delegate?.destinationsSelected(destinations)
    }
    
    @objc func backBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension DestinationsFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationFilterTableCell", for: indexPath) as! DestinationFilterTableViewCell
        let destination = destinations[indexPath.row]
        cell.nameLabel.text = destination.name?.replacingOccurrences(of: "\\", with: "")
        cell.sevenSwitch.on = destination.selected
        cell.sevenSwitchTapped = sevenSwitchTapped
        return cell
    }
    
    func sevenSwitchTapped(cell: UITableViewCell, isOn: Bool) {
        if let indexPath = tableView.indexPathForRow(at: cell.center) {
            let destination = destinations[indexPath.row]
            destination.selected = !destination.selected
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // removing seperator inset
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = .zero
        }
        // prevent the cell from inheriting the tableView's margin settings
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        // explicitly setting cell's layout margins
        if cell.responds(to: #selector(setter: UITableViewCell.layoutMargins)) {
            cell.layoutMargins = .zero
        }
    }
}
