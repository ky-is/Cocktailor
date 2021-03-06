import SwiftUI

struct BuildSingle: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let cocktails: [CocktailData]
	let missingOneCocktails: [CocktailData]
	let hasFilteredCocktail: Bool
	let possibleIngredients: Set<IngredientData>?

	@State private var showCocktails = true

	var body: some View {
		ZStack(alignment: .bottom) {
			if !showCocktails {
				NavigationView {
					BuildIngredients(availableIngredientEntries: availableIngredientEntries, observedIngredients: observedIngredients, possibleIngredients: possibleIngredients, insertBlank: true)
				}
					.transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
			} else {
				NavigationView {
					BuildCocktailsDetailList(cocktails: cocktails, missingOneCocktails: missingOneCocktails, insertBlank: true)
					BuildCocktailPlaceholder()
				}
					.transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
			}
			ModePicker(showCocktails: $showCocktails, observedIngredients: observedIngredients, cocktails: cocktails, hasFilteredCocktail: hasFilteredCocktail)
		}
	}
}

private struct ModePicker: View {
	@Binding var showCocktails: Bool
	@ObservedObject var observedIngredients: ObservableIngredients
	let cocktails: [CocktailData]
	let hasFilteredCocktail: Bool

	var body: some View {
		Picker("", selection: $showCocktails.animation()) {
			Text(observedIngredients.selected!.count > 0 ? "Ingredient".pluralize(observedIngredients.selected!.count) : "Any Ingredients")
				.tag(false)
			Text(hasFilteredCocktail ? "Cocktail".pluralize(cocktails.count) : "All Cocktails")
				.tag(true)
		}
			.padding(.horizontal)
			.frame(height: 48)
			.background(BlurView(style: .systemChromeMaterial))
			.labelsHidden()
			.pickerStyle(SegmentedPickerStyle())
	}
}

struct BuildSingle_Previews: PreviewProvider {
	static var previews: some View {
		BuildSingle(availableIngredientEntries: [], observedIngredients: ObservableIngredients(selected: Set()), cocktails: Array(CocktailData.keyValues.values), missingOneCocktails: [], hasFilteredCocktail: true, possibleIngredients: Set(Array(IngredientData.keyValues.values)))
	}
}
