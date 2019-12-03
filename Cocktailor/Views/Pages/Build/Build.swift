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

	private func cocktailHasSelectedIngredients(_ cocktail: CocktailData, selectedIngredients: Set<String>) -> [IngredientData]? {
		var missingSelectedIngredients = Set(selectedIngredients)
		var foundIngredients = [IngredientData]()
		for ingredientQuantity in cocktail.ingredients {
			let ingredient = ingredientQuantity.ingredient
			if missingSelectedIngredients.contains(ingredient.id) {
				missingSelectedIngredients.remove(ingredient.id)
				foundIngredients.append(ingredient)
			} else {
				var hasSubstitute = false
				for substitution in ingredient.substitutions {
					let substituteIngredient = missingSelectedIngredients.remove(substitution.ingredient.id)
					if substituteIngredient != nil {
						hasSubstitute = true
						missingSelectedIngredients.remove(ingredient.id)
						foundIngredients.append(substitution.ingredient)
						break
					}
				}
				if !hasSubstitute {
					foundIngredients.append(ingredient)
				}
			}
		}
		return missingSelectedIngredients.isEmpty ? foundIngredients : nil
	}

	var body: some View {
		let availableIngredientEntries = ingredientEntries.filter { $0.owned && IngredientData.keyValues[$0.id] != nil }
		let availableIDs = availableIngredientEntries.map { $0.id }
		var displayCocktails = [CocktailData]()
		var missingOneCocktails = [CocktailData]()
		CocktailData.keyValues.values.forEach { cocktail in
			var missingCount = 0
			for ingredientQuantity in cocktail.ingredients {
				let ingredientID = ingredientQuantity.id
				if !availableIDs.contains(ingredientID) {
					var hasSubstitute = false
					for substitutionID in ingredientQuantity.ingredient.substitutionIDs {
						if availableIDs.contains(substitutionID) {
							hasSubstitute = true
							break
						}
					}
					if !hasSubstitute {
						missingCount += 1
						if missingCount > 1 {
							break
						}
					}
				}
			}
			if missingCount == 0 {
				displayCocktails.append(cocktail)
			} else if missingCount == 1 {
				missingOneCocktails.append(cocktail)
			}
		}
		var possibleIngredients = Set<IngredientData>()
		if let selectedIngredients = observedIngredients.selected {
			displayCocktails = displayCocktails.filter {
				if let found = cocktailHasSelectedIngredients($0, selectedIngredients: selectedIngredients) {
					found.forEach { possibleIngredients.insert($0) }
					return true
				}
				return false
			}
			missingOneCocktails = missingOneCocktails.filter { cocktailHasSelectedIngredients($0, selectedIngredients: selectedIngredients) != nil }
		}
		displayCocktails.sort { $0.id < $1.id }
		let hasFilteredCocktail = displayCocktails.count < CocktailData.keyValues.values.count
		return GeometryReader { geometry in
			if geometry.size.width > 1112 {
				BuildDoubleTripleColumn(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: hasFilteredCocktail ? possibleIngredients : nil)
			} else if geometry.size.width > 960 { // Needed to fix SplitView behavior on narrow screens which hide master.
				BuildTripleColumnManual(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: hasFilteredCocktail ? possibleIngredients : nil)
			} else if geometry.size.width > 512 {
				BuildDoubleTripleColumn(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: hasFilteredCocktail ? possibleIngredients : nil)
					.navigationViewStyle(StackNavigationViewStyle())
			} else {
				BuildSingle(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, cocktails: displayCocktails, missingOneCocktails: missingOneCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: hasFilteredCocktail ? possibleIngredients : nil)
			}
		}
	}
}

struct BuildCocktailsDetailListEntries: View {
	let cocktails: [CocktailData]

	var body: some View {
		ForEach(cocktails) { cocktailData in
			NavigationLink(destination: CocktailDetail(data: cocktailData)) {
				BuildCocktailListRowContent(data: cocktailData)
			}
				.isDetailLink(true)
		}
	}
}

struct BuildCocktailsDetailList: View {
	let cocktails: [CocktailData]
	let missingOneCocktails: [CocktailData]
	let insertBlank: Bool

	var body: some View {
		List {
		EmptyView()
			Section(header: Text("Available")) {
				if !cocktails.isEmpty {
					BuildCocktailsDetailListEntries(cocktails: cocktails)
				} else {
					Text("No cocktails available, try adding some more ingredients!")
						.foregroundColor(.secondary)
						.multilineTextAlignment(.center)
						.padding()
				}
			}
			if !missingOneCocktails.isEmpty {
				Section(header: Text("Missing one")) {
					BuildCocktailsDetailListEntries(cocktails: missingOneCocktails)
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
				IngredientListEntry(data: IngredientData.keyValues[entry.id]!, entry: .constant(entry), observededIngredients: self.observedIngredients, hasCocktail: self.possibleIngredients?.contains(IngredientData.keyValues[entry.id]!) ?? true) //TODO filter []! != nil
			}
			if insertBlank {
				Text("")
			}
		}
			.navigationBarTitle("Ingredients")
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
