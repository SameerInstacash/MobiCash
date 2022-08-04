//
//  VolumeRockerVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 19/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import JPSVolumeButtonHandler
import PopupDialog
import SwiftyJSON

class VolumeRockerVC: UIViewController {
    
    var volumeRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var volumeTestDiagnosis: ((_ testJSON: JSON) -> Void)?

    //@IBOutlet weak var btnInfo: UITextView!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var volumeUpImg: UIImageView!
    @IBOutlet weak var volumeDownImg: UIImageView!
    var resultJSON = JSON()
    var isComingFromTestResult = false
    
    private var audioLevel : Float = 0.0
    //var audioSession = AVAudioSession.sharedInstance()
    var audioSession : AVAudioSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
                
        //self.lblInfo.text = "hard_btn_info".localized
      
        /*
        self.volumeButtonHandler = JPSVolumeButtonHandler(up: {
            
                print("Volume up pressed")
                self.volumeUpImg.image = UIImage(named: "volume_up_green")
                self.volUp = true
                
                if(self.volDown == true){
                    
                    print("Volume test passed")
                    self.tearDown()
                    
                    UserDefaults.standard.set(true, forKey: "volume")
                    self.resultJSON["Hardware Buttons"].int = 1
                    
                    /*
                    if self.isComingFromTestResult {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                        vc.resultJSON = self.resultJSON
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneJackVC
                        vc.resultJSON = self.resultJSON
                        self.present(vc, animated: true, completion: nil)
                    }*/
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                    
                }
                self.action()
            
            }, downBlock: {
                
                print("Volume down pressed")
                self.volumeDownImg.image = UIImage(named: "volume_down_green")
                self.volDown = true
                
                if(self.volUp == true){
                    
                    print("Volume test passed")
                    UserDefaults.standard.set(true, forKey: "volume")
                    self.resultJSON["Hardware Buttons"].int = 1
                    self.tearDown()
                    
                    //UserDefaults.standard.set(true, forKey: "charger")
                    //UserDefaults.standard.set(true, forKey: "earphone")
                               
                    /*
                    if self.isComingFromTestResult {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                        vc.resultJSON = self.resultJSON
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneJackVC
                        vc.resultJSON = self.resultJSON
                        self.present(vc, animated: true, completion: nil)
                    }*/
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                self.action()
        })
     
        let handler = volumeButtonHandler
        handler!.start(true)
        */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // SAM comment on 18/4/22
        //self.audioSession?.removeObserver(self, forKeyPath: "outputVolume", context: nil)
    }
    
    var volDown = false
    var volUp = false
    private var volumeButtonHandler: JPSVolumeButtonHandler?
    
    var action: (() -> Void) = {} {
        didSet {
            // Is the handler already there, that is, is this module already in use?..
            if let handler = self.volumeButtonHandler {
                // ..If so, then add the action to the handler right away.
                handler.upBlock = action
                handler.downBlock = action
            }
            // Otherwise, just save the action here and see it added when the handler is created when the module goes into use (isInUse = true).
        }
    }
    
    func tearDown() {
        if let handler = volumeButtonHandler {
            handler.stop()
            self.volumeButtonHandler = nil
        }
    }

    func listenVolumeButton() {
        
        self.audioSession = AVAudioSession.sharedInstance()
        
        do {
            try self.audioSession?.setActive(true, with: [])
            self.audioSession?.addObserver(self, forKeyPath: "outputVolume",
                                     options: NSKeyValueObservingOptions.new, context: nil)
            self.audioLevel = (self.audioSession?.outputVolume ?? 0.0)
        } catch {
            print("Error")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //DispatchQueue.main.async {
            
            if keyPath == "outputVolume" {
                
                //let audioSession = AVAudioSession.sharedInstance()
                
                if (self.audioSession?.outputVolume ?? 0.0) > self.audioLevel {
                    
                    print("Volume up pressed")
                    self.volumeUpImg.image = UIImage(named: "volume_up_green")
                    self.volUp = true
                    
                    if (self.volDown == true) {
                        
                        self.audioSession?.removeObserver(self, forKeyPath: "outputVolume", context: nil)
                        
                        print("Volume test passed")
                        
                        UserDefaults.standard.set(true, forKey: "volume")
                        self.resultJSON["Hardware Buttons"].int = 1
                        
                        /*
                        if self.isComingFromTestResult {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                        }else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneJackVC
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                        }*/
                        
                        if self.isComingFromTestResult {
                            
                            guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                            didFinishRetryDiagnosis(self.resultJSON)
                            self.dismiss(animated: false, completion: nil)
                            
                        }
                        else{
                            
                            guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
                            didFinishTestDiagnosis(self.resultJSON)
                            self.dismiss(animated: false, completion: nil)
                            
                        }
                        
                    }
                    
                }
                
                if (self.audioSession?.outputVolume ?? 0.0) < self.audioLevel {
                    
                    print("Volume down pressed")
                    self.volumeDownImg.image = UIImage(named: "volume_down_green")
                    self.volDown = true
                    
                    if (self.volUp == true) {
                        
                        self.audioSession?.removeObserver(self, forKeyPath: "outputVolume", context: nil)
                        
                        print("Volume test passed")
                        
                        UserDefaults.standard.set(true, forKey: "volume")
                        self.resultJSON["Hardware Buttons"].int = 1
                        
                        /*
                        if self.isComingFromTestResult {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                        }else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneJackVC
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                        }*/
                        
                        if self.isComingFromTestResult {
                            
                            guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                            didFinishRetryDiagnosis(self.resultJSON)
                            self.dismiss(animated: false, completion: nil)
                            
                        }
                        else{
                            
                            guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
                            didFinishTestDiagnosis(self.resultJSON)
                            self.dismiss(animated: false, completion: nil)
                            
                        }
                        
                    }
                    
                }
                
                self.audioLevel = (self.audioSession?.outputVolume ?? 0.0)
                print("self.audioSession.outputVolume is:", self.audioSession?.outputVolume ?? 0.0)
                
            }
        //}
    }
    
    //MARK: IBAction
    @IBAction func volumeButtonStartPressed(_ sender: UIButton) {
        // SAM comment on 18/4/22
        self.listenVolumeButton()
    }
        
    @IBAction func volumeRockerSkipPressed(_ sender: UIButton) {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        let title = "hardware_test".localized
        let message = "skip_info".localized
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            
            //self.audioSession.removeObserver(self, forKeyPath: "outputVolume", context: nil)
            
            self.tearDown()
            UserDefaults.standard.set(false, forKey: "volume")
            self.resultJSON["Hardware Buttons"].int = 0
          
            /*
            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneJackVC
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
            }*/
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
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
        
        popUpVC.strTitle = "Hardware Button Diagnosis"
        popUpVC.strMessage = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                self.audioSession?.removeObserver(self, forKeyPath: "outputVolume", context: nil)
                
                print("Hardware Buttons Skipped!")
                
                self.tearDown()
                UserDefaults.standard.set(false, forKey: "volume")
                self.resultJSON["Hardware Buttons"].int = -1
              
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
