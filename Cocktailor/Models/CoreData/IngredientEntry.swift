import CoreData

@objc(IngredientEntry)
public final class IngredientEntry: NSManagedObject, Identifiable {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientEntry> {
		return NSFetchRequest<IngredientEntry>(entityName: "IngredientEntry")
	}

	@NSManaged public var favorite: Bool
	@NSManaged public var id: String
	@NSManaged public var owned: Bool
}
