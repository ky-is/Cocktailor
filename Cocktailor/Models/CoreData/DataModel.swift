import CoreData

struct DataModel {
	static let persistentContainer: NSPersistentCloudKitContainer = {
		let container = NSPersistentCloudKitContainer(name: "Cocktailor")
		container.loadPersistentStores { storeDescription, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
			container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
			container.viewContext.automaticallyMergesChangesFromParent = true
		}
		return container
	}()

	static func perform(block: @escaping () -> Void) {
		persistentContainer.viewContext.perform(block)
		saveContext()
	}

	static func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
}

extension CocktailEntry {
	convenience init(id: String) {
		self.init(context: DataModel.persistentContainer.viewContext)
		self.id = id
	}
}
