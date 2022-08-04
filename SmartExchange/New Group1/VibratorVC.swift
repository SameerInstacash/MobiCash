//
//  VibratorVC.swift
//  InstaCash
//
//  Created by Sameer Khan on 04/03/21.
//  Copyright © 2021 Prakhar Gupta. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog
import AVFoundation
import AudioToolbox
import CoreMotion

class VibratorVC: UIViewController {
    
    var vibratorRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var vibratorTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var lblCheckingVibrator: UILabel!
    @IBOutlet weak var lblPleaseEnsure: UILabel!
    
    @IBOutlet weak var txtFieldNum: UITextField!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    

    var resultJSON = JSON()
    var num1 = 0
    var gameTimer: Timer?
    var runCount = 0
    
    var isComingFromTestResult = false
    var isComingFromProductquote = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        self.hideKeyboardWhenTappedAround()
        
        self.txtFieldNum.layer.cornerRadius = 10.0
        self.txtFieldNum.layer.borderWidth = 1.0
        self.txtFieldNum.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
                
        //self.setStatusBarColor()
        
        if isComingFromTestResult == false && isComingFromProductquote == false {
            //userDefaults.removeObject(forKey: "Vibrator")
            //userDefaults.setValue(false, forKey: "Vibrator")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //AppOrientationUtility.lockOrientation(.portrait)
        //self.changeLanguageOfUI()
    }

    func changeLanguageOfUI() {
  
        self.lblCheckingVibrator.text = "Checking Vibrator".localized
        self.lblPleaseEnsure.text = "Count how many times your phone has vibrated and then type it in the text box provided".localized
        
        self.btnStart.setTitle("Start Test".localized, for: UIControlState.normal)
        self.btnSkip.setTitle("Skip".localized, for: UIControlState.normal)
    }
    
    //MARK:- button action methods
    @IBAction func onClickStart(sender: UIButton) {
        
        if sender.titleLabel?.text == "Start Test".localized {
            sender.setTitle("Submit".localized, for: .normal)
            
            self.startTest()
        }else {
            
            guard !(self.txtFieldNum.text?.isEmpty ?? false) else {
                DispatchQueue.main.async() {
                    self.view.makeToast("Enter Number", duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if txtFieldNum.text == String(num1) {

                self.resultJSON["Vibrator"].int = 1
                UserDefaults.standard.set(true, forKey: "Vibrator")
                
                self.goNext()
            }else {

                self.resultJSON["Vibrator"].int = 0
                UserDefaults.standard.set(false, forKey: "Vibrator")
                
                self.goNext()
            }
            
        }
    
    }
    
    @IBAction func onClickSkip(sender: UIButton) {
        self.skipTest()
    }
    
    func startTest() {
        
        let randomNumber = Int.random(in: 1...5)
        print("Number: \(randomNumber)")
        self.num1 = randomNumber
        
        self.gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        
        self.runCount += 1
        self.checkVibrator()
        
        if self.runCount == self.num1 {
            self.gameTimer?.invalidate()
            self.txtFieldNum.isHidden = false
        }
        
    }
    
    func checkVibrator() {
        
        let manager = CMMotionManager()
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
               
                if let x = data?.userAcceleration.x, x > 0.03 {
                    print("Device Vibrated at: \(x)")
                    manager.stopDeviceMotionUpdates()
                }
            }
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func goNext() {
        
        /*
        if self.isComingFromTestResult {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }else {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TorchVC") as! TorchVC
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }*/
        
        if self.isComingFromTestResult {
            
            guard let didFinishRetryDiagnosis = self.vibratorRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        else{
            
            guard let didFinishTestDiagnosis = self.vibratorTestDiagnosis else { return }
            didFinishTestDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    func skipTest() {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        
        //let title = "Vibrator Test".localized
        let title = "vibrator_test".localized
        let message = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?".localized
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            
            self.resultJSON["Vibrator"].int = -1
            UserDefaults.standard.set(false, forKey: "Vibrator")

            /*
            if self.isComingFromTestResult {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                
                self.resultJSON["Vibrator"].int = -1
                UserDefaults.standard.set(false, forKey: "Vibrator")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }else {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TorchVC") as! TorchVC
                
                self.resultJSON["Vibrator"].int = -1
                UserDefaults.standard.set(false, forKey: "Vibrator")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }*/
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.vibratorRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.vibratorTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
          
        }
        
        let buttonTwo = DefaultButton(title: "No".localized) {
            //Do Nothing
            self.btnStart.setTitle("Start Test".localized, for: .normal)
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
        
        popUpVC.strTitle = "Vibrator Diagnosis"
        popUpVC.strMessage = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("Vibrator Skipped!")
                
                self.resultJSON["Vibrator"].int = -1
                UserDefaults.standard.set(false, forKey: "Vibrator")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.vibratorRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.vibratorTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                                
            case 2:
                
                self.btnStart.setTitle("Start Test".localized, for: .normal)
                
            default:
                                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
