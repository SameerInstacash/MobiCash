//
//  CameraLayerVC.swift
//  InstaCash
//
//  Created by Sameer Khan on 10/09/22.
//  Copyright © 2022 Prakhar Gupta. All rights reserved.
//

import UIKit
import AVFoundation

class CameraLayerVC: UIViewController, AVCapturePhotoCaptureDelegate {

    var isBackClicked = false
    var isFrontClicked = false
    var isBothCameraClicked : (() -> Void)?
    var isBackCameraClicked : (() -> Void)?
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    
    private let photoOutput = AVCapturePhotoOutput()
    
    //MARK: 10/10/22
    var cameraLayer : AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    var cameraDevice: AVCaptureDevice?
    //var photoOutput : AVCapturePhotoOutput?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeImage = UIImage(named: "cross-camera")
        let closeTintedImage = closeImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeTintedImage, for: .normal)
        closeButton.tintColor = .white
        
        
        let captureImage = UIImage(named: "capture_photo")
        let captureTintedImage = captureImage?.withRenderingMode(.alwaysTemplate)
        captureButton.setImage(captureTintedImage, for: .normal)
        captureButton.tintColor = .white

        self.openCamera()
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
            
        case .denied:
            print("the user has denied previously to access the camera.")
            self.handleDismiss()
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.handleDismiss()
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {
        
        //let captureSession = AVCaptureSession()
        
        self.captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if ((captureSession?.canAddInput(input)) != nil) {
                    captureSession?.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if ((captureSession?.canAddOutput(photoOutput)) != nil) {
                captureSession?.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
            
            self.view.bringSubview(toFront: self.overlayView)
            self.view.bringSubview(toFront: self.closeButton)
            
            captureSession?.startRunning()
            //self.setupUI()
        }
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: IBActions
    @IBAction func cameraDismiss(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func handleTakePhoto(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            //photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    //MARK: AVCapturePhotoOutput Delegate
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCaptureFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("didFinishProcessingPhoto")
        
        if self.isBackClicked {
            self.isFrontClicked = true
        }
        
        self.isBackClicked = true
                
        guard let isBackCameraClick = self.isBackCameraClicked else { return }
        isBackCameraClick()
        
        
        /*
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        
        let photoPreviewContainer = PhotoPreviewView(frame: self.view.frame)
        photoPreviewContainer.photoImageView.image = previewImage
        self.view.addSubviews(photoPreviewContainer)
        */
        
        //captureSession.stopRunning()
        
        if self.isBackClicked == true && self.isFrontClicked == true {
            
            //DispatchQueue.main.async {
                guard let isBothCameraClicked = self.isBothCameraClicked else { return }
                isBothCameraClicked()
                //self.dismiss(animated: true, completion: nil)
            //}
            
        }else {
            
            //let captureSession = AVCaptureSession()
            
            self.captureSession = AVCaptureSession()
            
            if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                
                do {
                    let input = try AVCaptureDeviceInput(device: captureDevice)
                    if ((captureSession?.canAddInput(input)) != nil) {
                        captureSession?.addInput(input)
                    }
                } catch let error {
                    print("Failed to set input device with error: \(error)")
                }
                
                /*
                if ((captureSession?.canAddOutput(photoOutput)) != nil) {
                    captureSession?.addOutput(photoOutput)
                }
                */
                
                let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
                cameraLayer.frame = self.view.frame
                cameraLayer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(cameraLayer)
                
                self.view.bringSubview(toFront: self.overlayView)
                self.view.bringSubview(toFront: self.closeButton)
                
                captureSession?.startRunning()
                //self.setupUI()
            }
            
        }
        
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
