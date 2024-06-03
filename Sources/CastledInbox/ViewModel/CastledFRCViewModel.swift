//
//  FRCModel.swift
//  CoredataPOC
//
//  Created by Antony Joe Mathew on 01/09/2022.
//

import CoreData
import Foundation

struct FRCViewModelActions {
    let controllerWillChangeContent: () -> Void?
    let controllerDidChangeContent: () -> Void?
    let insertSections: (IndexSet) -> Void?
    let deleteSections: (IndexSet) -> Void?
    let insertRowsAtIndexPath: (IndexPath) -> Void?
    let deletRowsAtIndexPath: (IndexPath) -> Void?
    let updateRowsAtIndexPath: (IndexPath) -> Void?
    let moveRowsAtIndexPath: (_ fr: IndexPath, _ t: IndexPath) -> Void?
}

protocol FRCViewModelInput {}

protocol FRCViewModelOutput {
    func numberOfSections() -> Int
    func numberOfRowsIn(section sec: Int) -> Int
}

class CastledFRCViewModel: NSObject, FRCViewModelInput, FRCViewModelOutput {
    let currentCategory: String
    let currentIndex: Int

    init(category: String, index: Int) {
        self.currentCategory = category
        self.currentIndex = index
    }

    private var actions: FRCViewModelActions? = nil

    lazy var fetchedResultsController:
        NSFetchedResultsController<CastledAppInbox> = {
            // 1
            let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
//            fetchRequest.fetchLimit = 2
//            fetchRequest.fetchBatchSize = 2
            let pinSort = NSSortDescriptor(
                key: #keyPath(CastledAppInbox.isPinned), ascending: false)
            let dateSort = NSSortDescriptor(
                key: #keyPath(CastledAppInbox.addedDate), ascending: false)

            fetchRequest.sortDescriptors = [pinSort, dateSort]
            let predicate = NSPredicate(format: currentIndex == 0 ? "isRemoved == %@" : "isRemoved == %@ AND tag = '\(currentCategory)'", NSNumber(value: false))
            fetchRequest.predicate = predicate
            fetchRequest.fetchLimit = 250
            // 2
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: CastledCoreDataStack.shared.mainContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            fetchedResultsController.delegate = self
            return fetchedResultsController
        }()

    func initialiseActions(actions: FRCViewModelActions? = nil) {
        self.actions = actions
    }

    func removeFRCDelegate() {
        fetchedResultsController.delegate = nil
    }

    func setUpDataSource() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
}

extension CastledFRCViewModel: NSFetchedResultsControllerDelegate {
    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsIn(section sec: Int) -> Int {
        guard let sectionInfo =
            fetchedResultsController.sections?[sec]
        else {
            return 0
        }

        return sectionInfo.numberOfObjects
    }

    // MARK: - FRC Delegates

    func controllerWillChangeContent(_:
        NSFetchedResultsController<NSFetchRequestResult>)
    {
        actions?.controllerWillChangeContent()
    }

    func controller(_:
        NSFetchedResultsController<NSFetchRequestResult>,
        didChange _: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?)
    {
        switch type {
        case .insert:
            actions?.insertRowsAtIndexPath(newIndexPath!)

        case .delete:
            actions?.deletRowsAtIndexPath(indexPath!)

        case .update:
            actions?.updateRowsAtIndexPath(indexPath!)

        case .move:
            actions?.moveRowsAtIndexPath(indexPath!, newIndexPath!)

            break

        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }

    func controllerDidChangeContent(_:
        NSFetchedResultsController<NSFetchRequestResult>)
    {
        actions?.controllerDidChangeContent()
    }

    func controller(_:
        NSFetchedResultsController<NSFetchRequestResult>,
        didChange _: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType)
    {
        let indexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            actions?.insertSections(indexSet)

        case .delete:

            actions?.deleteSections(indexSet)

        default: break
        }
    }
}
