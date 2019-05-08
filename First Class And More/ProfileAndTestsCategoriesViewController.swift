//
//  ProfileAndTestsCategoriesViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 12/3/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class ProfileAndTestsCategoriesViewController: SFSidebarViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var page: Int = 1
    var loadMoreDealsStatus: Bool = false
	var deals: [DealModel] = []
	
    var categories: [Int] = []
    var orderBy: RouterDeals.Sorting = .none
    var layout: ProfileAndTestsViewController.Layout = .twoColumns
    
    var dealsLoaded: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addHomeBtn()
        if !dealsLoaded {
            dealsLoaded = true
            loadDeals()
        }
    }
    
    func loadDeals() {
        if isConnectedToNetwork(repeatedFunction: loadDeals) {
            if !categories.isEmpty {
                if page == 1 {
                    startLoading()
                }
                Server.shared.loadDeals(type: .category, param: categories, page: page, orderBy: orderBy) { deals, error in
                    DispatchQueue.main.async {
                        if self.page == 1 {
                            self.stopLoading()
                        }
                        if error != nil {
                            self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                        } else {
                            if let deals = deals as? [DealModel] {
                                if self.page == 1 {
                                    self.deals = deals
                                } else {
                                    self.deals.append(contentsOf: deals)
                                }
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
	
	private func sortDeals(_ deals: [DealModel]) -> [DealModel] {
		return deals.sorted { $0.title ?? "" < $1.title ?? "" }
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "showWKWebViewVC":
                    let dvc = segue.destination as! WKWebViewController
                    dvc.pageLoaded = false
                    dvc.deal = sender as? DealModel
                default:
                    break
            }
        }
    }
    
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
            page += 1
            loadDeals()
        }
    }
    
    // MARK: Actions
    
    override func homeBtnTapped() {
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            navigationVC.setViewControllers([navigationVC.homeVC], animated: true)
        }
    }
    
}

extension ProfileAndTestsCategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = layout == .oneColumn ? "oneColumnCell" : "profilesAndTestsCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ProfilesAndTestsCollectionViewCell
        
        let deal = deals[indexPath.row]
        if let imageUrlString = deal.imageUrlString, let url = URL(string: imageUrlString) {
            cell.spinner.startAnimating()
            cell.dealImageView.image = nil
            cell.dealImageView.af_setImage(
                withURL: url,
                progressQueue: DispatchQueue.main,
                imageTransition: .crossDissolve(0.2),
                runImageTransitionIfCached: false,
                completion: { image in
                    cell.spinner.stopAnimating()
                }
            )
        }
        cell.titleLabel.text = deal.title
        if let date = deal.date?.date(format: "yyyy-MM-dd"), let label = cell.dateLabel {
            label.text = date.string(format: "dd. MMMM yyyy")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deal = deals[indexPath.row]
        
        var width: CGFloat
        var imageHeight: CGFloat
        
        if layout == .oneColumn {
            width = UIScreen.main.bounds.width - 16.0 * 2 - 12.0
            imageHeight = 150
        } else {
            width = (UIScreen.main.bounds.width - 16.0 * 2 - 12.0) / 2
            imageHeight = width / 1.5
        }
        let titleHeight = deal.title?.size(withConstrainedWidth: width, font: UIFont(name: "Roboto-Medium", size: 17.0)!, numberOfLines: 3).height ?? 0
        let dateHeight = deal.date?.date(format: "yyyy-MM-dd")?.string(format: "dd. MMMM yyyy")?.size(withConstrainedWidth: width, font: UIFont(name: "Roboto-Regular", size: 11.0)!, numberOfLines: 1).height ?? 0
        let height = imageHeight + 12.0 + titleHeight + 4.0 + dateHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let index = indexPath.row
        let deal = deals[index]
        if let access = deal.access {
            if access == 0 {
                showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Dieser Deal ist nicht für Ihr Mitgliedschafts-Level freigegeben", cancelBtn: false, okBtnCompletion: nil)
            } else {
                performSegue(withIdentifier: "showWKWebViewVC", sender: deal)
            }
        }
    }
}
