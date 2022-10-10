//
//  QuestionsVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 23/05/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class QuestionsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {
    
    var arrQuestionAnswer : Questions?
    var TestDiagnosisForward: (() -> Void)?
    var selectedAppCode = ""
    var selectedCellIndex = -1
    var arrSelectedCellIndex = [Int]()
    
    @IBOutlet weak var lblQuestionName: UILabel!
    //@IBOutlet weak var cosmeticCollectionView: UICollectionView!
    @IBOutlet weak var cosmeticTableView: UITableView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cosmeticTableView.layer.cornerRadius = 10.0
        
        if AppQuestionIndex == 0 {
            self.btnPrevious.isHidden = true
        }else {
            self.btnPrevious.isHidden = false
        }
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            //self.lblQuestionName.text = arrQuestionAnswer?.specificationName
            self.lblQuestionName.text = arrQuestionAnswer?.specificationName ?? ""
            
        }else {
            //self.lblQuestionName.text = arrQuestionAnswer?.conditionSubHead
            self.lblQuestionName.text = arrQuestionAnswer?.conditionSubHead ?? ""
        }
      
    }
    
    //MARK: IBActions
    @IBAction func previousBtnPressed(_ sender: UIButton) {
        
        arrAppQuestionsAppCodes?.remove(at: AppQuestionIndex-1)
        print("arrQuestionsAppCodes are when back:", arrAppQuestionsAppCodes ?? [])
        
        hardwareQuestionsCount += 2
        AppQuestionIndex -= 2
        
        
        guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
        didFinishRetryDiagnosis()
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if self.selectedAppCode == "" {
                
                arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                print("arrQuestionsAppCodes are when forward:", arrAppQuestionsAppCodes ?? [])
                
                guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }else {
                
                arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                print("arrQuestionsAppCodes are when forward:", arrAppQuestionsAppCodes ?? [])
                
                // 14/3/22
                //AppResultString = AppResultString + self.selectedAppCode + ";"
                
                guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
            }
            
        }else {
            // "radio"
            // "select"
            
            if self.selectedAppCode == "" {
                DispatchQueue.main.async() {
                    self.view.makeToast("Please select one option", duration: 2.0, position: .bottom)
                }
            }else {
                
                arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                print("arrQuestionsAppCodes are when forward:", arrAppQuestionsAppCodes ?? [])
                
                // 14/3/22
                //AppResultString = AppResultString + self.selectedAppCode + ";"
                
                guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
            }
            
        }
                        
    }
    
    // MARK: - UITableView DataSource & Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                return (self.arrQuestionAnswer?.specificationValue?.count ?? 0) + 1
            }else {
                return self.arrQuestionAnswer?.specificationValue?.count ?? 0
            }
            
        }else {
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                return (self.arrQuestionAnswer?.conditionValue?.count ?? 0) + 1
            }else {
                return self.arrQuestionAnswer?.conditionValue?.count ?? 0
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CosmeticQuestionTblCell = tableView.dequeueReusableCell(withIdentifier: "CosmeticQuestionTblCell", for: indexPath) as! CosmeticQuestionTblCell
        
        CosmeticQuestionTblCell.layer.cornerRadius = 5.0
        CosmeticQuestionTblCell.baseContentView.layer.cornerRadius = 5.0
        
        //let iconImgView : UIImageView = CosmeticQuestionTblCell.viewWithTag(10) as! UIImageView
        //let lblIconName : UILabel = CosmeticQuestionTblCell.viewWithTag(20) as! UILabel
        
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                
                if indexPath.row == self.arrQuestionAnswer?.specificationValue?.count {
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                    CosmeticQuestionTblCell.lblIconName.text = "NONE OF THE ABOVE"
                }
                
            }
            
            if indexPath.row < (self.arrQuestionAnswer?.specificationValue?.count ?? 0) {
            
                let answer = self.arrQuestionAnswer?.specificationValue?[indexPath.item]
                
                //let str = answer?.value?.removingPercentEncoding
                let str = answer?.value?.removingPercentEncoding ?? ""
                CosmeticQuestionTblCell.lblIconName.text = str.replacingOccurrences(of: "+", with: " ")
                
                
                if let qImage = self.arrQuestionAnswer?.specificationValue?[indexPath.item].image {
                    
                    if let imgUrl = URL(string: qImage) {
                        CosmeticQuestionTblCell.iconImgView.isHidden = false
                        CosmeticQuestionTblCell.iconImgView.af_setImage(withURL: imgUrl)
                    }else {
                        CosmeticQuestionTblCell.iconImgView.isHidden = true
                    }
                    
                }else {
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                }
                
            }
            
            
        }else {
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                
                if indexPath.row == self.arrQuestionAnswer?.conditionValue?.count {
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                    CosmeticQuestionTblCell.lblIconName.text = "NONE OF THE ABOVE"
                }
                
            }
            
            
            if indexPath.row < (self.arrQuestionAnswer?.conditionValue?.count ?? 0) {
                
                let answer = self.arrQuestionAnswer?.conditionValue?[indexPath.item]
                
                //let str = answer?.value?.removingPercentEncoding
                let str = answer?.value?.removingPercentEncoding ?? ""
                CosmeticQuestionTblCell.lblIconName.text = str.replacingOccurrences(of: "+", with: " ")
                
            
                if let qImage = self.arrQuestionAnswer?.conditionValue?[indexPath.item].image {
                    
                    if let imgUrl = URL(string: qImage) {
                        CosmeticQuestionTblCell.iconImgView.isHidden = false
                        CosmeticQuestionTblCell.iconImgView.af_setImage(withURL: imgUrl)
                    }else {
                        CosmeticQuestionTblCell.iconImgView.isHidden = true
                    }
                    
                }else {
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                }
                
            }
                
         
        }
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if self.arrSelectedCellIndex.contains(indexPath.item) {
                //CosmeticQuestionTblCell.layer.borderWidth = 1.0
                //CosmeticQuestionTblCell.layer.borderColor = UIColor.init(hexString: "#05adef").cgColor
                
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#05adef")
                
            }else {
                //CosmeticQuestionTblCell.layer.borderWidth = 0.0
                //CosmeticQuestionTblCell.layer.borderColor = UIColor.clear.cgColor
                
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.white
            }
        
        }else {
            
            if self.selectedCellIndex == indexPath.item {
                //CosmeticQuestionTblCell.layer.borderWidth = 1.0
                //CosmeticQuestionTblCell.layer.borderColor = UIColor.init(hexString: "#05adef").cgColor
                
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#05adef")
                
            }else {
                //CosmeticQuestionTblCell.layer.borderWidth = 0.0
                //CosmeticQuestionTblCell.layer.borderColor = UIColor.clear.cgColor
                
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.white
            }
            
        }
        
        return CosmeticQuestionTblCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                
                //MARK: To handle the case of NONE OF THE ABOVE
                if indexPath.row == self.arrQuestionAnswer?.specificationValue?.count {
                    
                    self.selectedAppCode = ""
                    
                    arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                    print("arrQuestionsAppCodes are when NONE OF THE ABOVE:", arrAppQuestionsAppCodes ?? [])
                    
                    guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                    return
                }
                
                
                if self.selectedAppCode == "" {
                    self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? ""
                }else {
                    if !self.selectedAppCode.contains(self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? "") {
                        self.selectedAppCode += ";" + (self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? "")
                    }
                }
                               
                
            }else {
                
                //MARK: To handle the case of NONE OF THE ABOVE
                if indexPath.row == self.arrQuestionAnswer?.conditionValue?.count {
                    
                    self.selectedAppCode = ""
                    
                    arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                    print("arrQuestionsAppCodes are when NONE OF THE ABOVE:", arrAppQuestionsAppCodes ?? [])
                    
                    guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                    return
                }
                
                
                if self.selectedAppCode == "" {
                    self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? ""
                }else {
                    if !self.selectedAppCode.contains(self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? "") {
                        self.selectedAppCode += ";" + (self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? "")
                    }
                }
                
                
            }
            
            print("self.selectedAppCode is:-", self.selectedAppCode)
            
            self.arrSelectedCellIndex.append(indexPath.item)
            //self.selectedCellIndex = indexPath.item
            self.cosmeticTableView.reloadData()
            
        }else {
            // "radio"
            // "select"
            
            if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? ""
            }else {
                self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? ""
            }
            
            print("self.selectedAppCode is:-", self.selectedAppCode)
            
            self.selectedCellIndex = indexPath.item
            self.cosmeticTableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                print("arrQuestionsAppCodes are when forward:", arrAppQuestionsAppCodes ?? [])
                                
                guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
            }
            
        }
        
        
        /* 14/3/22
        AppResultString = AppResultString + self.selectedAppCode + ";"
        
        guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
        didFinishRetryDiagnosis()
        self.dismiss(animated: false, completion: nil)
        */
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
  
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - UICollectionView DataSource & Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            return self.arrQuestionAnswer?.specificationValue?.count ?? 0
        }else {
            return self.arrQuestionAnswer?.conditionValue?.count ?? 0
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cosmeticCell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "cosmeticCell1", for: indexPath)
        cosmeticCell1.layer.cornerRadius = 5.0
        
        //let iconImgView : UIImageView = cosmeticCell1.viewWithTag(10) as! UIImageView
        let lblIconName : UILabel = cosmeticCell1.viewWithTag(20) as! UILabel
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            let answer = self.arrQuestionAnswer?.specificationValue?[indexPath.item]
            
            //let str = answer?.value?.removingPercentEncoding
            let str = answer?.value?.removingPercentEncoding ?? ""
            lblIconName.text = str.replacingOccurrences(of: "+", with: " ")
            
            /*
            if let qImage = self.arrQuestionAnswer?.specificationValue?[indexPath.item].image {
                if let imgUrl = URL(string: qImage) {
                    iconImgView.af.setImage(withURL: imgUrl)
                }
            }*/
            
        }else {
            let answer = self.arrQuestionAnswer?.conditionValue?[indexPath.item]
            
            //let str = answer?.value?.removingPercentEncoding
            let str = answer?.value?.removingPercentEncoding ?? ""
            lblIconName.text = str.replacingOccurrences(of: "+", with: " ")
            
            /*
            if let qImage = self.arrQuestionAnswer?.conditionValue?[indexPath.item].image {
                if let imgUrl = URL(string: qImage) {
                    iconImgView.af.setImage(withURL: imgUrl)
                }
            }*/
         
        }
        
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if self.arrSelectedCellIndex.contains(indexPath.item) {
                cosmeticCell1.layer.borderWidth = 1.0
                cosmeticCell1.layer.borderColor = UIColor.init(hexString: "#05adef").cgColor
            }else {
                cosmeticCell1.layer.borderWidth = 0.0
                cosmeticCell1.layer.borderColor = UIColor.clear.cgColor
            }
        
        }else {
            
            if self.selectedCellIndex == indexPath.item {
                cosmeticCell1.layer.borderWidth = 1.0
                cosmeticCell1.layer.borderColor = UIColor.init(hexString: "#05adef").cgColor
            }else {
                cosmeticCell1.layer.borderWidth = 0.0
                cosmeticCell1.layer.borderColor = UIColor.clear.cgColor
            }
            
        }
                
        return cosmeticCell1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                
                if self.selectedAppCode == "" {
                    self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? ""
                }else {
                    if !self.selectedAppCode.contains(self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? "") {
                        self.selectedAppCode += ";" + (self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? "")
                    }
                    
                }
                
            }else {
                
                if self.selectedAppCode == "" {
                    self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? ""
                }else {
                    if !self.selectedAppCode.contains(self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? "") {
                        self.selectedAppCode += ";" + (self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? "")
                    }
                }
                
            }
            
            print("self.selectedAppCode is:-", self.selectedAppCode)
            
            self.arrSelectedCellIndex.append(indexPath.item)
            //self.selectedCellIndex = indexPath.item
            self.cosmeticTableView.reloadData()
            
        }else {
            // "radio"
            // "select"
            
            if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? ""
            }else {
                self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? ""
            }
            
            print("self.selectedAppCode is:-", self.selectedAppCode)
            
            self.selectedCellIndex = indexPath.item
            self.cosmeticTableView.reloadData()
            
        }
        
        
        /* 14/3/22
        AppResultString = AppResultString + self.selectedAppCode + ";"
        
        guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
        didFinishRetryDiagnosis()
        self.dismiss(animated: false, completion: nil)
        */
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: collectionView.bounds.width, height: 60.0)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
