import SwiftUI

struct BuildTripleColumnManual: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let cocktails: [CocktailData]
	let missingOneCocktails: [CocktailData]
	let hasFilteredCocktail: Bool
	let possibleIngredients: Set<IngredientData>?

	@State private var selectedCocktail: CocktailData?

	var body: some View {
		HStack(spacing: 0) {
			NavigationView {
				BuildIngredients(availableIngredientEntries: availableIngredientEntries, observedIngredients: observedIngredients, possibleIngredients: possibleIngredients, insertBlank: false)
			}
				.frame(width: 321) //TODO iPadPro13 376
			NavigationView {
				BuildCocktailsManualList(cocktails: cocktails, missingOneCocktails: missingOneCocktails, selectedCocktail: $selectedCocktail)
					.navigationBarTitle("Cocktails")
			}
				.frame(width: 321)
			NavigationView {
				Group {
					if selectedCocktail != nil {
						CocktailDetail(data: selectedCocktail!)
					} else {
						BuildCocktailPlaceholder()
					}
				}
					.frame(maxWidth: .greatestFiniteMagnitude)
			}
				.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}

private struct BuildCocktailsManualListEntries: View {
	let cocktails: [CocktailData]
	@Binding var selectedCocktail: CocktailData?

	var body: some View {
		ForEach(cocktails) { cocktailData in
			Button(action: {
				self.selectedCocktail = cocktailData
			}) {
				BuildCocktailListRowContent(data: cocktailData)
			}
				.tag(cocktailData as CocktailData?)
		}
	}
}

private struct BuildCocktailsManualList: View {
	let cocktails: [CocktailData]
	let missingOneCocktails: [CocktailData]
	@Binding var selectedCocktail: CocktailData?

	var body: some View {
		List {
			SectionVibrant(label: "\(cocktails.count) available") {
				if self.cocktails.isEmpty {
					BuildEmptyCocktails()
				} else {
					BuildCocktailsManualListEntries(cocktails: self.cocktails, selectedCocktail: self.$selectedCocktail)
				}
			}
			if !missingOneCocktails.isEmpty {
				SectionVibrant(label: "\(missingOneCocktails.count) missing one") {
					BuildCocktailsManualListEntries(cocktails: self.missingOneCocktails, selectedCocktail: self.$selectedCocktail)
						.foregroundColor(.secondary)
				}
			}
		}
	}
}

struct BuildTripleColumnManual_Previews: PreviewProvider {
	static var previews: some View {
		BuildTripleColumnManual(availableIngredientEntries: [], observedIngredients: ObservableIngredients(selected: Set()), cocktails: Array(CocktailData.keyValues.values), missingOneCocktails: [], hasFilteredCocktail: true, possibleIngredients: Set(Array(IngredientData.keyValues.values)))
			.previewDevice(.iPadPro11)
	}
}
