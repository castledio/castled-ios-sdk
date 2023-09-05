//
//  ViewController.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import UIKit
import Castled

class ViewController: UIViewController, CastledInboxDelegate {

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
                let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
                self?.navigationItem.rightBarButtonItem = nil
                let inboxButton = UIBarButtonItem(image: UIImage(systemName: "bell", withConfiguration: largeConfig), style: .plain, target: self, action: #selector(self?.inboxTapped))
                self?.navigationItem.rightBarButtonItem = inboxButton
                self?.setUpInboxCallback()

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

        //let userId    = "antony@castled.io"
        let userId    = "antony@castled.io"
        // let userId    = "abhilash@castled.io"

        let token : String? = nil // Replace with valid token
        Castled.registerUser(userId: userId, apnsToken: token)
        UserDefaults.standard.setValue(userId, forKey: userIdKey)
        UserDefaults.standard.synchronize()
        showRequiredViews()

    }
    // MARK: - Inbox related
    @objc func inboxTapped() {
        // Handle the button tap here
        let style = CastledInboxConfig()
        style.backgroundColor = .white
        style.navigationBarBackgroundColor = .link
        style.title = "Castled Inbox"
        style.navigationBarButtonTintColor = .white
        style.loaderTintColor = .blue
        style.hideCloseButton = false

        let inboxViewController = Castled.sharedInstance?.getInboxViewController(with: style,andDelegate: self)
        //inboxViewController?.modalPresentationStyle = .fullScreen
        //self.present(inboxViewController!, animated: true)
        self.navigationController?.pushViewController(inboxViewController!, animated: true)

    }
    func setUpInboxCallback(){
        Castled.sharedInstance?.setInboxUnreadCount(callback: { unreadCount in
            print("Inbox unread count is \(unreadCount)")
            print("Inbox unread count is -> \( Castled.sharedInstance?.getUnreadMessageCount())")

        })
        //        Castled.sharedInstance?.getInboxItems(completion: { success, items, errorMessage in
        //
        //        })
    }
    // MARK: - Inbox delegate
    func didSelectedInboxWith(_ kvPairs: [AnyHashable : Any]?, _ inboxItem: CastledInboxItem) {
        print("didSelectedInboxWith kvPairs \(kvPairs) inboxItem\(inboxItem)")
    }

    //For testing purpose
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
    }

}

