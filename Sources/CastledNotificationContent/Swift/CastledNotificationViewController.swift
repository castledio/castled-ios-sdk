//
//  CastledNotificationContent.swift
//  CastledNotificationContent
//
//  Created by Abhilash Thulaseedharan on 11/05/23.
//

import Foundation
import UserNotifications
import UserNotificationsUI

@objc open class CastledNotificationViewController: UIViewController, UNNotificationContentExtension {

    @objc public var appGroupId = "" {
        didSet{
            if let mediaVC = childViewController as? CastledMediasViewController{
                mediaVC.setUserdefaults(FromAppgroup: appGroupId)
            }
        }
    }

    private static let kCustomKey        = "castled"
    private static let kMsg_frames       = "msg_frames"
    @IBOutlet var imageView: UIImageView!
    var childViewController: UIViewController?

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Do any required interface initialization here.
    }

    @available(iOSApplicationExtension 10.0, *)
    @objc open func didReceive(_ notification: UNNotification) {

        if let customCasledDict = notification.request.content.userInfo[CastledNotificationViewController.kCustomKey] as? NSDictionary{
            
            if  let msgFramesString = customCasledDict[CastledNotificationViewController.kMsg_frames] as? String{
                //type =  carousel
                if  let convertedAttachments = convertToArray(text: msgFramesString){
                    let mediaListVC = CastledMediasViewController(mediaObjects: convertedAttachments)
                    addChild(mediaListVC)
                    mediaListVC.view.frame = view.frame
                    view.addSubview(mediaListVC.view)
                    if appGroupId.count > 0{
                        mediaListVC.setUserdefaults(FromAppgroup: appGroupId)
                    }
                    childViewController = mediaListVC
                    mediaListVC.view.layoutIfNeeded()
                    self.preferredContentSize = mediaListVC.preferredContentSize
                    
                }
            }
            //other types
        }
    }
    
    open override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        
        self.preferredContentSize = childViewController?.preferredContentSize ?? CGSizeZero
    }
    
    //Handle next previos action here
    @objc public func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        // Your code implementation here
        
        completion(.dismissAndForwardAction)
    }
    
    
    private func convertToArray(text: String) -> [CastledNotificationMediaObject]? {
        // Convert the string to data
        guard let jsonData = text.data(using: .utf8) else {
            return nil
        }
        let jsonDecoder = JSONDecoder()
        let convertedAttachments = try? jsonDecoder.decode([CastledNotificationMediaObject].self, from: jsonData)
        return convertedAttachments
    }

}


