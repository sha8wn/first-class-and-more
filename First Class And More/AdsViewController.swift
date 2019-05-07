//
//  AdsViewController.swift
//  First Class And More
//

import UIKit

class AdsViewController: UIViewController {

    @IBOutlet weak var scrollView: ImageScrollView!
	
    var imageName: String!
	var image: UIImage? {
		let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let fileURL = documentsURL.appendingPathComponent("ads/\(imageName!)")
		return UIImage(contentsOfFile: fileURL.path)
	}
    var ad: AdvertisementModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
		view.addGestureRecognizer(tapGesture)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		scrollView.setupWithImage(image)
	}
    
    @objc func viewTapped() {
        print(Date())
        if let ad = ad, let _ = URL(string: ad.url), let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            dismiss(animated: true) {
                appDelegate.showWebView(ad.url)
            }
        }
    }
    
    @IBAction func closeBtnPressed() {
        print(Date())
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.timerFrequency = Double(appDelegate.timerSettings.frequency)
            appDelegate.restartTimer()
        }
        dismiss(animated: true, completion: nil)
    }
}
