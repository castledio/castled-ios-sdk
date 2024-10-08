//
//  ViewController.swift
//  CastledDemo
//
//  Created by Antony Joe Mathew.
//

import Castled
import CastledInbox
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
        //    Castled.sharedInstance.pauseInApp()
        //

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //
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

    func logUserAttributes() {
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
        Castled.sharedInstance.setUserAttributes(userAttributes)
    }

    func showRequiredViews() {
        if UserDefaults.standard.value(forKey: self.userIdKey ?? "userIdKey") != nil {
            self.btnGotoSecondVC.isHidden = false
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            self.navigationItem.rightBarButtonItem = nil
            let inboxButton = UIBarButtonItem(image: UIImage(systemName: "bell", withConfiguration: largeConfig), style: .plain, target: self, action: #selector(self.inboxTapped))
            self.navigationItem.rightBarButtonItem = inboxButton
            self.setUpInboxCallback()
            // Castled.sharedInstance.logPageViewedEvent("DetailsScreen")
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
        style.inboxViewBackgroundColor = UIColor(hexString: "ADD8E6")
        style.navigationBarBackgroundColor = .link
        style.navigationBarTitle = "Castled Inbox"
        style.navigationBarButtonTintColor = .white
        style.loaderTintColor = .blue

        //  Optional
        //  style.hideBackButton = true
        //  style.backButtonImage = UIImage(named: 'back_image')

        // for catgory tabs
//        style.showCategoriesTab = true
//        style.tabBarDefaultTextColor = .green
//        style.tabBarSelectedTextColor = .brown
//        style.tabBarDefaultBackgroundColor = .purple
//        style.tabBarSelectedBackgroundColor = .lightGray
//        style.tabBarIndicatorBackgroundColor = .red
        let inboxViewController = CastledInbox.sharedInstance.getInboxViewController(withUIConfigs: style, andDelegate: self)
        // inboxViewController.modalPresentationStyle = .fullScreen
        present(inboxViewController, animated: true)
        //  navigationController?.setNavigationBarHidden(true, animated: false)
        // navigationController?.pushViewController(inboxViewController, animated: true)
        Castled.sharedInstance.logCustomAppEvent("antony_event_both", params: ["IntValue": 200,
                                                                               // "Date": Date(),
                                                                               "BoolValue": true,
                                                                               "Name": "Antony Joe Mathew"])
        self.logUserAttributes()
    }

    func setUpInboxCallback() {
        CastledInbox.sharedInstance.observeUnreadCountChanges(listener: { unreadCount in
            print("Inbox unread count is \(unreadCount)")
        })

        CastledInbox.sharedInstance.getInboxItems(completion: { _, result, _ in
            // let inboxItem = result?.first
            // let inboxItemDelete = result?.last
            // CastledInbox.sharedInstance.logInboxItemClicked(inboxItem!, buttonTitle: "")
            // CastledInbox.sharedInstance.logInboxItemsRead([inboxItemDelete!])
            // CastledInbox.sharedInstance.deleteInboxItem(inboxItem!)
            print("getInboxItems \(result?.count)")
        })

        //       Castled.sharedInstance.dismissInboxViewController()
    }

    // MARK: - Inbox delegate

    func didSelectedInboxWith(_ buttonAction: CastledButtonAction, inboxItem: CastledInboxItem) {
        print("didSelectedInboxWith type \(buttonAction.actionType) title '\(buttonAction.buttonTitle ?? "")' uri '\(buttonAction.actionUri ?? "")'kvPairs \(buttonAction.keyVals) inboxItem\(inboxItem)")
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
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
