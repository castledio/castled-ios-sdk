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
    lazy var inboxUnreadCount: Int = {
        CastledStore.getIAllnboxItemsCount(realm: CastledDBManager.shared.getRealm())

    }()

    @Published var errorMessage: String?
    @Published var showLoader: Bool = false
    var isLoading = false
    func didLoadNextPage() {
        if isLoading {
            return
        }
        isLoading = true
        if inboxUnreadCount == 0 {
            showLoader = true
        }
        Castled.fetchInboxItems { [weak self] response in
            if !response.success {
                CastledLog.castledLog("Fetch inbox items failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
//                DispatchQueue.main.async {
//                    self?.errorMessage = response.errorMessage
//                }
            }
            self?.showLoader = false
            self?.isLoading = false
        }
    }

    func didSelectItem(at index: Int) {}
}
