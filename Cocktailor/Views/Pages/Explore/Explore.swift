import SwiftUI

struct Explore: View {
	var body: some View {
		let cocktails = CocktailData.keyValues.values.sorted(\.id, <)
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
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.favorite, ascending: false)], predicate: \IngredientEntry.owned == true) private var ownedIngredientEntries: FetchedResults<IngredientEntry>

	let cocktails: [CocktailData]

	var body: some View {
		let allCocktails = CocktailData.keyValues.values
		let ownedIngredientIDs = ownedIngredientEntries.map(\.id)
		let cocktailsAndMissingCounts: [(cocktail: CocktailData, missingIngredientCount: Int)] = allCocktails
			.map { cocktail in
				let missingIngredientCount = cocktail.ingredients.reduce(0) { $1.ingredient.usableIn(available: ownedIngredientIDs) == nil ? $0 + 1 : $0 }
				return (cocktail, missingIngredientCount)
			}
			.filter(\.missingIngredientCount, >, 0)
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
		let topIngredientIDs = missingIngredientScoresByID
			.filter(\.value.score, >, 1)
			.sorted(\.value.score, >)
			.prefix(5)
		return List {
			if !topIngredientIDs.isEmpty {
				SectionVibrant(label: "Next ingredients") {
					ForEach(topIngredientIDs, id: \.key) { ingredientScore in
						ExploreIngredientRow(ingredientID: ingredientScore.key, count: ingredientScore.value.count)
					}
				}
			}
			SectionVibrant(label: "\(cocktails.count) cocktails") {
				BuildCocktailsDetailListEntries(cocktails: self.cocktails, insertBlank: false)
			}
		}
			.navigationBarTitle("Explore")
	}
}

private struct ExploreIngredientRow: View {
	let data: IngredientData
	let count: Int

	init(ingredientID: String, count: Int) {
		self.data = IngredientData.keyValues[ingredientID]!
		self.count = count
	}

	var body: some View {
		HStack(spacing: 0) {
			IngredientButtonOwned(data: data, entry: nil, hasCocktail: true, withContent: false)
				.buttonStyle(BorderlessButtonStyle())
			NavigationLink(destination: IngredientEntryDetail(data: data)) {
				IngredientListItem(data: data, available: true, substitute: nil)
					.layoutPriority(2)
				Spacer()
					.frame(minWidth: 10)
				HStack {
					Text(count.description)
						.bold()
					+
					Text(" cocktail".pluralize(count, withNumber: false))
				}
					.font(.caption)
					.fixedSize()
			}
		}
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
