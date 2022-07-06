//
//  CameraViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 21/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import AVFoundation
import DKCamera
import PopupDialog
import SwiftyJSON


class CameraViewController: UIViewController {

    var resultJSON = JSON()
    var isFrontClick = false
    var isBackClick = false
    var isComingFromTestResult = false
    
    /*
    @IBAction func clickPictureBtnPressed(_ sender: Any) {
        let camera = DKCamera()
        
        camera.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        
        camera.didFinishCapturingImage = { (image: UIImage?, metadata: [AnyHashable : Any]?) in
            print("didFinishCapturingImage")
            self.dismiss(animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "camera")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerPrintVC") as! FingerprintViewController
            self.resultJSON["Camera"].int = 1
            vc.resultJSON = self.resultJSON
            self.present(vc, animated: true, completion: nil)
        }
        
        self.present(camera, animated: true, completion: nil)
    }
    */
    
    @IBAction func clickPictureBtnPressed(_ sender: Any) {
        
        let camera = DKCamera()
        
        DispatchQueue.main.async {
            camera.cameraSwitchButton.isUserInteractionEnabled = false
            camera.cameraSwitchButton.isHidden = true
        }
        
        camera.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        
        camera.didFinishCapturingImage = { (image: UIImage?, metadata: [AnyHashable : Any]?) in
            
            let isFront = camera.currentDevice == camera.captureDeviceFront
            if isFront {
                self.isFrontClick = true
            }
            else {
                self.isBackClick = true
                if self.isFrontClick == false {
                    camera.currentDevice = camera.currentDevice == camera.captureDeviceRear ?
                        camera.captureDeviceFront : camera.captureDeviceRear
                    camera.setupCurrentDevice()
                }
            }
            
            if self.isFrontClick == true && self.isBackClick == true {
                
                self.dismiss(animated: true, completion: nil)
                UserDefaults.standard.set(true, forKey: "camera")
                self.resultJSON["Camera"].int = 1
                
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerPrintVC") as! FingerprintViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
        }
        
        self.present(camera, animated: true, completion: nil)
    }
    
    @IBAction func skipPictureBtnPressed(_ sender: Any) {
        // Prepare the popup assets
        let title = "camera_test".localized
        let message = "skip_info".localized
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            DispatchQueue.main.async() {
                UserDefaults.standard.set(false, forKey: "camera")
                self.resultJSON["Camera"].int = 0
                
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerPrintVC") as! FingerprintViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }
                
                
            }
        }
        
        let buttonTwo = DefaultButton(title: "No".localized) {
            //Do Nothing
            popup.dismiss(animated: true, completion: nil)
        }
        
        
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo])
        popup.dismiss(animated: true, completion: nil)
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: GlobalUtility().AppFontMedium, size: 20)!
        pv.messageFont  = UIFont(name: GlobalUtility().AppFontRegular, size: 16)!
        
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: GlobalUtility().AppFontMedium, size: 16)!
        
        
        
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        cb.titleFont      = UIFont(name: GlobalUtility().AppFontMedium, size: 16)!
        
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
