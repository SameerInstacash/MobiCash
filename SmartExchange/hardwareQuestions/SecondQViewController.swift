//
//  SecondQViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 24/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class SecondQViewController: UIViewController {

    @IBOutlet weak var ans1view: UILabel!
    @IBOutlet weak var ans3view: UILabel!
    @IBOutlet weak var ans2view: UILabel!
    @IBOutlet weak var ans4view: UILabel!
    var obstacleViews : [UILabel] = []
    var appCodes: [String] = []
    var appCodeStr: String = ""
    var resultJSON = JSON()
    
    var ans1selected = false
    var ans2selected = false
    var ans3selected = false
    
    @IBAction func nextBtn(_ sender: Any) {
        for appCode in appCodes {
            appCodeStr = "\(appCodeStr);\(appCode)"
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q3VC") as! Q3ViewController
        vc.appCodeStr = self.appCodeStr
        vc.resultJSON = self.resultJSON
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        obstacleViews.append(ans1view)
        obstacleViews.append(ans2view)
        obstacleViews.append(ans3view)
        obstacleViews.append(ans4view)
        // Do any additional setup after loading the view.
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
                    appCodes.append("CACC01")
                    ans1view.backgroundColor = UIColor(hexString: "#1eba5c")
                        ans1selected = true
                    }else{
                        if let index = appCodes.index(where: {$0 == "CACC01"}) {
                            appCodes.remove(at: index)
                        }
                        ans1view.backgroundColor = UIColor.groupTableViewBackground
                        ans1selected = false
                    }
                case 1:
                    if !ans2selected{
                        appCodes.append("CACC02")
                        ans2view.backgroundColor = UIColor(hexString: "#1eba5c")
                        ans2selected = true
                    }else{
                        if let index = appCodes.index(where: {$0 == "CACC02"}) {
                            appCodes.remove(at: index)
                        }
                        ans2view.backgroundColor = UIColor.groupTableViewBackground
                        ans2selected = false
                    }
                case 2:
                    if !ans3selected{
                        appCodes.append("CACC03")
                        ans3view.backgroundColor = UIColor(hexString: "#1eba5c")
                        ans3selected = true
                    }else{
                        if let index = appCodes.index(where: {$0 == "CACC03"}) {
                            appCodes.remove(at: index)
                        }
                        ans3view.backgroundColor = UIColor.groupTableViewBackground
                        ans3selected = false
                    }
                case 3:
                    if let index = appCodes.index(where: {$0 == "CACC01"}) {
                        appCodes.remove(at: index)
                    }
                    ans1view.backgroundColor = UIColor.groupTableViewBackground
                    ans1selected = false
                    if let index = appCodes.index(where: {$0 == "CACC02"}) {
                        appCodes.remove(at: index)
                    }
                    ans2view.backgroundColor = UIColor.groupTableViewBackground
                    ans2selected = false
                    if let index = appCodes.index(where: {$0 == "CACC03"}) {
                        appCodes.remove(at: index)
                    }
                    ans3view.backgroundColor = UIColor.groupTableViewBackground
                    ans3selected = false
                    ans4view.backgroundColor = UIColor(hexString: "#1eba5c")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // change 2 to desired number of
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q3VC") as! Q3ViewController
                        vc.appCodeStr = self.appCodeStr
                        self.present(vc, animated: true, completion: nil)
                    }
                default:
                    if !ans1selected{
                        appCodes.append("CACC01")
                        ans1view.backgroundColor = UIColor(hexString: "#1eba5c")
                        ans1selected = true
                    }else{
                        if let index = appCodes.index(where: {$0 == "CACC01"}) {
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


