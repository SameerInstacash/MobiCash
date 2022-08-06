//
//  GlobalUtility.swift
//  SmartExchange
//
//  Created by Sameer Khan on 13/05/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit

class GlobalUtility: NSObject {
    
    let AppFontRegular = "Poppins-Regular"
    let AppFontMedium = "Poppins-Medium"
    let AppFontBold = "Poppins-Bold"
    
    var AppThemeColor : UIColor = UIColor().HexToColor(hexString: "#05adef", alpha: 1.0)
    
}

extension UIViewController {
    
    func setStatusBarColor(themeColor : UIColor) {
        if #available(iOS 13.0, *) {
            
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = themeColor
            view.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
            
        } else {
            
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = themeColor
            
        }
    }
    
    
    func showAlert(_ title: String, message: String, alertButtonTitles: [String], alertButtonStyles: [UIAlertAction.Style], vc: UIViewController, completion: @escaping (Int)->Void) -> Void
    {
        let alert = UIAlertController(title: title,message: message,preferredStyle: UIAlertController.Style.alert)
        
        for title in alertButtonTitles {
            let actionObj = UIAlertAction(title: title,
                                          style: alertButtonStyles[alertButtonTitles.index(of: title)!], handler: { action in
                                            completion(alertButtonTitles.index(of: action.title!)!)
            })
            
            alert.addAction(actionObj)
        }
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        
        // alert.view.tintColor = Utility.themeColor
        //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
        vc.present(alert, animated: true, completion: nil)
    }
    
}

extension UIColor
{
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor
    {
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt64
    {
        var hexInt: UInt64 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt64(&hexInt)
        return hexInt
    }
}

@IBDesignable class CornerButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
}

@IBDesignable class cornerView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
}

extension UIView {
    
    //to add Shadow and Radius On desired UIView
    static func addShadow(baseView: UIView) {
        baseView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        baseView.layer.shadowOffset = CGSize.init(width: 0.0, height: 1.2)
        baseView.layer.shadowOpacity = 1.0
        baseView.layer.shadowRadius = 1.5
        baseView.layer.masksToBounds = false
    }
    
    //to add 4 side Shadow and Radius On desired UIView
    static func addShadowOn4side(baseView: UIView) {
        let shadowSize : CGFloat = 3.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,y: -shadowSize / 2,width: baseView.frame.size.width + shadowSize,height: baseView.frame.size.height + shadowSize))
        baseView.layer.masksToBounds = false
        baseView.layer.shadowColor = UIColor.darkGray.cgColor
        baseView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        baseView.layer.shadowOpacity = 0.5
        baseView.layer.shadowPath = shadowPath.cgPath
        
        baseView.layer.cornerRadius = 5
    }
    
    static func addShadowOnViewThemeColor(baseView: UIView) {
        baseView.layer.cornerRadius = 5.0
        baseView.layer.shadowColor = UIColor.gray.cgColor
        baseView.layer.shadowOffset = CGSize.init(width: 0.0, height: 0.0)
        baseView.layer.shadowOpacity = 1.0
        baseView.layer.shadowRadius = 5.0
        baseView.layer.masksToBounds = false
    }
    
}

extension String {

    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
 
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func convertToDateFormate(current: String, convertTo: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = current
        guard let date = dateFormatter.date(from: self) else {
            return self
        }
        dateFormatter.dateFormat = convertTo
        return  dateFormatter.string(from: date)
    }
    
}

@IBDesignable class GradientBGView: UIView {
    
    private var gradientLayer: CAGradientLayer!
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        self.gradientLayer = self.layer as? CAGradientLayer
        self.gradientLayer.colors = [UIColor.white.cgColor, UIColor().HexToColor(hexString:"#05ADEF").cgColor]
    
        //self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        //self.gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
}

@IBDesignable class shadowCornerView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.4).cgColor
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOpacity = 1
            
            let backgroundCGColor = backgroundColor?.cgColor
            backgroundColor = nil
            layer.backgroundColor =  backgroundCGColor
            
            setNeedsLayout()
        }
    }
}

@IBDesignable class shadowCornerButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.4).cgColor
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOpacity = 1
            
            let backgroundCGColor = backgroundColor?.cgColor
            backgroundColor = nil
            layer.backgroundColor =  backgroundCGColor
            
            setNeedsLayout()
        }
    }
}
