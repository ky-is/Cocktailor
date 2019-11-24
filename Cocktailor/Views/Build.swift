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
		return NavigationView {
			BuildIngredients(ingredientEntries: ingredientEntries, observedIngredients: observedIngredients)
				.navigationBarTitle("Build")
			BuildCocktails(displayCocktails: displayCocktails)
		}
			.padding(0.25) //BUILD 13.2.2: required workaround to force master/detail to both show
	}
}

private struct BuildIngredients: View {
	let ingredientEntries: FetchedResults<IngredientEntry>
	let observedIngredients: ObservableIngredients

	var body: some View {
		let availableIngredients = ingredientEntries.filter { $0.owned }
		return List {
			ForEach(availableIngredients, id: \.self) { entry in
				IngredientListEntry(data: ingredients[entry.id]!, entry: .constant(entry), observededIngredients: self.observedIngredients) //TODO filter []! != nil
			}
		}
	}
}

private struct BuildCocktails: View {
	let displayCocktails: [CocktailData]

	var body: some View {
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
}

struct Build_Previews: PreviewProvider {
	static var previews: some View {
		Build()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
