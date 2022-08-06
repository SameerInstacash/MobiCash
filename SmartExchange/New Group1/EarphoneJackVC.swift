//
//  EarphoneJackVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 20/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import AVFoundation
import PopupDialog
import SwiftGifOrigin
import SwiftyJSON

class EarphoneJackVC: UIViewController {
    
    var earphoneRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var earphoneTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    var resultJSON = JSON()
    @IBOutlet weak var earphoneInfoImage: UIImageView!
    var isComingFromTestResult = false
    
    let session = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //self.earphoneInfoImage.loadGif(name: "earphone_jack")
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBAction
    @IBAction func startbuttonPressed(_ sender: UIButton) {
    
        let currentRoute = self.session.currentRoute
        if currentRoute.outputs.count != 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphone plugged in")
                } else {
                    print("headphone pulled out")
                }
            }
        } else {
            print("requires connection to device")
        }
        
        sender.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.audioRouteChangeListener),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
        
    }
    
    @IBAction func skipbuttonPressed(_ sender: UIButton) {
        self.ShowGlobalPopUp()
    }
    
    @IBAction func earphoneSkipPressed(_ sender: Any) {
        
        /*
        // Prepare the popup assets
        let title = "earphone_test".localized
        let message = "skip_info".localized
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            UserDefaults.standard.set(false, forKey: "earphone")
            self.resultJSON["Earphone"].int = 0
            
            /*
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! DeviceChargerVC
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }*/
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.earphoneRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.earphoneTestDiagnosis else { return }
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
                
                print("Earphone Skipped!")
                
                UserDefaults.standard.set(false, forKey: "earphone")
                self.resultJSON["Earphone"].int = -1
             
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.earphoneRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.earphoneTestDiagnosis else { return }
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

    @objc dynamic private func audioRouteChangeListener(notification:NSNotification) {
        
        DispatchQueue.main.async {
            let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
            
            switch audioRouteChangeReason {
            case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
                print("headphone plugged in")
                UserDefaults.standard.set(true, forKey: "earphone")
                self.resultJSON["Earphone"].int = 1
                
                /*
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! DeviceChargerVC
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }*/
                
                DispatchQueue.main.async {
                    self.view.makeToast("Test Passed!", duration: 2.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.earphoneRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.earphoneTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                
                break
            case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
                print("headphone pulled out")
                UserDefaults.standard.set(true, forKey: "earphone")
                self.resultJSON["Earphone"].int = 1
                
                /*
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! DeviceChargerVC
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }*/
                
                DispatchQueue.main.async {
                    self.view.makeToast("Test Passed!", duration: 2.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.earphoneRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.earphoneTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                
                break
            default:
                break
            }
        }
    }

}
