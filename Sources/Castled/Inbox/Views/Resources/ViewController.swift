//
//  ViewController.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import UIKit

class ViewController: UIViewController, CastledInboxDelegate {



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        gotTbleViewController(UIButton())
    }
    @IBAction func gotTbleViewController(_ sender: Any) {
       let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: nil).instantiateViewController(identifier: "CastledInboxViewController") as! CastledInboxViewController
        castledInboxVC.delegate = self
        self.navigationController?.pushViewController(castledInboxVC, animated: true)
    }

    func didSelectedInboxWith(_ kvPairs: [AnyHashable : Any]?, _ inboxItem: CastledInboxItem) {

    }
    
}

