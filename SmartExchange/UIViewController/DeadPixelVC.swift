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

    @IBOutlet weak var startTestBtn: UIButton!
    @IBOutlet weak var deadPixelInfoImage: UIImageView!
    @IBOutlet weak var deadPixelInfo: UILabel!
    @IBOutlet weak var deadPixelNavBar: UINavigationBar!
    
    var timer: Timer?
    var timerIndex = 0
    var resultJSON = JSON()
    var audioPlayer = AVAudioPlayer()
    
    var isComingFromTestResult = false
    
    let audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        deadPixelInfoImage.loadGif(name: "dead_pixel")

        //self.checkMicrophone()
        //self.checkVibrator()
        //self.playSound()
        
        DispatchQueue.main.async {
            self.configureAudioSessionCategory()
            self.playSound()
        }
           
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkVibrator()
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func setRandomBackgroundColor() {
        timerIndex += 1
        let colors = [
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        ]
        switch timerIndex {
        case 5:
            self.view.backgroundColor = colors[0]
            timer?.invalidate()
            timer = nil
            
            
            // Prepare the popup assets
            let title = "Dead_Pixel_Test".localized
            let message = "dead_pixel_msg".localized
            
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: "Yes".localized) {
                self.resultJSON["Dead Pixels"].int = 0
                UserDefaults.standard.set(false, forKey: "deadPixel")
                print("Dead Pixel Failed!")
                
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenVC") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
            
            let buttonTwo = DefaultButton(title: "No".localized) {
                self.resultJSON["Dead Pixels"].int = 1
                UserDefaults.standard.set(true, forKey: "deadPixel")
                print("Dead Pixel Passed!")
                
                if self.isComingFromTestResult {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenVC") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
            
            let buttonThree = DefaultButton(title: "retry".localized) {
                self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
                self.view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.startTestBtn.isHidden = true
                self.deadPixelInfo.isHidden = true
                self.deadPixelInfoImage.isHidden = true
                self.timerIndex = 0
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
            break
            
        default:
            self.view.backgroundColor = colors[0]
        }
        
    }
   
    
    @IBAction func startDeadPixelTest(_ sender: AnyObject) {
//        checkVibrator()
//        playSound()
                
        self.deadPixelNavBar.isHidden = true
        
        // Sameer
        //self.resultJSON["Speakers"].int = 1
        //self.resultJSON["MIC"].int = 1
        //UserDefaults.standard.set(true, forKey: "mic")
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
        self.view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.startTestBtn.isHidden = true
        self.deadPixelInfo.isHidden = true
        self.deadPixelInfoImage.isHidden = true
        
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
