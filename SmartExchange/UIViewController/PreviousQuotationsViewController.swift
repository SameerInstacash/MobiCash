//
//  PreviousQuotationsViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 02/08/19.
//  Copyright © 2019 ZeroWaste. All rights reserved.
//

import UIKit
//import SwiftSpinner
import SwiftyJSON
import JGProgressHUD

class PreviousQuotationsViewController: UIViewController {

    @IBOutlet weak var referenceNumText: UITextField!
    @IBOutlet weak var submitBtnPrev: UIButton!
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var secondStack: UIStackView!
    @IBOutlet weak var refId: UILabel!
    @IBOutlet weak var prefTime: UILabel!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var mobText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var tableView: UILabel!
    var ref = ""
    var endPoint = ""
    @IBOutlet weak var smartExLoadingImage: UIImageView!
    
    let hud = JGProgressHUD()
    
    @IBAction func homeBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
        
        let imei = UserDefaults.standard.string(forKey: "imei_number")
        vc.IMEINumber = imei ?? ""
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        ref = referenceNumText.text ?? "0"
        if (ref.length ?? 0 > 1)  {
            //smartExLoadingImage.isHidden = false
            //smartExLoadingImage.rotate360Degrees()
            
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            modAPI()
        }
    }
    
    
    func modAPI()
    {
        //self.endPoint = "https://exchange.buyblynk.com/api/v1/public/" // Blynk
       
        
        self.endPoint = AppBaseUrl
        
        var request = URLRequest(url: URL(string: "\(endPoint)/getSessionIdbyIMEI")!)
        request.httpMethod = "POST"
        let preferences = UserDefaults.standard
        //        let postString = "productId=\(productId!)&customerId=\(customerId!)&userName=planetm&apiKey=fd9a42ed13c8b8a27b5ead10d054caaf"
        var postString = ""
        let imei = UserDefaults.standard.string(forKey: "imei_number")
        
        postString = "IMEINumber=\(imei!)&quotationId=\(ref)&userName=planetm&apiKey=fd9a42ed13c8b8a27b5ead10d054caaf"
        request.httpBody = postString.data(using: .utf8)
        
        print("url is :",request,"\nParam is :",postString)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                /*
                // check for fundamental networking error
                print("error=\(error.debugDescription)")
                
                DispatchQueue.main.async() {
                    //self.smartExLoadingImage.layer.removeAllAnimations()
                    //self.smartExLoadingImage.isHidden = true
                    
                    self.hud.dismiss()
                }
                
                DispatchQueue.main.async {
                    self.view.makeToast("internet_prompt".localized, duration: 2.0, position: .bottom)
                }*/
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    
                    print(json)
                    DispatchQueue.main.async() {
                        let msg = json["msg"]
                        let id = msg["id"].string ?? ""
                        let name = msg["name"].string ?? ""
                        let mobileNumber = msg["mobileNumber"].string ?? ""
                        let email = msg["email"].string ?? ""
                        let productSummary = msg["productSummary"] ?? ""
                        self.mobText.text = mobileNumber
                        self.nameText.text = name
                        self.emailText.text = email
                        self.refId.text = id
                        self.prefTime.text = "Not Set"
                        self.topStack.isHidden = false
                        self.secondStack.isHidden = false
                        self.submitBtnPrev.isHidden = true
                        self.referenceNumText.isHidden = true
                        self.tableView.isHidden = false
                        let htmlString = productSummary.string ?? ""
                        // works even without <html><body> </body></html> tags, BTW
                        let data = htmlString.data(using: String.Encoding.unicode)! // mind "!"
                        let attrStr = try? NSAttributedString( // do catch
                            data: data,
                            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                            documentAttributes: nil)
                        // suppose we have an UILabel, but any element with NSAttributedString will do
                        self.tableView.attributedText = attrStr
                        
                    }
                }else {
                    let msg = json["msg"].string
                    DispatchQueue.main.async() {
                        self.view.makeToast(msg, duration: 3.0, position: .bottom)
                    }
                }
            }catch {
                DispatchQueue.main.async() {
                    self.view.makeToast("Something went wrong!!", duration: 3.0, position: .bottom)
                }
            }
            
            
            /* SAMEER-14/6/22
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                
                DispatchQueue.main.async() {
                    //self.smartExLoadingImage.layer.removeAllAnimations()
                    //self.smartExLoadingImage.isHidden = true
                    
                    self.hud.dismiss()
                }
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response.debugDescription)")
            } else{
                
                DispatchQueue.main.async() {
                    //self.smartExLoadingImage.layer.removeAllAnimations()
                    //self.smartExLoadingImage.isHidden = true
                    
                    self.hud.dismiss()
                }
                
                do {
                    let json = try JSON(data: data)
                    if json["status"] == "Success" {
                        print(json)
                        DispatchQueue.main.async() {
                            let msg = json["msg"]
                            let id = msg["id"].string ?? ""
                            let name = msg["name"].string ?? ""
                            let mobileNumber = msg["mobileNumber"].string ?? ""
                            let email = msg["email"].string ?? ""
                            let productSummary = msg["productSummary"] ?? ""
                            self.mobText.text = mobileNumber
                            self.nameText.text = name
                            self.emailText.text = email
                            self.refId.text = id
                            self.prefTime.text = "Not Set"
                            self.topStack.isHidden = false
                            self.secondStack.isHidden = false
                            self.submitBtnPrev.isHidden = true
                            self.referenceNumText.isHidden = true
                            self.tableView.isHidden = false
                            let htmlString = productSummary.string ?? ""
                            // works even without <html><body> </body></html> tags, BTW
                            let data = htmlString.data(using: String.Encoding.unicode)! // mind "!"
                            let attrStr = try? NSAttributedString( // do catch
                                data: data,
                                options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                documentAttributes: nil)
                            // suppose we have an UILabel, but any element with NSAttributedString will do
                            self.tableView.attributedText = attrStr
                            
                        }
                    }
                }catch{
                    
                }
                
            }*/
            
        }
        task.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        referenceNumText.placeholder = "reference_no".localized
        let sub = "continue".localized
        submitBtnPrev.setTitle(sub, for: .normal)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


