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
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.favorite, ascending: false), NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>
	@ObservedObject private var observedIngredients = ObservableIngredients.active

	private func availableIngredientsFor(cocktail: CocktailData, ifItHasAll selectedIngredients: Set<String>, availableIngredients: [String]) -> Set<IngredientData>? {
		var missingSelectedIngredients = Set(selectedIngredients)
		var foundIngredients = Set<IngredientData>()
		for ingredientQuantity in cocktail.ingredients {
			let ingredient = ingredientQuantity.ingredient
			if let usableIngredient = ingredient.bestIngredient(available: availableIngredients) {
				if missingSelectedIngredients.remove(ingredient.id) == nil {
					missingSelectedIngredients.remove(usableIngredient.id)
				}
				foundIngredients.insert(usableIngredient)
			}
		}
		return missingSelectedIngredients.isEmpty ? foundIngredients : nil
	}

	var body: some View {
		let availableIngredientEntries = ingredientEntries.filter { $0.owned && IngredientData.keyValues[$0.id] != nil }
		let ownedIngredientIDs = availableIngredientEntries.map { $0.id }
		var possibleCocktails = [CocktailData]()
		var missingOneCocktails = [CocktailData]()
		CocktailData.keyValues.values.forEach { cocktail in
			var missingCount = 0
			for ingredientQuantity in cocktail.ingredients {
				let usableIngredient = ingredientQuantity.ingredient.bestIngredient(available: ownedIngredientIDs)
				if usableIngredient == nil {
					missingCount += 1
					if missingCount > 1 {
						break
					}
				}
			}
			if missingCount == 0 {
				possibleCocktails.append(cocktail)
			} else if missingCount == 1 {
				missingOneCocktails.append(cocktail)
			}
		}
		var ingredientsInFilteredCocktails = Set<IngredientData>()
		let displayCocktails: [CocktailData]
		if let selectedIngredients = observedIngredients.selected, !selectedIngredients.isEmpty {
			displayCocktails = possibleCocktails
				.filter { cocktail in
					if let availableIngredientsForCocktail = availableIngredientsFor(cocktail: cocktail, ifItHasAll: selectedIngredients, availableIngredients: ownedIngredientIDs) {
						ingredientsInFilteredCocktails.formUnion(availableIngredientsForCocktail)
						return true
					}
					return false
				}
				.sorted { $0.id < $1.id }
			missingOneCocktails = missingOneCocktails.filter { availableIngredientsFor(cocktail: $0, ifItHasAll: selectedIngredients, availableIngredients: ownedIngredientIDs) != nil }
		} else {
			displayCocktails = possibleCocktails
		}
		let hasFilteredCocktail = displayCocktails.count < possibleCocktails.count
		let possibleIngredients = hasFilteredCocktail ? ingredientsInFilteredCocktails : nil
		return GeometryReader { geometry in
			if geometry.size.width > 1112 {
				BuildDoubleTripleColumn(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: possibleIngredients)
			} else if geometry.size.width > 960 { // Needed to fix SplitView behavior on narrow screens which hide master.
				BuildTripleColumnManual(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: possibleIngredients)
			} else if geometry.size.width > 512 {
				BuildDoubleTripleColumn(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: possibleIngredients)
					.navigationViewStyle(StackNavigationViewStyle())
			} else {
				BuildSingle(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: possibleIngredients)
			}
		}
	}
}

struct BuildCocktailsDetailListEntries: View {
	let cocktails: [CocktailData]
	let insertBlank: Bool

	var body: some View {
		ForEach(cocktails) { cocktailData in
			NavigationLink(destination:
				CocktailDetail(data: cocktailData)
					.padding(.bottom, self.insertBlank ? 36 : 0)
			) {
				BuildCocktailListRowContent(data: cocktailData)

			}
				.isDetailLink(true)
		}
	}
}

struct BuildEmptyCocktails: View {
	var body: some View {
		Text("No cocktails available, try adding some more ingredients!")
			.foregroundColor(.secondary)
			.multilineTextAlignment(.center)
			.padding()
	}
}

struct BuildCocktailsDetailList: View {
	let cocktails: [CocktailData]
	let missingOneCocktails: [CocktailData]
	let insertBlank: Bool

	var body: some View {
		List {
			SectionVibrant(label: "\(cocktails.count) available") {
				if !self.cocktails.isEmpty {
					BuildCocktailsDetailListEntries(cocktails: self.cocktails, insertBlank: self.insertBlank)
				} else {
					BuildEmptyCocktails()
				}
			}
			if !missingOneCocktails.isEmpty {
				SectionVibrant(label: "\(missingOneCocktails.count) missing one") {
					BuildCocktailsDetailListEntries(cocktails: self.missingOneCocktails, insertBlank: self.insertBlank)
						.foregroundColor(.secondary)
				}
			}
			if insertBlank {
				Text("")
			}
		}
			.navigationBarTitle("Cocktails")
	}
}

struct BuildCocktailListRowContent: View {
	let data: CocktailData

	var body: some View {
		HStack {
			HStack(spacing: 0) {
				CocktailImage(data: data, size: 80)
				Text(data.name)
					.frame(minWidth: 64)
					.layoutPriority(0.5)
			}
			Spacer()
			HStack(spacing: 0) {
				ForEach(data.ingredients) { ingredientQuantity in
					IngredientImage(data: ingredientQuantity.ingredient, size: 32)
				}
			}
				.layoutPriority(1)
		}
	}
}

struct BuildCocktailPlaceholder: View {
	var body: some View {
		Text("Toggle ingredients or select a cocktail")
			.foregroundColor(.secondary)
	}
}

struct BuildIngredients: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let possibleIngredients: Set<IngredientData>?
	let insertBlank: Bool

	var body: some View {
		List {
			ForEach(availableIngredientEntries) { entry in
				IngredientListEntry(data: IngredientData.keyValues[entry.id]!, entry: .constant(entry), observedIngredients: self.observedIngredients, hasCocktail: self.possibleIngredients?.contains(IngredientData.keyValues[entry.id]!) ?? true) //TODO filter []! != nil
			}
			if insertBlank {
				Text("")
			}
		}
			.navigationBarTitle("Ingredient".pluralize(availableIngredientEntries.count))
			.navigationBarItems(trailing:
				Group {
					if !(self.observedIngredients.selected?.isEmpty ?? true) {
						Button(action: {
							self.observedIngredients.selected?.removeAll()
						}, label: {
							Text("Clear ingredients")
						})
					}
				}
			)
	}
}

struct Build_Previews: PreviewProvider {
	static var previews: some View {
		Build()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
