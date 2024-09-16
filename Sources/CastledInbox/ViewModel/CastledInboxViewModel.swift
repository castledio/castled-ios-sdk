//
//  CastledInboxViewModel.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import Combine
import Foundation

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
    lazy var inboxItemsCount: Int = {
        CastledInboxCoreDataOperations.shared.getAllInboxItemsCount()

    }()

    @Published var errorMessage: String?
    @Published var showLoader: Bool = false
    var isLoading = false
    func didLoadNextPage() {
        if isLoading {
            return
        }
        isLoading = true
        if inboxItemsCount == 0 {
            showLoader = true
        }
        CastledInboxRepository.fetchInboxItems { [weak self] in
            self?.showLoader = false
            self?.isLoading = false
        }
    }

    func didSelectItem(at index: Int) {}
}
