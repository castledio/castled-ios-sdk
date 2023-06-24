//
//  DeeplinkViewController.swift
//  CastledPusherExample
//
//  Created by Faisal Azeez on 04/12/2022.
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
