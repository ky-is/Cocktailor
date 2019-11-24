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
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>
	@ObservedObject private var observedIngredients = ObservableIngredients.active

	init() {

	}

	var body: some View {
		var displayCocktails = Array(cocktails.values)
		if let selectedIngredients = observedIngredients.selected {
			displayCocktails = displayCocktails.filter { cocktail in
				for selectedIngredient in selectedIngredients {
					var foundIngredient = false
					for cocktailIngredientQuantity in cocktail.ingredients {
						if cocktailIngredientQuantity.ingredient.id == selectedIngredient {
							foundIngredient = true
							break
						}
					}
					if !foundIngredient {
						return false
					}
				}
				return true
			}
		}
		let availableIngredients = ingredientEntries.filter { $0.owned }
		return NavigationView {
			List {
				ForEach(availableIngredients, id: \.self) { entry in
					IngredientListEntry(data: ingredients[entry.id]!, entry: .constant(entry), observededIngredients: self.observedIngredients) //TODO filter []! != nil
				}
			}
				.navigationBarTitle("Build")
			NavigationView {
				List {
					ForEach(displayCocktails) { data in
						NavigationLink(destination: CocktailDetail(data: data)) {
							Text(data.name)
						}
							.isDetailLink(false)
					}
				}
			}
		}
			.padding(0.25) //BUILD 13.2.2: required workaround to force master/detail to both show
	}
}

struct Build_Previews: PreviewProvider {
	static var previews: some View {
		Build()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
