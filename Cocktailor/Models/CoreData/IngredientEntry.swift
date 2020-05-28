import CoreData

@objc(IngredientEntry)
public final class IngredientEntry: NSManagedObject, Identifiable {
	@NSManaged public var id: String
	@NSManaged public var favorite: Bool
	@NSManaged public var owned: Bool
}
