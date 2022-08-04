//
//  FlashLightVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog
import AVKit
import SwiftyJSON

class TorchVC: UIViewController {
    
    var flashLightRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var flashLightTestDiagnosis: ((_ testJSON: JSON) -> Void)?

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var numberTxtField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    
    var resultJSON = JSON()
    var isComingFromTestResult = false
    var num1 = 0
    var gameTimer: Timer?
    var runCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberTxtField.layer.cornerRadius = 10.0
        self.numberTxtField.layer.borderWidth = 1.0
        self.numberTxtField.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.setUIElementsProperties()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //AppOrientationUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.hideKeyboardWhenTappedAround()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)

    }
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Start Test".localized {
            sender.setTitle("Submit".localized, for: .normal)
            
            self.startTest()
        }else {
            
            guard !(self.numberTxtField.text?.isEmpty ?? false) else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast("Enter Number", duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if self.numberTxtField.text == String(num1) {
                
                self.resultJSON["Torch"].int = 1
                UserDefaults.standard.set(true, forKey: "Torch")
                
                self.goNext()
            }else {

                self.resultJSON["Torch"].int = 0
                UserDefaults.standard.set(false, forKey: "Torch")
                
                self.goNext()
            }
            
        }
    
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
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
        
        self.toggleTorch(on: true)
        
        if runCount == self.num1 {
            self.gameTimer?.invalidate()
            self.numberTxtField.isHidden = false
        }
        
    }

    func toggleTorch(on: Bool) {
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            //To on the Torch
            do {
                try device.lockForConfiguration()
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    //To off the Torch
                    do {
                        try device.lockForConfiguration()
                        if on == true {
                            device.torchMode = .off
                        } else {
                            device.torchMode = .on
                        }
                        device.unlockForConfiguration()
                    } catch {
                        
                        self.gameTimer?.invalidate()
                        
                        DispatchQueue.main.async() {
                            self.view.makeToast("FlashLight not working", duration: 2.0, position: .bottom)
                        }
                        
                    }
                }
                
            } catch {
                
                self.gameTimer?.invalidate()
                
                DispatchQueue.main.async() {
                    self.view.makeToast("FlashLight not working", duration: 2.0, position: .bottom)
                }
                
                
            }
        } else {
            self.gameTimer?.invalidate()
            
            DispatchQueue.main.async() {
                self.view.makeToast("FlashLight not working", duration: 2.0, position: .bottom)
            }
            
            
        }
    }
    
    func goNext() {
        
        /*
        if self.isComingFromTestResult {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }else {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RotationVC") as! AutoRotationVC
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }*/
        
        if self.isComingFromTestResult {
            
            guard let didFinishRetryDiagnosis = self.flashLightRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        else{
            
            guard let didFinishTestDiagnosis = self.flashLightTestDiagnosis else { return }
            didFinishTestDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    func skipTest() {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        
        let title = "FlashLight Test".localized
        let message = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?".localized
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            
            self.resultJSON["Torch"].int = -1
            UserDefaults.standard.set(false, forKey: "Torch")

            /*
            if self.isComingFromTestResult {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                
                self.resultJSON["Torch"].int = -1
                UserDefaults.standard.set(false, forKey: "Torch")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }else {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "RotationVC") as! AutoRotationVC
                
                self.resultJSON["Torch"].int = -1
                UserDefaults.standard.set(false, forKey: "Torch")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }*/
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.flashLightRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.flashLightTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
          
        }
        
        let buttonTwo = DefaultButton(title: "No".localized) {
            //Do Nothing
            self.startBtn.setTitle("Start Test", for: .normal)
            popup.dismiss(animated: true, completion: nil)
        }
        
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo])
        popup.dismiss(animated: true, completion: nil)
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            pv.titleFont    = UIFont(name: GlobalUtility().AppFontMedium, size: 20)!
            pv.messageFont  = UIFont(name: GlobalUtility().AppFontRegular, size: 16)!
        }else {
            pv.titleFont    = UIFont(name: GlobalUtility().AppFontMedium, size: 20)!
            pv.messageFont  = UIFont(name: GlobalUtility().AppFontRegular, size: 16)!
        }
        
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
        
        popUpVC.strTitle = "FlashLight Diagnosis"
        popUpVC.strMessage = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("FlashLight Skipped!")
                
                self.resultJSON["Torch"].int = -1
                UserDefaults.standard.set(false, forKey: "Torch")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.flashLightRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.flashLightTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                                
            case 2:
                
                self.startBtn.setTitle("Start Test", for: .normal)
                
            default:
                                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        /*
        // Prepare the popup assets
        let title = "Quit Diagnosis"
        let message = "Are you sure you want to quit?"
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes") {
            DispatchQueue.main.async() {
                //self.dismiss(animated: true) {
                    //self.NavigateToHomePage()
                //}
            }
        }
        
        let buttonTwo = DefaultButton(title: "No") {
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
        if UIDevice.current.model.hasPrefix("iPad") {
            pv.titleFont    = UIFont(name: AppBrownFontBold, size: 26)!
            pv.messageFont  = UIFont(name: AppBrownFontRegular, size: 22)!
        }else {
            pv.titleFont    = UIFont(name: AppBrownFontBold, size: 20)!
            pv.messageFont  = UIFont(name: AppBrownFontRegular, size: 16)!
        }
        
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
        DispatchQueue.main.async {
            db.titleLabel?.textColor = AppThemeColor
        }
        if UIDevice.current.model.hasPrefix("iPad") {
            db.titleFont      = UIFont(name: AppBrownFontRegular, size: 22)!
        }else {
            db.titleFont      = UIFont(name: AppBrownFontRegular, size: 16)!
        }
                
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            cb.titleFont      = UIFont(name: AppBrownFontRegular, size: 22)!
        }else {
            cb.titleFont      = UIFont(name: AppBrownFontRegular, size: 16)!
        }
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
        */
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
