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

class IdUploadVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var IdFrontImageView: UIImageView!
    @IBOutlet weak var IdBackImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var btnTap = 0

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
        self.dismiss(animated: true)
    }
    
    @IBAction func IdFrontImageBtnClicked(_ sender: UIButton) {
        
        self.btnTap = 1
        self.SetActionSetForMoreOptionForImageUpload()
        
    }
    
    @IBAction func IdBackImageBtnClicked(_ sender: UIButton) {
      
        self.btnTap = 2
        self.SetActionSetForMoreOptionForImageUpload()
        
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
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
        let imageData:NSData = UIImageJPEGRepresentation(image, 0.25)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
               
        switch self.btnTap {
            
        case 1:
            self.IdFrontImageView.image = image
        default:
            self.IdBackImageView.image = image
        }
        
        dismiss(animated: true) { }
            
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
