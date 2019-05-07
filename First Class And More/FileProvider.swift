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
	
	func open(_ type: FileType) {
		currentType = type
		let quickLookController = QLPreviewController()
		quickLookController.dataSource = self
		viewController?.present(quickLookController, animated: true, completion: nil)
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
