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

//			try! container.viewContext.execute(NSBatchDeleteRequest(fetchRequest: IngredientEntry.fetchRequest())) //SAMPLE
		}
		return container
	}()

	static func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			context.safeSave()
		}
	}
}

extension CocktailEntry {
	convenience init(id: String, insertInto context: NSManagedObjectContext?) {
		self.init(entity: Self.entity(), insertInto: context)
		self.id = id
	}
}

extension IngredientEntry {
	convenience init(id: String, insertInto context: NSManagedObjectContext?) {
		self.init(entity: Self.entity(), insertInto: context)
		self.id = id
	}
}

extension NSManagedObjectContext {
	func safeSave() {
		do {
			try save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}

	func performAndSave(block: @escaping () -> Void) {
		perform {
			block()
			self.safeSave()
		}
	}
}
