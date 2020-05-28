import SwiftUI

struct MyBar: View {
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>

	private let displayIngredients = IngredientData.ownableIngredients.sorted(\.id, <)

	var body: some View {
		let ingredientEntriesByID = ingredientEntries.keyed(by: \.id)
		return NavigationView {
			List(displayIngredients) { data in
				IngredientListEntry(data: data, entry: ingredientEntriesByID[data.id], observedIngredients: ObservableIngredients.inactive, hasCocktail: true)
			}
				.modifier(MyBarNavigationModifier(ownedEntries: ingredientEntries.filter(\.owned)))
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

private struct MyBarNavigationModifier: ViewModifier {
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
