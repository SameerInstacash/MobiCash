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

    @IBOutlet weak var biometricImage: UIImageView!
    @IBOutlet weak var lblTitleMessage: UILabel!
    var isComingFromTestResult = false
    
    var resultJSON = JSON()
    @IBAction func fingerprintSkipBtnPressed(_ sender: Any) {
        // Prepare the popup assets
        let title = "fingerprint_test".localized
        let message = "skip_info".localized
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            UserDefaults.standard.set(false, forKey: "fingerprint")
            self.resultJSON["Fingerprint Scanner"].int = 0
            
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
    
    
    @IBAction func scanFingerprintBtnPressed(_ sender: Any) {
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
                
                DispatchQueue.main.async() {
                    self?.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                }
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
                    }
                }
            }
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        if BioMetricAuthenticator.canAuthenticate() {
            if BioMetricAuthenticator.shared.faceIDAvailable() {
                
                print("hello faceid available")
                // device supports face id recognition.
                let yourImage: UIImage = UIImage(named: "face-id")!
                biometricImage.image = yourImage
                
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
                biometricImage.image = yourImage
              
                break
            default:
                
                break
            }
            //*/
            
            
        }
        
        
        
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
