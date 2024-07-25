//
//  SecondViewController.swift
//  CastledDemo
//
//  Created by antony on 18/04/2023.
//

import Castled
import UIKit

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Second VC"
        // Do any additional setup after loading the view.
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }

    @IBAction func addToCartActiuonnn(_ sender: Any) {
        Castled.sharedInstance.logCustomAppEvent("added_to_cart", params: ["Int": 100, "Date": "12-16-2000", "Name": "Antony"])
    }

    @IBAction func resumeInappNotification(_ sender: Any) {
        Castled.sharedInstance.resumeInAppNotifications()
    }

    @IBAction func suspendInappNotification(_ sender: Any) {
        Castled.sharedInstance.suspendInAppNotifications()
    }

    @IBAction func discardInAppNotifications(_ sender: Any) {
        Castled.sharedInstance.discardInAppNotifications()
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }

     */
}
