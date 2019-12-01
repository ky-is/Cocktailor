import SwiftUI

struct BuildDoubleTripleColumn: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let displayCocktails: [CocktailData]
	let hasFilteredCocktail: Bool
	let possibleIngredients: Set<IngredientData>?

	var body: some View {
		HStack(spacing: 0) {
			NavigationView {
				BuildIngredients(availableIngredientEntries: availableIngredientEntries, observedIngredients: observedIngredients, possibleIngredients: possibleIngredients, insertBlank: false)
			}
				.frame(width: 321)
			NavigationView {
				BuildCocktailsDetailList(displayCocktails: displayCocktails, insertBlank: false)
				BuildCocktailPlaceholder()
			}
		}
	}
}

struct BuildDoubleTripleColumn_Previews: PreviewProvider {
	static var previews: some View {
		BuildDoubleTripleColumn(availableIngredientEntries: [], observedIngredients: ObservableIngredients(selected: Set()), displayCocktails: Array(CocktailData.keyValues.values), hasFilteredCocktail: true, possibleIngredients: Set(Array(IngredientData.keyValues.values)))
	}
}
