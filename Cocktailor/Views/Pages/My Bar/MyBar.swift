import SwiftUI

struct MyBar: View {
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>

	@Environment(\.managedObjectContext) private var managedObjectContext
	private let displayIngredients = IngredientData.ownableIngredients.sorted(\.id, <)

	var body: some View {
		var ingredientEntriesByID = [String: IngredientEntry]()
		for ingredientEntry in ingredientEntries {
			ingredientEntriesByID[ingredientEntry.id] = ingredientEntry
		}
		let ownedEntries = ingredientEntries.filter(\.owned)
		let ownedCount = ownedEntries.count
		return NavigationView {
			List(displayIngredients) { data in
				IngredientListEntry(data: data, entry: .constant(ingredientEntriesByID[data.id]), observedIngredients: ObservableIngredients.inactive, hasCocktail: true)
			}
				.navigationBarTitle("Ingredient".pluralize(ownedCount))
				.navigationBarItems(trailing:
					Group {
						if ownedCount > 0 {
							Button(action: {
								self.managedObjectContext.perform {
									ownedEntries.forEach { $0.owned = false }
								}
							}, label: {
								Text("Clear owned")
							})
						}
					}
				)
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct MyBar_Previews: PreviewProvider {
	static var previews: some View {
		MyBar()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
