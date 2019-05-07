//
//  TutorialViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 12/27/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import SwiftyGif

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var pauseView: UIView!

    var currentStep: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImageView.delegate = self
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentStep = 0
        gifImageView.clear()
        gifImageView.isHidden = true
        loadNextGif()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    fileprivate func loadNextGif() {
        currentStep += 1
        showTextGif()
    }
    
    private func showTextGif() {
        let textImage = UIImage(named: "step-\(currentStep)-text.png", in: Bundle.main, compatibleWith: nil)
        imageView.image = textImage
        showContinueWithAnimatedGIFButton()
    }
    
    private func showAnimatedGIF() {
        gifImageView.isHidden = false
        let gif = UIImage(gifName: "step-\(currentStep)")
        gifImageView.setGifImage(gif, loopCount: 1)
    }
    
    fileprivate func showContinueWithAnimatedGIFButton() {
        continueButton.setTitle(currentStep == 10 ? "SCHLIESSEN" : "WEITER", for: .normal)
        continueButton.isHidden = false
    }
    
    fileprivate func hideContinueWithAnimatedGIFButton() {
        continueButton.isHidden = true
    }
    
    @IBAction func continueBtnPressed() {
        hideContinueWithAnimatedGIFButton()
        if currentStep == 10 {
            closeBtnPressed()
        } else {
            showAnimatedGIF()
        }
    }
    
    fileprivate func hideControls() {
        gifImageView.isHidden = true
        pauseView.isHidden = true
    }
    
    fileprivate func showControls() {
        pauseView.isHidden = false
    }
    
    @IBAction func previousBtnPressed() {
        hideControls()
        currentStep = currentStep - 1 >= 1 ? currentStep - 1 : 9
        showTextGif()
    }
    
    @IBAction func repeatBtnPressed() {
        hideControls()
        showAnimatedGIF()
    }
    
    @IBAction func nextBtnPressed() {
        hideControls()
        currentStep = currentStep + 1 <= 10 ? currentStep + 1 : 1
        showTextGif()
    }
    
    @IBAction func closeBtnPressed() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restartTimer()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension TutorialViewController: SwiftyGifDelegate {
    func gifDidLoop(sender: UIImageView) {
        showControls()
    }
}

