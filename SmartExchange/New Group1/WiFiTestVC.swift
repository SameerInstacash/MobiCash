//
//  WiFiTestVC.swift
//  InstaCash
//
//  Created by Sameer Khan on 10/04/21.
//  Copyright © 2021 Prakhar Gupta. All rights reserved.
//

import UIKit
import Luminous
import SwiftyJSON
import PopupDialog
//import SwiftSpinner
import JGProgressHUD

class WiFiTestVC: UIViewController {
    
    var wifiRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var wifiTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var btnStart: UIButton!
    //@IBOutlet weak var btnSkip: UIButton!
    
    @IBOutlet weak var lblTestWiFi: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    let hud = JGProgressHUD()
    var resultJSON = JSON()
    
    var isComingFromTestResult = false
    var iscomingFromHome = false
    var wifiTimer: Timer?
    var count = 0
    var isWiFiPass = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        //self.changeLanguageOfUI()
        
        //print("WiFi Signal strength is:", self.wifiStrength() ?? 0)
        //statusBarManager
    }
    
    private func wifiStrength() -> Int? {
        let app = UIApplication.shared
        var rssi: Int?
        guard let statusBar = app.value(forKey: "statusBar") as? UIView, let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else {
            return rssi
        }
        for view in foregroundView.subviews {
            if let statusBarDataNetworkItemView = NSClassFromString("UIStatusBarDataNetworkItemView"), view .isKind(of: statusBarDataNetworkItemView) {
                if let val = view.value(forKey: "wifiStrengthRaw") as? Int {
                    print("rssi: \(val)")

                    rssi = val
                    break
                }
            }
        }
        return rssi
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeLanguageOfUI() {
        
         self.lblTestWiFi.text = "Testing WiFi".localized
         self.lblDesc.text = "To test WIFI, turn WIFI on and connect to your preferred network then Press “START“".localized
        self.btnStart.setTitle("Start".localized, for: UIControlState.normal)
         
    }
    
    // MARK: Custom Methods
    
    @objc func runTimedCode() {
        
        self.count += 1
        
        //DispatchQueue.main.async {
            //SwiftSpinner.show(progress: Double(self.count)*0.25, title: "Checking WiFi...".localized)
            //SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
        
            self.hud.textLabel.text = "Checking WiFi...".localized
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.indicatorView = JGProgressHUDRingIndicatorView()
            self.hud.progress = Float(self.count)*0.25
            self.hud.show(in: self.view)
        //}
        
        if Luminous.System.Network.isConnectedViaWiFi {
            
            self.resultJSON["WIFI"].int = 1
            UserDefaults.standard.setValue(true, forKey: "WIFI")
            
            self.isWiFiPass = true
        }
        else{
            self.resultJSON["WIFI"].int = 0
            UserDefaults.standard.setValue(false, forKey: "WIFI")
            
            self.isWiFiPass = false
        }
        
        if count > 3 {
            
            DispatchQueue.main.async {
                //SwiftSpinner.hide()
                self.hud.dismiss()
            }
            
            UserDefaults.standard.setValue(true, forKey: "WIFI_complete")
            
            self.wifiTimer?.invalidate()
            
            self.navigateToBackgroundTestScreen()
        }
        
    }
    
    func navigateToBackgroundTestScreen() {
        
        /*
        if self.isComingFromTestResult {

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        else{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
            vc.resultJSON = self.resultJSON
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
           
        }*/
        
        if self.isWiFiPass {
            
            DispatchQueue.main.async {
                self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.wifiRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.wifiTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
            
            }
            
        }else {
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.wifiRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.wifiTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            
        }
        
        
    }
    
    // MARK: IBActions
    @IBAction func btnStartWiFiTestClicked(_ sender: UIButton) {
      
        self.wifiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    
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
                
                print("WIFI Skipped!")
                                
                UserDefaults.standard.setValue(false, forKey: "WIFI")
                self.resultJSON["WIFI"].int = -1
             
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.wifiRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.wifiTestDiagnosis else { return }
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
