//
//  SFHomeCarouselView.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/22/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import AlamofireImage
import DZNEmptyDataSet

protocol CarouselDelegate {
    func slideSelected(slide: SlideModel) -> Void
    func showPopup() -> Void
}

class SFHomeCarouselView: UIView, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var featuredCarousel: UICollectionView!
	var infiniteScrollingBehaviour: InfiniteScrollingBehaviour!
    var delegate: CarouselDelegate?
    
    var slides: [SlideModel] = []
    
    public func configureCarousel()
    {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset            = .zero
        layout.itemSize                = bounds.size
        layout.minimumLineSpacing      = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection         = .horizontal
        featuredCarousel = UICollectionView(frame: bounds, collectionViewLayout: layout)
		featuredCarousel.translatesAutoresizingMaskIntoConstraints = false
        featuredCarousel.register(UINib(nibName: "SliderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SliderCollectionViewCell")
        featuredCarousel.backgroundColor                = .white
//        featuredCarousel.delegate                       = self
//        featuredCarousel.dataSource                     = self
        featuredCarousel.emptyDataSetSource             = self
        featuredCarousel.emptyDataSetDelegate           = self
        featuredCarousel.isPagingEnabled                = true
        featuredCarousel.alwaysBounceHorizontal         = true
        featuredCarousel.showsVerticalScrollIndicator   = false
        featuredCarousel.showsHorizontalScrollIndicator = false
        addSubview(featuredCarousel)
		
		NSLayoutConstraint.activate([
			featuredCarousel.topAnchor.constraint(equalTo: topAnchor),
			featuredCarousel.bottomAnchor.constraint(equalTo: bottomAnchor),
			featuredCarousel.leadingAnchor.constraint(equalTo: leadingAnchor),
			featuredCarousel.trailingAnchor.constraint(equalTo: trailingAnchor)
			])
    }
	
	func setupInfiniteScrollBehaviour() {
		let config = CollectionViewConfiguration(layoutType: .numberOfCellOnScreen(1),
												 scrollingDirection: .horizontal,
												 carouselMode: true)
		infiniteScrollingBehaviour = InfiniteScrollingBehaviour(withCollectionView: featuredCarousel, andData: slides, delegate: self, configuration: config)
	}
    
    func updateCarousel(slides: [SlideModel]) {
        self.slides = slides
		if slides.count == 0 {
			featuredCarousel.reloadData()
		}
		else {
			setupInfiniteScrollBehaviour()
		}
    }
    
    // MARK: Empty dataset
    
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return #imageLiteral(resourceName: "empty")
//    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "Keine Folien"
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 24.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
//    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let title = "Some very long test description about empty dataset"
//        let attributes = [
//            NSFontAttributeName: UIFont(name: "RobotoCondensed-Regular", size: 17.0)!,
//            NSForegroundColorAttributeName: UIColor.darkGray
//        ]
//        return NSAttributedString(string: title, attributes: attributes)
//    }
}

// MARK: - InfiniteScrollingBehaviourDelegate

extension SFHomeCarouselView: InfiniteScrollingBehaviourDelegate {
	
	func configuredCell(forItemAtIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, forInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell {
		let cell = featuredCarousel.dequeueReusableCell(withReuseIdentifier: "SliderCollectionViewCell", for: indexPath)
		
		if let sliderCell = cell as? SliderCollectionViewCell, let slide = data as? SlideModel {
			sliderCell.slideTitleLabel.text = slide.title
			sliderCell.slideShortTitleLabel.text = slide.shortTitle?.uppercased()
			sliderCell.slideImageView.image = nil
            if let urlString = slide.imageUrl, let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!) {
				sliderCell.activityIndicator.startAnimating()
				sliderCell.titleView.isHidden = true
				sliderCell.slideImageView.af_setImage(
					withURL: url,
					progressQueue: DispatchQueue.main,
					imageTransition: .crossDissolve(0.2),
					runImageTransitionIfCached: false,
					completion: { image in
						sliderCell.activityIndicator.stopAnimating()
						sliderCell.titleView.isHidden = false
				})
			}
		}
		
		return cell
	}
	
	func didSelectItem(atIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> Void {
		guard let slide = data as? SlideModel else { return }
		
		if let access = slide.access, access == 1 {
			delegate?.slideSelected(slide: slide)
		} else {
			delegate?.showPopup()
		}
	}
	
}
