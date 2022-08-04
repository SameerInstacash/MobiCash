//
//  DeviceDetectVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 01/08/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON

class DeviceDetectVC: UIViewController {
    
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var getQuoteBtn: UIButton!
    @IBOutlet weak var contactSupportBtn: UIButton!
    
    var productName = ""
    var productImage = ""
    var productPrice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomUI()
    }
    
    //MARK: Custom Methods
    func setCustomUI() {
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.lblDeviceName.text = self.productName
        
        if let url = URL.init(string: self.productImage) {
            self.deviceImage.af_setImage(withURL: url)
        }
    
        
    }
    
    //MARK: IBActions
    @IBAction func getQuoteBtnClicked(_ sender: Any) {
        self.DeadPixelTest()
    }
    
    @IBAction func contactSupportBtnClicked(_ sender: Any) {
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension DeviceDetectVC {
    
    func DeadPixelTest() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelVC") as! DeadPixelVC
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .flipHorizontal
        
        vc.deadPixelTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.touchScreenTest(rsltJson)
                //self.BackgroundTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func touchScreenTest(_ testResultJSON : JSON) {

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenVC") as! ScreenViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.screenTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.MicrophoneTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func MicrophoneTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrophoneVC") as! MicrophoneVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.micTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.SpeakerTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func SpeakerTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.speakerTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.VibratorTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func VibratorTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.vibratorTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.FlashlightTest(rsltJson)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func FlashlightTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TorchVC") as! TorchVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.flashLightTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.AutoRotationTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func AutoRotationTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RotationVC") as! AutoRotationVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.rotationTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.ProximityTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func ProximityTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityView") as! ProximityVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.proximityTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.VolumeButtonTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func VolumeButtonTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VRVC") as! VolumeRockerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.volumeTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.EarphoneTest(rsltJson)
                
            }
            
            /*
            DispatchQueue.main.async() {
                
                switch UIDevice.current.currentModelName {
                case "iPhone 4","iPhone 4s","iPhone 5","iPhone 5c","iPhone 5s","iPhone 6","iPhone 6 Plus","iPhone 6s","iPhone 6s Plus":
                                
                    //self.EarphoneTest()
                    self.CameraTest()
                    break
                default:
                    
                    //self.ChargerTest()
                    self.CameraTest()
                    break
                }
                
            }*/
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func EarphoneTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneJackVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.earphoneTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.ChargerTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func ChargerTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! DeviceChargerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.chargerTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.CameraTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func CameraTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.cameraTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.BiometricTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func BiometricTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerPrintVC") as! FingerprintViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.biometricTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.WiFiTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func WiFiTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.wifiTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.BackgroundTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func BackgroundTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalVC") as! InternalTestsVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.backgroundTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.TestResultScreen(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func TestResultScreen(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.testResultTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                print("rsltJson",rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
                
    }
    
    
}
