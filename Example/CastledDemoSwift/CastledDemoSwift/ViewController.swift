//
//  ViewController.swift
//  CastledDemo
//
//  Created by Antony Joe Mathew.
//

import Castled
import UIKit

class ViewController: UIViewController, CastledInboxViewControllerDelegate {
    let userIdKey = "userIdKey"
    @IBOutlet weak var btnRegisterUser: UIButton!
    @IBOutlet weak var btnGotoSecondVC: UIButton!
    var mainWindow: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Castled"

        showRequiredViews()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        Castled.sharedInstance?.logPageViewedEventIfAny(context: self)
        //        CastledConfigs.sharedInstance.enablePush = true
    }

    func showRequiredViews() {
        DispatchQueue.main.async { [weak self] in

            if UserDefaults.standard.value(forKey: self?.userIdKey ?? "userIdKey") != nil {
                self?.btnGotoSecondVC.isHidden = false
                let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
                self?.navigationItem.rightBarButtonItem = nil
                let inboxButton = UIBarButtonItem(image: UIImage(systemName: "bell", withConfiguration: largeConfig), style: .plain, target: self, action: #selector(self?.inboxTapped))
                self?.navigationItem.rightBarButtonItem = inboxButton
                self?.setUpInboxCallback()
            }
            else {
                self?.btnGotoSecondVC.isHidden = true
            }
            self?.btnRegisterUser.isHidden = !(self?.btnGotoSecondVC.isHidden)!
        }
    }

    @IBAction func registerUserAction(_ sender: Any) {
        registerUserAPI()
    }

    // Function for registering the user with Castled
    func registerUserAPI() {
        let userId = "antony@castled.io"
        // let userId    = "abhilash@castled.io"

        Castled.sharedInstance?.setUserId(userId)
        UserDefaults.standard.setValue(userId, forKey: userIdKey)
        UserDefaults.standard.synchronize()
        showRequiredViews()
    }

    // MARK: - Inbox related

    @objc func inboxTapped() {
        // Handle the button tap here
        let style = CastledInboxDisplayConfig()
        style.inboxViewBackgroundColor = .lightText
        style.navigationBarBackgroundColor = .link
        style.navigationBarTitle = "Castled Inbox"
        style.navigationBarButtonTintColor = .lightGray
        style.loaderTintColor = .blue
        style.hideCloseButton = true

        let inboxViewController = Castled.sharedInstance?.getInboxViewController(with: style, andDelegate: self)
        // inboxViewController?.modalPresentationStyle = .fullScreen
        // present(inboxViewController!, animated: true)
        navigationController?.pushViewController(inboxViewController!, animated: true)
    }

    func setUpInboxCallback() {
        //        Castled.sharedInstance?.inboxUnreadCount(listener: {unreadCount in
        //                print("Inbox unread count is \(unreadCount)")
        //            print("Inbox unread count is -> \(Castled.sharedInstance?.getInboxUnreadCount())")
        //
        //        })
        //        Castled.sharedInstance?.getInboxItems(completion: { _, result, errormessage in
        //
        //            print("getInboxItems \(result) \(errormessage)")
        //        })
        //       Castled.sharedInstance?.dismissInboxViewController()
    }

    // MARK: - Inbox delegate

    func didSelectedInboxWith(_ action: CastledClickActionType, _ kvPairs: [AnyHashable: Any]?, _ inboxItem: CastledInboxItem) {
        switch action {
            case .deepLink:
                break
            case .navigateToScreen:
                break
            case .richLanding:
                break
            case .requestForPush:
                break
            case .dismiss:
                break
            case .custom:
                break
            default:
                break
        }
        print("didSelectedInboxWith kvPairs \(action) \(kvPairs) inboxItem\(inboxItem)")
    }
}
