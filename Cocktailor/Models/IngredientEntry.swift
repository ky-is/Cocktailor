import Foundation
import CoreData

@objc(IngredientEntry)
public class IngredientEntry: NSManagedObject {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientEntry> {
		return NSFetchRequest<IngredientEntry>(entityName: "IngredientEntry")
	}

	@NSManaged public var favorite: Bool
	@NSManaged public var id: String
	@NSManaged public var owned: Bool
}
