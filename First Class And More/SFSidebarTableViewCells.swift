//
//  SFSidebarTableViewCells.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/24/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//
// Manages the cells of the sidebar view class

import UIKit

class SFMenuSectionTableViewCell: UITableViewCell
{
    var headerView: UIView!
    var chevronImage: UIImageView!
    var sectionLabel: SFFCAMLabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        selectionStyle = .none
    }
    
    func configureCell()
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: 30))
        headerView.backgroundColor = fcamBlue
        
//        let chevronImage = UIImage(named: "DownArrow")
//        let chevronImageView = UIImageView(frame: CGRect(x: headerView.frame.size.width - (chevronImage?.size.width)! - 10,
//                                                         y: (headerView.frame.size.height - (chevronImage?.size.height)!) / 2,
//                                                         width: (chevronImage?.size.width)!,
//                                                         height: (chevronImage?.size.height)!))
//        chevronImageView.image = chevronImage
        
        sectionLabel = SFFCAMLabel(frame: CGRect(x: 16, y: (headerView.frame.size.height - 15) / 2, width: headerView.frame.size.width - 30, height: 15))
        sectionLabel.type = .Body
        sectionLabel.textColor = .white
        
//        headerView.addSubview(chevronImageView)
        headerView.addSubview(sectionLabel)
        contentView.addSubview(headerView)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

class SFMenuTableViewCell: UITableViewCell
{
    var optionImage: UIImageView!
    var optionName: UILabel!
    var optionId: String!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        optionImage = UIImageView()
        contentView.addSubview(optionImage)
        optionImage.contentMode = .scaleAspectFit

        optionName = UILabel()
        contentView.addSubview(optionName)
        optionName.textColor = #colorLiteral(red: 0.4941176471, green: 0.4980392157, blue: 0.5058823529, alpha: 1)
        optionName.font = UIFont(name: "RobotoCondensed-Regular", size: 16.0)!
        clipsToBounds = true
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func configureCell()
    {
        optionImage.frame = CGRect(x: 20, y: 10, width: 20, height: 20)
        optionName.frame = CGRect(x: 55, y: 0, width: 200, height: 40)
    }
}
