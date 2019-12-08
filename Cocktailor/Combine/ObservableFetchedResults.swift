import Combine
import CoreData
import SwiftUI

final class ObservableFetchedResults<ResultType: NSFetchRequestResult>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
	let controller: NSFetchedResultsController<ResultType>
	var results: [ResultType] {
		return controller.fetchedObjects!
	}
	internal let objectWillChange = ObservableObjectPublisher()

	init(fetchRequest: NSFetchRequest<ResultType>, managedObjectContext: NSManagedObjectContext) {
		self.controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		super.init()
		self.controller.delegate = self
		do {
			try controller.performFetch()
		} catch {
			print(error)
		}
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		objectWillChange.send()
	}
}
