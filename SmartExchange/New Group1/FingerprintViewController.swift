//
//  FingerprintViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 03/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import PopupDialog
import BiometricAuthentication
import SwiftyJSON
import Luminous

class FingerprintViewController: UIViewController {
    
    var biometricRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var biometricTestDiagnosis: ((_ testJSON: JSON) -> Void)?

    @IBOutlet weak var biometricImage: UIImageView!
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTitleMessage: UILabel!
    
    var isComingFromTestResult = false
    
    var resultJSON = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
                
        if BioMetricAuthenticator.canAuthenticate() {
            
            if BioMetricAuthenticator.shared.faceIDAvailable() {
                
                print("hello faceid available")
                // device supports face id recognition.
                let yourImage: UIImage = UIImage(named: "face-id")!
                self.biometricImage.image = yourImage
                
                self.lblTestTitle.text = "Testing Face ID"
                self.lblTitleMessage.text = "First, enable the face-Id function on your phone." +
                "During the test place your face on the scanner as you normally would to unlock your phone."
                
            }else {
                self.biometricImage.image = UIImage(named: "fingerprint")!
                
                self.lblTestTitle.text = "Testing fingerprint"
                self.lblTitleMessage.text = "First, please enable fingerprint function." +
                "Then you will place your finger on the fingerprint scanner like you normally would during unlock."
            }
            
        }else {
            
            DispatchQueue.main.async {
                
                let alertController = UIAlertController (title:  "Enable Biometric".localized , message: "Go to Settings -> Touch ID & Passcode".localized, preferredStyle: .alert)
                
                let settingsAction = UIAlertAction(title: "Settings".localized, style: .default) { (_) -> Void in
                    
                    guard let settingsUrl = URL(string: "App-Prefs:root") else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            
                            UIApplication.shared.open(settingsUrl, options: [:]) { (success) in
                                
                            }
                            
                        } else {
                            // Fallback on earlier versions
                            
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    }
                }
                
                alertController.addAction(settingsAction)
                
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: .default) { (_) -> Void in
                    
                    UserDefaults.standard.set(false, forKey: "fingerprint")
                    self.resultJSON["Fingerprint Scanner"].int = 0
                    
                    /*
                    if self.isComingFromTestResult {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }*/
                    
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.biometricRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.biometricTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                    
                }
                
                alertController.addAction(cancelAction)
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.bounds
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            //*
            switch UIDevice.current.moName {
            case "iPhone X","iPhone XR","iPhone XS","iPhone XS Max","iPhone 11","iPhone 11 Pro","iPhone 11 Pro Max","iPhone 12 mini","iPhone 12","iPhone 12 Pro","iPhone 12 Pro Max", "iPhone 13 Mini", "iPhone 13", "iPhone 13 Pro", "iPhone 13 Pro Max", "iPad Pro (11-inch) (1st generation)", "iPad Pro (11-inch) (2nd generation)", "iPad Pro (12.9-inch) (3rd generation)", "iPad Pro (12.9-inch) (4th generation)" :
                
                print("hello faceid available")
                // device supports face id recognition.
                
                let yourImage: UIImage = UIImage(named: "face-id")!
                self.biometricImage.image = yourImage
                
                self.lblTestTitle.text = "Testing Face ID"
                self.lblTitleMessage.text = "First, enable the face-Id function on your phone." +
                "During the test place your face on the scanner as you normally would to unlock your phone."
                              
                break
            default:
                
                break
            }
            //*/
            
        }
        
    }
    
    //MARK: IBActions
    @IBAction func scanFingerprintBtnPressed(_ sender: UIButton) {
        
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", success: {
            
            UserDefaults.standard.set(true, forKey: "fingerprint")
            self.resultJSON["Fingerprint Scanner"].int = 1
            
            /*
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                //let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }*/
            
            DispatchQueue.main.async {
                self.view.makeToast("Test Passed!", duration: 2.0, position: .bottom)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.biometricRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.biometricTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            // authentication successful
            
        }, failure: { [weak self] (error) in
            
            // do nothing on canceled
            if error == .canceledByUser || error == .canceledBySystem {
                return
            }
                
                // device does not support biometric (face id or touch id) authentication
            else if error == .biometryNotAvailable {
                print(error.message())
                
                DispatchQueue.main.async {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // show alternatives on fallback button clicked
            else if error == .fallback {
                
                // here we're entering username and password
                DispatchQueue.main.async {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // No biometry enrolled in this device, ask user to register fingerprint or face
            else if error == .biometryNotEnrolled {
                DispatchQueue.main.async {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
            else if error == .biometryLockedout {
                // show passcode authentication
                DispatchQueue.main.async {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // show error on authentication failed
            else {
                UserDefaults.standard.set(false, forKey: "fingerprint")
                self?.resultJSON["Fingerprint Scanner"].int = 0
                
                DispatchQueue.main.async() {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    
                    /*
                    if self?.isComingFromTestResult ?? false {
                        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                        vc.resultJSON = self?.resultJSON ?? JSON()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true, completion: nil)
                    }else {
                        //let vc = self?.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
                        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                        vc.resultJSON = (self?.resultJSON)!
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true, completion: nil)
                    }*/
                    
                    if ((self?.isComingFromTestResult) != nil) {
                        
                        guard let didFinishRetryDiagnosis = self?.biometricRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self?.resultJSON ?? JSON())
                        self?.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self?.biometricTestDiagnosis else { return }
                        didFinishTestDiagnosis(self?.resultJSON ?? JSON())
                        self?.dismiss(animated: false, completion: nil)
                        
                    }
                    
                    
                }
            }
        })
        
    }
    
    @IBAction func fingerprintSkipBtnPressed(_ sender: Any) {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        let title = "fingerprint_test".localized
        let message = "skip_info".localized
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            UserDefaults.standard.set(false, forKey: "fingerprint")
            self.resultJSON["Fingerprint Scanner"].int = 0
            
            /*
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                //let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }*/
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.biometricRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.biometricTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
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
                
                print("Fingerprint Scanner Skipped!")
                
                UserDefaults.standard.set(false, forKey: "fingerprint")
                self.resultJSON["Fingerprint Scanner"].int = -1
             
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.biometricRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.biometricTestDiagnosis else { return }
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
        
    override func viewDidAppear(_ animated: Bool) {
        
        /*
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", success: {
            UserDefaults.standard.set(true, forKey: "fingerprint")
            self.resultJSON["Fingerprint Scanner"].int = 1
            
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                //let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
            // authentication successful
            
        }, failure: { [weak self] (error) in
            
            // do nothing on canceled
            if error == .canceledByUser || error == .canceledBySystem {
                return
            }
                
                // device does not support biometric (face id or touch id) authentication
            else if error == .biometryNotAvailable {
                print(error.message())
                DispatchQueue.main.async {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // show alternatives on fallback button clicked
            else if error == .fallback {
                
                // here we're entering username and password
                DispatchQueue.main.async {
                self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // No biometry enrolled in this device, ask user to register fingerprint or face
            else if error == .biometryNotEnrolled {
                DispatchQueue.main.async {
                self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
            else if error == .biometryLockedout {
                // show passcode authentication
                DispatchQueue.main.async {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
            }
                
                // show error on authentication failed
            else {
                UserDefaults.standard.set(false, forKey: "fingerprint")
                self?.resultJSON["Fingerprint Scanner"].int = 0
                DispatchQueue.main.async {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
                
                if self?.isComingFromTestResult ?? false {
                    let vc = self?.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self?.resultJSON ?? JSON()
                    self?.present(vc, animated: true, completion: nil)
                }else {
                    //let vc = self?.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
                    let vc = self?.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                    vc.resultJSON = (self?.resultJSON)!
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true, completion: nil)
                }
                
            }
        })
        */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}