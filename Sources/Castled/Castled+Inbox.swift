//
//  Castled+Inbox.swift
//  Castled
//
//  Created by antony on 31/08/2023.
//

import Foundation
import UIKit

extension Castled{
    /**
     Inbox : Function that will returns the Inbox ViewController
     */
    @objc public func getInboxViewController() -> CastledInboxViewController {

        let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: Castled.self)).instantiateViewController(identifier: "CastledInboxViewController") as! CastledInboxViewController
        castledInboxVC.inboxItems.append(contentsOf: inboxItemsArray)
        return castledInboxVC

    }
    /**
     Inbox : Function to get inbox items array
     */
    @objc public func getInboxItems(completion: @escaping (_ success: Bool, _ items: [CastledInboxItem]?,_ errorMessage: String?) -> Void){
        Castled.fetchInboxItems {[weak self] response in
            if(response.success){
                self?.inboxItemsArray.removeAll()
                self?.inboxItemsArray.append(contentsOf: response.result ?? [])
            }
            completion(response.success,response.result,response.errorMessage)
        }
    }
    /**
     Inbox : Function to mark inbox items as read
     */
    @objc public func logInboxItemsRead(_ inboxItems : [CastledInboxItem]){

        CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems)

    }
    /**
     Inbox : Function to mark inbox item as clicked
     */
    @objc public func logInboxItemClicked(_ inboxItem : CastledInboxItem, buttonTitle: String?){
        CastledInboxServices().reportInboxItemsClicked(inboxObject: inboxItem, buttonTitle: buttonTitle)
    }
    /**
     Inbox : Function to delete an inbox item
     */
    @objc public func deleteInboxItem(_ inboxItem : CastledInboxItem,completion: @escaping (_ success: Bool,_ errorMessage: String?) ->Void){
        CastledInboxServices().reportInboxItemsDeleted(inboxObject: inboxItem) { success, errorMessage in
            completion(success,errorMessage)
        }
    }
}
