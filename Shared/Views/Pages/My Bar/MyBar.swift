import SwiftUI

struct MyBar: View {
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>

	private let displayIngredients = IngredientData.ownableIngredients.sorted(\.id, <)

	var body: some View {
		NavigationView {
			AllIngredientsList(ingredientEntriesByID: ingredientEntries.keyed(by: \.id))
				.modifier(AllIngredientsListModifier(ownedEntries: ingredientEntries.filter(\.owned)))
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

private struct AllIngredientsList: View {
	let ingredientEntriesByID: [String: IngredientEntry]

	private let displayIngredients = IngredientData.ownableIngredients.sorted(\.id, <)

	var body: some View {
		List(displayIngredients) { data in
			IngredientListEntry(data: data, entry: self.ingredientEntriesByID[data.id], observedIngredients: ObservableIngredients.inactive, hasCocktail: true)
		}
	}
}

private struct AllIngredientsListModifier: ViewModifier {
	let ownedEntries: [IngredientEntry]

	@Environment(\.managedObjectContext) private var context

	func body(content: Content) -> some View {
		content
			.navigationBarTitle("Ingredient".pluralize(ownedEntries.count))
			.navigationBarItems(trailing: Group {
				if !ownedEntries.isEmpty {
					Button(action: {
						self.context.performAndSave {
							self.ownedEntries.forEach { $0.owned = false }
						}
					}, label: {
						Text("Clear owned")
					})
				}
			})
	}
}

struct MyBar_Previews: PreviewProvider {
	static var previews: some View {
		MyBar()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
