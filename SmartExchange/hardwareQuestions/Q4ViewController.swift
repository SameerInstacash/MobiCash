//
//  Q4ViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 24/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class Q4ViewController: UIViewController {

    
    
    @IBOutlet weak var ans1view: UILabel!
    @IBOutlet weak var ans2view: UILabel!
    @IBOutlet weak var ans3view: UILabel!
    
    var obstacleViews : [UILabel] = []
    var appCodeStr: String = ""
    var resultJSON = JSON()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        obstacleViews.append(ans1view)
        obstacleViews.append(ans2view)
        obstacleViews.append(ans3view)
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
                    if(!appCodeStr.contains("CAGE01")){
                            appCodeStr = "\(appCodeStr);CAGE01"
                    }
                    
                    ans1view.backgroundColor = UIColor(hexString: "#1eba5c")
                case 1:
                    if(!appCodeStr.contains("CAGE02")){
                        appCodeStr = "\(appCodeStr);CAGE02"
                    }
                    ans2view.backgroundColor = UIColor(hexString: "#1eba5c")
                case 2:
                    if(!appCodeStr.contains("CAGE05")){
                        appCodeStr = "\(appCodeStr);CAGE05"
                    }
                    ans3view.backgroundColor = UIColor(hexString: "#1eba5c")
                default:
                    if(!appCodeStr.contains("CAGE05")){
                        appCodeStr = "\(appCodeStr);CAGE05"
                    }
                    ans3view.backgroundColor = UIColor(hexString: "#1eba5c")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // change 2 to desired number of
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q5VC") as! Q5ViewController
                    vc.appCodeStr = self.appCodeStr
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
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



