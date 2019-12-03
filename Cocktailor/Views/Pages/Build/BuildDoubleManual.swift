import SwiftUI

struct BuildTripleColumnManual: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let cocktails: [CocktailData]
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
					BuildCocktailsManualList(cocktails: cocktails, selectedCocktail: $selectedCocktail)
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
	let cocktails: [CocktailData]
	@Binding var selectedCocktail: CocktailData?

	var body: some View {
		List(cocktails, selection: $selectedCocktail) { cocktailData in
			Button(action: {
				self.selectedCocktail = cocktailData
			}) {
				BuildCocktailListRowContent(data: cocktailData)
			}
				.tag(cocktailData as CocktailData?)
		}
	}
}

struct BuildTripleColumnManual_Previews: PreviewProvider {
	static var previews: some View {
		BuildTripleColumnManual(availableIngredientEntries: [], observedIngredients: ObservableIngredients(selected: Set()), cocktails: Array(CocktailData.keyValues.values), hasFilteredCocktail: true, possibleIngredients: Set(Array(IngredientData.keyValues.values)))
	}
}
