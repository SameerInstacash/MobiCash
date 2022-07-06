//
//  Q3ViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 24/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class Q3ViewController: UIViewController {

    
    @IBOutlet weak var ans1view: UILabel!
    @IBOutlet weak var ans2view: UILabel!
    var obstacleViews : [UILabel] = []
    var appCodes: [String] = []
    var appCodeStr: String = ""
    var resultJSON = JSON()
    var ans1selected = false
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        for appCode in appCodes {
            appCodeStr = "\(appCodeStr);\(appCode)"
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q4VC") as! Q4ViewController
        vc.appCodeStr = self.appCodeStr
        vc.resultJSON = self.resultJSON
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        obstacleViews.append(ans1view)
        obstacleViews.append(ans2view)
        
        /*
        if(!UserDefaults.standard.bool(forKey: "camera")){
            appCodeStr = "\(appCodeStr);CISS01"
        }
        if(!UserDefaults.standard.bool(forKey: "volume")){
            appCodeStr = "\(appCodeStr);CISS02;CISS03"
        }
        if(!UserDefaults.standard.bool(forKey: "connection")){
            appCodeStr = "\(appCodeStr);CISS04"
        }
        if(!UserDefaults.standard.bool(forKey: "charger")){
            appCodeStr = "\(appCodeStr);CISS05"
        }
        if(!UserDefaults.standard.bool(forKey: "earphone")){
            appCodeStr = "\(appCodeStr);CISS11"
        }
        if(!UserDefaults.standard.bool(forKey: "fingerprint")){
            appCodeStr = "\(appCodeStr);CISS12"
        }
        */
        
        
        
        
        if(!UserDefaults.standard.bool(forKey: "camera")){
            self.appCodeStr = "\(self.appCodeStr);CISS01"
        }
        if(!UserDefaults.standard.bool(forKey: "volume")){
            self.appCodeStr = "\(self.appCodeStr);CISS02;CISS03"
        }
        if(!UserDefaults.standard.bool(forKey: "connection")){
            self.appCodeStr = "\(self.appCodeStr);CISS04"
        }
        if(!UserDefaults.standard.bool(forKey: "charger")){
            self.appCodeStr = "\(self.appCodeStr);CISS05"
        }
        if(!UserDefaults.standard.bool(forKey: "earphone")){
            self.appCodeStr = "\(self.appCodeStr);CISS11"
        }
        if(!UserDefaults.standard.bool(forKey: "fingerprint")){
            self.appCodeStr = "\(self.appCodeStr);CISS12"
        }
        if(!UserDefaults.standard.bool(forKey: "mic")){
            self.appCodeStr = "\(self.appCodeStr);CISS08"
        }
        if(!UserDefaults.standard.bool(forKey: "Speakers")){
            self.appCodeStr = "\(self.appCodeStr);CISS07"
        }
        if(!UserDefaults.standard.bool(forKey: "rotation")){
            self.appCodeStr = "\(self.appCodeStr);CISS14"
        }
        if(!UserDefaults.standard.bool(forKey: "proximity")){
            self.appCodeStr = "\(self.appCodeStr);CISS15"
        }
        /*
        if(!UserDefaults.standard.bool(forKey: "NFC")){
            self.appCodeStr = "\(self.appCodeStr);CISS04"
        }*/
        if(!UserDefaults.standard.bool(forKey: "Vibrator")){
            self.appCodeStr = "\(self.appCodeStr);CISS13"
        }
        if(!UserDefaults.standard.bool(forKey: "GSM")) {
            self.appCodeStr = "\(self.appCodeStr);CISS10"
        }
        if(!UserDefaults.standard.bool(forKey: "Bluetooth")) {
            self.appCodeStr = "\(self.appCodeStr);CISS04"
        }
        if(!UserDefaults.standard.bool(forKey: "GPS")) {
            self.appCodeStr = "\(self.appCodeStr);CISS04"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        testTouches(touches: touches)
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
                switch index{
                case 0:
                    if !ans1selected{
                        appCodes.append("CIFA01")
                        ans1view.backgroundColor = UIColor(hexString: "#1eba5c")
                        ans1selected = true
                    }else{
                        if let index = appCodes.index(where: {$0 == "CIFA01"}) {
                            appCodes.remove(at: index)
                        }
                        ans1view.backgroundColor = UIColor.groupTableViewBackground
                        ans1selected = false
                    }
                case 1:
                    if let index = appCodes.index(where: {$0 == "CIFA01"}) {
                        appCodes.remove(at: index)
                    }
                    ans1view.backgroundColor = UIColor.groupTableViewBackground
                    ans1selected = false
                    ans2view.backgroundColor = UIColor(hexString: "#1eba5c")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // change 2 to desired number of
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q4VC") as! Q4ViewController
                        vc.appCodeStr = self.appCodeStr
                        vc.resultJSON = self.resultJSON
                        self.present(vc, animated: true, completion: nil)
                    }
                default:
                    if !ans1selected{
                        appCodes.append("CIFA01")
                        ans1view.backgroundColor = UIColor(hexString: "#1eba5c")
                        ans1selected = true
                    }else{
                        if let index = appCodes.index(where: {$0 == "CIFA01"}) {
                            appCodes.remove(at: index)
                        }
                        ans1view.backgroundColor = UIColor.groupTableViewBackground
                        ans1selected = false
                    }
                }
                
            }
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
    
}

