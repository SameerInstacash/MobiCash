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
    
    //@IBOutlet weak var lblCheckingVibrator: UILabel!
    @IBOutlet weak var lblPleaseEnsure: UILabel!
    @IBOutlet weak var txtFieldNum: UITextField!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var btnOneVibration: UIButton!
    @IBOutlet weak var btnTwoVibration: UIButton!
    @IBOutlet weak var btnThreeVibration: UIButton!
    @IBOutlet weak var btnFourVibration: UIButton!
    @IBOutlet weak var btnNoVibration: UIButton!
    
    var strSelectedNumber = ""
    
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
        
        //self.txtFieldNum.layer.cornerRadius = 20.0
        //self.txtFieldNum.layer.borderWidth = 1.0
        //self.txtFieldNum.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
                
        //self.setStatusBarColor()
        
        if self.isComingFromTestResult == false && self.isComingFromProductquote == false {
            //userDefaults.removeObject(forKey: "Vibrator")
            //userDefaults.setValue(false, forKey: "Vibrator")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //AppOrientationUtility.lockOrientation(.portrait)
        //self.changeLanguageOfUI()
    }

    func changeLanguageOfUI() {
  
        //self.lblCheckingVibrator.text = "Checking Vibrator".localized
        self.lblPleaseEnsure.text = "Count how many times your phone has vibrated and then type it in the text box provided".localized
        
        self.btnStart.setTitle("Start Test".localized, for: UIControlState.normal)
        self.btnSkip.setTitle("Skip".localized, for: UIControlState.normal)
    }
    
    //MARK:- button action methods
    @IBAction func onClickStart(sender: UIButton) {
        
        if sender.titleLabel?.text == "Start Test" {
            //sender.setTitle("Submit".localized, for: .normal)
            
            self.num1 = 0
            self.runCount = 0
            self.gameTimer?.invalidate()
            
            self.btnOneVibration.isSelected = false
            self.btnTwoVibration.isSelected = false
            self.btnThreeVibration.isSelected = false
            self.btnFourVibration.isSelected = false
            
            self.btnStart.isHidden = true
            self.startTest()
            
        }else if sender.titleLabel?.text == "Retry" {
            
            self.num1 = 0
            self.runCount = 0
            self.gameTimer?.invalidate()
            
            self.btnOneVibration.isSelected = false
            self.btnTwoVibration.isSelected = false
            self.btnThreeVibration.isSelected = false
            self.btnFourVibration.isSelected = false
            
            self.btnStart.isHidden = true
            self.startTest()
            
        } else {
            
            /*
            guard !(self.txtFieldNum.text?.isEmpty ?? false) else {
                DispatchQueue.main.async() {
                    self.view.makeToast("Enter Number", duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if txtFieldNum.text == String(num1) {

                self.resultJSON["Vibrator"].int = 1
                UserDefaults.standard.set(true, forKey: "Vibrator")
                
                DispatchQueue.main.async {
                    self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                    self.goNext()
                }
            }else {

                self.resultJSON["Vibrator"].int = 0
                UserDefaults.standard.set(false, forKey: "Vibrator")
                
                self.goNext()
            }
            */
            
            guard !(self.strSelectedNumber.isEmpty) else {
                DispatchQueue.main.async() {
                    self.view.makeToast("Select Number", duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if self.strSelectedNumber == String(self.num1) {
                
                self.resultJSON["Vibrator"].int = 1
                UserDefaults.standard.set(true, forKey: "Vibrator")
                
                DispatchQueue.main.async {
                    self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    self.goNext()
                }
                
            }else if self.strSelectedNumber == "0" {
                
                self.resultJSON["Vibrator"].int = 0
                UserDefaults.standard.set(false, forKey: "Vibrator")
                
                self.goNext()
                
            }else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast("Wrong selection. Please retry or skip", duration: 2.0, position: .bottom)
                }
                
            }
            
        }
    
    }
    
    @IBAction func onClickSkip(sender: UIButton) {
        self.skipTest()
    }
    
    func startTest() {
        
        let randomNumber = Int.random(in: 1...4)
        print("Number: \(randomNumber)")
        self.num1 = randomNumber
        
        self.gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        
        self.runCount += 1
        self.checkVibrator()
        
        if self.runCount == self.num1 {
            self.gameTimer?.invalidate()
            //self.txtFieldNum.isHidden = false
            
            self.numberView.isHidden = false
            self.btnStart.isHidden = false
            self.btnStart.setTitle("VERIFY CODE".localized, for: UIControlState.normal)
            
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
        
        popUpVC.strTitle = "Are you sure?"
        popUpVC.strMessage = "If you skip this test there would be a substantial decline in the price offered."
        popUpVC.strBtnYesTitle = "Skip Test"
        popUpVC.strBtnNoTitle = "Don't Skip"
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
    
    //MARK: IBActions for number of vibrations selection
    @IBAction func oneVibrationBtnClicked(sender: UIButton) {
        self.btnOneVibration.isSelected = true
        self.btnTwoVibration.isSelected = false
        self.btnThreeVibration.isSelected = false
        self.btnFourVibration.isSelected = false
        self.btnNoVibration.isSelected = false
        
        self.strSelectedNumber = "1"
        
        if String(self.num1) != self.strSelectedNumber {
            self.btnStart.setTitle("Retry", for: .normal)
            
            DispatchQueue.main.async() {
                self.view.makeToast("Wrong selection. Please retry or skip", duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    @IBAction func twoVibrationBtnClicked(sender: UIButton) {
        self.btnOneVibration.isSelected = false
        self.btnTwoVibration.isSelected = true
        self.btnThreeVibration.isSelected = false
        self.btnFourVibration.isSelected = false
        self.btnNoVibration.isSelected = false
        
        self.strSelectedNumber = "2"
        
        if String(self.num1) != self.strSelectedNumber {
            self.btnStart.setTitle("Retry", for: .normal)
            
            DispatchQueue.main.async() {
                self.view.makeToast("Wrong selection. Please retry or skip", duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    @IBAction func threeVibrationBtnClicked(sender: UIButton) {
        self.btnOneVibration.isSelected = false
        self.btnTwoVibration.isSelected = false
        self.btnThreeVibration.isSelected = true
        self.btnFourVibration.isSelected = false
        self.btnNoVibration.isSelected = false
        
        self.strSelectedNumber = "3"
        
        if String(self.num1) != self.strSelectedNumber {
            self.btnStart.setTitle("Retry", for: .normal)
            
            DispatchQueue.main.async() {
                self.view.makeToast("Wrong selection. Please retry or skip", duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    @IBAction func fourVibrationBtnClicked(sender: UIButton) {
        self.btnOneVibration.isSelected = false
        self.btnTwoVibration.isSelected = false
        self.btnThreeVibration.isSelected = false
        self.btnFourVibration.isSelected = true
        self.btnNoVibration.isSelected = false
        
        self.strSelectedNumber = "4"
        
        if String(self.num1) != self.strSelectedNumber {
            self.btnStart.setTitle("Retry", for: .normal)
            
            DispatchQueue.main.async() {
                self.view.makeToast("Wrong selection. Please retry or skip", duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    @IBAction func noVibrationBtnClicked(sender: UIButton) {
        self.btnOneVibration.isSelected = false
        self.btnTwoVibration.isSelected = false
        self.btnThreeVibration.isSelected = false
        self.btnFourVibration.isSelected = false
        self.btnNoVibration.isSelected = true
        
        self.strSelectedNumber = "0"
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
