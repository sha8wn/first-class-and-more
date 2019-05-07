//
//  ProfileAndTestsViewController.swift
//  First Class And More
//

import UIKit

class ProfileAndTestsViewController: SFSidebarViewController {
    
    enum Layout {
        case oneColumn
        case twoColumns
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var introLabel: UITextView!
	@IBOutlet weak var introLabelHeight: NSLayoutConstraint!
    
    var categories: [Int] = []
    var profileAndTest: ProfileAndTest? {
        didSet {
           setupUI()
        }
    }
    var orderBy: RouterDeals.Sorting = .none
    var layout: Layout = .twoColumns
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setupUI()
	}
    
    func setupUI() {
		guard let _ = titleLabel, let _ = introLabel, let profileAndTest = profileAndTest, let html2AttributedString = profileAndTest.introWithLinks?.html2AttributedString else { return }
		
		titleLabel?.text = profileAndTest.title?.html2String
		
		let mutableString = NSMutableAttributedString(attributedString: html2AttributedString)
		
		let font = introLabel.font!
		let textColor = introLabel.textColor!
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		
		mutableString.addAttributes(
			[.font: font,
			 .foregroundColor: textColor,
			 .paragraphStyle: paragraphStyle],
			range: NSRange(location: 0, length: mutableString.length))
		
		introLabel?.attributedText = mutableString
		
		let fixedWidth = introLabel.frame.size.width
		let newSize = introLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
		let adjustedSize = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
		introLabelHeight.constant = adjustedSize.height
    }
    
    @IBAction func continueBtnPressed() {
        performSegue(withIdentifier: "showProfilesAndTestsCategoriesVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showProfilesAndTestsCategoriesVC" {
                let dvc = segue.destination as! ProfileAndTestsCategoriesViewController
                dvc.dealsLoaded = false
                dvc.categories = categories
                dvc.orderBy = orderBy
                dvc.layout = layout
            }
        }
    }
}
