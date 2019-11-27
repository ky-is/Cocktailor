import SwiftUI

struct BuildDoubleManual: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let displayCocktails: [CocktailData]
	let hasFilteredCocktail: Bool
	let possibleIngredients: Set<IngredientData>?

	@State private var selectedCocktail: CocktailData?

	var body: some View {
		HStack(spacing: 0) {
			NavigationView {
				BuildIngredients(availableIngredientEntries: availableIngredientEntries, observedIngredients: observedIngredients, possibleIngredients: possibleIngredients, insertBlank: false)
			}
			.frame(width: 321)
			NavigationView {
				HStack(spacing: 0) {
					BuildCocktailsManualList(displayCocktails: displayCocktails, selectedCocktail: $selectedCocktail)
						.frame(width: 321)
					Divider()
					Group {
						if selectedCocktail != nil {
							CocktailDetail(data: selectedCocktail!)
						} else {
							BuildCocktailPlaceholder()
								.navigationBarTitle("Cocktails")
						}
					}
					.frame(maxWidth: .greatestFiniteMagnitude)
				}
			}
			.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}

private struct BuildCocktailsManualList: View {
	let displayCocktails: [CocktailData]
	@Binding var selectedCocktail: CocktailData?

	var body: some View {
		List(displayCocktails, selection: $selectedCocktail) { cocktailData in
			Button(action: {
				self.selectedCocktail = cocktailData
			}) {
				BuildCocktailListRowContent(data: cocktailData)
			}
			.tag(cocktailData as CocktailData?)
		}
	}
}

struct BuildDoubleManual_Previews: PreviewProvider {
	static var previews: some View {
		BuildDoubleManual(availableIngredientEntries: [], observedIngredients: ObservableIngredients(selected: Set()), displayCocktails: Array(CocktailData.keyValues.values), hasFilteredCocktail: true, possibleIngredients: Set(Array(IngredientData.keyValues.values)))
	}
}
