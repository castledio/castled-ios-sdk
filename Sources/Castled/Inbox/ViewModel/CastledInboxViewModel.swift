//
//  CastledInboxViewModel.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import Foundation
import Combine

struct CastledInboxViewModelActions {

}
protocol CastledInboxViewModelInput {
    func didLoadNextPage()
    func didSelectItem(at index: Int)
}
protocol CastledInboxViewModelOutput {
    var inboxItems: [CastledInboxItem] { get }
    var errorMessage: String? { get }
    var showLoader: Bool { get }

}
protocol DefaultCastledInboxViewModel: CastledInboxViewModelInput, CastledInboxViewModelOutput {}

final class CastledInboxViewModel: DefaultCastledInboxViewModel {
    @Published var inboxItems =  [CastledInboxItem]()
    @Published var errorMessage: String?
    @Published var showLoader: Bool = false

    func didLoadNextPage() {
        showLoader = true
        Castled.sharedInstance?.getInboxItems(completion: {[weak self] success, items, errorMessage1 in
            if success {
                self?.inboxItems.removeAll()
                self?.inboxItems.append(contentsOf: items ?? [])
            } else {
                self?.errorMessage = errorMessage1
            }
            self?.showLoader = false
        })
    }

    func didSelectItem(at index: Int) {

    }

}
