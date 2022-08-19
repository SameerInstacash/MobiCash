//
//  SpeakerVC.swift
//  TechCheck
//
//  Created by CULT OF PERSONALITY on 03/03/21.
//  Copyright © 2021 Sameer Khan. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog
import AVFoundation
import AudioToolbox

class SpeakerVC: UIViewController, UITextFieldDelegate {
    
    var speakerRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var speakerTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    //@IBOutlet weak var lblCheckingSpeaker: UILabel!
    //@IBOutlet weak var lblPleaseEnsure: UILabel!
    //@IBOutlet weak var txtFieldNum: UITextField!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    //Speaker
    @IBOutlet weak var btnSpeakerPlayPause: UIButton!
    @IBOutlet weak var txtFieldSpeakerCode: UITextField!
    @IBOutlet weak var btnSpeakerVerifyCode: UIButton!
    
    //Receiver
    @IBOutlet weak var btnReceiverPlayPause: UIButton!
    @IBOutlet weak var txtFieldReceiverCode: UITextField!
    @IBOutlet weak var btnReceiverVerifyCode: UIButton!
    
    var isSpeakerCodeEntered = false
    var isReceiverCodeEntered = false
    
    var resultJSON = JSON()
    var num1 = 0
    var num2 = 0
    var num3 = 0
    var num4 = 0
    
    //var soundFiles = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    var soundFiles = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    var audioPlayer: AVAudioPlayer!

    var isComingFromTestResult = false
    var isComingFromProductquote = false
    
    //let audioSession = AVAudioSession.sharedInstance()
    var audioSession: AVAudioSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        self.hideKeyboardWhenTappedAround()
        
        //self.txtFieldNum.layer.cornerRadius = 10.0
        //self.txtFieldNum.layer.borderWidth = 1.0
        //self.txtFieldNum.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
        
        self.txtFieldSpeakerCode.layer.cornerRadius = 20.0
        self.txtFieldSpeakerCode.layer.borderWidth = 1.0
        self.txtFieldSpeakerCode.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
        
        self.txtFieldReceiverCode.layer.cornerRadius = 20.0
        self.txtFieldReceiverCode.layer.borderWidth = 1.0
        self.txtFieldReceiverCode.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
                
        //self.setStatusBarColor()
        
        if self.isComingFromTestResult == false && self.isComingFromProductquote == false {
            //userDefaults.removeObject(forKey: "Speakers")
            //userDefaults.setValue(false, forKey: "Speakers")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //AppOrientationUtility.lockOrientation(.portrait)
        //self.changeLanguageOfUI()
    }

    func changeLanguageOfUI() {
  
        //self.lblCheckingSpeaker.text = "Checking Speaker".localized
        //self.lblPleaseEnsure.text = "Your phone will play some numbers out loud, and then type it in the text box provided.".localized
        
        //self.btnStart.setTitle("Start Test".localized, for: UIControlState.normal)
        //self.btnSkip.setTitle("Skip".localized, for: UIControlState.normal)
    }
    
    func configureAudioSessionCategory() {
        
        self.audioSession = AVAudioSession.sharedInstance()
        
        print("Configuring audio session")
        do {
            //try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.audioSession?.setActive(true)
            try self.audioSession?.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            print("AVAudio Session out options: ", self.audioSession?.currentRoute ?? "")
            print("Successfully configured audio session.")
        } catch (let error) {
            print("Error while configuring audio session: \(error)")
        }
    }
    
    //MARK: button action methods
    @IBAction func btnSpeakerPlayPauseClicked(sender: UIButton) {
        
        if sender.isSelected {
            
            sender.isSelected = !sender.isSelected
            sender.setImage(UIImage.init(named: "play"), for: .normal)
            
            self.audioSession = nil
            self.audioPlayer.pause()
            self.audioPlayer = nil
            
        }else {
            
            self.txtFieldSpeakerCode.text = ""
            
            sender.isSelected = !sender.isSelected
            sender.setImage(UIImage.init(named: "pause"), for: .normal)
            
            self.audioSession = nil
            self.audioPlayer = nil
            
            self.btnSpeakerPlayPause.isUserInteractionEnabled = false
            
            self.playSoundFromSpeaker()
        }
    
    }
    
    @IBAction func btnSpeakerVerifyCodeClicked(sender: UIButton) {
        
        guard !(self.txtFieldSpeakerCode.text?.isEmpty ?? false) else {
            DispatchQueue.main.async() {
                self.view.makeToast("Please Enter Speaker Code", duration: 2.0, position: .bottom)
            }
            
            return
        }
        
        if self.txtFieldSpeakerCode.text == String(self.num1) + String(self.num2) {
            
            if self.isReceiverCodeEntered {
                
                self.resultJSON["Speakers"].int = 1
                UserDefaults.standard.set(true, forKey: "Speakers")
                
                DispatchQueue.main.async {
                    self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    self.goNext()
                }
                    
            }else {
                self.isSpeakerCodeEntered = true
                
                self.btnSpeakerVerifyCode.isHidden = true
                self.btnSpeakerPlayPause.isUserInteractionEnabled = false
            }

            //self.resultJSON["Speakers"].int = 1
            //UserDefaults.standard.set(true, forKey: "Speakers")
            //self.goNext()
            
        }else {
            
            //self.resultJSON["Speakers"].int = 0
            //UserDefaults.standard.set(false, forKey: "Speakers")
            //self.goNext()
            
            DispatchQueue.main.async() {
                self.view.makeToast("Wrong Code Entered", duration: 2.0, position: .bottom)
            }
            
        }
    
    }
        
    @IBAction func btnReceiverPlayPauseClicked(sender: UIButton) {
    
        if sender.isSelected {
            
            sender.isSelected = !sender.isSelected
            sender.setImage(UIImage.init(named: "play"), for: .normal)
            
            self.audioSession = nil
            self.audioPlayer.pause()
            self.audioPlayer = nil
            
        }else {
            
            self.txtFieldReceiverCode.text = ""
            
            sender.isSelected = !sender.isSelected
            sender.setImage(UIImage.init(named: "pause"), for: .normal)
            
            self.audioSession = nil
            self.audioPlayer = nil
            
            self.btnReceiverPlayPause.isUserInteractionEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.playSoundFromReceiver()
            }
            
        }
        
    }
    
    @IBAction func btnReceiverVerifyCodeClicked(sender: UIButton) {
        
        guard !(self.txtFieldReceiverCode.text?.isEmpty ?? false) else {
            DispatchQueue.main.async() {
                self.view.makeToast("Please Enter Receiver Code", duration: 2.0, position: .bottom)
            }
            
            return
        }
        
        if self.txtFieldReceiverCode.text == String(self.num3) + String(self.num4) {
            
            if self.isSpeakerCodeEntered {
                
                self.resultJSON["Speakers"].int = 1
                UserDefaults.standard.set(true, forKey: "Speakers")
                
                DispatchQueue.main.async {
                    self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    self.goNext()
                }
                
            }else {
                self.isReceiverCodeEntered = true
                
                self.btnReceiverVerifyCode.isHidden = true
                self.btnReceiverPlayPause.isUserInteractionEnabled = false
            }
            
            //self.resultJSON["Speakers"].int = 1
            //UserDefaults.standard.set(true, forKey: "Speakers")
            //self.goNext()
            
        }else {
            
            //self.resultJSON["Speakers"].int = 0
            //UserDefaults.standard.set(false, forKey: "Speakers")
            //self.goNext()
            
            DispatchQueue.main.async() {
                self.view.makeToast("Wrong Code Entered", duration: 2.0, position: .bottom)
            }
            
        }
    
    }
    
    func playSoundFromSpeaker() {
        
        let randomSoundFile = Int(arc4random_uniform(UInt32(soundFiles.count)))
        print(randomSoundFile)
        self.num1 = randomSoundFile
        
        guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
            return
        }
        
        // This is to audio output from bottom (main) speaker
        self.audioSession = AVAudioSession.sharedInstance()
        print("Configuring audio session")
    
        do {
            
            //try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try self.audioSession?.setActive(true)
            print("AVAudio Session out options: ", self.audioSession?.currentRoute ?? "")
            print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",self.audioSession?.currentRoute.outputs ?? 0)
            
        } catch let error as NSError {
            print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
        }
        
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            self.audioPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num2 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                self.audioPlayer.play()
                
                self.btnSpeakerPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
                self.btnSpeakerPlayPause.isUserInteractionEnabled = true
                self.btnSpeakerPlayPause.isSelected = !self.btnSpeakerPlayPause.isSelected
                                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    func playSoundFromReceiver() {
        
        // To play number from earpiece speaker (upper speaker)
        let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
        print(randomSoundFile)
        self.num3 = randomSoundFile
        
        guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
            return
        }
        
        // To play number from earpiece speaker (upper speaker)
        self.audioSession = AVAudioSession.sharedInstance()
        print("Configuring audio session")
        
        do {
            
            try self.audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            try self.audioSession?.setActive(true)
            print("Successfully configured audio session (SPEAKER-Upper).", "\nCurrent audio route: ",self.audioSession?.currentRoute.outputs ?? 0)
            
        } catch let error as NSError {
            print("#configureAudioSessionToEarpieceSpeaker Error \(error.localizedDescription)")
        }
        
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            //self.audioPlayer.volume = .greatestFiniteMagnitude
            self.audioPlayer.play()
                        
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num4 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                //self.audioPlayer.volume = .greatestFiniteMagnitude
                self.audioPlayer.play()
                
                self.btnReceiverPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
                self.btnReceiverPlayPause.isUserInteractionEnabled = true
                self.btnReceiverPlayPause.isSelected = !self.btnReceiverPlayPause.isSelected
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
    }
  
    @IBAction func onClickStart(sender: UIButton) {
        
        if sender.titleLabel?.text == "Start Test".localized {
            //sender.setTitle("Submit".localized, for: .normal)
            
            self.configureAudioSessionCategory()
            self.startTest()
            
            /*
            self.startTest {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            */
            
        }else {
            
            guard !(self.txtFieldSpeakerCode.text?.isEmpty ?? false) else {
                DispatchQueue.main.async() {
                    self.view.makeToast("Enter Number", duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if self.txtFieldSpeakerCode.text == String(num1) + String(num2) + String(num3) + String(num4) {
                self.resultJSON["Speakers"].int = 1
                //self.resultJSON["Microphone"].int = 1
                //UserDefaults.standard.set(true, forKey: "Microphone")
                UserDefaults.standard.set(true, forKey: "Speakers")
                
                self.goNext()
            }else {
                self.resultJSON["Speakers"].int = 0
                //self.resultJSON["Microphone"].int = 0
                //UserDefaults.standard.set(false, forKey: "Microphone")
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                self.goNext()
            }
            
            
        }
    
    }
    
    @IBAction func onClickSkip(sender: UIButton) {
        self.skipTest()
    }
    
    func startTest() {
        
        let randomSoundFile = Int(arc4random_uniform(UInt32(soundFiles.count)))
        print(randomSoundFile)
        self.num1 = randomSoundFile
        
        guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
            return
        }
        
        
        // 8/10/21
        // This is to audio output from bottom (main) speaker
        do {
            try self.audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try self.audioSession?.setActive(true)
            //print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",self.audioSession?.currentRoute.outputs)
        } catch let error as NSError {
            print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
        }
        
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            self.audioPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num2 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                self.audioPlayer.play()
                
                //self.txtFieldNum.isHidden = false
                //self.txtFieldNum.delegate = self
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
        
        
        // To play number from earpiece speaker (upper speaker)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num3 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            // This is to audio output from bottom (main) speaker
            do {
                try self.audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                try self.audioSession?.setActive(true)
                //print("Successfully configured audio session (SPEAKER-Upper).", "\nCurrent audio route: ",self.audioSession?.currentRoute.outputs)
            } catch let error as NSError {
                print("#configureAudioSessionToEarpieceSpeaker Error \(error.localizedDescription)")
            }
            
            
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                //self.audioPlayer.volume = .greatestFiniteMagnitude
                self.audioPlayer.play()
                
                //self.txtFieldNum.isHidden = false
                //self.txtFieldNum.delegate = self
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num4 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            /*
            // This is to audio output from bottom (main) speaker
            do {
                try self.audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                try self.audioSession.setActive(true)
                print("Successfully configured audio session (SPEAKER-Upper).", "\nCurrent audio route: ",self.audioSession.currentRoute.outputs)
            } catch let error as NSError {
                print("#configureAudioSessionToEarpieceSpeaker Error \(error.localizedDescription)")
            }
            */
            
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                //self.audioPlayer.volume = .greatestFiniteMagnitude
                self.audioPlayer.play()
                
                self.txtFieldSpeakerCode.isHidden = false
                //self.txtFieldNum.delegate = self
                
            } catch let error {
                print(error.localizedDescription)
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
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }*/
        
        if self.isComingFromTestResult {
            
            guard let didFinishRetryDiagnosis = self.speakerRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        else{
            
            guard let didFinishTestDiagnosis = self.speakerTestDiagnosis else { return }
            didFinishTestDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        
        
    }
    
    //MARK: TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.txtFieldSpeakerCode {
            // YOU SHOULD FIRST CHECK FOR THE BACKSPACE. IF BACKSPACE IS PRESSED ALLOW IT
            
            if string == "" {
                return true
            }
            
            if let characterCount = textField.text?.count {
                // CHECK FOR CHARACTER COUNT IN TEXT FIELD
                
                if characterCount > 0 {
                    // RESIGN FIRST RERSPONDER TO HIDE KEYBOARD
                    //return textField.resignFirstResponder()
                    
                    if self.txtFieldSpeakerCode.text == String(num1) + String(num2) {
                        self.resultJSON["Speakers"].int = 1
                        //self.resultJSON["Microphone"].int = 1
                        UserDefaults.standard.set(true, forKey: "Speakers")
                        
                        self.goNext()
                    }else {
                        self.resultJSON["Speakers"].int = 0
                        //self.resultJSON["Microphone"].int = 0
                        UserDefaults.standard.set(false, forKey: "Speakers")
                        
                        self.goNext()
                    }
                    
                }
            }
        }
            return true
            
    }
    
    func checkTest(completion: @escaping () -> Void) {
        
        guard let filePath = Bundle.main.path(forResource: "whistle", ofType: "mp3") else {
            return
        }
        
        do {
            
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            self.audioPlayer.play()

            let outputVol = AVAudioSession.sharedInstance().outputVolume
            
            if(outputVol > 0.36) {
                self.resultJSON["Speakers"].int = 1
                //self.resultJSON["Microphone"].int = 1
                //UserDefaults.standard.set(true, forKey: "Microphone")
                UserDefaults.standard.set(true, forKey: "Speakers")
                
                completion()
            }else{
                self.resultJSON["Speakers"].int = 0
                //self.resultJSON["Microphone"].int = 0
                //UserDefaults.standard.set(false, forKey: "Microphone")
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                completion()
            }
        } catch let error {
            self.resultJSON["Speakers"].int = 0
            //self.resultJSON["Microphone"].int = 0
            //UserDefaults.standard.set(false, forKey: "Microphone")
            UserDefaults.standard.set(false, forKey: "Speakers")
            
            print(error.localizedDescription)
            completion()
        }
        
    }
 
    func skipTest() {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        
        //let title = "Speaker Test".localized
        let title = "speakers_test".localized
        let message = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?".localized
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            
            self.resultJSON["Speakers"].int = -1
            UserDefaults.standard.set(false, forKey: "Speakers")
            
            /*
            if self.isComingFromTestResult {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                
                self.resultJSON["Speakers"].int = -1
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }else {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                
                self.resultJSON["Speakers"].int = -1
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }*/
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.speakerRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.speakerTestDiagnosis else { return }
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
                
                print("Speakers Skipped!")
                
                self.resultJSON["Speakers"].int = -1
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.speakerRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.speakerTestDiagnosis else { return }
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
    
}
