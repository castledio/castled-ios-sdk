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
    let realm = try! Realm()
    lazy var inboxItems: Results<CAppInbox> = { realm.objects(CAppInbox.self) }()

    @Published var errorMessage: String?
    @Published var showLoader: Bool = false

    func didLoadNextPage() {
        if inboxItems.isEmpty {
            showLoader = true
        }
        Castled.sharedInstance?.getInboxItems(completion: { [weak self] success, _, errorMessage1 in
            if !success {
                DispatchQueue.main.async {

                        self?.errorMessage = errorMessage1
           
                }
            }
            self?.showLoader = false
        })
    }

    func didSelectItem(at index: Int) {}
}
