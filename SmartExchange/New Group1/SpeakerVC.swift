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
    
    @IBOutlet weak var lblCheckingSpeaker: UILabel!
    @IBOutlet weak var lblPleaseEnsure: UILabel!
    
    @IBOutlet weak var txtFieldNum: UITextField!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    
    var resultJSON = JSON()
    var num1 = 0
    var num2 = 0
    var num3 = 0
    var num4 = 0
    
    var soundFiles = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    var audioPlayer: AVAudioPlayer!

    var isComingFromTestResult = false
    var isComingFromProductquote = false
    
    let audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        self.hideKeyboardWhenTappedAround()
        
        self.txtFieldNum.layer.cornerRadius = 20.0
        self.txtFieldNum.layer.borderWidth = 1.0
        self.txtFieldNum.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
                
        //self.setStatusBarColor()
        
        if isComingFromTestResult == false && isComingFromProductquote == false {
            //userDefaults.removeObject(forKey: "Speakers")
            //userDefaults.setValue(false, forKey: "Speakers")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //AppOrientationUtility.lockOrientation(.portrait)
        //self.changeLanguageOfUI()
    }

    func changeLanguageOfUI() {
  
        self.lblCheckingSpeaker.text = "Checking Speaker".localized
        self.lblPleaseEnsure.text = "Your phone will play some numbers out loud, and then type it in the text box provided.".localized
        
        self.btnStart.setTitle("Start".localized, for: UIControlState.normal)
        self.btnSkip.setTitle("Skip".localized, for: UIControlState.normal)
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
    
    //MARK:- button action methods
    @IBAction func onClickStart(sender: UIButton) {
        
        if sender.titleLabel?.text == "Start".localized {
            sender.setTitle("Submit".localized, for: .normal)
            
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
            
            guard !(self.txtFieldNum.text?.isEmpty ?? false) else {
                DispatchQueue.main.async() {
                    self.view.makeToast("Enter Number", duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if txtFieldNum.text == String(num1) + String(num2) + String(num3) + String(num4) {
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
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try audioSession.setActive(true)
            print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",audioSession.currentRoute.outputs)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num3 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            // This is to audio output from bottom (main) speaker
            do {
                try self.audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                try self.audioSession.setActive(true)
                print("Successfully configured audio session (SPEAKER-Upper).", "\nCurrent audio route: ",self.audioSession.currentRoute.outputs)
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
                
                self.txtFieldNum.isHidden = false
                //self.txtFieldNum.delegate = self
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    func goNext() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
        vc.resultJSON = self.resultJSON
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtFieldNum {
            // YOU SHOULD FIRST CHECK FOR THE BACKSPACE. IF BACKSPACE IS PRESSED ALLOW IT
            
            if string == "" {
                return true
            }
            
            if let characterCount = textField.text?.count {
                // CHECK FOR CHARACTER COUNT IN TEXT FIELD
                
                if characterCount > 0 {
                    // RESIGN FIRST RERSPONDER TO HIDE KEYBOARD
                    //return textField.resignFirstResponder()
                    
                    if txtFieldNum.text == String(num1) + String(num2) {
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
        
        // Prepare the popup assets
        
        //let title = "Speaker Test".localized
        let title = "speakers_test".localized
        let message = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?".localized
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {

            if self.isComingFromTestResult {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                
                self.resultJSON["Speakers"].int = -1
                //self.resultJSON["Microphone"].int = 0
                //UserDefaults.standard.set(false, forKey: "Microphone")
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
          
        }
        
        let buttonTwo = DefaultButton(title: "No".localized) {
            //Do Nothing
            self.btnStart.setTitle("Start".localized, for: .normal)
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
    }
    
}
