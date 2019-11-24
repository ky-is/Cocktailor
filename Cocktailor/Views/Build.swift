import SwiftUI

final class ObservableIngredients: ObservableObject {
	static let active = ObservableIngredients(selected: Set<String>())
	static let inactive = ObservableIngredients(selected: nil)

	@Published var selected: Set<String>?

	init(selected: Set<String>?) {
		self.selected = selected
	}
}

struct Build: View {
	let displayCocktails: [CocktailData]

	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>
	@ObservedObject private var observedIngredients = ObservableIngredients.active

	init() {
		self.displayCocktails = Array(cocktails.values)
	}

	var body: some View {
		var ingredientEntriesByID = [String: IngredientEntry]()
		for ingredientEntry in ingredientEntries {
			ingredientEntriesByID[ingredientEntry.id] = ingredientEntry
		}
		let availableIngredients = ingredientEntries.filter { $0.owned }
		return NavigationView {
			List {
				ForEach(availableIngredients, id: \.self) { entry in
					IngredientListEntry(data: ingredients[entry.id]!, entry: .constant(entry), observededIngredients: self.observedIngredients) //TODO filter []! != nil
				}
			}
				.navigationBarTitle("Build")
			List {
				ForEach(displayCocktails) { data in
					Text(data.name)
				}
			}
		}
	}
}

struct Build_Previews: PreviewProvider {
	static var previews: some View {
		Build()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
