//
//  CastledCommonClass.swift
//  Castled
//
//  Created by Castled Data on 01/12/2022.
//
import UIKit

import Foundation

class CastledCommonClass{
    static func showNotificationWIthTitle(title:String,body : String){

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["value": "Data with local notification"]
        let fireDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date().addingTimeInterval(2))
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
        let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print("Error = \(error?.localizedDescription ?? "error local notification")")
            }
        }
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                castledLog(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func getCastledPushNotificationId(dict: [AnyHashable: Any])-> String?{
        guard let customDict = dict[CastledConstants.PushNotification.customKey] as? NSDictionary,
              let notificationId = customDict[CastledConstants.PushNotification.CustomProperties.notificationId] as? String
        else{
            return nil;
        }
        return notificationId
    }
    
    static func getActionDetails(dict: [AnyHashable: Any], actionType: String) -> [String: Any]? {
        guard let customDict = dict[CastledConstants.PushNotification.customKey] as? NSDictionary,
              //              let notificationId = customDict[CastledConstants.PushNotification.CustomProperties.notificationId] as? String,
              let notification = dict[CastledConstants.PushNotification.apsKey] as? NSDictionary,
              let category = notification[CastledConstants.PushNotification.ApsProperties.category] as? String,
              let categoryJsonString = customDict[CastledConstants.PushNotification.CustomProperties.categoryActions] as? String,
              let deserializedDict = CastledCommonClass.convertToDictionary(text: categoryJsonString),
              let actionsArray = deserializedDict[CastledConstants.PushNotification.CustomProperties.Category.actionComponents] as? [[String: Any]] else {
            return nil
        }
        
        for action in actionsArray {
            if let identifier = action[CastledConstants.PushNotification.CustomProperties.Category.Action.actionId] as? String, identifier == actionType {
                return [
                    CastledConstants.PushNotification.ApsProperties.category: category,
                    CastledConstants.PushNotification.CustomProperties.Category.Action.actionId: identifier,
                    CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction: action[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String ?? "",
                    CastledConstants.PushNotification.CustomProperties.Category.Action.clickActionUrl: action[CastledConstants.PushNotification.CustomProperties.Category.Action.url] as? String ?? "",
                    CastledConstants.PushNotification.CustomProperties.Category.Action.useWebView: action[CastledConstants.PushNotification.CustomProperties.Category.Action.useWebView] as? Bool ?? false
                ]
            }
        }
        return nil
    }
    
    static func getDefaultActionDetails(dict: [AnyHashable: Any], index : Int? = 0) -> [String: Any]? {
        guard let customDict = dict[CastledConstants.PushNotification.customKey] as? [String: Any]
        else {
            return nil
        }
        if let msgFramesString = customDict["msg_frames"] as? String,
           let detailsArray = CastledCommonClass.convertToArray(text: msgFramesString) as? Array<Any>,
           detailsArray.count > index!,
           let selectedCategory = detailsArray[index!] as? [String : Any]{

            return selectedCategory

        }
        return nil


    }
    static func convertToArray(text: String) -> Any?  {
        guard let data = text.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

    static func getImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        
        let cache = NSCache<NSURL, UIImage>()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let cachedImage = cache.object(forKey: url as NSURL) {
                DispatchQueue.main.async {
                    completion(cachedImage)
                }
            } else {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    
                    guard let data = data, let image = UIImage(data: data) else {
                        
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    
                    // Cache the downloaded image
                    cache.setObject(image, forKey: url as NSURL)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }.resume()
            }
        }
    }
    
    static internal func hexStringToUIColor (hex:String) -> UIColor? {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return nil
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    static internal func instantiateFromNib<T: UIViewController>(vc : T.Type) -> T {


        return T.init(nibName: String(describing: T.self), bundle:Bundle.resourceBundle(for: Self.self))
    }

    
    static func loadView<T :UIView>(fromNib name: String, withType type: T.Type) -> T? {
        
        let bundle  = Bundle.resourceBundle(for: Self.self)


        if let view = UINib(
            nibName: name,
            bundle: bundle
        ).instantiate(withOwner: nil, options: nil)[0] as? T {
            return view
        }
        if let view = bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        return nil

    }
}

extension UIView {
    func addShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    func applyShadow(radius: CGFloat){
        layer.cornerRadius = radius
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 5)


    }
    
}

extension UIWindow {
    func castledTopViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        Castled.sharedInstance?.clientRootViewController = top
        return top
    }
}


extension Bundle {


    static func resourceBundle(for bundleClass: AnyClass) -> Bundle {

        let mainBundle = Bundle.main
        let sourceBundle = Bundle(for: bundleClass)
        guard let moduleName = String(reflecting: bundleClass).components(separatedBy: ".").first else {
            fatalError("Couldn't determine module name from class \(bundleClass)")
        }
        // SPM
        var bundle: Bundle?
        if bundle == nil,let bundlePath = sourceBundle.path(forResource: "Castled", ofType: "bundle") {
            //cocoapod
            bundle = Bundle(path: bundlePath)
        }

        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "\(moduleName)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }

        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "Castled_CastledNotificationContent", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "Castled_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if let bundlePath = mainBundle.path(forResource: "\(bundleClass)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = sourceBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }

        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        // CocoaPods (static)
        else if bundle == nil, let staticBundlePath = mainBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: staticBundlePath)
        }

        // CocoaPods (framework)
        else if bundle == nil, let frameworkBundlePath = sourceBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: frameworkBundlePath)
        }
        return bundle ?? sourceBundle
    }
}



