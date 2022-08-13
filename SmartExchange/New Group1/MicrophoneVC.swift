//
//  MicrophoneVC.swift
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
import SwiftGifOrigin

class MicrophoneVC: UIViewController, AVAudioRecorderDelegate, RecorderDelegate {
    
    var micRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var micTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    //@IBOutlet weak var lblCheckingMicrophone: UILabel!
    @IBOutlet weak var lblPleaseEnsure: UILabel!
    @IBOutlet weak var lblTimerCount: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var speechImgView: UIImageView!

    var resultJSON = JSON()
    var gameTimer: Timer?
    var runCount = 0
    
    var isComingFromTestResult = false
    var isComingFromProductquote = false
    
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder!
    
    var recording: Recording!
    var recordDuration = 0
    var isBitRate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        self.hideKeyboardWhenTappedAround()

        //self.setStatusBarColor()
        
        if isComingFromTestResult == false && isComingFromProductquote == false {
            //userDefaults.removeObject(forKey: "Microphone")
            //userDefaults.setValue(false, forKey: "Microphone")
        }
        
        // Recording audio requires a user's permission to stop malicious apps doing malicious things, so we need to request recording permission from the user.
        
        self.recordingSession = AVAudioSession.sharedInstance()

        do {
            try self.recordingSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.recordingSession?.setActive(true)
            
            self.recordingSession?.requestRecordPermission() { [unowned self] allowed in
                
                if allowed {
                    //self.loadRecordingUI()
                    
                    //self.btnStart.isHidden = false
                    
                    DispatchQueue.main.async {
                        self.createRecorder()
                    }
                    
                } else {
                    // failed to record!
                    DispatchQueue.main.async() {
                        self.view.makeToast("failed to record!", duration: 2.0, position: .bottom)
                    }
                    
                }
                
            }
        } catch {
            // failed to record!
            DispatchQueue.main.async() {
                self.view.makeToast("failed to record!", duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //AppOrientationUtility.lockOrientation(.portrait)
        //self.changeLanguageOfUI()
        
        // Earphones plugged in. Please remove the Earphones and click on the start button below to start the test
    }

    func changeLanguageOfUI() {
  
        //self.lblCheckingMicrophone.text = "Checking Microphone"
        self.lblPleaseEnsure.text = "Click to start button. after that microphone will listen your voice for 4 seconds to check your microphone is working or not"
        
        self.btnStart.setTitle("Start Test".localized, for: UIControlState.normal)
        self.btnSkip.setTitle("Skip".localized, for: UIControlState.normal)
    }
    
    open func createRecorder() {
        self.recording = Recording(to: "recording.m4a")
        self.recording.delegate = self
        
        // Optionally, you can prepare the recording in the background to
        // make it start recording faster when you hit `record()`.
        
        DispatchQueue.global().async {
            // Background thread
            do {
                try self.recording.prepare()
            } catch {
                
            }
        }
    }
    
    open func startRecording(url: URL) {
        recordDuration = 0
        do {
            Timer.scheduledTimer(timeInterval: 4,
                                 target: self,
                                 selector: #selector(self.stopRecording),
                                 userInfo: nil,
                                 repeats: false)
            
            try recording.record()
            //self.playUsingAVAudioPlayer(url: url)
        } catch {
            
        }
    }
    
    @objc func stopRecording() {
        self.gameTimer = nil
        self.gameTimer?.invalidate()
        
        self.recordDuration = 0
        self.recording.stop()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.isBitRate {
                self.finishRecording(success: self.isBitRate)
            }else {
                self.finishRecording(success: self.isBitRate)
            }
        }
        
    
        
        /*
        do {
            //try recording.play()
        } catch {
            
        }*/
    }
        
    func audioMeterDidUpdate(_ db: Float) {
        self.recording.recorder?.updateMeters()
        let ALPHA = 0.05
        let peakPower = pow(10, (ALPHA * Double((self.recording.recorder?.peakPower(forChannel: 0))!)))
        var rate: Double = 0.0
        if (peakPower <= 0.2) {
            rate = 0.2
        } else if (peakPower > 0.9) {
            rate = 1.0
            self.isBitRate = true
        } else {
            rate = peakPower
        }
        
        print(rate)
        self.recordDuration += 1
    }

    //MARK: button action methods
    @IBAction func onClickStart(sender: UIButton) {
        
        if sender.titleLabel?.text == "Start Test".localized {
            //sender.setTitle("SKIP", for: .normal)
            //self.startTest()
            
            //sender.isHidden = true
            //self.speechImgView.isHidden = false
            //self.speechImgView.loadGif(name: "speech")
            
            
            /*
            // Load GIF In Image view
            let jeremyGif = UIImage.gifImageWithName("speech")
            self.speechImgView.image = jeremyGif
            self.speechImgView.stopAnimating()
            self.speechImgView.startAnimating()
            */
            
            sender.isHidden = true
            self.lblTimerCount.text = "4"
            
            //Run Timer for 4 Seconds to record the audio
            self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runTimerForReverseCounter), userInfo: nil, repeats: true)
            
            
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            self.startRecording(url: audioFilename)
            
        }else {
            self.skipTest()
        }
    
    }
    
    @IBAction func onClickSkip(sender: UIButton) {
        self.skipTest()
    }
    
    @IBAction func onClickRetry(sender: UIButton) {
        
    }
    
    @objc func runTimerForReverseCounter() {
        self.runCount += 1
        
        if self.runCount <= 4 {
            self.lblTimerCount.text = "\(4 - self.runCount)"
        }else {
            
        }
        
    }
    
    func startTest() {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: false)
        }
        
        //Run Timer for 4 Seconds to record the audio
        self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        self.runCount += 1
        
        if self.runCount > 4 {
            self.finishRecording(success: self.isBitRate)
        }
    }
    
    func finishRecording(success: Bool) {
        //audioRecorder.stop()
        self.audioRecorder = nil
        
        self.gameTimer?.invalidate()
        self.recording.recorder?.deleteRecording()

        if success {
            
            self.resultJSON["MIC"].int = 1
            UserDefaults.standard.set(true, forKey: "mic")
            
            DispatchQueue.main.async {
                self.view.makeToast("Test Passed!", duration: 2.0, position: .bottom)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                
                self.goNext()
                
            }
            
        } else {
            
            self.resultJSON["MIC"].int = 0
            UserDefaults.standard.set(false, forKey: "mic")
            
            self.goNext()
            
        }
        
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func goNext() {
                
        /*
        if self.isComingFromTestResult {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }else {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }*/
        
        if self.isComingFromTestResult {
            
            guard let didFinishRetryDiagnosis = self.micRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        else{
            
            guard let didFinishTestDiagnosis = self.micTestDiagnosis else { return }
            didFinishTestDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        
        
    }
    
    func skipTest() {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        
        //let title = "Microphone Test".localized
        let title = "mic_test".localized
        let message = "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?".localized
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Yes".localized) {
            
            self.resultJSON["MIC"].int = -1
            UserDefaults.standard.set(false, forKey: "mic")
                
            /*
            if self.isComingFromTestResult {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                
                self.resultJSON["MIC"].int = -1
                UserDefaults.standard.set(false, forKey: "mic")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }else {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                
                self.resultJSON["MIC"].int = -1
                UserDefaults.standard.set(false, forKey: "mic")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }*/
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.micRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.micTestDiagnosis else { return }
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
                
                print("Mic Skipped!")
                
                self.resultJSON["MIC"].int = -1
                UserDefaults.standard.set(false, forKey: "mic")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.micRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.micTestDiagnosis else { return }
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

