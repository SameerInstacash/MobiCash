//
//  IMEIViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 04/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import Toast_Swift
//import DKImagePickerController
import SwiftOCR


extension String{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func substring(fromIndex: Int, toIndex:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: fromIndex)
        let endIndex = self.index(startIndex, offsetBy: toIndex-fromIndex)
        
        return String(self[startIndex...endIndex])
    }
}

class IMEIViewController: UIViewController,UITextFieldDelegate {

    @IBAction func useOCRBtnClicked(_ sender: Any) {
        
        /*
        let pickerController = DKImagePickerController()
        pickerController.allowMultipleTypes = false
        pickerController.maxSelectableCount = 1
        pickerController.autoCloseOnSingleSelect = true
        pickerController.assetType = .allPhotos
       
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            let swiftOCRInstance = SwiftOCR()
            
            
            for asset in assets {
                
                asset.fetchOriginalImageWithCompleteBlock({ (image, info) in
                    
                    swiftOCRInstance.recognize(image!) { recognizedString in
                        
                        print("recognizedString: \(recognizedString)")
                }
                })
            }
            
            
            }
        

       present(pickerController, animated: true) {}
        */
        
    }
    
    
    
    @IBOutlet weak var changeLanguageButton: UIButton!
    
    @IBAction func didPressChangeLanguageButton(_ sender: Any) {
        let message = "Change language of this app including its content."
        let sheetCtrl = UIAlertController(title: "Choose language", message: message, preferredStyle: .actionSheet)
        
        for languageCode in Bundle.main.localizations.filter({ $0 != "Base" }) {
            let langName = Locale.current.localizedString(forLanguageCode: languageCode)
            let action = UIAlertAction(title: langName, style: .default) { _ in
                self.changeToLanguage(languageCode) // see step #2
            }
            sheetCtrl.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheetCtrl.addAction(cancelAction)
        
        sheetCtrl.popoverPresentationController?.sourceView = self.view
        sheetCtrl.popoverPresentationController?.sourceRect = self.changeLanguageButton.frame
        present(sheetCtrl, animated: true, completion: nil)
    }
    
    
    private func changeToLanguage(_ langCode: String) {
        if Bundle.main.preferredLocalizations.first != langCode {
            let message = "In order to change the language, the App must be closed and reopened by you."
            let confirmAlertCtrl = UIAlertController(title: "App restart required", message: message, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Close now", style: .destructive) { _ in
                UserDefaults.standard.set([langCode], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                exit(EXIT_SUCCESS)
            }
            confirmAlertCtrl.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            confirmAlertCtrl.addAction(cancelAction)
            
            present(confirmAlertCtrl, animated: true, completion: nil)
        }
    }
    
    
    @IBOutlet weak var imeiEditText: UITextField!
    @IBAction func continueBtnPressed(_ sender: Any) {
        
        if self.imeiEditText.text?.count == 15 {
            /*
            if isIMEIValid(imeiNumber: imeiEditText.text!){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                vc.IMEINumber = imeiEditText.text!
                UserDefaults.standard.set("\(imeiEditText.text!)", forKey: "imei_number")
                self.present(vc, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    self.view.makeToast("invalid_imei".localized, duration: 2.0, position: .top)
                }
            }*/
            
            if (self.imeiEditText.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0) > 0 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                vc.IMEINumber = imeiEditText.text!
                UserDefaults.standard.set("\(imeiEditText.text!)", forKey: "imei_number")
                self.present(vc, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    self.view.makeToast("invalid_imei".localized, duration: 2.0, position: .top)
                }
            }
            
        }else{
            DispatchQueue.main.async {
                self.view.makeToast("imei_validation_info".localized, duration: 2.0, position: .top)
            }
        }
    }
    
    @IBOutlet weak var skioBtn: UITabBarItem!
    
    override func viewDidLoad() {
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        self.hideKeyboardWhenTappedAround()
        
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], for: .selected)
       
        imeiEditText.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let imei = UserDefaults.standard.string(forKey: "imei_number")
        
        if (imei?.count == 15){
            print(imei!)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
            vc.IMEINumber = imei!
            self.present(vc, animated: true, completion: nil)
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
//            self.present(vc, animated: true, completion: nil)
        }else{
            print("user defaults not present")
        }
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
    
    func isIMEIValid(imeiNumber: String) -> Bool {
        var sum = 0;
        for i in (0..<15){
            var number = Int(imeiNumber.substring(fromIndex: i, toIndex: i))
            if ((i+1)%2==0){
                number = number!*2;
                number = number!/10+number!%10;
            }
            sum=sum+number!
        }
        if(sum%10 == 0) {
            return true
        }else{
            return false
        }
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
