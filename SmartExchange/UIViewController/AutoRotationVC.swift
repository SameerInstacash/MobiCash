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

class AutoRotationVC: UIViewController {
    
    @IBOutlet weak var beginBtn: UIButton!
    @IBOutlet weak var AutoRotationText: UITextView!
    @IBOutlet weak var AutoRotationImage: UIImageView!
    @IBOutlet weak var AutoRotationImageView: UIImageView!
    @IBOutlet weak var screenRotationInfo: UITextView!
    var hasStarted = false
    var resultJSON = JSON()
    var isComingFromTestResult = false
    
    @IBAction func beginBtnClicked(_ sender: Any) {
        
        if self.hasStarted {
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
                
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityView") as! ProximityVC
                    vc.resultJSON = self.resultJSON
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
            
        }else{
            self.hasStarted = true
            self.AutoRotationText.text = "landscape_mode".localized
            self.beginBtn.setTitle("skip".localized,for: .normal)
            self.AutoRotationImage.isHidden = true
            self.AutoRotationImageView.isHidden = false
            self.AutoRotationImageView.image = UIImage(named: "landscape_image")!
                        
            NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.AutoRotationImage.loadGif(name: "rotation")
        self.screenRotationInfo.text = "rota_info".localized
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func rotated()
    {
        if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            print("LandScape")
            self.AutoRotationText.text = "portrait_mode".localized
            self.AutoRotationImageView.image = UIImage(named: "portrait_image")!
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            print("Portrait")
            UserDefaults.standard.set(true, forKey: "rotation")
            self.resultJSON["Rotation"].int = 1
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityView") as! ProximityVC
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }
            
            // let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraViewController
            //self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
}
