//
//  ScreenViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 11/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import PopupDialog
import SwiftyJSON
import AVKit

class ScreenViewController: UIViewController {
    
    var screenRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var screenTestDiagnosis: ((_ testJSON: JSON) -> Void)?

    @IBOutlet weak var startScreenBtn: UIButton!
    @IBOutlet weak var screenImageView: UIImageView!
    @IBOutlet weak var screenText: UILabel!
    //@IBOutlet weak var screenNavBar: UINavigationBar!
    var isComingFromTestResult = false
    
    var obstacleViews : [UIView] = []
    var flags: [Bool] = []
    var countdownTimer: Timer!
    var totalTime = 40
    var startTest = false
    var resultJSON = JSON()
    
    var recordingSession: AVAudioSession!
    
    var isTestPass = true
    
    @IBAction func beginScreenBtnClicked(_ sender: Any) {
        self.isTestPass = true
        
        self.drawScreenTest()
    }
    
    func drawScreenTest(){
        
        self.startScreenBtn.isHidden = true
        self.screenImageView.isHidden = true
        //screenNavBar.isHidden = true
        self.screenText.isHidden = true
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth:Int = Int(screenSize.width)
        let screenHeight:Int = Int(screenSize.height)
        let widthPerimeterImage:Int =  Int(screenWidth/9)
        let heightPerimeterImage:Int = Int((screenHeight)/14)
        
        var l = 0
        var t = 20
        
        for var _ in (0..<14).reversed()
        {
            for var _ in (0..<9).reversed()
            {
                let view = LevelView(frame: CGRect(x: l, y: t, width: widthPerimeterImage, height: heightPerimeterImage))
                l = l+widthPerimeterImage
                
                obstacleViews.append(view)
                flags.append(false)
                self.view.addSubview(view)
            }
            l=0
            t=t+heightPerimeterImage
        }
        startTest = true
        startTimer()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        DispatchQueue.main.async {
            //self.checkMicrophone()
        }
        
        //"Click 'Start Test', then swipe along the squares"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkMicrophone() {
        // Recording audio requires a user's permission to stop malicious apps doing malicious things, so we need to request recording permission from the user.
        
        self.recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //self.createRecorder()
                        
                        self.resultJSON["MIC"].int = 1
                        UserDefaults.standard.set(true, forKey: "mic")
                        
                    } else {
                        // failed to record!
                        //self.showaAlert(message: "failed to record!")
                        
                        self.resultJSON["MIC"].int = 0
                        UserDefaults.standard.set(false, forKey: "mic")
                    }
                }
            }
        } catch {
            // failed to record!
            //self.showaAlert(message: "failed to record!")
            
            self.resultJSON["MIC"].int = 0
            UserDefaults.standard.set(false, forKey: "mic")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        testTouches(touches: touches)
        
//        if let layer = self.view.layer.hitTest(point!) as? CAShapeLayer { // If you hit a layer and if its a Shapelayer
//            if CGPathContainsPoint(layer.path, nil, point, false) { // Optional, if you are inside its content path
//                println("Hit shapeLayer") // Do something
//            }
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent!) {
        testTouches(touches: touches)
    }

    
    
    func testTouches(touches: Set<UITouch>) {
        // Get the first touch and its location in this view controller's view coordinate system
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self.view)
        var finalFlag = true
        
        for (index,obstacleView) in obstacleViews.enumerated() {
            // Convert the location of the obstacle view to this view controller's view coordinate system
            let obstacleViewFrame = self.view.convert(obstacleView.frame, from: obstacleView.superview)
            
            // Check if the touch is inside the obstacle view
            if obstacleViewFrame.contains(touchLocation) {
                flags[index] = true
                let levelLayer = CAShapeLayer()
                levelLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                                   y: 0,
                                                                   width: obstacleViewFrame.width + 10,
                                                                   height: obstacleViewFrame.height),
                                               cornerRadius: 0).cgPath
                //levelLayer.fillColor = UIColor.init(hexString: "#05adef").cgColor
                levelLayer.fillColor = UIColor.init(hexString: "#05adef").cgColor
                
                obstacleView.layer.addSublayer(levelLayer)
                
            }
            finalFlag = flags[index]&&finalFlag
        }
        if finalFlag && startTest{
            endTimer(type: 1)
        }
    }
    
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer(type: 0)
        }
    }
    
    func endTimer(type: Int) {
        
        self.countdownTimer.invalidate()
        
        if type == 1 {
            
            if self.isTestPass {
                
                self.isTestPass = false
                
                
                UserDefaults.standard.set(true, forKey: "screen")
                resultJSON["Screen"].int = 1
                
                /*
                 if self.isComingFromTestResult {
                 
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
                 vc.resultJSON = self.resultJSON
                 vc.modalPresentationStyle = .fullScreen
                 self.present(vc, animated: true, completion: nil)
                 
                 }else {
                 //let vc = self.storyboard?.instantiateViewController(withIdentifier: "RotationVC") as! AutoRotationVC
                 
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrophoneVC") as! MicrophoneVC
                 vc.resultJSON = self.resultJSON
                 vc.modalPresentationStyle = .fullScreen
                 self.present(vc, animated: true, completion: nil)
                 }*/
                
                DispatchQueue.main.async {
                    self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.screenTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                
            }else {
                
            }
            
        }else{
            
            self.ShowGlobalPopUp()
            
            /*
             let title = "screen_failed_info".localized
             let message = "retry_test".localized
             
             
             // Create the dialog
             let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
             
             // Create buttons
             let buttonOne = DefaultButton(title: "Yes".localized) {
             popup.dismiss(animated: true, completion: nil)
             
             //let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenVC") as! ScreenViewController
             //vc.resultJSON = self.resultJSON
             //self.present(vc, animated: true, completion: nil)
             
             DispatchQueue.main.async {
             for v in self.obstacleViews{
             v.removeFromSuperview()
             }
             self.obstacleViews = []
             self.flags = []
             self.totalTime = 40
             self.startTest = false
             //self.resultJSON = JSON()
             //self.startScreenBtn.isHidden = false
             self.screenImageView.isHidden = false
             }
             
             }
             
             let buttonTwo = CancelButton(title: "No".localized) {
             //Do Nothing
             UserDefaults.standard.set(false, forKey: "screen")
             self.resultJSON["Screen"].int = 0
             
             /*
              if self.isComingFromTestResult {
              
              let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
              vc.resultJSON = self.resultJSON
              vc.modalPresentationStyle = .fullScreen
              self.present(vc, animated: true, completion: nil)
              
              }else {
              
              print("This screen not dismissed")
              //let vc = self.storyboard?.instantiateViewController(withIdentifier: "RotationVC") as! AutoRotationVC
              
              let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrophoneVC") as! MicrophoneVC
              vc.resultJSON = self.resultJSON
              vc.modalPresentationStyle = .fullScreen
              self.present(vc, animated: true, completion: nil)
              }*/
             
             if self.isComingFromTestResult {
             
             guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
             didFinishRetryDiagnosis(self.resultJSON)
             self.dismiss(animated: false, completion: nil)
             
             }
             else{
             
             guard let didFinishTestDiagnosis = self.screenTestDiagnosis else { return }
             didFinishTestDiagnosis(self.resultJSON)
             self.dismiss(animated: false, completion: nil)
             
             }
             
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
        
    }
    
    @IBAction func skipbuttonPressed(_ sender: UIButton) {
        
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
                
                print("Screen Skipped!")
                
                self.resultJSON["Screen"].int = -1
                UserDefaults.standard.set(false, forKey: "screen")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.screenTestDiagnosis else { return }
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
    
    func ShowGlobalPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Test Failed!"
        popUpVC.strMessage = "Do you want to retry the test?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("Screen Test Retry!")
                self.totalTime = 40
                
                self.startTest = true
                self.startTimer()
                
                /*
                self.startScreenBtn.isHidden = false
                
                DispatchQueue.main.async {
                    for v in self.obstacleViews{
                        v.removeFromSuperview()
                    }
                    self.obstacleViews = []
                    self.flags = []
                    self.totalTime = 40
                    self.startTest = false
                    //self.resultJSON = JSON()
                    //self.startScreenBtn.isHidden = false
                    self.screenImageView.isHidden = false
                }*/
                                                
            case 2:
                
                print("Screen Test Failed!")
                
                UserDefaults.standard.set(false, forKey: "screen")
                self.resultJSON["Screen"].int = 0
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.screenTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            default:
                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }

}

class LevelView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1.0
        let levelLayer = CAShapeLayer()
        levelLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                           y: 0,
                                                           width: frame.width,
                                                           height: frame.height),
                                       cornerRadius: 0).cgPath
        
        //levelLayer.fillColor = UIColor.white.cgColor
        levelLayer.fillColor = UIColor.gray.cgColor
        self.layer.addSublayer(levelLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Required, but Will not be called in a Playground")
    }
}


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

