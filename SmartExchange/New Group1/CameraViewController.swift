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
    
    var cameraRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var cameraTestDiagnosis: ((_ testJSON: JSON) -> Void)?

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
    
    @IBAction func clickPictureBtnPressed(_ sender: UIButton) {
        
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
                
                //self.dismiss(animated: true, completion: nil)
                
                UserDefaults.standard.set(true, forKey: "camera")
                self.resultJSON["Camera"].int = 1
                
                
                if self.isComingFromTestResult {
                    
                    camera.dismiss(animated: false) {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
                            didFinishRetryDiagnosis(self.resultJSON)
                            self.dismiss(animated: false, completion: nil)
                        }
                        
                    }
                    
                }
                else{
                    
                    camera.dismiss(animated: false) {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            guard let didFinishTestDiagnosis = self.cameraTestDiagnosis else { return }
                            didFinishTestDiagnosis(self.resultJSON)
                            self.dismiss(animated: false, completion: nil)
                        }
                        
                    }
                    
                }
                
                
                /*
                 if self.isComingFromTestResult {
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                 vc.resultJSON = self.resultJSON
                 self.present(vc, animated: true, completion: nil)
                 }else {
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerPrintVC") as! FingerprintViewController
                 vc.resultJSON = self.resultJSON
                 self.present(vc, animated: true, completion: nil)
                 }*/
                
            }
        }
        
        self.present(camera, animated: true, completion: nil)
    }
    
    @IBAction func skipPictureBtnPressed(_ sender: Any) {
        
        self.ShowGlobalPopUp()
        
        /*
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
                
                /*
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerPrintVC") as! FingerprintViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }*/
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.cameraTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
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
        pcv.cornerRadius    = 10
        //pcv.cornerRadius    = 2
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
        */
        
    }

    func ShowGlobalPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Are you sure?"
        popUpVC.strMessage = "If you skip this test there would be a substantial decline in the price offered."
        popUpVC.strBtnYesTitle = "Skip Test"
        popUpVC.strBtnNoTitle = "Don't Skip"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("Camera Skipped!")
                
                UserDefaults.standard.set(false, forKey: "camera")
                self.resultJSON["Camera"].int = -1
              
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.cameraTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            case 2:
                
                break
                
            default:
                                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
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
