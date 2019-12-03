import SwiftUI

struct BuildDoubleTripleColumn: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let cocktails: [CocktailData]
	let missingOneCocktails: [CocktailData]
	let hasFilteredCocktail: Bool
	let possibleIngredients: Set<IngredientData>?

	var body: some View {
		HStack(spacing: 0) {
			NavigationView {
				BuildIngredients(availableIngredientEntries: availableIngredientEntries, observedIngredients: observedIngredients, possibleIngredients: possibleIngredients, insertBlank: false)
			}
				.frame(width: 321) //TODO iPadPro13 376
			NavigationView {
				BuildCocktailsDetailList(cocktails: cocktails, missingOneCocktails: missingOneCocktails, insertBlank: false)
				BuildCocktailPlaceholder()
			}
		}
	}
}

struct BuildDoubleTripleColumn_Previews: PreviewProvider {
	static var previews: some View {
		BuildDoubleTripleColumn(availableIngredientEntries: [], observedIngredients: ObservableIngredients(selected: Set()), cocktails: Array(CocktailData.keyValues.values), missingOneCocktails: [], hasFilteredCocktail: true, possibleIngredients: Set(Array(IngredientData.keyValues.values)))
			.previewDevice(.iPadPro11)
	}
}
