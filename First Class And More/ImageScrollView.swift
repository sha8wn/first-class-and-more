//
//  ImageScrollView.swift
//  First Class And More
//
//  Created by Vadim on 23/01/2019.
//  Copyright © 2019 Shawn Frank. All rights reserved.
//

import UIKit

final class ImageScrollView: UIScrollView {
	
	override var frame: CGRect {
		didSet {
			if frame.size != oldValue.size { setZoomScale() }
		}
	}
	
	private let imageView = UIImageView()
	
	required init(image: UIImage) {
		super.init(frame: .zero)
		setupWithImage(image)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setupWithImage(_ image: UIImage?) {
		guard imageView.image == nil else { return }
		
		imageView.image = image
		imageView.contentMode = .scaleAspectFill
		imageView.frame = frame

		addSubview(imageView)
		contentSize = imageView.bounds.size
		
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
		alwaysBounceHorizontal = true
		alwaysBounceVertical = true
		isScrollEnabled = false
		delegate = self
	}
	
	// MARK: - Helper methods
	
	func setZoomScale() {
		let widthScale = frame.size.width / imageView.bounds.width
		let heightScale = frame.size.height / imageView.bounds.height
		let minScale = min(widthScale, heightScale)
		minimumZoomScale = minScale
		maximumZoomScale = 5
		zoomScale = 1
	}
	
}

// MARK: - UIScrollViewDelegate

extension ImageScrollView: UIScrollViewDelegate {
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let imageViewSize = imageView.frame.size
		let scrollViewSize = scrollView.bounds.size
		let zoomed = imageViewSize.width > scrollViewSize.width || imageViewSize.height > scrollViewSize.height
		isScrollEnabled = zoomed
		let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
		let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
		scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
	}
	
}
