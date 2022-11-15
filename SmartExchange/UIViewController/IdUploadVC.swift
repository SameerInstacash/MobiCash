//
//  IdUploadVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 19/08/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit
import DKCamera
import Photos
import SwiftyJSON
import JGProgressHUD

class IdUploadVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var isIDUpload = false
    var isPhotoIdUploaded : (() -> Void)?
    let reachability: Reachability? = Reachability()
    
    @IBOutlet weak var IdFrontImageView: UIImageView!
    @IBOutlet weak var IdBackImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var btnTap = 0
    var orderID = ""
    
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.checkPermissionForCamera()
        self.imagePicker.delegate = self
        
    }
    
    //MARK: Custom Methods
    func checkPermissionForCamera() {
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("access is granted by user.")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                print("status is \(newStatus)")
                
                if newStatus == PHAuthorizationStatus.authorized {
                    print("success")
                }
                
            }
        default:
            print("user has denied the request.")
        }
    }
    
    //MARK: IBActions
    @IBAction func popUpCloseBtnClicked(_ sender: UIButton) {
        
        if self.isIDUpload {
            
            guard let didFinishIdUpload = self.isPhotoIdUploaded else { return }
            didFinishIdUpload()
            self.dismiss(animated: true, completion: nil)
            
        }else {
            self.dismiss(animated: true)
        }
        
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        
        if self.isIDUpload {
            
            guard let didFinishIdUpload = self.isPhotoIdUploaded else { return }
            didFinishIdUpload()
            self.dismiss(animated: true, completion: nil)
            
        }else {
            self.dismiss(animated: true)
        }
        
    }
    
    @IBAction func IdFrontImageBtnClicked(_ sender: UIButton) {
        
        self.btnTap = 1
        self.SetActionSetForMoreOptionForImageUpload()
        
    }
    
    @IBAction func IdBackImageBtnClicked(_ sender: UIButton) {
      
        self.btnTap = 2
        self.SetActionSetForMoreOptionForImageUpload()
        
    }

    
    //MARK: action sheet method
    
    func SetActionSetForMoreOptionForImageUpload()
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            self.importImageFromGallery(src: "Camera")
        })
        
        let galleryiAction = UIAlertAction(title: "Gallery", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            self.importImageFromGallery(src: "Photo Library")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.popoverPresentationController?.sourceView = self.view
        optionMenu.popoverPresentationController?.sourceRect = self.view.bounds
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(galleryiAction)
        
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func importImageFromGallery(src:String) {
        
        if src == "Photo Library" {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        } else if src == "Camera" {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                
            }
        }
        self.imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true) { }
        
    }
    
    //MARK: image picker delegate
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //let imageData:NSData = UIImageJPEGRepresentation(image, 0.25)! as NSData
        //let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        
      
               
        switch self.btnTap {
            
        case 1:
            //self.IdFrontImageView.image = image
            
            if self.reachability?.connection.description != "No Connection" {
                
                self.uploadPhotoId(image, "")
                
            }else {
                DispatchQueue.main.async {
                    self.view.makeToast("No connection found", duration: 3.0, position: .bottom)
                }
            }
            
        default:
            //self.IdBackImageView.image = image
            
            if self.reachability?.connection.description != "No Connection" {
                
                self.uploadPhotoId(image, "back")
                
            }else {
                DispatchQueue.main.async {
                    self.view.makeToast("No connection found", duration: 3.0, position: .bottom)
                }
            }
            
        }
        
        dismiss(animated: true) { }
            
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    var holdCaptureImage = UIImage()
    var holdImgType = String()
    func uploadPhotoId(_ captureImage: UIImage, _ imgType : String) {
        
        holdCaptureImage = captureImage
        holdImgType = imgType
    
        
        let newImage = self.resizeImage(image: captureImage, newWidth: 800)
        
        let backgroundImage = newImage
        let watermarkImage = #imageLiteral(resourceName: "watermark")
        
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.draw(in: CGRect(x: 0.0, y: 0.0, width: backgroundImage.size.width, height: backgroundImage.size.height))
        watermarkImage.draw(in: CGRect(x: 0, y: 0, width: watermarkImage.size.width, height: backgroundImage.size.height))
        
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        let uploadImageData = result?.jpeg(.high)
        let strBase64 = uploadImageData?.base64EncodedString(options: .lineLength64Characters)
                        
        
        //let imageData:NSData = UIImagePNGRepresentation(result ?? newImage) as? NSData ?? NSData()
        //let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        

        var request = URLRequest(url: URL(string: "\(AppBaseUrl)/idProof")!)
        request.httpMethod = "POST"
        let customerId = UserDefaults.standard.string(forKey: "customer_id") ?? ""
        let postString = "customerId=\(customerId)&orderId=\(self.orderID)&photo=\(strBase64 ?? "")&type=\(imgType)&userName=planetm&apiKey=fd9a42ed13c8b8a27b5ead10d054caaf"
        
        //print("idProof url is :",request,"\nParam is :",postString)
        
        //SwiftSpinner.show("")
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)

        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.hud.dismiss()
            }
            
            guard let dataThis = data, error == nil else {
                
                DispatchQueue.main.async() {
                    //self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                    
                    print(error?.localizedDescription ?? "")
                    
                    if ((error?.localizedDescription.contains("The request timed out.")) != nil) {
                        
                        self.showAlert("Error", message: "The request timed out.", alertButtonTitles: ["Retry", "Cancel"], alertButtonStyles: [.default, .destructive], vc: self) { index in
                            
                            if index == 0 {
                                
                                if self.reachability?.connection.description != "No Connection" {
                                    
                                    self.uploadPhotoId(self.holdCaptureImage, self.holdImgType)
                                    
                                }else {
                                    DispatchQueue.main.async {
                                        self.view.makeToast("No connection found", duration: 3.0, position: .bottom)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }else {
                        self.view.makeToast("Something went wrong!!", duration: 3.0, position: .bottom)
                    }
                }
                
                return
            }
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: dataThis)
                if json["status"] == "Success" {
                    
                    DispatchQueue.main.async() {
                        ////self.uploadIdBtn.setTitle("Back to home", for: .normal)
                        
                        if self.btnTap == 1 {
                            self.IdFrontImageView.image = captureImage
                        }else {
                            self.IdBackImageView.image = captureImage
                        }
                        
                        self.isIDUpload = true
                        
                        self.view.makeToast("Photo Id uploaded successfully!", duration: 1.0, position: .bottom)
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
            
        }

        task.resume()
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

extension UIImage {
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    /*
    enum PNGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func png(_ quality: PNGQuality) -> Data? {
        return UIImagePNGRepresentation(self)
    }
    */
    
}
