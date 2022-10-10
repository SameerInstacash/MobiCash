//
//  DeadPixelVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 18/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import PopupDialog
import QRCodeReader
import AVFoundation
import SwiftGifOrigin
import AudioToolbox
import SwiftyJSON
import CoreMotion
import AVFoundation

class DeadPixelVC: UIViewController {
    
    var deadPixelRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var deadPixelTestDiagnosis: ((_ testJSON: JSON) -> Void)?

    @IBOutlet weak var startTestBtn: UIButton!
    @IBOutlet weak var deadPixelInfoImage: UIImageView!
    //@IBOutlet weak var deadPixelInfo: UILabel!
    //@IBOutlet weak var deadPixelNavBar: UINavigationBar!
    @IBOutlet weak var pixelView: UIView!
    
    var testPixelView = UIView()
    
    var pixelTimer: Timer?
    var pixelTimerIndex = 0
    var resultJSON = JSON()
    var audioPlayer = AVAudioPlayer()
    
    var isComingFromTestResult = false
    let audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //self.deadPixelInfoImage.loadGif(name: "dead_pixel")

        //self.checkMicrophone()
        //self.checkVibrator()
        //self.playSound()
        
        //DispatchQueue.main.async {
            //self.configureAudioSessionCategory()
            //self.playSound()
        //}
           
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //self.checkVibrator()
        //}
        
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
    @IBAction func startDeadPixelTest(_ sender: UIButton) {
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.testPixelView.frame = screenSize
        self.testPixelView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(self.testPixelView)
     
        //self.pixelView.isHidden = !self.pixelView.isHidden
        
        DispatchQueue.main.async {
            self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
        }
        
        
        
        /* Sameer 1/8/22
        checkVibrator()
        playSound()
                
        self.deadPixelNavBar.isHidden = true
        
        // Sameer
        //self.resultJSON["Speakers"].int = 1
        //self.resultJSON["MIC"].int = 1
        //UserDefaults.standard.set(true, forKey: "mic")
        
        self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
        self.view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.startTestBtn.isHidden = true
        self.deadPixelInfo.isHidden = true
        self.deadPixelInfoImage.isHidden = true
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
                
                print("Dead Pixel Skipped!")
                
                self.resultJSON["Dead Pixels"].int = -1
                UserDefaults.standard.set(false, forKey: "deadPixel")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
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
    
    @objc func setRandomBackgroundColor() {
        self.pixelTimerIndex += 1
        
        let colors = [
            #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.003921568627, blue: 0.9843137255, alpha: 1),#colorLiteral(red: 0.003921568627, green: 0.003921568627, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 1, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ]
        
        switch self.pixelTimerIndex {
            
        case 5:
            
            self.testPixelView.removeFromSuperview()
            //self.pixelView.isHidden = !self.pixelView.isHidden
            
            //self.view.backgroundColor = colors[pixelTimerIndex]
            self.pixelTimer?.invalidate()
            self.pixelTimer = nil
            
            
            self.ShowPopUpForDeadPixel()
            
            
            /*
            // Prepare the popup assets
            let title = "Dead_Pixel_Test".localized
            let message = "dead_pixel_msg".localized
            
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: "Yes".localized) {
                
                self.resultJSON["Dead Pixels"].int = 0
                UserDefaults.standard.set(false, forKey: "deadPixel")
                print("Dead Pixel Failed!")
                
                /*
                if self.isComingFromTestResult {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenVC") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }*/
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            let buttonTwo = DefaultButton(title: "No".localized) {
                
                self.resultJSON["Dead Pixels"].int = 1
                UserDefaults.standard.set(true, forKey: "deadPixel")
                print("Dead Pixel Passed!")
                
                /*
                if self.isComingFromTestResult {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenVC") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }*/
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            let buttonThree = DefaultButton(title: "retry".localized) {
                
                /* Sameer 1/8/22
                self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
                self.view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.startTestBtn.isHidden = true
                self.deadPixelInfo.isHidden = true
                self.deadPixelInfoImage.isHidden = true
                self.timerIndex = 0
                */
                
                self.pixelTimerIndex = 0
                self.startDeadPixelTest(UIButton())
                
            }
            
                        
            // Add buttons to dialog
            // Alternatively, you can use popup.addButton(buttonOne)
            // to add a single button
            popup.addButtons([buttonOne, buttonTwo,buttonThree])
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
            
            break
            
        default:
            //self.view.backgroundColor = colors[0]
            
            if self.pixelTimerIndex < colors.count {
                DispatchQueue.main.async {
                    self.testPixelView.backgroundColor = colors[self.pixelTimerIndex]
                }
            }
            
        }
        
    }
   
    func ShowPopUpForDeadPixel() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Dead Pixels"
        popUpVC.strMessage = "Did you find any spot?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = "Retry"
        popUpVC.isShowThirdBtn = true
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                self.resultJSON["Dead Pixels"].int = 0
                UserDefaults.standard.set(false, forKey: "deadPixel")
                print("Dead Pixel Failed!")
                
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            case 2:
                
                self.resultJSON["Dead Pixels"].int = 1
                UserDefaults.standard.set(true, forKey: "deadPixel")
                print("Dead Pixel Passed!")
                
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = false
                    self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                
            default:
                
                self.pixelTimerIndex = 0
                self.startDeadPixelTest(UIButton())
                                
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
        
    func configureAudioSessionCategory() {
        print("Configuring audio session")
        do {
            //try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            print("AVAudio Session out options: ", audioSession.currentRoute)
            print("Successfully configured audio session.")
        } catch (let error) {
            print("Error while configuring audio session: \(error)")
        }
    }

    
//    func playUsingAVAudioPlayer(url: URL) {
//        var audioPlayer: AVAudioPlayer?
//        self.resultJSON["Speakers"].int = 1
//        self.resultJSON["MIC"].int = 1
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer?.play()
//            print("playing audio")
//        } catch {
//            print(error)
//        }
//    }
    
    
    func playSound() {

            guard let url = Bundle.main.path(forResource: "whistle", ofType: "mp3") else {
                print("not found")
                return
            }
            
            
            // 8/10/21
            // This is to audio output from bottom (main) speaker
            do {
                try self.audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                try self.audioSession.setActive(true)
                print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",self.audioSession.currentRoute.outputs)
            } catch let error as NSError {
                print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
            }
            
            
            do {
                
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
                self.audioPlayer.play()
                
                let outputVol = AVAudioSession.sharedInstance().outputVolume
                
                if(outputVol > 0.20) {
                    self.resultJSON["Speakers"].int = 1
                    UserDefaults.standard.set(true, forKey: "Speakers")
                    
                    //self.resultJSON["MIC"].int = 1
                }else{
                    self.resultJSON["Speakers"].int = 0
                    UserDefaults.standard.set(false, forKey: "Speakers")
                    
                    //self.resultJSON["MIC"].int = 0
                }
            } catch let error {
                self.resultJSON["Speakers"].int = 0
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                //self.resultJSON["MIC"].int = 0
                print(error.localizedDescription)
            }
        
    }

    func checkVibrator(){
        self.resultJSON["Vibrator"].int = 0
        UserDefaults.standard.set(false, forKey: "Vibrator")
        
        let manager = CMMotionManager()
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                if let x = data?.userAcceleration.x,
                    x > 0.03 {
                    
                    print("Device Vibrated at: \(x)")
                    self?.resultJSON["Vibrator"].int = 1
                    UserDefaults.standard.set(true, forKey: "Vibrator")
                    
                    manager.stopDeviceMotionUpdates()
                }
            }
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
