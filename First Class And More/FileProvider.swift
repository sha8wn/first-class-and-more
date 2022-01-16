//
//  FileProvider.swift
//  First Class And More
//
//  Created by Vadim on 29/01/2019.
//  Copyright © 2019 Shawn Frank. All rights reserved.
//

import UIKit
import QuickLook

enum FileType: Int {
	case agb
	case datenschutz
	
	var fileName: String {
		switch self {
		case .agb:
			return "agb.docx"
		case .datenschutz:
			return "datenschutz.docx"
		}
	}
	
	static let all: [FileType] = [.agb, .datenschutz]
}

final class FileProvider {
	private var viewController: UIViewController?
	private lazy var fileURLs: [URL] = self.prepareFileURLs()
	private var currentType: FileType?
	
	init(viewController: UIViewController) {
		self.viewController = viewController
	}
    
    func get(_ type: FileType) -> UIViewController {
        currentType = type
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        quickLookController.navigationItem.leftBarButtonItems = nil
        
        // Setting Up the Logo
        let logo = UIImage(named: "NavLogo")
        let imageView = UIImageView(image: logo)
        quickLookController.navigationItem.titleView = imageView
        
        let homeBtn = UIButton(type: .custom)
        homeBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        homeBtn.setImage(#imageLiteral(resourceName: "MenuButtonTapped"), for: .normal)
        homeBtn.addTarget(self, action: #selector(sidebarButtonTapped), for: .touchUpInside)
        let homeBarBtn = UIBarButtonItem(customView: homeBtn)
        quickLookController.navigationItem.setLeftBarButtonItems([homeBarBtn], animated: false)
        
        quickLookController.navigationItem.setRightBarButtonItems(nil, animated: false)
        
        return quickLookController
    }
	
	func open(_ type: FileType) {
        let controller = self.get(type)
        self.viewController?.present(controller, animated: true, completion: nil)
	}
    
    @objc private func sidebarButtonTapped() {
        guard let navBar = self.viewController as? SFSidebarNavigationController else {
            return
        }
        navBar.toggleMenu(toDestination: nil)
    }
	
	private func prepareFileURLs() -> [URL] {
		var urls: [URL] = []
		for type in FileType.all {
			let fileParts = type.fileName.components(separatedBy: ".")
			if let fileUrl = Bundle.main.url(forResource: fileParts[0], withExtension: fileParts[1]) {
				if FileManager.default.fileExists(atPath: fileUrl.path)  {
					urls.append(fileUrl)
				}
			}
		}
		return urls
	}
}

extension FileProvider: QLPreviewControllerDataSource {
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return 1
	}
	
	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
		let itemIndex = currentType?.rawValue ?? index
		return fileURLs[itemIndex] as QLPreviewItem
	}
}
