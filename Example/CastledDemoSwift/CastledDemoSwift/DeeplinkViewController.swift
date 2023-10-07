//
//  DeeplinkViewController.swift
//  CastledDemo
//
//

import UIKit

class DeeplinkViewController: UIViewController {
    @IBOutlet weak var lblEventType: UILabel!
    var params : [String : String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Deeplink View"
        if params != nil{
            lblEventType.text = params?.description
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
