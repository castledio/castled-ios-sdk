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
//    private func convertToArray(text: String) -> [CastledNotificationMediaObject]? {
//        // Convert the string to data
//        guard let jsonData = text.data(using: .utf8) else {
//            return nil
//        }
//
//        let jsonDecoder = JSONDecoder()
//        let convertedAttachments = try? jsonDecoder.decode([CastledNotificationMediaObject].self, from: jsonData)
//        return convertedAttachments
//    }
    
    static func getAppURLSchemes() -> [String]? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
            return nil
        }
        
        var schemes: [String] = []
        
        for urlType in urlTypes {
            if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String] {
                schemes.append(contentsOf: urlSchemes)
            }
        }
        return schemes.count > 0 ? schemes : nil
    }
    
    static func getSchemeFromPlist() -> String? {
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]],
           let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String] {
            return urlSchemes.first
        }
        return nil
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
}

extension UIView {
    func addShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
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

extension UIImageView {
    func loadImage(from url: URL) {
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        // Try to load the image from the cache
        if let data = cache.cachedResponse(for: request)?.data,
           let image = UIImage(data: data) {
            self.image = image
            return
        }
        
        // If the image isn't in the cache, download it
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let response = response,
               let image = UIImage(data: data) {
                // Cache the image
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)
                
                // Display the image
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
        task.resume()
    }
}
