//
//  ViewController.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import UIKit
import Castled


class ViewController: UIViewController {
    let userIdKey = "userIdKey"
    @IBOutlet weak var btnRegisterUser: UIButton!
    @IBOutlet weak var btnGotoSecondVC: UIButton!
    var mainWindow: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Castled"

        showRequiredViews()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        Castled.sharedInstance?.logPageViewedEventIfAny(context: self)
        //        CastledConfigs.sharedInstance.enablePush = true
    }

    func showRequiredViews(){
        DispatchQueue.main.async { [weak self] in

            if  UserDefaults.standard.value(forKey: self?.userIdKey ?? "userIdKey") != nil {
                self?.btnGotoSecondVC.isHidden = false
            }
            else
            {
                self?.btnGotoSecondVC.isHidden = true

            }
            self?.btnRegisterUser.isHidden = !(self?.btnGotoSecondVC.isHidden)!

        }
    }

    @IBAction func registerUserAction(_ sender: Any) {
        registerUserAPI()
    }

    //Function for registering the user with Castled
    func registerUserAPI() {

        let userId    = "antony@castled.io"
       //let userId    = "frank@castled.io"
       // let userId    = "abhilash@castled.io"

        let token : String? = nil // Replace with valid token
        Castled.registerUser(userId: userId, apnsToken: token)
        UserDefaults.standard.setValue(userId, forKey: userIdKey)
        UserDefaults.standard.synchronize()
        showRequiredViews()

    }


    //For testing purpose
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
    }

}
