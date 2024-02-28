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
    @IBOutlet weak var btnLogout: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Castled"

        self.showRequiredViews()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        Castled.sharedInstance.logPageViewedEventIfAny(context: self)
        //        CastledConfigs.sharedInstance.enablePush = true

        /*   let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Customize the format as needed

         // Create a Date object representing the date you want to convert to a string
         let date = Date() // This represents the current date and time

         // Use the DateFormatter to convert the Date to a string
         let dateString = dateFormatter.string(from: date)

         Castled.sharedInstance.logCustomAppEvent("antony_event", params: ["IntValue": 200,
                                                                           //"Date": Date(),
                                                                           "BoolValue": true,
                                                                           "Name": "Antony Joe Mathew"])

         let userAttributes = CastledUserAttributes()
         userAttributes.setFirstName("Antony Joe Mathew 1")
         userAttributes.setLastName("Mathew")
         userAttributes.setCity("Sanfrancisco")
         userAttributes.setCountry("US")
         userAttributes.setEmail("doe@email.com")
         userAttributes.setDOB("02-01-1995")
         userAttributes.setGender("M")
         userAttributes.setPhone("+13156227533")
         // Custom Attributes
         userAttributes.setCustomAttribute("prime_member", true)
         userAttributes.setCustomAttribute("int", 500)
         userAttributes.setCustomAttribute("double", 500.01)
         userAttributes.setCustomAttribute("occupation", "artist")
         Castled.sharedInstance.setUserAttributes(userAttributes)*/
    }

    func showRequiredViews() {
        if UserDefaults.standard.value(forKey: self.userIdKey ?? "userIdKey") != nil {
            self.btnGotoSecondVC.isHidden = false
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            self.navigationItem.rightBarButtonItem = nil
            let inboxButton = UIBarButtonItem(image: UIImage(systemName: "bell", withConfiguration: largeConfig), style: .plain, target: self, action: #selector(self.inboxTapped))
            self.navigationItem.rightBarButtonItem = inboxButton
            self.setUpInboxCallback()
        }
        else {
            self.btnGotoSecondVC.isHidden = true
        }
        self.btnRegisterUser.isHidden = !(self.btnGotoSecondVC.isHidden)
        self.btnLogout.isHidden = !self.btnRegisterUser.isHidden
    }

    @IBAction func registerUserAction(_ sender: Any) {
        self.registerUserAPI()
    }

    // Function for registering the user with Castled
    func registerUserAPI() {
        let userId = "antony@castled.io"
        Castled.sharedInstance.setUserId("antony@castled.io", userToken: "vbePXGpzBunDmIK6SRbetvWGXaAf48xZEnDTAzMRDkE=")

        UserDefaults.standard.setValue(userId, forKey: self.userIdKey)
        UserDefaults.standard.synchronize()
        self.showRequiredViews()
    }

    @IBAction func logoutbtnCliked(_ sender: Any) {
        Castled.sharedInstance.logout()
        UserDefaults.standard.removeObject(forKey: "userIdKey")
        self.showRequiredViews()
    }

    // MARK: - Inbox related

    @objc func inboxTapped() {
        // Handle the button tap here
        let style = CastledInboxDisplayConfig()
        style.inboxViewBackgroundColor = .white
        style.navigationBarBackgroundColor = .link
        style.navigationBarTitle = "Castled Inbox"
        style.navigationBarButtonTintColor = .white
        style.loaderTintColor = .blue
        style.hideCloseButton = false

        // for catgory tabs
//        style.showCategoriesTab = true
//        style.tabBarDefaultTextColor = .green
//        style.tabBarSelectedTextColor = .brown
//        style.tabBarDefaultBackgroundColor = .purple
//        style.tabBarSelectedBackgroundColor = .lightGray
//        style.tabBarIndicatorBackgroundColor = .red
        let inboxViewController = Castled.sharedInstance.getInboxViewController(withUIConfigs: style, andDelegate: self)
        inboxViewController.modalPresentationStyle = .fullScreen
        // present(inboxViewController, animated: true)
        // navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.pushViewController(inboxViewController, animated: true)
    }

    func setUpInboxCallback() {
        //   return;
        Castled.sharedInstance.observeUnreadCountChanges(listener: { unreadCount in
            print("Inbox unread count is \(unreadCount)")
        })

        Castled.sharedInstance.getInboxItems(completion: { _, _, _ in

            //   print("getInboxItems \(result) \(errormessage)")
        })
        //       Castled.sharedInstance.dismissInboxViewController()
    }

    // MARK: - Inbox delegate

    func didSelectedInboxWith(_ buttonAction: CastledButtonAction, inboxItem: CastledInboxItem) {
        print("didSelectedInboxWith title '\(buttonAction.buttonTitle ?? "")' uri '\(buttonAction.actionUri ?? "")'kvPairs \(buttonAction.keyVals) inboxItem\(inboxItem)")
        switch buttonAction.actionType {
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
    }

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
