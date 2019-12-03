import SwiftUI

struct Explore: View {
	var body: some View {
		let cocktails = CocktailData.keyValues.values.sorted { $0.id < $1.id }
		return GeometryReader { geometry in
			if geometry.size.width > 1112 {
				ExploreDoubleTripleColumn(cocktails: cocktails)
			} else if geometry.size.width > 960 { // Needed to fix SplitView behavior on narrow screens which hide master.
				ExploreSingleColumn(cocktails: cocktails)
			} else if geometry.size.width > 512 {
				ExploreDoubleTripleColumn(cocktails: cocktails)
					.navigationViewStyle(StackNavigationViewStyle())
			} else {
				ExploreSingleColumn(cocktails: cocktails)
			}
		}
	}
}

private struct ExploreList: View {
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.favorite, ascending: false)], predicate: NSPredicate(format: "owned == TRUE")) private var ownedIngredientEntries: FetchedResults<IngredientEntry>

	let cocktails: [CocktailData]

	var body: some View {
		let allCocktails = CocktailData.keyValues.values
		let ownedIngredientIDs = ownedIngredientEntries.map { $0.id }
		let cocktailsAndMissingCounts = allCocktails
			.map { cocktail -> (cocktail: CocktailData, missingIngredientCount: Int) in
				let missingIngredientCount = cocktail.ingredients.reduce(0) { $1.ingredient.usableIn(available: ownedIngredientIDs) == nil ? $0 + 1 : $0 }
				return (cocktail, missingIngredientCount)
			}
			.filter { $0.missingIngredientCount > 0 }
		let mostMissingIngredients = Double(cocktailsAndMissingCounts.reduce(1) { min($0, $1.missingIngredientCount) })
		var missingIngredientScoresByID = [String: (count: Int, score: Double)]()
		for cocktailAndMissingCount in cocktailsAndMissingCounts {
			let missingIngredientCount = cocktailAndMissingCount.missingIngredientCount
			let cocktailScore = 1 / (Double(missingIngredientCount) / mostMissingIngredients)
			for ingredientQuantity in cocktailAndMissingCount.cocktail.ingredients {
				guard ingredientQuantity.ingredient.usableIn(available: ownedIngredientIDs) == nil else {
					continue
				}
				let ingredientID = ingredientQuantity.id
				if missingIngredientScoresByID[ingredientID] != nil {
					missingIngredientScoresByID[ingredientID]!.count += 1
					missingIngredientScoresByID[ingredientID]!.score += cocktailScore
				} else {
					missingIngredientScoresByID[ingredientID] = (1, cocktailScore)
				}
			}
		}
		let bestIngredientIDs = missingIngredientScoresByID.sorted(by: { $0.value.score > $1.value.score }).prefix(3)
		return List {
			if !bestIngredientIDs.isEmpty {
				Section(header: Text("Next ingredients")) {
					ForEach(bestIngredientIDs, id: \.key) { ingredientScore in
//						let ingredient = IngredientData.keyValues[ingredientScore.key]! //TODO
						NavigationLink(destination: IngredientEntryDetail(data: IngredientData.keyValues[ingredientScore.key]!)) {
							HStack {
								IngredientListItem(data: IngredientData.keyValues[ingredientScore.key]!, available: true, substitute: nil)
								Spacer()
								HStack {
									Text("used in ")
										+
										Text(ingredientScore.value.count.description)
											.bold()
										+
										Text(" cocktail".pluralize(ingredientScore.value.count, withNumber: false))
								}
									.font(.caption)
							}
						}
					}
				}
			}
			Section(header: Text("All cocktails")) {
				BuildCocktailsDetailListEntries(cocktails: cocktails)
			}
		}
			.navigationBarTitle("Explore")
	}
}

private struct ExploreDoubleTripleColumn: View {
	let cocktails: [CocktailData]

	var body: some View {
		NavigationView {
			ExploreList(cocktails: cocktails)
			BuildCocktailPlaceholder()
		}
	}
}

private struct ExploreSingleColumn: View {
	let cocktails: [CocktailData]

	var body: some View {
		NavigationView {
			ExploreList(cocktails: cocktails)
			BuildCocktailPlaceholder()
		}
	}
}

struct Explore_Previews: PreviewProvider {
	static var previews: some View {
		Explore()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
