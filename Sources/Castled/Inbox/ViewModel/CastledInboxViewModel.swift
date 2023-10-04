//
//  CastledInboxViewModel.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import Combine
import Foundation
import RealmSwift

struct CastledInboxViewModelActions {}

protocol CastledInboxViewModelInput {
    func didLoadNextPage()
    func didSelectItem(at index: Int)
}

protocol CastledInboxViewModelOutput {
    var errorMessage: String? { get }
    var showLoader: Bool { get }
}

protocol DefaultCastledInboxViewModel: CastledInboxViewModelInput, CastledInboxViewModelOutput {}

final class CastledInboxViewModel: DefaultCastledInboxViewModel {
    let realm = CastledDBManager.shared.getRealm()
    lazy var inboxItems: Results<CAppInbox> = { realm.objects(CAppInbox.self)
        .filter("isDeleted == false")
        .sorted(byKeyPath: "isPinned", ascending: false)
        .sorted(byKeyPath: "addedDate", ascending: false)
    }()

    @Published var errorMessage: String?
    @Published var showLoader: Bool = false

    func didLoadNextPage() {
        if inboxItems.isEmpty {
            showLoader = true
        }
        Castled.fetchInboxItems { response in
            if !response.success {
                DispatchQueue.main.async {
                    self.errorMessage = response.errorMessage
                }
            }
            self.showLoader = false
        }
    }

    func didSelectItem(at index: Int) {}
}
