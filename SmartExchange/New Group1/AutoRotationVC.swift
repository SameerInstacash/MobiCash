//
//  AutoRotationVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 20/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog
import CoreMotion

class AutoRotationVC: UIViewController {
    
    var rotationRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var rotationTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var beginBtn: UIButton!
    @IBOutlet weak var AutoRotationImage: UIImageView!
    @IBOutlet weak var AutoRotationImageView: UIImageView!
    //@IBOutlet weak var screenRotationInfo: UITextView!
    //@IBOutlet weak var AutoRotationText: UITextView!
    @IBOutlet weak var AutoRotationText: UILabel!
    
    var hasStarted = false
    var resultJSON = JSON()
    var isComingFromTestResult = false
    
    let motion = CMMotionManager()
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //self.AutoRotationImage.loadGif(name: "rotation")
        //self.screenRotationInfo.text = "rota_info".localized
        self.AutoRotationText.text = "rota_info".localized
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func beginBtnClicked(_ sender: UIButton) {
        
        sender.isHidden = true
    
        
        self.hasStarted = true
        self.AutoRotationText.text = "landscape_mode".localized
        //self.beginBtn.setTitle("skip".localized,for: .normal)
        self.AutoRotationImage.isHidden = true
        
        self.AutoRotationImageView.isHidden = false
        self.AutoRotationImageView.image = UIImage(named: "landscape_image")!
                    
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        /*
        if self.hasStarted {
            
            self.ShowGlobalPopUp()
            
            /*
            // Prepare the popup assets
            let title = "rotation_test".localized
            let message = "skip_info".localized
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: "Yes".localized) {
                UserDefaults.standard.set(false, forKey: "rotation")
                self.resultJSON["Rotation"].int = 0
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
                
                /*
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityView") as! ProximityVC
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }*/
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.rotationRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.rotationTestDiagnosis else { return }
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
            
        }else{
            self.hasStarted = true
            self.AutoRotationText.text = "landscape_mode".localized
            self.beginBtn.setTitle("skip".localized,for: .normal)
            self.AutoRotationImage.isHidden = true
            self.AutoRotationImageView.isHidden = false
            self.AutoRotationImageView.image = UIImage(named: "landscape_image")!
                        
            NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
        */
        
        
    }
    
    @IBAction func skipbuttonPressed(_ sender: UIButton) {
        self.ShowGlobalPopUp()
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
                
                print("Rotation Skipped!")
                
                UserDefaults.standard.set(false, forKey: "rotation")
                self.resultJSON["Rotation"].int = -1
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.rotationRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.rotationTestDiagnosis else { return }
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
    
    @objc func rotated()
    {
        //self.startGyros()
        
        if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            print("LandScape")
            self.AutoRotationText.text = "portrait_mode".localized
            self.AutoRotationImageView.image = UIImage(named: "portrait_image")!
        }
        
        if (UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            print("Portrait")
            UserDefaults.standard.set(true, forKey: "rotation")
            self.resultJSON["Rotation"].int = 1
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            
            
            /*
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityView") as! ProximityVC
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }
            */
            
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = false
                self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.rotationRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.rotationTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            
        }
        
    }
    
    
}

extension AutoRotationVC {
    
    func startGyros() {
        if motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = 1.0 / 60.0
            self.motion.startGyroUpdates()
            
            // Configure a timer to fetch the accelerometer data.
            self.timer = Timer(fire: Date(), interval: (1.0/60.0), repeats: true, block: { (timer) in
                
                // Get the gyro data.
                if let data = self.motion.gyroData {
                    
                    let x = data.rotationRate.x
                    let y = data.rotationRate.y
                    let z = data.rotationRate.z
                    
                    print("X-axis",x)
                    print("Y-axis",y)
                    print("Z-axis",z)
                    
                    // Use the gyroscope data in your app.
                    self.stopGyros()
                    
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
        }
    }

    func stopGyros() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            
            self.motion.stopGyroUpdates()
        }
    }
    
}
