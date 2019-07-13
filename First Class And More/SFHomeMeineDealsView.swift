//
//  SFMeineDealsView.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/22/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

private enum Constants {
	static let dealsCount = 8
	static let columns = 3
	static let rows = 3
}

protocol SFHomeMeineDealsViewDelegate: class
{
    func meineDealItemTapped(with type: DealType)
}

class SFHomeMeineDealsView: UIView
{
    var delegate: SFHomeMeineDealsViewDelegate?
	
	private var dealsCollectionView: UICollectionView?
	private var dealState: DealState = .blue
	
	let sampleButtonImage = UIImage(named: "Deals0")
	var sampleButtonSize: CGSize {
		return CGSize(width: 70, height: 95)
	}
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
    
    public func setUpButtons()
    {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		
		let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(UINib(nibName: "SFHomeMeineDealsItemCell", bundle: nil), forCellWithReuseIdentifier: "SFHomeMeineDealsItemCell")
		
		addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
			])
		
		dealsCollectionView = collectionView
    }
    
    public func updateButtons(with color: DealState) {
		dealState = color
		dealsCollectionView?.reloadData()
    }
}

// MARK: - CollectionView

extension SFHomeMeineDealsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if UserModel.sharedInstance.logined {
            return Constants.dealsCount + 1
        }
        
        return Constants.dealsCount
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SFHomeMeineDealsItemCell", for: indexPath) as! SFHomeMeineDealsItemCell
        
        var offset = 0
        
        var dealType = DealType(rawValue: indexPath.row) ?? .Alle
        
        if(indexPath.row != 0 && !UserModel.sharedInstance.logined && indexPath.row < Constants.dealsCount) {
            dealType = DealType(rawValue: indexPath.row + 1) ?? .Alle
            offset += 1
        }
		
		var image: UIImage?
		switch dealState {
		case .blue:
			image = UIImage(named: "Deals\(indexPath.row + offset)")
		case .gold:
			image = UIImage(named: "Deals\(indexPath.row + offset)-gold")
		}
		
		
		cell.dealTitleLabel.text = DealType.printEnumValue(oFDealType: dealType).uppercased()
		cell.dealImageView.image = image
		cell.dealType = dealType
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var offset = 0
        
        if(indexPath.row != 0 && !UserModel.sharedInstance.logined && indexPath.row < Constants.dealsCount) {
            offset += 1
        }
        
		guard let type = DealType(rawValue: indexPath.row + offset) else { return }
		delegate?.meineDealItemTapped(with: type)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return sampleButtonSize
	}
	
	var marginX: CGFloat {
		return (frame.size.width - sampleButtonSize.width * CGFloat(Constants.columns)) / CGFloat(Constants.columns + 1)
	}
	
	var marginY: CGFloat {
		return (frame.size.height - sampleButtonSize.height * CGFloat(Constants.rows)) / CGFloat(Constants.rows + 1)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: marginY, left: marginX, bottom: marginY, right: marginX)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return marginY
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return marginX
	}
    
    func reloadOptions() {
        
        dealsCollectionView?.reloadData()
        
    }
}
