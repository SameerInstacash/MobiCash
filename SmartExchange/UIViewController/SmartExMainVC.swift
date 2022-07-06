//
//  SmartExMainVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 16/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import Luminous

class SmartExMainVC: UIViewController {

    var stringPassed = Data()
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productMAxPrice: UILabel!
    
    
    var productName = ""
    var productImage = ""
    var productPrice = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        let device = Luminous.System.Hardware.Device.current
        productNameLabel.text = self.productName
        productMAxPrice.text = "₹ \(self.productPrice)"
        
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
