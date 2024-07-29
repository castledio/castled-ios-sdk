//
//  CastledDefaultViewController.swift
//  CastledNotificationContent
//
//  Created by antony on 25/07/2024.
//

import UIKit

class CastledDefaultViewController: UIViewController {
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

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
    func populateDetails() {
        lblTitle.text = "Create complex customer journeys and personalised engagement campaigns using customer data locked securely in your data warehouse.Create complex customer journeys and personalised engagement campaigns using customer data locked securely in your data warehouse.Create complex customer journeys and personalised engagement campaigns using customer data locked securely in your data warehouse.Create complex customer journeys and personalised engagement campaigns using customer data locked securely in your data warehouse.Create complex customer journeys and personalised engagement campaigns using customer data locked securely in your data warehouse."
        lblSubTitle.text = "Sub Create the most effective user segments using our visual audience builder to run your dream cross-channel campaigns. Integrate effortlessly with other tools in your marketing ecosystem..Create the most effective user segments using our visual audience builder to run your dream cross-channel campaigns. Integrate effortlessly with other tools in your marketing ecosystem..Create the most effective user segments using our visual audience builder to run your dream cross-channel campaigns. Integrate effortlessly with other tools in your marketing ecosystem..Create the most effective user segments using our visual audience builder to run your dream cross-channel campaigns. Integrate effortlessly with other tools in your marketing ecosystem..f"
        lblBody.text = "Body The ROI of these platforms begins to decline once you surpass initial growth thresholds, ultimately leading to a point where developing an in-house solution becomes the only viable option.The ROI of these platforms begins to decline once you surpass initial growth thresholds, ultimately leading to a point where developing an in-house solution becomes the only viable optionThe ROI of these platforms begins to decline once you surpass initial growth thresholds, ultimately leading to a point where developing an in-house solution becomes the only viable optionThe ROI of these platforms begins to decline once you surpass initial growth thresholds, ultimately leading to a point where developing an in-house solution becomes the only viable optionThe ROI of these platforms begins to decline once you surpass initial growth thresholds, ultimately leading to a point where developing an in-house solution becomes the only viable optionThe ROI of these platforms begins to decline once you surpass initial growth thresholds, ultimately leading to a point where developing an in-house solution becomes the only viable option f"
    }

    func getContentHeight() -> Double {
        return lblTitle.frame.origin.y+lblBody.frame.origin.y+lblBody.frame.size.height+lblTitle.frame.origin.y
    }
}
