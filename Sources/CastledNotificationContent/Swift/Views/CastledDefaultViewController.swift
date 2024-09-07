//
//  CastledDefaultViewController.swift
//  CastledNotificationContent
//
//  Created by antony on 25/07/2024.
//

import UIKit
@_spi(CastledInternal) import Castled

class CastledDefaultViewController: UIViewController, CastledNotificationContentProtocol {
    @IBOutlet weak var constraintBodyTop: NSLayoutConstraint!
    var userDefaults: UserDefaults?
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        viewContainer.layer.borderColor = UIColor.systemGray.cgColor
        viewContainer.layer.cornerRadius = 10
        viewContainer.layer.borderWidth = 1
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
        if let subTitle = lblSubTitle.text, subTitle.isEmpty {
            constraintBodyTop.constant = 0
            lblTitle.numberOfLines = 20
            lblBody.numberOfLines = lblTitle.numberOfLines
        }
        lblBody.text = notificaiton.request.content.body
        lblDate.text = notificaiton.date.timeAgo()
    }

    func getContentSizeHeight() -> CGFloat {
        return viewContainer.frame.origin.y+viewContainer.frame.size.height+viewContainer.frame.origin.y
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        userDefaults?.setValue(0, forKey: CastledPushMediaConstants.CastledClickedNotiContentIndx)
        userDefaults?.synchronize()
        extensionContext?.performNotificationDefaultAction()
    }
}
