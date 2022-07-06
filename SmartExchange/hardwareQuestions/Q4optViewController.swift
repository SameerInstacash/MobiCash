//
//  Q4optViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 05/08/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class Q4optViewController: UIViewController {

    @IBOutlet weak var ansView1: UILabel!
    @IBOutlet weak var ansView2: UILabel!
    
    
    
    
    var obstacleViews : [UILabel] = []
    var appCodeStr: String = ""
    var resultJSON = JSON()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        obstacleViews.append(ansView1)
        obstacleViews.append(ansView2)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q1VC") as! FirstQViewController
        //                vc.questionsString = data
        vc.resultJSON = self.resultJSON
        self.present(vc, animated: true, completion: nil)
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
                    if(!appCodeStr.contains("CLOK01")){
                        appCodeStr = "\(appCodeStr);CLOK01"
                        UserDefaults.standard.set(ansView1.text, forKey: "lock")
                    }
                    ansView1.backgroundColor = UIColor(hexString: "#05adef")
                case 1:
                    if(!appCodeStr.contains("CLOK02")){
                        appCodeStr = "\(appCodeStr);CLOK02"
                        UserDefaults.standard.set(ansView2.text, forKey: "lock")
                    }
                    ansView2.backgroundColor = UIColor(hexString: "#05adef")
                default:
                    if(!appCodeStr.contains("CLOK01")){
                        appCodeStr = "\(appCodeStr);CLOK01"
                        UserDefaults.standard.set(ansView1.text, forKey: "lock")
                    }
                    ansView1.backgroundColor = UIColor(hexString: "#05adef")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // change 2 to desired number of
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q5VC") as! Q5ViewController
                    vc.appCodeStr = self.appCodeStr
                    print("Result JSON 2: \(self.resultJSON)")
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
