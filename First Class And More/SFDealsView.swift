//
//  SFDealsView.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/22/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class SFDealsCell: UITableViewCell {
    enum DealTiers {
        case non, gold, platinum, diamond
    }
    
    @IBOutlet var dealsImage: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var dealsCategory: SFFCAMLabel!
    @IBOutlet weak var dealsDate: SFFCAMLabel!
    @IBOutlet weak var dealsExpireDate: SFFCAMLabel!
    @IBOutlet var dealsTitle: SFFCAMLabel!
    @IBOutlet var dealsDescription: SFFCAMLabel!
    @IBOutlet var dealsTierRibbon: UIImageView!
    @IBOutlet weak var dealExpiredImageView: UIImageView!
    @IBOutlet var favoriteButtonOutlet: UIButton!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var favoriteBtnAction: ((UITableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dealsDate.type = .Subtitle
        dealsCategory.type = .Subtitle
        dealsExpireDate.type = .Subtitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        clipsToBounds = true
        selectionStyle = .none
    }
    
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
        favoriteBtnAction?(self)
    }
}

protocol SFDealsSearchBarDelegate {
    func filterBarButtonTapped()
    func displayError(description: String)
}

protocol SFFiltersDelegate {
    func filterSelected(at: Int, row: RowNumber)
    func showUnlockFiltersDialog()
}

internal enum RowNumber {
    case first, second
}

class SFDealsView: UIView, SFFlexibleSegmentDelegate
{
    var flexibleSegment: SFFlexibleSegment?
    var extraFlexibleSegment: SFFlexibleSegment?
    var searchViewContainer: UIView!
    var filterSearchBarOutlet: UIButton!
    var searchTextBgView: UIView!
    var searchTextField: UITextField!
    var dealsTableView: SFTableView!
    var tableViewFooterActivityIndicator: UIActivityIndicatorView?
    var isFiltersEnabled = true
    var hasSearchBar = false
    
    var source: [DealModel] = []
	
    var dealsDelegate: UIViewController!
    {
        willSet(newValue)
        {
            dealsTableView.dataSource = newValue as? UITableViewDataSource
            dealsTableView.delegate = newValue as? UITableViewDelegate
            dealsTableView.emptyDataSetSource = newValue as? DZNEmptyDataSetSource
            dealsTableView.emptyDataSetDelegate = newValue as? DZNEmptyDataSetDelegate
        }
    }
    
    var filtersDelegate: SFFiltersDelegate?
    var searchBarDelegate: SFDealsSearchBarDelegate?
    
    var secondaryFilters: [String]?
    var extraSecondaryFilters: [String]?
    
    public func configureDealsView()
    {
        var y = CGFloat(0)
        
        if isFiltersEnabled
        {
            generateSecondaryFilters()
            y = (flexibleSegment?.frame.origin.y)! + (flexibleSegment?.frame.size.height)!
            if let _ = extraSecondaryFilters {
                generateExtraSecondaryFilters()
                y = (extraFlexibleSegment?.frame.origin.y)! + (extraFlexibleSegment?.frame.size.height)!
            }
        }
        
        if hasSearchBar
        {
            generateSearchBar(atCurrentY: y)
        }
        
        var topInset = CGFloat(0)

        let height = frame.height - y
        
        dealsTableView = SFTableView(frame: CGRect(x: 0, y: y, width: frame.size.width, height: height))
        dealsTableView.register(UINib(nibName: "SFDealsCell", bundle: nil), forCellReuseIdentifier: "SFDealsCell")
        dealsTableView.alwaysBounceVertical = true
        dealsTableView.configure()
        dealsTableView.estimatedRowHeight = 315
        dealsTableView.rowHeight = UITableView.automaticDimension
        dealsTableView.tableFooterView = {
            let footerView = UIView(frame:
                CGRect(
                    x: 0,
                    y: 0,
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.width * 0.138889 + 32.0
                )
            )
            tableViewFooterActivityIndicator = {
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.hidesWhenStopped = true
                activityIndicator.style = .white
                activityIndicator.color = fcamBlue
                return activityIndicator
            }()
            tableViewFooterActivityIndicator!.frame = CGRect(
                x: UIScreen.main.bounds.width / 2 - 20.0 / 2,
                y: (footerView.frame.size.height - 20.0) / 2,
                width: 20.0,
                height: 20.0
            )
            footerView.addSubview(tableViewFooterActivityIndicator!)
            return footerView
        }()
        addSubview(dealsTableView)
        
        if searchViewContainer != nil
        {
            bringSubviewToFront(searchViewContainer)
            topInset = 50
        }
        
        dealsTableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 10, right: 0)
        sourceChanged()
    }
	
	public func updateSource(with deals: [DealModel], scrollToTop: Bool = false) {
		self.source = deals
		if scrollToTop {
			dealsTableView.setContentOffset(.zero, animated: false)
		}
		dealsTableView?.reloadData()
		tableViewFooterActivityIndicator?.stopAnimating()
		sourceChanged()
	}
	
    private func adjustDealsView()
    {
        var y = CGFloat(0)
        if isFiltersEnabled, let flexibleSegment = flexibleSegment
        {
            y = flexibleSegment.frame.origin.y + flexibleSegment.frame.size.height
        }
        if isFiltersEnabled, let extraFlexibleSegment = extraFlexibleSegment {
            y = extraFlexibleSegment.frame.origin.y + extraFlexibleSegment.frame.size.height
        }
        if hasSearchBar, !source.isEmpty
        {
            searchViewContainer?.frame = CGRect(x: 0, y: y, width: frame.size.width, height: 45)
        }
        let height = frame.height - y
        dealsTableView?.frame = CGRect(x: 0, y: y, width: frame.size.width, height: height)
    }
    
    private func generateSecondaryFilters()
    {
        if flexibleSegment == nil
        {
            flexibleSegment = SFFlexibleSegment(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 40))
            flexibleSegment?.segmentFont = UIFont(name: "RobotoCondensed-Regular", size: 10)
            addSubview(flexibleSegment!)
            flexibleSegment?.datasource = secondaryFilters
            flexibleSegment?.delegate = self
        }
    }
    
    private func generateExtraSecondaryFilters() {
        if extraFlexibleSegment == nil
        {
            let y = (flexibleSegment?.frame.origin.y)! + (flexibleSegment?.frame.size.height)!
            extraFlexibleSegment = SFFlexibleSegment(frame: CGRect(x: 0, y: y, width: frame.size.width, height: 40))
            extraFlexibleSegment?.segmentFont = UIFont(name: "RobotoCondensed-Regular", size: 10)
            addSubview(extraFlexibleSegment!)
            extraFlexibleSegment?.datasource = extraSecondaryFilters
            extraFlexibleSegment?.delegate = self
        }
    }
    
    func sourceChanged() {
        searchViewContainer?.isHidden = source.isEmpty
        dealsTableView?.backgroundColor = source.isEmpty ? .white : fcamLightGrey
        let dealsHeight: CGFloat = flexibleSegment?.segmentCollectionView.contentSize.height ?? 0
        flexibleSegment?.frame.size = CGSize(width: frame.size.width, height: dealsHeight)
        let extraDealsHeight: CGFloat = extraFlexibleSegment?.segmentCollectionView.contentSize.height ?? 0
        extraFlexibleSegment?.frame.size = CGSize(width: frame.size.width, height: extraDealsHeight)
        adjustDealsView()
    }
    
    func adjustSegmentSize(view: UIView?, withNewSize newSize: CGSize)
    {
        if view == flexibleSegment {
            flexibleSegment?.frame.size = newSize
        }
        if view == extraFlexibleSegment {
            extraFlexibleSegment?.frame.size = newSize
        }
        adjustDealsView()
    }
    
    func displayError(description: String) {
        searchBarDelegate?.displayError(description: description)
    }
    
    func showUlockFiltersDialog() {
        filtersDelegate?.showUnlockFiltersDialog()
    }
    
    func updateFilters() {
        flexibleSegment?.updateFilters()
        extraFlexibleSegment?.updateFilters()
    }
    
    func selectedFilter(at: Int, view: UIView) {
        if view == flexibleSegment {
            filtersDelegate?.filterSelected(at: at, row: .first)
        } else {
            filtersDelegate?.filterSelected(at: at, row: .second)
        }
    }
    
    private func generateSearchBar(atCurrentY y: CGFloat)
    {
        searchViewContainer = UIView(frame: CGRect(x: 0, y: y, width: frame.size.width, height: 45))
        searchViewContainer.backgroundColor = fcamLightGrey
        addSubview(searchViewContainer)
        
        filterSearchBarOutlet = UIButton(type: .custom)
        filterSearchBarOutlet.frame = CGRect(x: frame.size.width - 40, y: 2.5, width: 40, height: 40)
        filterSearchBarOutlet.setImage(UIImage(named: "SearchFilterButton"), for: .normal)
        filterSearchBarOutlet.addTarget(self, action: #selector(filterSearchBarButtonTapped), for: .touchUpInside)
        
        let x: CGFloat = 10.0
        let width = filterSearchBarOutlet.frame.origin.x - 5.0 - x
        searchTextBgView = UIView(frame: CGRect(x: x, y: 7.5, width: width, height: 30))
        searchTextBgView.clipsToBounds = true
        searchTextBgView.backgroundColor = .white
        searchTextBgView.layer.borderWidth = 1.0
        searchTextBgView.layer.borderColor = fcamBlue.cgColor
        searchTextBgView.layer.cornerRadius = 15
        
        let placeholderLabel = SFFCAMLabel()
        placeholderLabel.type = .Subtitle
        placeholderLabel.text = "Suche"
        placeholderLabel.textColor = fcamLightGrey
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 10, y: (searchTextBgView.frame.size.height - placeholderLabel.frame.size.height) / 2)
        
        searchViewContainer.addSubview(filterSearchBarOutlet)
        searchViewContainer.addSubview(searchTextBgView)
        searchTextBgView.addSubview(placeholderLabel)
    }
    
    @objc private func filterSearchBarButtonTapped()
    {
        searchBarDelegate?.filterBarButtonTapped()
    }

}
