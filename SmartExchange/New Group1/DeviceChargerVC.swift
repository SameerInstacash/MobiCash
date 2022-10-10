//
//  DeviceChargerVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 20/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import PopupDialog
import DKCamera
import SwiftGifOrigin
import SwiftyJSON

class DeviceChargerVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var chargerRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var chargerTestDiagnosis: ((_ testJSON: JSON) -> Void)?

    var resultJSON = JSON()
    @IBOutlet weak var chargerInfoImage: UIImageView!
    var isComingFromTestResult = false
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //self.chargerInfoImage.loadGif(name: "charging")
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBAction
    @IBAction func startChargerTestBtnPressed(_ sender: UIButton) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryLevelDidChange), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        
        sender.isHidden = true
    }
    
    @IBAction func skipbuttonPressed(_ sender: UIButton) {
        self.ShowGlobalPopUp()
    }
    
    @IBAction func chargerSkipPressed(_ sender: Any) {
        
        /*
        // Prepare the popup assets
        let title = "charger_test".localized
        let message = "skip_info".localized
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            DispatchQueue.main.async() {
                UserDefaults.standard.set(false, forKey: "charger")
                self.resultJSON["USB"].int = 0
                
                /*
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }*/
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.chargerRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.chargerTestDiagnosis else { return }
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
                
                print("charger Skipped!")
                
                UserDefaults.standard.set(false, forKey: "charger")
                self.resultJSON["USB"].int = -1
              
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.chargerRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.chargerTestDiagnosis else { return }
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
    
    @objc func batteryStateDidChange(notification: NSNotification){
        
        // The stage did change: plugged, unplugged, full charge...
        print("Device plugged in.")
        DispatchQueue.main.async() {
            UserDefaults.standard.set(true, forKey: "charger")
            self.resultJSON["USB"].int = 1
            
            /*
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }*/
            
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = false
                self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.chargerRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.chargerTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
        }
        
        
    }
    
    
    @objc func batteryLevelDidChange(notification: NSNotification){
        // The battery's level did change (98%, 99%, ...)
    }
    
}
