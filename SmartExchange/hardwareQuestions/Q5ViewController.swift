//
//  Q5ViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 24/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class Q5ViewController: UIViewController {

    
    @IBOutlet weak var ans1view: UIButton!
    @IBOutlet weak var ans2view: UIButton!
    @IBOutlet weak var ans3view: UIButton!
    @IBOutlet weak var ans4view: UIButton!
    @IBOutlet weak var ans5view: UIButton!
        
    @IBOutlet weak var questNameView: UILabel!

    var appCodeStr: String = ""
    var resultJSON = JSON()
    var endPoint = "http://exchange.getinstacash.in/stores-asia/api/v1/public/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.endPoint = UserDefaults.standard.string(forKey: "endpoint")!
        if self.endPoint.range(of:"store-asia") != nil || self.endPoint.range(of:"stores-asia") != nil || self.endPoint.range(of:"asurionre") != nil || self.endPoint.range(of:"seatest") != nil{
            self.questNameView.text = "cpbp_info".localized
        }
        UserDefaults.standard.removeObject(forKey:"back")
        UserDefaults.standard.synchronize()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func backBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q4oVC") as! Q4optViewController
        var appCodeTemp = appCodeStr.components(separatedBy: ";")
        print("AppCodeTempL: \(appCodeTemp[0]); AppCodeStr: \(appCodeStr)")
        vc.appCodeStr = "\(appCodeTemp[0]);\(appCodeTemp[1])"
        vc.resultJSON = self.resultJSON
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func ans1Clicked(_ sender: Any) {
        if(!appCodeStr.contains("CPBP01")){
            appCodeStr = "\(appCodeStr);CPBP01"
        }
        UserDefaults.standard.set("Flawless", forKey: "back")
        ans1view.backgroundColor = UIColor(hexString: "#05adef")
        finaliseButtonClickes()
    }
    
    @IBAction func ans2Clicked(_ sender: Any) {
        if(!appCodeStr.contains("CPBP02")){
            appCodeStr = "\(appCodeStr);CPBP02"
        }
        UserDefaults.standard.set("2-3 Minor Scratches", forKey: "back")
        ans2view.backgroundColor = UIColor(hexString: "#05adef")
        finaliseButtonClickes()
    }
    
    @IBAction func ans3Clicked(_ sender: Any) {
        if(!appCodeStr.contains("CPBP03")){
               appCodeStr = "\(appCodeStr);CPBP03"
           }
           UserDefaults.standard.set(ans3view.currentTitle, forKey: "back")
           ans3view.backgroundColor = UIColor(hexString: "#05adef")
        finaliseButtonClickes()
    }
    
    @IBAction func ans4Clicked(_ sender: Any) {
        if(!appCodeStr.contains("CPBP05")){
            appCodeStr = "\(appCodeStr);CPBP05"
        }
        UserDefaults.standard.set(ans4view.currentTitle, forKey: "back")
        ans4view.backgroundColor = UIColor(hexString: "#05adef")
        finaliseButtonClickes()
    }
    
    @IBAction func ans5Clicked(_ sender: Any) {
        if(!appCodeStr.contains("CPBP04")){
            appCodeStr = "\(appCodeStr);CPBP04"
        }
        UserDefaults.standard.set(ans5view.currentTitle, forKey: "back")
        ans5view.backgroundColor = UIColor(hexString: "#05adef")
        finaliseButtonClickes()
    }
 
    func finaliseButtonClickes(){
        UserDefaults.standard.synchronize()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.endPoint = UserDefaults.standard.string(forKey: "endpoint")!
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserVC") as! UserDetailsViewController
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsVC") as! UserDetailsVC
            vc.appCodeStr = self.appCodeStr
            print("Result JSON 3: \(self.resultJSON)")
            vc.resultJOSN = self.resultJSON
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




