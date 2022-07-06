//
//  FirstQViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 24/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class FirstQViewController: UIViewController {

    @IBOutlet weak var ans1view: UIButton!
    @IBOutlet weak var ans2view: UIButton!
    @IBOutlet weak var ans3view: UIButton!
    @IBOutlet weak var ans4view: UIButton!
    @IBOutlet weak var ans5view: UIButton!
    
    @IBOutlet weak var questNameView: UILabel!

    var appCodeStr = "STON01;"
    var isBrk = false
    var resultJSON = JSON()
    var endPoint = "http://exchange.getinstacash.in/stores-asia/api/v1/public/"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        isBrk = UserDefaults.standard.bool(forKey: "deadPixel") && UserDefaults.standard.bool(forKey: "screen")
        self.endPoint = UserDefaults.standard.string(forKey: "endpoint")!
        if (self.endPoint.range(of:"store-asia") != nil) || self.endPoint.range(of:"stores-asia") != nil || self.endPoint.range(of:"asurionre") != nil || self.endPoint.range(of:"seatest") != nil{
            self.questNameView.text = "lcd".localized
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func ans1clicked(_ sender: Any) {
        if(!isBrk){
            
            if(!appCodeStr.contains("SBRK01")){
                print("SBRK01")
                appCodeStr = "\(appCodeStr)SBRK01"
                UserDefaults.standard.set("Not_Working".localized, forKey: "lcd")
            }
        }else{
            if(!appCodeStr.contains("SPTS01")){
                print("SPTS01")
                appCodeStr = "\(appCodeStr)SPTS01"
                UserDefaults.standard.set("flawless".localized, forKey: "lcd")
            }
        }
        self.ans1view.backgroundColor = UIColor(hexString: "#05adef")
        finishButtonClicks()
    }
    
    @IBAction func ans2Clicked(_ sender: Any) {
        if(!isBrk){
            if(!appCodeStr.contains("SBRK01")){
                print("SBRK01")
                appCodeStr = "\(appCodeStr)SBRK01"
                UserDefaults.standard.set("Not_Working".localized, forKey: "lcd")
            }
        }else{
            if(!appCodeStr.contains("SPTS02")){
                print("SPTS02")
                appCodeStr = "\(appCodeStr)SPTS02"
                UserDefaults.standard.set("Minor_Scratches".localized, forKey: "lcd")
            }
        }
        ans2view.backgroundColor = UIColor(hexString: "#05adef")
        finishButtonClicks()
    }
    
    @IBAction func ans3Clicked(_ sender: Any) {
        if(!isBrk){
            if(!appCodeStr.contains("SBRK01")){
                print("SBRK01")
                appCodeStr = "\(appCodeStr)SBRK01"
                UserDefaults.standard.set("Not_Working".localized, forKey: "lcd")
            }
        }else{
            if(!appCodeStr.contains("SPTS03")){
                print("SPTS03")
                appCodeStr = "\(appCodeStr)SPTS03"
                UserDefaults.standard.set("Heavily_Scratched".localized, forKey: "lcd")
            }
        }
        ans3view.backgroundColor = UIColor(hexString: "#05adef")
        finishButtonClicks()
    }
    
    @IBAction func ans4clicked(_ sender: Any) {
        if(!appCodeStr.contains("SBRK01")){
            print("SBRK01")
            appCodeStr = "\(appCodeStr)SBRK01"
            UserDefaults.standard.set("Not_Working".localized, forKey: "lcd")
        }
        ans4view.backgroundColor = UIColor(hexString: "#05adef")
        finishButtonClicks()
    }
    
    
    @IBAction func ans5Clicked(_ sender: Any) {
        if(!isBrk){
            if(!appCodeStr.contains("SBRK01")) {
                print("SBRK01")
                appCodeStr = "\(appCodeStr)SBRK01"
                UserDefaults.standard.set("Not_Working".localized, forKey: "lcd")
            }
        }else{
            if(!appCodeStr.contains("SPTS04")){
                print("SPTS04")
                appCodeStr = "\(appCodeStr)SPTS04"
                UserDefaults.standard.set("cracked".localized, forKey: "lcd")
            }
        }
        ans5view.backgroundColor = UIColor(hexString: "#05adef")
        finishButtonClicks()
    }
    
    func finishButtonClicks(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { //
            
            
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
            

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q4oVC") as! Q4optViewController
            vc.appCodeStr = self.appCodeStr
            print("Result JSON 1: \(self.resultJSON)")
            vc.resultJSON = self.resultJSON
            self.present(vc, animated: true, completion: nil)
           
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

