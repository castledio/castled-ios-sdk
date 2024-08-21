//
//  CastledDefaultViewController.swift
//  CastledNotificationContent
//
//  Created by antony on 25/07/2024.
//

import UIKit
@_spi(CastledInternal) import Castled

class CastledDefaultViewController: UIViewController, CastledNotificationContentProtocol {
    var userDefaults: UserDefaults?
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
    func populateDetailsFrom(notificaiton: UNNotification) {
        lblTitle.text = notificaiton.request.content.title
        lblSubTitle.text = notificaiton.request.content.subtitle
        lblBody.text = notificaiton.request.content.body
        lblDate.text = notificaiton.date.timeAgo()
    }

    func getContentSizeHeight() -> CGFloat {
        return lblTitle.frame.origin.y+lblBody.frame.origin.y+lblBody.frame.size.height+lblTitle.frame.origin.y
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        userDefaults?.setValue(0, forKey: CastledNotificationContentConstants.kCastledClickedNotiContentIndx)
        userDefaults?.synchronize()
        extensionContext?.performNotificationDefaultAction()
    }
}
