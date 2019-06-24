//
//  SFFlexibleSegment.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/22/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class SFFlexibleSegmentCell: UICollectionViewCell
{
    var segmentLabel: SFFCAMLabel
    
    override init(frame: CGRect)
    {
        // when making it extensible, make it a normal label
        segmentLabel = SFFCAMLabel()
        
        super.init(frame: frame)

        segmentLabel.type = .Body
        segmentLabel.layer.cornerRadius = 5.0
        segmentLabel.clipsToBounds = true
        segmentLabel.numberOfLines = 1
        segmentLabel.textAlignment = .center
        contentView.addSubview(segmentLabel)
        
        segmentLabel.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = segmentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let trailingConstraint = segmentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let topConstraint = segmentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        let bottomConstraint = segmentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        let constraints = [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        segmentLabel.textColor = .white
        segmentLabel.backgroundColor = .white
    }
}

protocol SFFlexibleSegmentDelegate: class
{
    func adjustSegmentSize(view: UIView?, withNewSize newSize: CGSize)
    func displayError(description: String)
    func selectedFilter(at: Int, view: UIView)
    func showUlockFiltersDialog()
}

class SFFlexibleSegment: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var segmentCollectionView: UICollectionView!
    var delegate: SFFlexibleSegmentDelegate?
    var highlightedBgColor: UIColor!
    var highlightedTextColor: UIColor!
    var normalBgColor: UIColor!
    var normalTextColor: UIColor!
    var disabledTextColor: UIColor!
    var segmentFont: UIFont?
    var currentlySelected = 0
    private var isCollectionViewHeightSet = false
    
    var datasource: [String]!
    {
        didSet(newValue)
        {
            if(datasource.count > 0)
            {
                segmentCollectionView.reloadData()
            }
            
        }
    }
    
    var segmentColor: UIColor
    {
        didSet(newValue)
        {
            segmentCollectionView.backgroundColor = newValue
        }
    }

    override init(frame: CGRect)
    {
        highlightedBgColor = fcamBlue
        highlightedTextColor = .white
        normalBgColor = .white
        normalTextColor = fcamDarkGrey
        disabledTextColor = UIColor(red: 200.0/255.0, green: 201.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        segmentColor = .white
        segmentFont = UIFont.systemFont(ofSize: 10.0)
        
        super.init(frame: frame)
        
        setUpCollectionView(inFrame: frame)
    }
    
    private func setUpCollectionView(inFrame frame: CGRect)
    {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        
        var frame = frame
        frame.origin.y = 0
        segmentCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        segmentCollectionView.backgroundColor = .white
        segmentCollectionView.dataSource = self
        segmentCollectionView.delegate = self
        segmentCollectionView.alwaysBounceHorizontal = false
        segmentCollectionView.showsVerticalScrollIndicator = false
        segmentCollectionView.register(SFFlexibleSegmentCell.self, forCellWithReuseIdentifier: "Cell")
        addSubview(segmentCollectionView)
    }
    
    func updateFilters() {
        segmentCollectionView.reloadData()
    }
    
    // MARK: - CollectionView DataSource & Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:SFFlexibleSegmentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SFFlexibleSegmentCell
        
        cell.segmentLabel.font = segmentFont
        cell.segmentLabel.text = datasource[indexPath.item]
        
        if currentlySelected == indexPath.item
        {
            cell.segmentLabel.textColor = highlightedTextColor
            cell.segmentLabel.backgroundColor = highlightedBgColor
        }
        else
        {
//            let user = UserModel.sharedInstance
//            let condition = (user.logined && user.isPremiuim) || user.unlockedFilters || user.isSubscribed
			cell.segmentLabel.textColor = normalTextColor // condition ? normalTextColor : disabledTextColor
            cell.segmentLabel.backgroundColor = normalBgColor
        }
        
        if indexPath.item == 0
        {
            self.setCollectionViewHeight()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
//        let user = UserModel.sharedInstance
//        if (user.logined && user.isPremiuim) || user.unlockedFilters || user.isSubscribed {
            if currentlySelected != indexPath.item {
                currentlySelected = indexPath.item
                delegate?.selectedFilter(at: indexPath.item, view: self)
                collectionView.reloadData()
            }
//        } else {
//            delegate?.showUlockFiltersDialog()
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return getSizeForText(text: datasource[indexPath.item])
    }
    
    func getSizeForText(text: String) -> CGSize
    {
        let size: CGSize = text.size(withAttributes: [NSAttributedString.Key.font: segmentFont!])
        return CGSize(width: size.width + 20, height: 40)
    }
    
    func setCollectionViewHeight()
    {
        if !isCollectionViewHeightSet
        {
            segmentCollectionView.frame.size = segmentCollectionView.contentSize
            isCollectionViewHeightSet = true
            self.delegate?.adjustSegmentSize(view: self, withNewSize: segmentCollectionView.contentSize)
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
